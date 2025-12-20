#!/bin/bash
set -e

# 1. Setup the folders Railway needs
USER_DATA_PATH="/freqtrade/user_data"
STRATEGY_PATH="$USER_DATA_PATH/strategies"
mkdir -p $STRATEGY_PATH

echo "Generating Config..."
# 2. Create the config file
cat > $USER_DATA_PATH/config.json <<EOL
{
    "\$schema": "https://schema.freqtrade.io/schema.json",
    "max_open_trades": 10,
    "stake_currency": "USDT",
    "stake_amount": "unlimited",
    "tradable_balance_ratio": 0.99,
    "timeframe": "5m",
    "dry_run": true,
    "dry_run_wallet": 10000,
    "entry_pricing": { "price_side": "same", "use_order_book": true },
    "exit_pricing": { "price_side": "same", "use_order_book": true },
    "exchange": {
        "name": "binance",
        "key": "${FREQTRADE__EXCHANGE__KEY}",
        "secret": "${FREQTRADE__EXCHANGE__SECRET}",
        "pair_whitelist": ["BTC/USDT","ETH/USDT","SOL/USDT","XRP/USDT","ADA/USDT","DOT/USDT"]
    },
    "telegram": {
        "enabled": true,
        "token": "${FREQTRADE__TELEGRAM_TOKEN}",
        "chat_id": "${FREQTRADE__TELEGRAM_CHAT_ID}"
    },
    "bot_name": "NFIX7_Bot"
}
EOL

echo "Checking Strategy File..."
# List files just so you can see them in Railway logs for debugging
ls -R /freqtrade/user_data/strategies

echo "Launching Bot..."
# 3. Start the trade
freqtrade trade -c $USER_DATA_PATH/config.json --strategy NostalgiaForInfinityX7 --strategy-path $STRATEGY_PATH

