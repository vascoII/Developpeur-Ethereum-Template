// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract EthManager {
    event EthReceived(address sender, uint amount);
    address payable public owner;

    constructor() {
        owner = payable(msg.sender); 
    }

    // Appelée pour une transaction simple d'Ether (sans données)
    receive() external payable {
        sendEthToOwner();
    }

    // Appelée lorsqu'aucune fonction correspondante n'est trouvée, ou si des données sont envoyées mais ne correspondent à aucune fonction
    fallback() external payable {
        sendEthToOwner();
    }

    function sendEthToOwner() private {
        (bool sent, ) = owner.call{value: msg.value}("");
        require(sent, "Failed to send Ether to owner");
    }

    function addEthToContract() public payable {
        emit EthReceived(msg.sender, msg.value); // Enregistrez qui a envoyé combien d'Ether
    }

}
