// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken{
    string public tokenName;
    string public tokenSymbol;
    uint256 public totalSupply;
    address public owner;
    mapping(address=>uint256) public balances;

    constructor(string memory _tokenName,string memory _tokenSymble){
        tokenName = _tokenName;
        tokenSymbol = _tokenSymble;
        owner = msg.sender;
    }

    function mint(uint256 amountToMint) public {
        balances[msg.sender] += amountToMint;
        totalSupply +=amountToMint;
    }

    function transfer(address payee,uint256 amount) public {
        require(balances[msg.sender] >= amount,"you dont have enough balance to transfer!");
        balances[msg.sender] -= amount;
        balances[payee] +=amount;
    }

    function balanceOf(address addr) public view returns(uint256){
        return balances[addr];
    }
}