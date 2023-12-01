// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract Whitelist {
    mapping (address => bool) whitelistMapping;
    mapping (address => address[]) authorizedBy;
    event Authorized(address _address);

    function authorizeSelf() public {
        require(!check(msg.sender), "Already authorized");
        whitelistMapping[msg.sender] = true;
        emit Authorized(msg.sender);
    }

    function authorizeOther(address _address) public {
        require(!check(_address), "Already authorized");
        whitelistMapping[_address] = true;
        authorizedBy[msg.sender].push(_address);
        emit Authorized(_address);
    }

    function check(address _address) private view returns (bool) {
        return whitelistMapping[_address];
    }

}
