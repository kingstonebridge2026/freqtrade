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
    "unfilledtimeout": {
        "entry": 5,
        "exit": 5,
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
            "BNB/.*", "TUSD/.*", "USDC/.*", "EUR/.*", "PAX/.*", "DAI/.*"
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
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": 8080,
        "verbosity": "info",
        "jwt_secret_key": "change_this_secret",
        "username": "admin",
        "password": "change_this_password"
    },
    "bot_name": "NFIX7_Bot",
    "initial_state": "running",
    "internals": {
        "process_throttle_secs": 2
    }
}
EOL

echo "Launching NostalgiaForInfinityX7..."
# Ensure the strategy file name matches exactly (minus .py)
freqtrade trade -c $CONFIG_PATH --strategy NostalgiaForInfinityX7

