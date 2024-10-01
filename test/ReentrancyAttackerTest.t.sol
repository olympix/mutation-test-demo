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
        vm.deal(attackerAddress, 100 ether);  // Fund attackerAddress with 200 ether

        // Deploy the SavingsAccount contract
        savingsAccount = new SavingsAccount();
        vm.deal(address(savingsAccount), 200 ether);  // Fund attackerAddress with 200 ether

        // Deploy the attacker contract from the attacker address
        vm.prank(attackerAddress);
        attacker = new ReentrancyAttack(savingsAccount);
    }

    function testReentrancyAttack() public {
        uint256 initialAttackerBalance = attackerAddress.balance;

        // Start the attack
        vm.prank(attackerAddress);
        attacker.attack{value: 100 ether}();

        // Collect the funds after the attack
        vm.prank(attackerAddress);
        attacker.collectFunds();

        uint256 finalContractBalance = address(savingsAccount).balance;
        uint256 finalAttackerBalance = attackerAddress.balance;

        // Verify that the attacker's balance has increased
        assertGt(finalAttackerBalance, initialAttackerBalance, "Attacker balance should increase");

        // Verify that the contract's balance has been drained or is very close to 0
        assertLe(finalContractBalance, 1 ether, "Contract should be drained or nearly drained");
    }
}
