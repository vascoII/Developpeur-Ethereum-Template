// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract CancunToken is ERC20, Ownable, Pausable {
    // Constante pour le plafond maximal de tokens
    uint256 public constant MAX_SUPPLY = 210000000;
    // Constante pour le plafond de tokens a mint
    uint256 public constant MINT_AMOUNT = 1000000;
    // Constante pour le temps entre deux mint
    uint256 public constant MINT_INTERVAL = 30 days;
    // Constante pour l'offre initiale de tokens
    uint256 public constant INITIAL_SUPPLY = 10000000;

    uint256 public lastMintTimestamp;

    constructor(address _address) ERC20("Cancun", "CAN") Ownable(_address) {
        _mint(msg.sender, INITIAL_SUPPLY / 2);
         _mint(_address, INITIAL_SUPPLY / 2);
    }

    // Fonction pour créer (mint) de nouveaux tokens
    function mintMonthly() public onlyOwner {
        require(block.timestamp >= lastMintTimestamp + MINT_INTERVAL, "CancunToken: minting not yet allowed");
        require(totalSupply() + MINT_AMOUNT <= MAX_SUPPLY, "CancunToken: cap exceeded");

        lastMintTimestamp = block.timestamp;
        _mint(msg.sender, MINT_AMOUNT);
    }
    
    // Fonction pour détruire (burn) des tokens
    function burn(uint256 amount) public {
        // Implémenter la logique de burning ici
    }

    // Fonction pour mettre en pause les transferts de tokens
    function pause() public onlyOwner {
        // Implémenter la logique de pause ici
    }

    // Fonction pour reprendre les transferts de tokens
    function unpause() public onlyOwner {
        // Implémenter la logique de unpause ici
    }

    // Override de la fonction transfer pour intégrer la pause
    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }

    // Override de la fonction transferFrom pour intégrer la pause
    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    // Optionnel : Fonction pour récupérer des tokens envoyés par erreur
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        // Implémenter la logique de récupération ici
    }

    // Optionnel : Ajouter d'autres fonctions et logiques selon les besoins
}


