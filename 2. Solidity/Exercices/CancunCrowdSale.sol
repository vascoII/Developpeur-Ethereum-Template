// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./CancunToken.sol";

contract CancunCrowdSale {
    uint256 public rate = 2000; 
    CancunToken public cancunToken;

    constructor() {
        cancunToken = new CancunToken(msg.sender);
    }

    receive() external payable {
        require(msg.value >= 0.05 ether, "Can not send less than 0.05 Eth");
        distributeToken(msg.value);
    }

    function distributeToken(uint256 _value) internal {
        uint256 amount = _value * rate;
        cancunToken.transfer(msg.sender, amount);
    }

}
