// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Admin is Ownable {
    mapping (address => bool) whitelistMapping;
    mapping (address => bool) blacklistMapping;
    event Whitelisted(address _address);
    event Blacklisted(address _address);

    modifier checkAddress(address _address) {
        require(_address != address(0), "Address is not correct");
        _;
    }

    modifier alreadyWhiteListed(address _address) {
        require(!whitelistMapping[_address], "Address already in whitelist");
        _;
    }

    modifier alreadyBlackListed(address _address) {
        require(!blacklistMapping[_address], "Address already in blacklist");
        _;
    }

    constructor() Ownable(msg.sender) {}

    function whitelist(address _address) public onlyOwner checkAddress(_address) alreadyWhiteListed(_address) alreadyBlackListed(_address) {
        whitelistMapping[_address] = true;
        emit Whitelisted(_address);
    }

    function blacklist(address _address) public onlyOwner checkAddress(_address) alreadyWhiteListed(_address) alreadyBlackListed(_address) {
        blacklistMapping[_address] = true;
        emit Blacklisted(_address);
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return whitelistMapping[_address];
    }

    function isBlacklisted(address _address) public view returns (bool) {
        return blacklistMapping[_address];
    }


}
