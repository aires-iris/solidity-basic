// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 1. 收款函数
// 2. 记录投资人并且查看
// 3. 锁定期内,达到指定资产 生产商可以提款
// 4. 锁定期内,没有达到制定资产,投资人可以退款

contract FounMe {
    AggregatorV3Interface internal dataFeed;
    address public  owner;

    mapping(address => uint256) public fundersToAmount;

    // 筹款最小值 一个 ETH
    uint256 MIN_VALUE = 100 * 10 ** 18; // USD

    // 筹款总额
    uint256 constant TARGET = 200 * 10 ** 18; // USD;

    constructor() {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        owner = msg.sender;
    }

    function fund() external payable  {
        require(MIN_VALUE <= convertEthToUsd(msg.value), "Fund more ETH!");
        fundersToAmount[msg.sender] = msg.value;

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

    function convertEthToUsd(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return (ethAmount * ethPrice) / (10 ** 8);
    }

    function transferOwnership(address newOwner) public  {
        require(msg.sender == owner,"Only owner can transfer ownership!");
        owner = newOwner;
    }


    function getFound() external  {
        require(convertEthToUsd(address(this).balance) >= TARGET,"Target not reached!");
        require(msg.sender == owner,"Only Owner can fund!");
        // 转账 transfer/send/call
        // payable (msg.sender).transfer(address(this).balance);

        // bool success = payable (msg.sender).send(address(this).balance);
        // require(success,"send error!");

        bool success;
        (success,) = payable(msg.sender).call{value:address(this).balance}("");
        require(success,"call error!");
 
    }

    function reFund() external {
        require(convertEthToUsd(address(this).balance) <= TARGET,"Target is reached!");
        require(fundersToAmount[msg.sender] != 0,"You have not funded yet!");
        bool success;
        (success,) = payable(msg.sender).call{value:fundersToAmount[msg.sender]}("");
        require(success,"refund error!");
        fundersToAmount[msg.sender] = 0;
    }
}
