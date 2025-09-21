// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import { HelloWorld } from "./test.sol";

contract Factory {

    HelloWorld hw;
    HelloWorld[] hws;
    // 创建并存储一个合约
    function createHelloWorl() public {
        hws.push(new HelloWorld());
    }

    // 根据索引获取已经存储的合约
    function getHelloWorldByIndex(uint index) public view returns (HelloWorld){
        return hws[index];
    }
    
    // 调用指定索引的合约中的函数
    function callSetHelloWorldFromFactory(uint256 index,string memory str,uint32 id) public {
        hws[index].setHelloWorld(str,id);
    } 

    // 调用指定索引的合约中的函数
    function callSayHelloFromFactory(uint256 index,uint256 id) public view returns (string memory){
       return  hws[index].sayHello(id);
    }



}
