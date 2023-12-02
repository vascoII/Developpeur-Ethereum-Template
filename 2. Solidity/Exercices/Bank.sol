// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract Bank {
    event Deposit(address from, uint amount);
    event Transfer(address from, address to, uint amount);
    // Mapping pour stocker les transactions des clients par date
    mapping(address => mapping(uint256 => int256[])) public customerTransactions;
    //Mapping pour stocker les balances des clients
    mapping(address => uint256) public customerBalances;

    modifier checkBalance(address from, uint256 amount) {
	    require(customerBalances[from] >= amount, "Insufficient balance for transaction");
	    _;
    }

    modifier checkValue(uint256 amount) {
	    require(amount != 0, "Deposit amount must be greater than zero");
	    _;
    }

    modifier checkAddress(address _address) {
    require(_address != address(0), "Address is not correct");
    _;
}

    // Fonction pour mettre à jour le solde d'un client à une date donnée
    function deposit() public checkValue(msg.value) payable {
        uint256 currentTimestamp = block.timestamp;
        customerTransactions[msg.sender][currentTimestamp].push(int256(msg.value));
        customerBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Fonction pour transfer d un customer à un autre à une date donnée
    function transfer(address to, uint256 amount) public checkBalance(msg.sender, amount) checkValue(amount) checkAddress(to) {
        uint256 currentTimestamp = block.timestamp;
        customerTransactions[msg.sender][currentTimestamp].push(-int256(amount));
        customerBalances[msg.sender] -= amount;
        customerBalances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    // Fonction pour obtenir le solde d'un customer
    function getCustomerBalance() public view returns (uint256) {
        return customerBalances[msg.sender];
    }

}
