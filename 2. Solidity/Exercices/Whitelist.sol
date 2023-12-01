// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract Whitelist {
    mapping (address => bool) whitelistMapping;
    event Authorized(address _address);

    constructor() {
        whitelistMapping[msg.sender] = true;
    }

    modifier check(){
	    require(whitelistMapping[msg.sender], "Not authorized to add address to whitelist");
	    _;
    }

    function authorize(address _address) public check() {
        whitelistMapping[_address] = true;
        emit Authorized(_address);
    }

}
