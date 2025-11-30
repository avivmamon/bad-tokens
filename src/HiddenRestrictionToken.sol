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
 * @title HiddenRestrictionToken
 * @dev A token that has hidden restrictions on transfers, e.g., only allowing small amounts or specific blocks.
 */
contract HiddenRestrictionToken is ERC20, Ownable {
    uint256 public maxTransferAmount;
    uint256 public maxTxAmount;
    uint256 public maxWallet;
    uint256 public maxSellAmount;
    uint256 public maxBuyAmount;
    bool public restrictionsEnabled = true;

    address public uniswapPair;
    uint256 public deploymentBlock;
    uint256 public constant SELL_LOCK_BLOCKS = 1000;

    constructor(uint256 initialSupply) ERC20("Hidden Restriction Token", "HRT") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
        deploymentBlock = block.number;
        maxTransferAmount = initialSupply / 1000;
        maxTxAmount = initialSupply / 1000;
        maxWallet = initialSupply / 500;
        maxSellAmount = initialSupply / 1000;
        maxBuyAmount = initialSupply / 1000;
    }

    function setMaxTransfer(uint256 _amount) external onlyOwner {
        maxTransferAmount = _amount;
    }

    function setUniswapPair(address _pair) external onlyOwner {
        uniswapPair = _pair;
    }

    function toggleRestrictions(bool _enabled) external onlyOwner {
        restrictionsEnabled = _enabled;
    }

    function _update(address from, address to, uint256 value) internal override {
        if (restrictionsEnabled && from != owner() && to != owner()) {
            if (to == uniswapPair && block.number < deploymentBlock + SELL_LOCK_BLOCKS) {
                revert("Selling is locked for the first 1000 blocks");
            }

            if (value > maxTransferAmount || value > maxTxAmount) {
                 revert("Transfer amount exceeds limit");
            }
            if (to != address(0) && balanceOf(to) + value > maxWallet) {
                 revert("Wallet limit exceeded");
            }
        }
        super._update(from, to, value);
    }

    function WARNING() public pure returns (string memory) {
        return "This contract is a test contract for security research purposes only and should not be interacted with.";
    }
}

