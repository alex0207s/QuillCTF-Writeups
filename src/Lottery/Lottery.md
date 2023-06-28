# Lottery

## Objective of CTF

There are 200 ethers lying on an unclaimed address waiting to be retrieved using the Factory contract.

You are given 11 ether use them to retrieve it

## Analysis

In the `dep()` function, a contract is created using the `create` opcode. The `create` opcode calculates the address using the following formula:

$new \ address = hash(sender, nonce)$

Every contract address has an associated nonce. Therefore, we try to call `dep()` until match the specific address (e.g. `0x0A1EB...`).

We will revert the contract creation if the contract address does not match the specific one, and transfer the entire balance of the contract when the contract matches the specified address.
