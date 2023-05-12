# InvestPool

## Objective of CTF

Your objective is to have a greater token balance than your initial balance.

You are a hacker, not the user.

## Analysis

We divide the solution into following two parts:

1. find the password string
2. hack it

### I. Find the password string

In order to able to call `deposit()` and `withdrawAll()` function, we need to find the password to initialize the variable `initialized` first.

According the hint, we first try everything in the contract itself, like load storage of this contract. But nothing to work to get the password.

Here, we got an extra hint from Sm4rty in QuillCTF discord channel.

![](https://hackmd.io/_uploads/H1VR-WrN2.jpg)

With this hint, we use [this](https://playground.sourcify.dev/) to decode the contract bytecode and get the metadata hash. The metadata hash value is ipfs url.

![](https://hackmd.io/_uploads/HJf4YA4Nn.png)

Navigate it with http url
https://ipfs.io/ipfs/QmU3YCRfRZ1bxDNnxB4LVNCUWLs26wVaqPoQSQ6RH2u86V or directly clike the "view on IPFS" button, then you will get the password string.

### II. Hack it

#### Vulnerability

The InvestPool contract uses the current token balance of the Invest pool (i.e. `token.balanceOf(address(this))`) in the formulas for `tokenToShares()` and `sharesToToken()` to calculate the amount of shares or tokens to give to the user. However, the current token value of the Invest pool could be changed by the token owner outside the Invest pool itself which could result in the incorrect amount of shares or tokens calculated in the Invest pool.

How could a malicious user (hacker) utilize this vulnerability to get back the more tokens than he/she deposited?

In the following section, we will describe a attack scenario.

#### Attack Steps

1. Hacker calls the `deposit ()` function of InvestPool with 1 wei and becomes the first depositor of the InvestPool.
   - hacker gains 1 wei share
   - the `totalShares` now is 1 wei share
   - the token balance of the InvestPool now is 1 wei
2. User deposits 100 ether tokens to the InvestPool.
   - user gains 0 share (**because the hacker performs a front-running attack to manipulate the amount of shares that the subsequent user obtains**, as shown in the next step)
   - the `totalShares` now is still 1 wei share
   - the token balance of the InvestPool now is 200 ether and 1wei
3. Hacker front-runs the user's deposit transaction and transfers the same or greater amount of tokens to the InvestPool through the `transfer` function of ERC20.
   - **the token balance of InvestPool is manipulated by the hacker here** which result in the next user get 0 share when he/she calls the`deposit()` function of the InvestPool
   - the token balance of the InvestPool now is 100 ether and 1 wei
4. Hacker calls the `withdrawAll()` function of the InvestPool to withdraw all tokens.
   - by the formulas of `sharesToToken()` function, the hacker withdraw total 200 ether and 1 wei token which is more than the amount of tokens he had deposited previously

So far, we have demonstrated the entire attack process. In addition, we would like to mention another vulnerability, although it does not relate to our solution.

If the hacker is able to transfer the tokens to the InvestPool through the `transfer()` function of ERC20 right after the InvestPool is deployed, then the subsequent user who deposit the tokens to the InvestPool through `deposit()` function would receive only 0 share which makes the InvestPool unusable. This type of attack is commonly known as a **DoS** attack.
