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

# Deploy specific contract by ID
./deploy.sh a1    # Exact Name Spoof
./deploy.sh b2    # Malicious Symbol Token
./deploy.sh c4    # Hidden Restriction Token

# Deploy by category
./deploy.sh visual      # All Visual Spoofing (a1-a3)
./deploy.sh metadata    # All Metadata Manipulation (b1-b3)
./deploy.sh contract    # All Contract Deception (c1-c4)

# Show help
./deploy.sh help
```

## Implemented Contracts

### Visual Spoofing (a)
- **a1** - Exact Name Spoof
- **a2** - Homoglyph Token
- **a3** - Invisible Char Token

### Metadata Manipulation (b)
- **b1** - Malicious Name Token (URL in name)
- **b2** - Malicious Symbol Token (URL in symbol)
- **b3** - Malicious URI Token (NFT with malicious image)

### Contract Deception (c)
- **c1** - Classic Honeypot (cannot sell)
- **c2** - Hidden Mint Token (unlimited supply)
- **c3** - High Tax Token (>50% tax)
- **c4** - Hidden Restriction Token (1000 block sell lock)

## Structure

```
.
├── src/               # All contracts in flat structure
├── script/
│   └── DeployAll.s.sol
├── deploy.sh
└── foundry.toml
```
