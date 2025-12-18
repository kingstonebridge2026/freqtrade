#!/bin/bash
set -e

echo "Initializing Scalper Environment..."
USER_DATA_PATH="/freqtrade/user_data"
CONFIG_PATH="$USER_DATA_PATH/config.json"

mkdir -p $USER_DATA_PATH

echo "Generating HFT Config..."
cat > $CONFIG_PATH <<EOL
{
  "exchange": {
    "name": "${FREQTRADE__EXCHANGE__NAME:-binance}",
    "key": "${FREQTRADE__EXCHANGE__KEY}",
    "secret": "${FREQTRADE__EXCHANGE__SECRET}",
    "pair_whitelist": ["BTC/USDT", "ETH/USDT", "SOL/USDT", "BNB/USDT", "XRP/USDT"],
    "pair_blacklist": [".*(BNB|BULL|BEAR|UP|DOWN)/.*"]
  },
  "dry_run": ${FREQTRADE__DRY_RUN:-true},
  "stake_currency": "USDT",
  "stake_amount": "unlimited",
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
    "use_order_book": true,
    "order_book_top": 1
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
      "number_assets": 50,
      "sort_key": "quoteVolume"
    }
  ]
}
EOL

echo "Launching TheSnapScalper..."
# No --strategy-path needed if your file is in user_data/strategies/
freqtrade trade -c $CONFIG_PATH --strategy TheSnapScalper

