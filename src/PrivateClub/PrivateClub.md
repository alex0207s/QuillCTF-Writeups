# PrivateClub

## Objective of CTF

1. Become a member of a private club.
2. Block future registrations.
3. Withdraw all Ether from the privateClub contract.

## Analysis

To become a member of the private club, we need to invoke the `becomeMember()` function. This function requires the caller to send a number of ethers equivalent to the length of `_members` to it and send 1 ether back to each element of `_members`. However, since the function does not impose any constraints on the element of `_members`, it is possible for caller to call the `becomeMember()` function with a customized `_members` array that satisfies the length requirement and includes only the caller's address. By doing so, we can become a member of private club without incurring any ether cost. This is because the ethers we paid to the `becomeMember()` function will be sent back to the caller.

To block the future registrations, we only need to continuously increase the length of `_member` array until the gas cost becomes unaffordable to execute the `becomeMember()` function. This is because as more elements are added to the `_member` array, more opcodes are required to execute the function.

To withdraw all ethers from the privateClub contract, we first need to call the `buyAdminRole()` function to become the contract's admin. Once we become the admin role, we can then call the `adminWithdraw()` function to withdraw all ethers in the privateClub contract.
