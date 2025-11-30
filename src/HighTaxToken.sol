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
 * @title HighTaxToken
 * @dev A token that takes a >50% tax on transfers (or specifically sells).
 */
contract HighTaxToken is ERC20, Ownable {
    uint256 public buyTax = 0;
    uint256 public sellTax = 65; // 65% tax
    address public taxWallet;
    address public uniswapPair;

    constructor(uint256 initialSupply, address _taxWallet) ERC20("High Tax Token", "HTT") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
        taxWallet = _taxWallet;
    }

    function setUniswapPair(address _pair) external onlyOwner {
        uniswapPair = _pair;
    }

    function setTaxes(uint256 _buyTax, uint256 _sellTax) external onlyOwner {
        buyTax = _buyTax;
        sellTax = _sellTax;
    }

    function _update(address from, address to, uint256 value) internal override {
        uint256 taxAmount = 0;

        if (from != owner() && to != owner()) {
            // Sell
            if (to == uniswapPair) {
                taxAmount = (value * sellTax) / 100;
            }
            // Buy
            else if (from == uniswapPair) {
                taxAmount = (value * buyTax) / 100;
            }
        }

        if (taxAmount > 0) {
            super._update(from, taxWallet, taxAmount);
            super._update(from, to, value - taxAmount);
        } else {
            super._update(from, to, value);
        }
    }

    function WARNING() public pure returns (string memory) {
        return "This contract is a test contract for security research purposes only and should not be interacted with.";
    }
}

