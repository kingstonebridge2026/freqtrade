
#!/bin/bash
set -e

echo "Initializing Scalper Environment..."

# 1. Define Paths (Railway typically uses /freqtrade/ as the root for this image)
USER_DATA_PATH="/freqtrade/user_data"
CONFIG_PATH="$USER_DATA_PATH/config.json"

# 2. Ensure the user_data directory exists for the config to live in
mkdir -p $USER_DATA_PATH

echo "Generating HFT Config..."
cat > $CONFIG_PATH <<EOL
{
  "exchange": {
    "name": "${FREQTRADE__EXCHANGE__NAME:-binance}",
    "key": "${FREQTRADE__EXCHANGE__KEY}",
    "secret": "${FREQTRADE__EXCHANGE__SECRET}",
    "pair_whitelist": [
      "BTC/USDT", "ETH/USDT", "SOL/USDT", "BNB/USDT", "XRP/USDT", "ADA/USDT"
    ],
    "pair_blacklist": [
      ".*(BNB|BULL|BEAR|UP|DOWN|HALF|STUPID|SUSD|TUSD|PAX|BUSD|USDC|DAI)/.*",
      ".*(AUD|BRZ|CAD|CHF|EUR|GBP|HKD|IDRT|JPY|NGN|PLN|RON|RUB|SGD|TRY|UAH|ZAR)/.*"
    ]
  },
  "dry_run": ${FREQTRADE__DRY_RUN:-true},
  "stake_currency": "${FREQTRADE__STAKE_CURRENCY:-USDT}",
  "stake_amount": "unlimited",
  "max_open_trades": 15,
  "strategy": "TheSnapScalper",
  "timeframe": "1m",
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
    }
  ]
}
EOL

echo "Launching TheSnapScalper..."
# We remove --strategy-path because Freqtrade will look in user_data/strategies by default
# relative to the current directory where your GitHub files are.
freqtrade trade -c $CONFIG_PATH --strategy TheSnapScalper
