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

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MaliciousURIToken is ERC721 {
    string private _baseTokenURI;

    uint256 private _tokenIdCounter;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) ERC721(name_, symbol_) {
        _baseTokenURI = baseURI_;
    }

    function mint(address to) external returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _mint(to, tokenId);
        return tokenId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function updateBaseURI(string memory newBaseURI) external {
        require(msg.sender == address(0), "Only for testing - disabled in this version");
        _baseTokenURI = newBaseURI;
    }

    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter;
    }

    function WARNING() public pure returns (string memory) {
        return "This contract is a test contract for security research purposes only and should not be interacted with.";
    }
}
