
#!/bin/bash
set -e

echo "Creating strategy directory..."
mkdir -p /freqtrade/user_data/strategies

echo "Downloading strategy repository (tar)..."
curl -L \
https://github.com/iterativv/NostalgiaForInfinity/archive/refs/heads/main.tar.gz \
-o /tmp/nfi.tar.gz

echo "Extracting strategy..."
tar -xzf /tmp/nfi.tar.gz -C /tmp

echo "Copying strategy file..."
cp /tmp/NostalgiaForInfinity-main/NostalgiaForInfinityX7.py \
/freqtrade/user_data/strategies/

echo "Starting freqtrade..."
freqtrade trade -c config.json
