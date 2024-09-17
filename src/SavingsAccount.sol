// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SavingsAccount is ReentrancyGuard {
    mapping(address => uint256) public balances;
    mapping(address => bool) public hasWithdrawnBonus;

    uint256 public totalDeposits;
    uint256 public loyaltyBonusThreshold = 100 ether;
    uint256 public loyaltyBonusAmount = 1 ether;

    // Deposit funds into the savings account
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be positive");
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    // Withdraw funds from the savings account
    function withdraw(uint256 _amount) external nonReentrant {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;

        // External call to transfer funds
        _sendFunds(msg.sender, _amount);

        // Check if user is eligible for loyalty bonus
        if (balances[msg.sender] >= loyaltyBonusThreshold) {
            if (!hasWithdrawnBonus[msg.sender]){
                _applyLoyaltyBonus(msg.sender);
            }
        }
    }

    // Internal function to send funds
    function _sendFunds(address _recipient, uint256 _amount) internal {
        (bool success, ) = payable(_recipient).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    // Internal function to apply loyalty bonus
    function _applyLoyaltyBonus(address _user) internal {
        hasWithdrawnBonus[_user] = true;
        balances[_user] += loyaltyBonusAmount;
        totalDeposits += loyaltyBonusAmount;
    }
}
