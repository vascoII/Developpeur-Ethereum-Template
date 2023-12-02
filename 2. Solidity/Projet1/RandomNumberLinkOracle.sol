// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomNumberLinkOracle is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    bytes32 internal constant KEY_HASH = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c; // (Sepolia testnet)
    uint256 internal constant FEE = 0.1 * 10 ** 18; // 0.1 LINK (ou le coût approprié pour votre réseau)
    address internal constant VRFCOORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625; // (Sepolia testnet)
    address internal constant LINKTOKEN = 0x779877A7B0D9E8603169DdbD7836e478b4624789; // (Sepolia testnet)
    
    constructor() VRFConsumerBase(VRFCOORDINATOR, LINKTOKEN) {
        keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c; // Key Hash
        fee = 0.1 * 10 ** 18; // 0.1 LINK (varie selon le réseau)
    }
    
    /** 
     * Demande aléatoire
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function utilisée par VRF Coordinator
     */
    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        randomResult = randomness;
    }
}
