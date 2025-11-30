# Token Security Research Test Suite

## ⚠️ DISCLAIMER

**FOR SECURITY RESEARCH AND TESTING PURPOSES ONLY**

This repository contains smart contracts with known vulnerabilities and malicious patterns designed to test token validation systems.


## Requirements

- **Foundry** - Solidity development framework
- **Node.js** (optional) - For additional tooling
- **Base Network RPC URL** - For deployments
- **Private Key** - For contract deployment
- **BaseScan API Key** (optional) - For contract verification

## Setup

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
forge install

# Configure environment
cp secrets.env.example secrets.env
# Edit secrets.env with your credentials

# Build contracts
forge build
```

## Deployment

```bash
# Deploy all contracts
./deploy.sh all

# Deploy specific contract
./deploy.sh spoof1      # Exact Name Spoof
./deploy.sh metadata2   # Malicious Symbol Token
./deploy.sh honeypot4   # Hidden Restriction Token

# Deploy by category
./deploy.sh visual      # All Visual Spoofing (spoof1-3)
./deploy.sh metadata    # All Metadata Manipulation (metadata1-3)
./deploy.sh honeypot    # All Honeypot tokens (honeypot1-4)

# Show help
./deploy.sh help
```

## Implemented Contracts

### Visual Spoofing
- **spoof1** - Exact Name Spoof (USDC)
- **spoof2** - Homoglyph Token (Cyrillic characters)
- **spoof3** - Invisible Character Token (zero-width spaces)

### Metadata Manipulation
- **metadata1** - Malicious Name Token (URL in name)
- **metadata2** - Malicious Symbol Token (URL in symbol)
- **metadata3** - Malicious URI Token (NFT with malicious image)

### Honeypot / Contract Deception
- **honeypot1** - Classic Honeypot (cannot sell, 10% distributed to holders)
- **honeypot2** - Hidden Mint Token (unlimited supply via disguised function)
- **honeypot3** - High Tax Token (65% sell tax)
- **honeypot4** - Hidden Restriction Token (1000 block sell lock, wallet limits)
