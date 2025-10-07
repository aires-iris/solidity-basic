// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from './FundMe.sol';

// 1.让FundMe的参与者,基于筹款数量领取相应的通证
// 2.参与者之间交换通证
// 3.使用完成之后需要烧掉通证


contract FundTokenERC20 is ERC20{

    FundMe fundMe;

    constructor(address fundMeAddress) ERC20("FundTokenERC20","FT"){
        // 初始化fundMe合约
        fundMe = FundMe(fundMeAddress);
    }

    function mint(uint256 amountToMint) public fundMeCompleted{
        require(fundMe.fundersToAmount(msg.sender) >= amountToMint,"you cant mint this many tokens!");
        _mint(msg.sender,amountToMint);
        fundMe.setFundersAmount(msg.sender, fundMe.fundersToAmount(msg.sender) - amountToMint);
    }

    function claim(uint256 amountToClaim) public fundMeCompleted{
        require(balanceOf(msg.sender) >= amountToClaim,"you dont have enough erc20 tokens!");
        // TODO
        _burn(msg.sender, amountToClaim);
    }

    modifier fundMeCompleted{
        require(fundMe.getFundSuccess(),"The FundMe is not completed yet");
        _;
    }

}
