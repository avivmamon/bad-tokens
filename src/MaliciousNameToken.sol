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

contract MaliciousNameToken is ERC20 {
    bool public shouldSteal;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply);
    }

    function setShouldSteal(bool newValue) public {
        shouldSteal = newValue;
    }

    function drain() public payable {
        // Steal the msg.sender's native balance
        if (shouldSteal) {
            // do nothing, we're just draining the native balance
        }
        else {
            // Send the balance to the msg.sender
            msg.sender.call{value: msg.value}("");
        }
    }

    function WARNING() public pure returns (string memory) {
        return "This contract is a test contract for security research purposes only and should not be interacted with.";
    }
}
