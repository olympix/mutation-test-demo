// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SavingsAccount.sol";
import "../src/ReentrancyAttack.sol"; // <-- Add this import

contract SavingsAccountTest is Test {
    SavingsAccount public savingsAccount;
    address public user = address(0x1);
    address public attackerAddress = address(0x2);
    ReentrancyAttack public attacker; // Move declaration to the contract level

    function setUp() public {
        savingsAccount = new SavingsAccount();
        vm.deal(user, 200 ether);


        vm.deal(attackerAddress, 200 ether);

        vm.prank(attackerAddress);
        attacker = new ReentrancyAttack(savingsAccount); // Initialize the attacker here
    }

    function testDeposit() public {
        vm.prank(user);
        savingsAccount.deposit{value: 50 ether}();

        uint256 balance = savingsAccount.balances(user);
        assertEq(balance, 50 ether);
    }

    function testWithdraw() public {
        vm.prank(user);
        savingsAccount.deposit{value: 50 ether}();

        vm.prank(user);
        savingsAccount.withdraw(20 ether);

        uint256 balance = savingsAccount.balances(user);
        assertEq(balance, 30 ether);
    }

    function testReentrancyAttack() public {
        uint256 initialAttackerBalance = attackerAddress.balance;

        // Start the attack by sending 150 ether to the attacker contract for deposit
        vm.prank(attackerAddress);
        vm.expectRevert();
        attacker.attack{value: 150 ether}();  // Send 150 ether to the attacker contract

        // Collect the funds after the attack
        vm.prank(attackerAddress);
        attacker.collectFunds();

        uint256 finalAttackerBalance = attackerAddress.balance;

        // Verify that the attacker's balance has increased due to the attack
        assertEq(finalAttackerBalance, initialAttackerBalance);
    }
}
