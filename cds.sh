#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 --endpoint-url <url> --priv-key-path <path> --match-i-c <value> --player-i-c <value> --prediction-c <value>"
    exit 1
}

# Check if the correct number of arguments are provided
if [ "$#" -ne 10 ]; then
    usage
fi

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --endpoint-url) endpoint_url="$2"; shift ;;
        --priv-key-path) priv_key_path="$2"; shift ;;
        --match-i-c) match_ic="$2"; shift ;;
        --player-i-c) player_ic="$2"; shift ;;
        --prediction-c) prediction_c="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Display the parsed arguments
echo "Endpoint URL: $endpoint_url"
echo "Private Key Path: $priv_key_path"
if [ -f "$priv_key_path" ]; then
    priv_key=$(cat "$priv_key_path")
    echo "Private Key: $priv_key"

    echo "initializing contracts"
    cast send --rpc-url $endpoint_url --private-key $priv_key $player_ic "init()"
    cast send --rpc-url $endpoint_url --private-key $priv_key $match_ic "init()"
    cast send --rpc-url $endpoint_url --private-key $priv_key $prediction_c "init()"

    echo "set up player info contract"
    cast send --rpc-url $endpoint_url --private-key $priv_key $player_ic "setMatchmakingContract(address)" $match_ic
    cast send --rpc-url $endpoint_url --private-key $priv_key $player_ic "setPredictionContract(address)" $prediction_c

    echo "setup match info contract"
    cast send --rpc-url $endpoint_url --private-key $priv_key $match_ic "setPlayerInfoSmartContractAddress(address)" $player_ic
    cast send --rpc-url $endpoint_url --private-key $priv_key $match_ic "setPredictionSmartContractAddress(address)" $prediction_c

    echo "setup prediction contract"
    cast send --rpc-url $endpoint_url --private-key $priv_key $prediction_c "setPlayerInfoSmartContractAddress(address)" $player_ic
    cast send --rpc-url $endpoint_url --private-key $priv_key $prediction_c "setMatchInfoSmartContractAddress(address)" $match_ic
    cast send --rpc-url $endpoint_url --private-key $priv_key $prediction_c "setThisAddress(address)" $prediction_c
    
    
else
    echo "Private key file not found at path: $priv_key_path"
    exit 1
fi
echo "Match IC: $match_ic"
echo "Player IC: $player_ic"
echo "Prediction C: $prediction_c"

# Add your contract deployment logic here
# Example:
# deploy_contract $endpoint_url $priv_key_path $match_ic $player_ic $prediction_c

echo "Contract deployment script executed successfully."