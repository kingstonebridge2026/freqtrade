#!/bin/bash

set -e

echo "Creating strategy directory..."
mkdir -p /freqtrade/user_data/strategies

echo "Downloading strategy..."
curl -fsSL \
https://raw.githubusercontent.com/kingstonebridge2026/freqtrade.git/develop/NostalgiaForInfinityX7.py \
-o /freqtrade/user_data/strategies/NostalgiaForInfinityX7.py

echo "Starting freqtrade with custom config..."
freqtrade trade -c config.json
