#!/bin/bash

# Load environment variables
if [ -f secrets.env ]; then
    export $(cat secrets.env | xargs)
fi

if [ -z "$RPC_URL" ] || [ -z "$PRIVATE_KEY" ]; then
    echo "Error: RPC_URL or PRIVATE_KEY not set in secrets.env"
    exit 1
fi

# Get deployer address
DEPLOYER_ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY)
echo "Deployer: $DEPLOYER_ADDRESS"

ROUTER="0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24"

remove_liquidity() {
    local pool=$1
    
    if [ -z "$pool" ]; then return; fi
    
    echo "----------------------------------------"
    echo "Checking pool: $pool"
    
    # Check LP token balance of deployer
    # We suppress error output in case the address is invalid or network fails, but keep stdout
    balance=$(cast call $pool "balanceOf(address)(uint256)" $DEPLOYER_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "Error checking balance for $pool"
        return
    fi

    if [ "$balance" != "0" ] && [ -n "$balance" ]; then
        echo "Found liquidity: $balance"
        echo "Removing..."
        
        # Get Token address (one of token0/token1 is WETH)
        token0=$(cast call $pool "token0()(address)" --rpc-url $RPC_URL)
        token1=$(cast call $pool "token1()(address)" --rpc-url $RPC_URL)
        weth=$(cast call $ROUTER "WETH()(address)" --rpc-url $RPC_URL)
        
        # Normalize addresses to lowercase for comparison
        token0_lower=$(echo $token0 | tr '[:upper:]' '[:lower:]')
        token1_lower=$(echo $token1 | tr '[:upper:]' '[:lower:]')
        weth_lower=$(echo $weth | tr '[:upper:]' '[:lower:]')
        
        if [ "$token0_lower" == "$weth_lower" ]; then
            TOKEN=$token1
        else
            TOKEN=$token0
        fi
        
        echo "Token address: $TOKEN"
        
        # Approve Router
        echo "Approving router..."
        cast send $pool "approve(address,uint256)" $ROUTER $balance \
            --rpc-url $RPC_URL \
            --private-key $PRIVATE_KEY
            
        # Remove Liquidity
        echo "Calling removeLiquidityETH..."
        deadline=$(($(date +%s) + 300))
        
        cast send $ROUTER "removeLiquidityETH(address,uint256,uint256,uint256,address,uint256)" \
            $TOKEN \
            $balance \
            0 0 \
            $DEPLOYER_ADDRESS \
            $deadline \
            --rpc-url $RPC_URL \
            --private-key $PRIVATE_KEY
            
        echo "Liquidity removed."
    else
        echo "No liquidity found to remove."
    fi
}

# Main logic
if [ -n "$1" ]; then
    # Parameter provided
    remove_liquidity "$1"
else
    # No parameter, check for pools.txt
    if [ -f pools.txt ]; then
        echo "No pool address provided. Reading from pools.txt..."
        while read -r pool; do
            remove_liquidity "$pool"
        done < pools.txt
    else
        echo "Usage: ./remove_liquidity.sh [POOL_ADDRESS]"
        echo "       Or ensure pools.txt exists."
        exit 1
    fi
fi

echo "Done."
