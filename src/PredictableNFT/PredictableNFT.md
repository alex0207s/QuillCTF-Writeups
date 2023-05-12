# PredictableNFT

## Objective of CTF

In this game, you can spend 1 ether to "mint" an NFT token with 3 possible ranks: **Common(1)**, **Rare(2)**, and **Superior(3)**. As a hacker, your goal is to always mint the Superior ones.

## Analysis

The contract is not open source in this challenge, but we can find its bytecode [here](https://goerli.etherscan.io/address/0xfd3cbdbd9d1bbe0452efb1d1bffa94c8468a66fc#code).

We decompile the bytecode and obtain the following code:

```
# Palkeoramix decompiler.

def storage:
  id is uint256 at storage 0
  tokens is mapping of uint256 at storage 1

def tokens(uint256 _param1): # not payable
  require calldata.size - 4 >=ΓÇ▓ 32
  return tokens[_param1]

def id(): # not payable
  return id

#
#  Regular functions
#

def _fallback() payable: # default function
  revert

def mint() payable:
  if call.value != 10^18:
      revert with 0, 'show me the money'
  if id > id + 1:
      revert with 0, 17
  id++
  if sha3(id, caller, block.number) % 100 > 90:
      tokens[stor0] = 3
  else:
      if sha3(id, caller, block.number) % 100 <= 80:
          tokens[stor0] = 1
      else:
          tokens[stor0] = 2
  return id
```

According to the decompile result, we know the rank of the token is determined by the sha3 hash value of the following three parameters:

- **id**
- **caller** which is **msg.sender** in solidity syntax
- **block.number**

The vulnerability of this contract lies in the predictability of these parameters. Since these variable are deterministic, we can pre-calculate the sha3 hash value of these variable and determine the modulo of the result when divided by 100. We call the **mint** function when the calculated modulo is greater than 90. This ensures that the minted token will always be a Superior (rank 3) one.

### :eyes: Here's a small detail to note: we need to convert the caller address variable into a uint type.
