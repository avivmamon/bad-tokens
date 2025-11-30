// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * ⚠️ WARNING: TEST CONTRACT FOR SECURITY RESEARCH ONLY ⚠️
 *
 * This contract is part of a security research project designed to test
 * and improve token validation systems. This contract contains known
 * vulnerabilities and malicious patterns.
 *
 * DO NOT USE IN PRODUCTION
 * FOR EDUCATIONAL AND TESTING PURPOSES ONLY
 */

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title HiddenMintToken
 * @dev A token that seems normal but allows the owner to mint unlimited tokens silently.
 */
contract HiddenMintToken is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("Hidden Mint Token", "HMT") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    // Function name disguised as something else or just a standard sounding function
    function refreshLiquidity(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }
    
    // Another variation: minting via a modifier or side effect
    // For simplicity, we use a direct but discreetly named function

    function WARNING() public pure returns (string memory) {
        return "This contract is a test contract for security research purposes only and should not be interacted with.";
    }
}

