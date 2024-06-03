source .env
forge script \
    --chain amoy script/AdvancedCollectible.s.sol:DeployScript \
    --rpc-url $AMOY_RPC_URL \
    --broadcast \
    --verify \
    -vvvv
