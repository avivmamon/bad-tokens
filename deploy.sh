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
    echo "  a1                    Deploy specific contract by ID (e.g., a1, b2, c3)"
    echo "  visual                Deploy all Visual Spoofing contracts (a1-a3)"
    echo "  metadata              Deploy all Metadata Manipulation contracts (b1-b3)"
    echo "  contract              Deploy all Contract Deception contracts (c1-c4)"
    echo "  help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh all           # Deploy everything"
    echo "  ./deploy.sh a1            # Deploy Exact Name Spoof only"
    echo "  ./deploy.sh b2            # Deploy Malicious Symbol Token"
    echo "  ./deploy.sh visual        # Deploy all visual spoofing variants"
    echo "  ./deploy.sh metadata      # Deploy all metadata manipulation tokens"
    echo "  ./deploy.sh contract      # Deploy all contract deception tokens"
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

        deploy "deploy_a1()" "a1 - Exact Name Spoof"
        deploy "deploy_a2()" "a2 - Homoglyph Token"
        deploy "deploy_a3()" "a3 - Invisible Char Token"
        deploy "deploy_b1()" "b1 - Malicious Name Token"
        deploy "deploy_b2()" "b2 - Malicious Symbol Token"
        deploy "deploy_b3()" "b3 - Malicious URI Token (NFT)"
        deploy "deploy_c1()" "c1 - Classic Honeypot"
        deploy "deploy_c2()" "c2 - Hidden Mint Token"
        deploy "deploy_c3()" "c3 - High Tax Token"
        deploy "deploy_c4()" "c4 - Hidden Restriction Token"

        show_summary
        ;;

    # Individual contract deployments
    a1)
        deploy "deploy_a1()" "a1 - Exact Name Spoof"
        show_summary
        ;;
    a2)
        deploy "deploy_a2()" "a2 - Homoglyph Token"
        show_summary
        ;;
    a3)
        deploy "deploy_a3()" "a3 - Invisible Char Token"
        show_summary
        ;;
    b1)
        deploy "deploy_b1()" "b1 - Malicious Name Token"
        show_summary
        ;;
    b2)
        deploy "deploy_b2()" "b2 - Malicious Symbol Token"
        show_summary
        ;;
    b3)
        deploy "deploy_b3()" "b3 - Malicious URI Token (NFT)"
        show_summary
        ;;
    c1)
        deploy "deploy_c1()" "c1 - Classic Honeypot"
        show_summary
        ;;
    c2)
        deploy "deploy_c2()" "c2 - Hidden Mint Token"
        show_summary
        ;;
    c3)
        deploy "deploy_c3()" "c3 - High Tax Token"
        show_summary
        ;;
    c4)
        deploy "deploy_c4()" "c4 - Hidden Restriction Token"
        show_summary
        ;;

    # Category deployments
    visual)
        echo -e "${GREEN}Deploying Visual Spoofing contracts (a1-a3)...${NC}\n"
        deploy "deploy_a1()" "a1 - Exact Name Spoof"
        deploy "deploy_a2()" "a2 - Homoglyph Token"
        deploy "deploy_a3()" "a3 - Invisible Char Token"
        show_summary
        ;;

    metadata)
        echo -e "${GREEN}Deploying Metadata Manipulation contracts (b1-b3)...${NC}\n"
        deploy "deploy_b1()" "b1 - Malicious Name Token"
        deploy "deploy_b2()" "b2 - Malicious Symbol Token"
        deploy "deploy_b3()" "b3 - Malicious URI Token (NFT)"
        show_summary
        ;;

    contract)
        echo -e "${GREEN}Deploying Contract Deception tokens (c1-c4)...${NC}\n"
        deploy "deploy_c1()" "c1 - Classic Honeypot"
        deploy "deploy_c2()" "c2 - Hidden Mint Token"
        deploy "deploy_c3()" "c3 - High Tax Token"
        deploy "deploy_c4()" "c4 - Hidden Restriction Token"
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
