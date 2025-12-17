
#!/bin/bash
set -e

echo "Creating required directories..."
mkdir -p /freqtrade/user_data/strategies
mkdir -p /freqtrade/user_data/data/binance

# Download strategy repository tarball
echo "Downloading strategy repository..."
curl -L \
https://github.com/iterativv/NostalgiaForInfinity/archive/refs/heads/main.tar.gz \
-o /tmp/nfi.tar.gz

echo "Extracting strategy..."
tar -xzf /tmp/nfi.tar.gz -C /tmp

echo "Copying strategy file..."
cp /tmp/NostalgiaForInfinity-main/NostalgiaForInfinityX7.py /freqtrade/user_data/strategies/

# Create config.json from ENV vars (non-interactive)
CONFIG_PATH="/freqtrade/user_data/config.json"
echo "Creating config.json from ENV vars..."
cat > $CONFIG_PATH <<EOL
{
  "exchange": {
    "name": "${FREQTRADE__EXCHANGE__NAME:-binance}",
    "key": "${FREQTRADE__EXCHANGE__KEY}",
    "secret": "${FREQTRADE__EXCHANGE__SECRET}",
    "pair_whitelist": [
      "BTC/USDT",
      "ETH/USDT",
      "SOL/USDT",
      "BNB/USDT",
      "XRP/USDT",
      "ADA/USDT",
      "DOT/USDT"
    ],
    "pair_blacklist": [
      ".*(BNB|BULL|BEAR|UP|DOWN|HALF|STUPID|SUSD|TUSD|PAX|BUSD|USDC|DAI)/.*",
      ".*(AUD|BRZ|CAD|CHF|EUR|GBP|HKD|IDRT|JPY|NGN|PLN|RON|RUB|SGD|TRY|UAH|ZAR)/.*"
    ],
    "ccxt_config": {},
    "ccxt_async_config": {}
  },
  "dry_run": ${FREQTRADE__DRY_RUN:-true},
  "stake_currency": "${FREQTRADE__STAKE_CURRENCY:-USDT}",
  "stake_amount": "${FREQTRADE__STAKE_AMOUNT:-unlimited}",
  "trading_mode": "${FREQTRADE__TRADING_MODE:-spot}",
  "max_open_trades": ${FREQTRADE__MAX_OPEN_TRADES:-5},
  "strategy": "NostalgiaForInfinityX7",
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
  "pairlists": [
    {
      "method": "VolumePairlist",
      "number_assets": 20,
      "sort_key": "quoteVolume",
      "min_value": 0,
      "refresh_period": 1800
    }
  ],
  "telegram": {
    "enabled": ${FREQTRADE__TELEGRAM_ENABLED:-false},
    "token": "${FREQTRADE__TELEGRAM_TOKEN:-}",
    "chat_id": "${FREQTRADE__TELEGRAM_CHAT_ID:-}"
  }
}
EOL

echo "Starting Freqtrade..."
# Launching with the strategy flag and the generated config
freqtrade trade -c $CONFIG_PATH --strategy NostalgiaForInfinityX7
