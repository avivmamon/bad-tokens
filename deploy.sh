#!/bin/bash

# Load environment variables
if [ -f secrets.env ]; then
    export $(cat secrets.env | xargs)
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Array to store deployment results
declare -a DEPLOYED_CONTRACTS

# Help message
show_help() {
    echo "Token Red Team - Deployment Script"
    echo "⚠️  FOR SECURITY RESEARCH ONLY"
    echo ""
    echo "Usage: ./deploy.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  all                   Deploy all contracts"
    echo "  spoof1                Deploy Exact Name Spoof (USDC)"
    echo "  spoof2                Deploy Homoglyph Token"
    echo "  spoof3                Deploy Invisible Character Token"
    echo "  metadata1             Deploy Malicious Name Token"
    echo "  metadata2             Deploy Malicious Symbol Token"
    echo "  metadata3             Deploy Malicious URI Token (NFT)"
    echo "  honeypot1             Deploy Classic Honeypot"
    echo "  honeypot2             Deploy Hidden Mint Token"
    echo "  honeypot3             Deploy High Tax Token"
    echo "  honeypot4             Deploy Hidden Restriction Token"
    echo "  visual                Deploy all Visual Spoofing contracts"
    echo "  metadata              Deploy all Metadata Manipulation contracts"
    echo "  honeypot              Deploy all Honeypot contracts"
    echo "  help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh all           # Deploy everything"
    echo "  ./deploy.sh spoof1        # Deploy Exact Name Spoof only"
    echo "  ./deploy.sh metadata2     # Deploy Malicious Symbol Token"
    echo "  ./deploy.sh visual        # Deploy all visual spoofing variants"
    echo "  ./deploy.sh metadata      # Deploy all metadata manipulation tokens"
    echo "  ./deploy.sh honeypot      # Deploy all honeypot tokens"
    echo ""
}

# Check if required env vars are set
check_env() {
    if [ -z "$PRIVATE_KEY" ] || [ -z "$RPC_URL" ]; then
        echo -e "${RED}Error: Missing required environment variables${NC}"
        echo "Please set PRIVATE_KEY and RPC_URL in secrets.env"
        exit 1
    fi

    if [ -z "$ETHERSCAN_API_KEY" ]; then
        echo -e "${YELLOW}Warning: ETHERSCAN_API_KEY not set - contracts will not be verified${NC}"
    fi
}

# Deploy function
deploy() {
    local sig=$1
    local name=$2

    echo -n -e "${YELLOW}Deploying $name...${NC}"

    # Build the base command
    local cmd="forge script script/DeployAll.s.sol:DeployAll \
        --sig \"$sig\" \
        --rpc-url $RPC_URL \
        --broadcast \
        --chain base"

    # Add verification flags if API key is set
    if [ -n "$ETHERSCAN_API_KEY" ]; then
        cmd="$cmd \
        --verify \
        --verifier etherscan \
        --etherscan-api-key $ETHERSCAN_API_KEY"
    fi

    cmd="$cmd -vv"

    # Capture output
    local output=$(eval $cmd 2>&1 | tee /dev/tty)
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e " ${GREEN}✓${NC}"

        # Try to extract contract address from output
        local address=$(echo "$output" | grep -F "$name" | grep -o "0x[a-fA-F0-9]\{40\}" | head -1)

        if [ -n "$address" ]; then
            DEPLOYED_CONTRACTS+=("$name|$address")
        else
            DEPLOYED_CONTRACTS+=("$name|Deployed (address not found)")
        fi
    else
        echo -e " ${RED}✗${NC}"
        DEPLOYED_CONTRACTS+=("$name|FAILED")
    fi
}

# Show deployment summary
show_summary() {
    if [ ${#DEPLOYED_CONTRACTS[@]} -eq 0 ]; then
        return
    fi

    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Deployment Summary${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

    for item in "${DEPLOYED_CONTRACTS[@]}"; do
        IFS='|' read -r name address <<< "$item"
        if [ "$address" = "FAILED" ]; then
            echo -e "${RED}✗ $name${NC} - ${RED}Failed${NC}"
        else
            echo -e "${GREEN}✓ $name${NC}"
            echo -e "  ${BLUE}→${NC} $address"
        fi
    done

    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

# Main script logic
check_env

case "$1" in
    all)
        echo -e "${GREEN}Deploying ALL contracts...${NC}\n"

        deploy "deploy_spoof1()" "spoof1 - Exact Name Spoof"
        deploy "deploy_spoof2()" "spoof2 - Homoglyph Token"
        deploy "deploy_spoof3()" "spoof3 - Invisible Char Token"
        deploy "deploy_metadata1()" "metadata1 - Malicious Name Token"
        deploy "deploy_metadata2()" "metadata2 - Malicious Symbol Token"
        deploy "deploy_metadata3()" "metadata3 - Malicious URI Token (NFT)"
        deploy "deploy_honeypot1()" "honeypot1 - Classic Honeypot"
        deploy "deploy_honeypot2()" "honeypot2 - Hidden Mint Token"
        deploy "deploy_honeypot3()" "honeypot3 - High Tax Token"
        deploy "deploy_honeypot4()" "honeypot4 - Hidden Restriction Token"

        show_summary
        ;;

    # Individual contract deployments
    spoof1)
        deploy "deploy_spoof1()" "spoof1 - Exact Name Spoof"
        show_summary
        ;;
    spoof2)
        deploy "deploy_spoof2()" "spoof2 - Homoglyph Token"
        show_summary
        ;;
    spoof3)
        deploy "deploy_spoof3()" "spoof3 - Invisible Char Token"
        show_summary
        ;;
    metadata1)
        deploy "deploy_metadata1()" "metadata1 - Malicious Name Token"
        show_summary
        ;;
    metadata2)
        deploy "deploy_metadata2()" "metadata2 - Malicious Symbol Token"
        show_summary
        ;;
    metadata3)
        deploy "deploy_metadata3()" "metadata3 - Malicious URI Token (NFT)"
        show_summary
        ;;
    honeypot1)
        deploy "deploy_honeypot1()" "honeypot1 - Classic Honeypot"
        show_summary
        ;;
    honeypot2)
        deploy "deploy_honeypot2()" "honeypot2 - Hidden Mint Token"
        show_summary
        ;;
    honeypot3)
        deploy "deploy_honeypot3()" "honeypot3 - High Tax Token"
        show_summary
        ;;
    honeypot4)
        deploy "deploy_honeypot4()" "honeypot4 - Hidden Restriction Token"
        show_summary
        ;;

    # Category deployments
    visual)
        echo -e "${GREEN}Deploying Visual Spoofing contracts...${NC}\n"
        deploy "deploy_spoof1()" "spoof1 - Exact Name Spoof"
        deploy "deploy_spoof2()" "spoof2 - Homoglyph Token"
        deploy "deploy_spoof3()" "spoof3 - Invisible Char Token"
        show_summary
        ;;

    metadata)
        echo -e "${GREEN}Deploying Metadata Manipulation contracts...${NC}\n"
        deploy "deploy_metadata1()" "metadata1 - Malicious Name Token"
        deploy "deploy_metadata2()" "metadata2 - Malicious Symbol Token"
        deploy "deploy_metadata3()" "metadata3 - Malicious URI Token (NFT)"
        show_summary
        ;;

    honeypot)
        echo -e "${GREEN}Deploying Honeypot tokens...${NC}\n"
        deploy "deploy_honeypot1()" "honeypot1 - Classic Honeypot"
        deploy "deploy_honeypot2()" "honeypot2 - Hidden Mint Token"
        deploy "deploy_honeypot3()" "honeypot3 - High Tax Token"
        deploy "deploy_honeypot4()" "honeypot4 - Hidden Restriction Token"
        show_summary
        ;;

    help|--help|-h)
        show_help
        ;;

    *)
        if [ -z "$1" ]; then
            echo -e "${RED}Error: No deployment option specified${NC}\n"
        else
            echo -e "${RED}Error: Unknown option '$1'${NC}\n"
        fi
        show_help
        exit 1
        ;;
esac
