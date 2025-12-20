#!/bin/bash
set -e

echo "Initializing Environment for NFIX7..."
USER_DATA_PATH="/freqtrade/user_data"
CONFIG_PATH="$USER_DATA_PATH/config.json"

mkdir -p $USER_DATA_PATH

echo "Generating Configuration..."
cat > $CONFIG_PATH <<EOL
{
    "\$schema": "https://schema.freqtrade.io/schema.json",
    "max_open_trades": 30,
    "stake_currency": "USDT",
    "stake_amount": "unlimited",
    "tradable_balance_ratio": 0.99,
    "fiat_display_currency": "USD",
    "timeframe": "5m",
    "dry_run": true,
    "dry_run_wallet": 10000, 
    "cancel_open_orders_on_exit": false,

    "order_types": {
        "entry": "limit",
        "exit": "limit",
        "emergency_exit": "market",
        "force_entry": "market",
        "force_exit": "market",
        "stoploss": "market",
        "stoploss_on_exchange": false
    },

    "entry_pricing": {
        "price_side": "other",
        "use_order_book": false,
        "order_book_top": 1
    },

    "exit_pricing": {
        "price_side": "other",
        "use_order_book": false
    },

    "unfilledtimeout": {
        "entry": 10,
        "exit": 30,
        "unit": "minutes"
    },

    "exchange": {
        "name": "binance",
        "key": "${FREQTRADE__EXCHANGE__KEY}",
        "secret": "${FREQTRADE__EXCHANGE__SECRET}",
        "ccxt_config": {
            "enableRateLimit": true
        },
        "pair_whitelist": [
            "BTC/USDT", "ETH/USDT", "SOL/USDT", "XRP/USDT", "DOGE/USDT", 
            "SUI/USDT", "AVAX/USDT", "ADA/USDT", "LINK/USDT", "DOT/USDT"
        ],
        "pair_blacklist": [
            "BNB/.*", "TUSD/.*", "USDC/.*", "EUR/.*", "PAX/.*", "DAI/.*", ".*DOWN/.*", ".*UP/.*"
        ]
    },

    "pairlists": [
        {
            "method": "VolumePairList",
            "number_assets": 50,
            "sort_key": "quoteVolume",
            "refresh_period": 1800
        }
    ],

    "telegram": {
        "enabled": true,
        "token": "${FREQTRADE__TELEGRAM_TOKEN}",
        "chat_id": "${FREQTRADE__TELEGRAM_CHAT_ID}"
    },

    "bot_name": "NFIX7_Railway",
    "initial_state": "running",
    "internals": {
        "process_throttle_secs": 5
    }
}
EOL

echo "Launching NostalgiaForInfinityX7..."
# Make sure NostalgiaForInfinityX7.py is in your user_data/strategies folder
freqtrade trade -c $CONFIG_PATH --strategy NostalgiaForInfinityX7

