// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 1. 收款函数
// 2. 记录投资人并且查看
// 3. 锁定期内,达到指定资产 生产商可以提款
// 4. 锁定期内,没有达到制定资产,投资人可以退款

contract FounMe {
    AggregatorV3Interface internal dataFeed;
    address public owner;

    mapping(address => uint256) public fundersToAmount;

    // 筹款最小值 一个 ETH
    uint256 MIN_VALUE = 100 * 10 ** 18; // USD

    // 筹款总额
    uint256 constant TARGET = 200 * 10 ** 18; // USD;

    // 部署时间戳
    uint256 deploymentTimestamp;
    // 锁定时间
    uint256 lockTime;

    constructor(uint256 _lockTime) {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
    }

    // 筹款函数
    function fund() external payable {
        require(MIN_VALUE <= convertEthToUsd(msg.value), "Fund more ETH!");
        require(
            block.timestamp < deploymentTimestamp + lockTime,
            "window is closed"
        );
        fundersToAmount[msg.sender] = msg.value;
    }

    // 获取喂价
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

    // 计算ETH转美元金额
    function convertEthToUsd(
        uint256 ethAmount
    ) internal view returns (uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return (ethAmount * ethPrice) / (10 ** 8);
    }

    // 合约所有权转移
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    // 合约提款
    function getFound() external windowClose onlyOwner {
        require(
            convertEthToUsd(address(this).balance) >= TARGET,
            "Target not reached!"
        );

        // 转账 transfer/send/call
        // payable (msg.sender).transfer(address(this).balance);

        // bool success = payable (msg.sender).send(address(this).balance);
        // require(success,"send error!");

        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(success, "call error!");
    }

    // 合约退款
    function reFund() external windowClose {
        require(
            convertEthToUsd(address(this).balance) <= TARGET,
            "Target is reached!"
        );
        require(fundersToAmount[msg.sender] != 0, "You have not funded yet!");
        bool success;
        (success, ) = payable(msg.sender).call{
            value: fundersToAmount[msg.sender]
        }("");
        require(success, "refund error!");
        fundersToAmount[msg.sender] = 0;
    }

    // 窗口期已关闭
    modifier windowClose() {
        require(
            block.timestamp >= deploymentTimestamp + lockTime,
            "window is not closed"
        );
        _;
    }

    // 只有合同部署者可以操作
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can operate this!");
        _;
    }
}
