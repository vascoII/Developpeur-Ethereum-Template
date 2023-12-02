// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract Random {

    uint private nonce = 0;

    function random() public returns (uint256) {
        // Important: Cela n'est pas sécurisé pour la génération de nombres aléatoires dans un contexte de production!
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100;
        nonce++;
        return randomNumber;
    }

}
