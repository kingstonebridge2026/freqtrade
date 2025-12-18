#!/bin/bash
set -e

echo "Initializing Scalper Environment..."
mkdir -p /freqtrade/user_data/strategies
mkdir -p /freqtrade/user_data/data/binance

# Note: We assume TheSnapScalper.py is already in your repo. 
# If it's not, you can add a curl command here to fetch it.

# Create config.json optimized for HFT
CONFIG_PATH="/freqtrade/user_data/config.json"
echo "Generating HFT Config..."
cat > $CONFIG_PATH <<EOL
{
  "exchange": {
    "name": "${FREQTRADE__EXCHANGE__NAME:-binance}",
    "key": "${FREQTRADE__EXCHANGE__KEY}",
    "secret": "${FREQTRADE__EXCHANGE__SECRET}",
    "pair_whitelist": [
      "BTC/USDT", "ETH/USDT", "SOL/USDT", "BNB/USDT"
    ],
    "pair_blacklist": [
      ".*(BNB|BULL|BEAR|UP|DOWN|HALF|STUPID|SUSD|TUSD|PAX|BUSD|USDC|DAI)/.*",
      ".*(AUD|BRZ|CAD|CHF|EUR|GBP|HKD|IDRT|JPY|NGN|PLN|RON|RUB|SGD|TRY|UAH|ZAR)/.*"
    ]
  },

  "telegram": {
    "enabled": true,
    "token": "${TELEGRAM_TOKEN}",
    "chat_id": "${TELEGRAM_CHAT_ID}",
    "keyboard": [
      ["/daily", "/profit", "/balance"],
      ["/status table", "/performance", "/count"],
      ["/reload_config", "/show_config", "/help"]
    ],
    "notification_settings": {
      "status": "on",
      "entry": "on",
      "exit": "on",
      "buy": "on",
      "sell": "on",
      "buy_fill": "on",
      "sell_fill": "on",
      "buy_cancel": "off",
      "sell_cancel": "off",
      "protection_trigger": "on",
      "protection_trigger_global": "on"
    }
  },
  
  "dry_run": ${FREQTRADE__DRY_RUN:-true},
  "stake_currency": "${FREQTRADE__STAKE_CURRENCY:-USDT}",
  "stake_amount": "unlimited",
  "trading_mode": "${FREQTRADE__TRADING_MODE:-spot}",
  "max_open_trades": 15,
  "strategy": "TheSnapScalper",
  "timeframe": "1m",
  "entry_pricing": {
    "price_side": "same",
    "use_order_book": true,
    "order_book_top": 1
  },
  "exit_pricing": {
    "price_side": "other", 
    "use_order_book": true
  },
  "order_types": {
    "entry": "limit",
    "exit": "market",
    "emergency_exit": "market",
    "stoploss": "market",
    "stoploss_on_exchange": false
  },
  "pairlists": [
    {
      "method": "VolumePairList",
      "number_assets": 80,
      "sort_key": "quoteVolume",
      "refresh_period": 900
    },
    {"method": "AgeFilter", "min_days_listed": 10},
    {"method": "SpreadFilter", "max_spread_ratio": 0.005}
  ]
}
EOL

echo "Launching TheSnapScalper..."
# Use --strategy-path to ensure it finds the file in user_data/strategies
freqtrade trade -c $CONFIG_PATH --strategy TheSnapScalper --strategy-path /freqtrade/user_data/strategies --db-url sqlite:///tradesv3.sqlite

