Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PeaceEnergyHubToken (PEHT)
 * @dev Token pentru finanțarea și guvernanța hub-urilor energetice de pace, 
 *      inclusiv mecanism de urgență (Kill-Switch) pentru situații de război/conflict.
 */
contract PeaceEnergyHubToken is ERC20, Ownable {

    // Starea hub-ului: true = Pace (flux normal), false = Război/Conflict (blocaj de siguranță)
    bool public isPeaceActive;
    
    // Adresa oracolului sau a comitetului de securitate internațională care controlează starea
    address public securityOracle;

    event PeaceStatusChanged(bool indexed newStatus);
    event DividendsDistributed(uint256 amount);

    modifier onlyOracleOrOwner() {
        require(msg.sender == securityOracle || msg.sender == owner(), "PEHT: Not authorized");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address _securityOracle,
        address initialOwner
    ) ERC20(name, symbol) Ownable(initialOwner) {
        _mint(initialOwner, initialSupply * 10 ** decimals());
        securityOracle = _securityOracle;
        isPeaceActive = true; // Implicit pornește pe timp de pace
    }

    /**
     * @dev Schimbă starea de securitate (ex: declanșat în caz de conflict militar).
     */
    function setPeaceStatus(bool _status) external onlyOracleOrOwner {
        isPeaceActive = _status;
        emit PeaceStatusChanged(_status);
    }

    function setSecurityOracle(address _newOracle) external onlyOwner {
        securityOracle = _newOracle;
    }

    /**
     * @dev Suprascrie funcția de transfer: dacă izbucnește războiul (isPeaceActive = false), 
     *      transferurile de tokeni și dividendele sunt blocate automat pentru protecția investitorilor.
     */
    function _update(address from, address to, uint256 value) internal virtual override {
        require(isPeaceActive, "PEHT: EMERGENCY LOCK - Transfers blocked due to active conflict or war.");
        super._update(from, to, value);
    }

    /**
     * @dev Funcție pentru distribuirea profiturilor din taxele de tranzit către deținătorii de tokeni.
     */
    function distributeTransitProfits() external payable onlyOwner {
        require(isPeaceActive, "PEHT: Cannot distribute funds during active conflict.");
        require(msg.value > 0, "PEHT: No profits to distribute");
        
        emit DividendsDistributed(msg.value);
        // Logica de distribuție proporțională poate fi extinsă aici
