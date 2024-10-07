// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract SavingsAccount {
    mapping(address => uint256) public balances;
    mapping(address => bool) public hasWithdrawnBonus;

    uint256 public totalDeposits;
    uint256 public loyaltyBonusThreshold = 100 ether;
    uint256 public loyaltyBonusAmount = 1 ether;

    event Bonus(uint256, address);

    // Deposit funds into the savings account
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be positive");
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    // Withdraw funds from the savings account
    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        require(!hasWithdrawnBonus[msg.sender], "Already withdrawn");

        balances[msg.sender] -= _amount;
        _applyLoyaltyBonus(msg.sender);

        // External call to transfer funds
        _sendFunds(msg.sender, _amount);

        // Check if user is eligible for loyalty bonus
        if (balances[msg.sender] < loyaltyBonusThreshold) {
            if (!hasWithdrawnBonus[msg.sender]){
                hasWithdrawnBonus[msg.sender] = true;
                emit Bonus(_amount, msg.sender);
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
        balances[_user] += loyaltyBonusAmount;
        totalDeposits += loyaltyBonusAmount;
    }

    function resetHasWithdrawnBonus(address _user) external {
        hasWithdrawnBonus[_user] = false;
    }
}
