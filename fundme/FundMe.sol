// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract FundMe {

    // 记录投资人的地址和金额
    // 查看投资人的金额
    // 锁定期内,没有达到预期金额,投资人可以退款
    // 锁定期内,达到预期金额,负责人可以提款

    mapping(address => uint256) public  fundersToAmount;

    uint256 MIN_VAL = 100 * 10 ** 18;

    // 目标金额
    uint256 constant TARGET = 300 * 10 ** 18;

    AggregatorV3Interface internal dataFeed;

    address public  owner;

    uint256 deploymentTimestamp;

    uint256 lockTime;


    constructor(uint256 _lockTime){
         dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
         owner = msg.sender;
         deploymentTimestamp = block.timestamp;
         lockTime = _lockTime;
    }

    // 参与者发起筹款
    function fund() external payable {
        require(block.timestamp < deploymentTimestamp + lockTime, "window is closed");
        require(MIN_VAL <= convertEthToUsd(msg.value), "Send more ETH!");
        uint256 currentAmount = fundersToAmount[msg.sender];
        if (currentAmount == 0) {
            fundersToAmount[msg.sender] = msg.value;
        } else {
            fundersToAmount[msg.sender] = fundersToAmount[msg.sender] + msg.value;
        }
    }

    // 合约负责人提款
    function getFund() external  windowClosed onlyOner{
        require(convertEthToUsd(address(this).balance) >= TARGET, "Target is not reached!");
        // 提款 transfer/send/call
        // payable(msg.sender).transfer(address(this).balance);

        // bool success = payable(msg.sender).send(address(this).balance)
        // require(success, "tx failed!");

        (bool success, ) = payable(msg.sender).call{value: address(this).balance}(""); 
        require(success,"tx fialed!");



    }

    // 参与者发起退款
    function reFund() external windowClosed{
        require(convertEthToUsd(address(this).balance) < TARGET, "Target has reached!");
        require(fundersToAmount[msg.sender] > 0, "there is no fund for you ");
        (bool success,) = payable(msg.sender).call{value:fundersToAmount[msg.sender]}("");
        require(success,"refund failed!");
        // 清空记录
        fundersToAmount[msg.sender] = 0;
    }



    // 修改合约负责人
    function transferOwnership(address newOwner) public onlyOner{
        owner = newOwner;
    }  


    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }
    
    function convertEthToUsd(uint256 ethAmount) internal view  returns (uint256){
            uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
            return  ethAmount * ethPrice / (10 ** 8);
    }
    modifier windowClosed(){
        require(block.timestamp >= deploymentTimestamp + lockTime, "window is not closed");
        _;
    }

    modifier onlyOner(){
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}
