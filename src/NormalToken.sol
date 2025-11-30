// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * ⚠️ WARNING: TEST CONTRACT FOR SECURITY RESEARCH ONLY ⚠️
 *
 * This contract is part of a security research project designed to test
 * and improve token validation systems. This is a control token with
 * no malicious behavior.
 *
 * DO NOT USE IN PRODUCTION
 * FOR EDUCATIONAL AND TESTING PURPOSES ONLY
 */

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title NormalToken
 * @dev A standard, legitimate ERC20 token with no restrictions, taxes, or malicious behavior.
 * This token allows normal transfers for all users without any limitations.
 */
contract NormalToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Normal Token", "NORM") {
        _mint(msg.sender, initialSupply);
    }

    function WARNING() public pure returns (string memory) {
        return "This contract is a test contract for security research purposes only and should not be interacted with.";
    }
}

