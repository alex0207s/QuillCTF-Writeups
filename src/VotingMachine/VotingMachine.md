# VotingMachine

## Objective of CTF

Accumulate at least 3000 votes in your hacker address. You don’t have any tokens in your wallet.

After trying all attempts and failing, you decided to perform a phishing attack and you successfully obtained the private keys from three users: Alice, Bob, and Carl.

Fortunately, Alice had 1000 vTokens, but Bob and Carl don’t have any tokens in their accounts. (**see foundry setUp**)

Now that you have access to the private keys of Alice, Bob, and Carl's accounts. So, try again.

## Analysis

The VoteToken contract uses the number of vote tokens to represent the number of votes. However, the vote tokens can be transferred by the token owner, and the votes still be attributed to the previous delegatee. For example, Alice has 100 vTokens and she delegates her votes to Bob, if she transfers the vTokens to someone else, the votes will still count towards Bob's account. This does not make sense.

The inconsistent updates allow malicious users to create additional votes. But how?

In the following section, we will demonstrate how to create 1000 additional votes with the vulnerability.

### Steps

1. The hacker first pretends to be Alice and calls the `delegate` function to delegate the vote to hacker himself.
2. The hacker transfers Alice's token to Bob
3. Repeat step 1, but now the hacker pretends to be Bob and calls the `delegate` function to delegate the vote to hacker himself.

Now, the hacker's account has 2000 votes (1000 from Alice's delegation and an additional 1000 votes from Bob's delegation), even though there were only 1000 vote tokens created. Essentially, the hacker has created an additional 1000 votes with only 1000 vote tokens.

You can follow these steps to create additional 2000 votes to the hacker(**see foundry test**)

### Mitigation

The mitigation solution should overwrite the implementation of the `transfer` and the `transferFrom` function of the ERC20. Not only update the balance of `from` and `to` address, but also update the vote of delegatee. If the vote token is transferred to someone else, the vote right should be removed from the delegatee's account at the same time.
