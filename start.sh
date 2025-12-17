#!/bin/bash
set -e

echo "Starting Freqtrade setup..."

# Create required directories
mkdir -p /freqtrade/user_data/strategies
mkdir -p /freqtrade/user_data/data/binance

# Download your strategy file
STRATEGY_URL="https://raw.githubusercontent.com/kingstonebridge2026/freqtrade/develop/user_data/NostalgiaForInfinityX7.py"
STRATEGY_PATH="/freqtrade/user_data/strategies/NostalgiaForInfinityX7.py"

if [ ! -f "$STRATEGY_PATH" ]; then
    echo "Downloading strategy..."
    curl -fsSL $STRATEGY_URL -o $STRATEGY_PATH
else
    echo "Strategy already exists."
fi

# Check if config.json exists
CONFIG_PATH="/freqtrade/user_data/config.json"

if [ ! -f "$CONFIG_PATH" ]; then
    echo "Creating default config.json..."
    freqtrade new-config --config $CONFIG_PATH
    echo "Config.json created at $CONFIG_PATH"
else
    echo "Config.json already exists."
fi

# Start Freqtrade in dry-run mode
echo "Starting Freqtrade..."
freqtrade trade -c $CONFIG_PATH

