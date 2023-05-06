# QuillCTF

This repo contains my solutions that I have submitted to QuillCTF. All solutions will be updated after the challenge has been retired.

# What is QuillCTF

Quill CTF is a game in which you hack Ethereum smart contracts to learn about security. It's meant to be both fun and educational. The game is designed to educate players on how to identify and fix security issues in Ethereum smart contracts.

The challenges contain several of the most common vulnerabilities found in Ethereum smart contracts today, including reentrancy, integer overflows/underflows, predictable randomness, and more!

### QuillCTF Website link: https://academy.quillaudits.com/challenges

### How to submit the solution:

Fill out the below submission form with Vulnerability details and a solution to CTF:  
[QuillCTF-Submit](https://quillaudits.typeform.com/QuillCTF#task=submit-solution)

After your submission has been reviewed by the Quill team, you will receive points based on the difficulty level. Check out the point distribution table below:"

| Difficulty | Points Awarded |
| ---------- | -------------- |
| Easy       | 100            |
| Medium     | 200            |
| Hard       | 300            |

#### Players who submit their solutions within “24 hours” of the CTF's launch will receive 2X points.

## Challenges:

| Challenge                                                                                            | Type              | Difficulty | Points | Solutions     |
| ---------------------------------------------------------------------------------------------------- | ----------------- | ---------- | ------ | ------------- |
| [🎲 PseudoRandom](https://academy.quillaudits.com/challenges/quillctf-challenges/pseudorandom)       | Solidity Security | Easy       | 100    | _Coming Soon_ |
| [📈 Invest Pool](https://academy.quillaudits.com/challenges/quillctf-challenges/invest-pool)         | DeFi Security     | Medium     | 200    | _Coming Soon_ |
| [🙈 Predictable NFT](https://academy.quillaudits.com/challenges/quillctf-challenges/predictable-nft) | Solidity Security | Easy       | 100    | _Coming Soon_ |
| [📇 Voting Machine](https://academy.quillaudits.com/challenges/quillctf-challenges/voting-machine)   | DeFi Security     | Medium     | 200    | _Coming Soon_ |
| [🕺 Private Club](https://academy.quillaudits.com/challenges/quillctf-challenges/private-club)       | DeFi Security     | Easy       | 100    | _Coming Soon_ |

# Getting Started

## Install & Update Foundry

```sh
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## Clone repo

```sh
git clone git@github.com:alex0207s/QuillCTF.git
forge install
cd QuillCTF
```

## Run Test

```sh
forge test --match-contract {contract} -vvvv
```

# Disclaimer

This repo is for educational purposes only. Please do not use these smart contracts in production.
