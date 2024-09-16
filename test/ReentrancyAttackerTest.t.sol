// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SavingsAccount.sol";
import "../src/ReentrancyAttack.sol";

contract ReentrancyAttackTest is Test {
    SavingsAccount public savingsAccount;
    ReentrancyAttack public attacker;
    address public attackerAddress = address(0x2);

    function setUp() public {
        // Ensure the attacker has sufficient funds
        vm.deal(attackerAddress, 200 ether);  // Fund attackerAddress with 200 ether

        // Deploy the SavingsAccount contract
        savingsAccount = new SavingsAccount();

        // Deploy the attacker contract from the attacker address
        vm.prank(attackerAddress);
        attacker = new ReentrancyAttack(savingsAccount);
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
