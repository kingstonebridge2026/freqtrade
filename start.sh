
#!/bin/bash
set -e

echo "Starting Freqtrade setup with ENV vars..."

# Create required directories
mkdir -p /freqtrade/user_data/strategies
mkdir -p /freqtrade/user_data/data/binance

# Download your strategy file if not exists
STRATEGY_URL="https://raw.githubusercontent.com/kingstonebridge2026/freqtrade/develop/user_data/NostalgiaForInfinityX7.py"
STRATEGY_PATH="/freqtrade/user_data/strategies/NostalgiaForInfinityX7.py"

if [ ! -f "$STRATEGY_PATH" ]; then
    echo "Downloading strategy..."
    curl -fsSL $STRATEGY_URL -o $STRATEGY_PATH
else
    echo "Strategy already exists."
fi

# Create config.json if not exists
CONFIG_PATH="/freqtrade/user_data/config.json"

if [ ! -f "$CONFIG_PATH" ]; then
    echo "Creating default config.json..."
    freqtrade new-config --config $CONFIG_PATH
fi

# Replace config values with ENV vars
echo "Injecting ENV vars into config.json..."
jq '.exchange.key = env.FREQTRADE__EXCHANGE__KEY |
    .exchange.secret = env.FREQTRADE__EXCHANGE__SECRET |
    .exchange.name = env.FREQTRADE__EXCHANGE__NAME |
    .dry_run = (env.FREQTRADE__DRY_RUN | test("true"))' \
    $CONFIG_PATH > tmp.json && mv tmp.json $CONFIG_PATH

# Start Freqtrade
echo "Starting Freqtrade..."
freqtrade trade -c $CONFIG_PATH
