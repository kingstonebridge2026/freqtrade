
#!/bin/bash
set -e

echo "Creating strategy directory..."
mkdir -p /freqtrade/user_data/strategies
mkdir -p /freqtrade/user_data/data/binance

# Download strategy repository tarball
echo "Downloading strategy repository (tar)..."
curl -L \
https://github.com/iterativv/NostalgiaForInfinity/archive/refs/heads/main.tar.gz \
-o /tmp/nfi.tar.gz

# Extract the tarball
echo "Extracting strategy..."
tar -xzf /tmp/nfi.tar.gz -C /tmp

# Copy strategy file
echo "Copying strategy file..."
cp /tmp/NostalgiaForInfinity-main/NostalgiaForInfinityX7.py \
/freqtrade/user_data/strategies/

# Create config.json if it doesn't exist
CONFIG_PATH="/freqtrade/user_data/config.json"
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Creating default config.json..."
    freqtrade new-config --config $CONFIG_PATH
fi

# Inject ENV vars into config.json
echo "Injecting ENV vars into config.json..."
jq '.exchange.key = env.FREQTRADE__EXCHANGE__KEY |
    .exchange.secret = env.FREQTRADE__EXCHANGE__SECRET |
    .exchange.name = env.FREQTRADE__EXCHANGE__NAME |
    .dry_run = (env.FREQTRADE__DRY_RUN | test("true"))' \
    $CONFIG_PATH > tmp.json && mv tmp.json $CONFIG_PATH

# Start Freqtrade
echo "Starting freqtrade..."
freqtrade trade -c $CONFIG_PATH
