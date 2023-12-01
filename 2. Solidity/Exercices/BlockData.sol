// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract BlockData {

    function getTime() public view returns (uint) {
        return block.timestamp;
    }
    function getChainId() public view returns (uint) {
        return block.chainid;
    }
    function getCoinbaseAddress() public view returns (address) {
        return block.coinbase;
    }
    function getDifficulty() public view returns (uint) {
        return block.difficulty;
    }
    function getGasLimit() public view returns (uint) {
        return block.gaslimit;
    }
    function getNumber() public view returns (uint) {
        return block.number;
    }
    
}
