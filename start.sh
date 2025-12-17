
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
    "name": "${FREQTRADE__EXCHANGE__NAME}",
    "key": "${FREQTRADE__EXCHANGE__KEY}",
    "secret": "${FREQTRADE__EXCHANGE__SECRET}"
  },
  "dry_run": ${FREQTRADE__DRY_RUN:-true},
  "stake_currency": "${FREQTRADE__STAKE_CURRENCY:-USDT}",
  "stake_amount": "${FREQTRADE__STAKE_AMOUNT:-unlimited}",
  "trading_mode": "${FREQTRADE__TRADING_MODE:-spot}",
  "max_open_trades": ${FREQTRADE__MAX_OPEN_TRADES:-5},
  "pairlists": [],
  "telegram": {
    "enabled": ${FREQTRADE__TELEGRAM_ENABLED:-false},
    "token": "${FREQTRADE__TELEGRAM_TOKEN:-}",
    "chat_id": "${FREQTRADE__TELEGRAM_CHAT_ID:-}"
  }
}
EOL

echo "Starting Freqtrade..."
freqtrade trade -c $CONFIG_PATH
