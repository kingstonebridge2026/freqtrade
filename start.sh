#!/bin/bash
set -e

echo "Creating strategy directory..."
mkdir -p /freqtrade/user_data/strategies

echo "Downloading strategy repository..."
curl -L \
https://github.com/iterativv/NostalgiaForInfinity/archive/refs/heads/main.zip \
-o /tmp/nfi.zip

echo "Unzipping..."
unzip /tmp/nfi.zip -d /tmp

echo "Copying strategy file..."
cp /tmp/NostalgiaForInfinity-main/NostalgiaForInfinityX7.py \
/freqtrade/user_data/strategies/

echo "Starting freqtrade..."
freqtrade trade -c config.json
