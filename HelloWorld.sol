// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloWorld {
    // 动态分配的bytes
    string _str_var = "Hello World";
    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }
    Info[] infos;

    mapping(uint256 => Info) infoMapping;

    function sayHello(uint _id) public view returns (string memory) {

        if (infoMapping[_id].addr == address(0x0)) {
            return addInfo(_str_var);
        } else {
            return addInfo(infoMapping[_id].phrase);
        }

    }

    function setHelloWorld(string memory newString, uint256 _id) public {
        Info memory info = Info(newString, _id, msg.sender);
        infoMapping[_id] = info;
        infos.push(info);
    }

    function addInfo(
        string memory sourceMsg
    ) private pure returns (string memory) {
        return string.concat(sourceMsg, " from kiki!");
    }
}
