#!/bin/bash
set -e

echo "Cleaning and Initializing for NFIX7..."
USER_DATA_PATH="/freqtrade/user_data"
CONFIG_PATH="$USER_DATA_PATH/config.json"

mkdir -p $USER_DATA_PATH

cat > $CONFIG_PATH <<EOL
{
    "\$schema": "https://schema.freqtrade.io/schema.json",
    "max_open_trades": 15,
    "stake_currency": "USDT",
    "stake_amount": "unlimited",
    "tradable_balance_ratio": 0.99,
    "fiat_display_currency": "USD",
    "timeframe": "5m",
    "dry_run": true,
    "dry_run_wallet": 10000,

    "entry_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1
    },

    "exit_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1
    },

    "order_types": {
        "entry": "limit",
        "exit": "limit",
        "emergency_exit": "market",
        "force_entry": "market",
        "force_exit": "market",
        "stoploss": "market",
        "stoploss_on_exchange": false
    },

    "exchange": {
        "name": "binance",
        "key": "${FREQTRADE__EXCHANGE__KEY}",
        "secret": "${FREQTRADE__EXCHANGE__SECRET}",
        "pair_whitelist": [
            "BTC/USDT", "ETH/USDT", "SOL/USDT", "XRP/USDT", "DOGE/USDT", 
            "SUI/USDT", "AVAX/USDT", "ADA/USDT", "LINK/USDT", "DOT/USDT"
        ]
    },

    "pairlists": [
        { "method": "StaticPairList" }
    ],

    "telegram": {
        "enabled": true,
        "token": "${FREQTRADE__TELEGRAM_TOKEN}",
        "chat_id": "${FREQTRADE__TELEGRAM_CHAT_ID}"
    },

    "bot_name": "NFIX7_Railway",
    "initial_state": "running"
}
EOL

echo "Launching Strategy..."
# This command tells freqtrade exactly where to look for your .py file
freqtrade trade -c $CONFIG_PATH --strategy NostalgiaForInfinityX7 --strategy-path /freqtrade/user_data/strategies
