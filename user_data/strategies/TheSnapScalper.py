
# --- Do not remove these libs ---
import numpy as np
import pandas as pd
from pandas import DataFrame
from freqtrade.strategy import IStrategy
import pandas_ta as ta

class TheSnapScalper(IStrategy):
    """
    TheSnapScalper - Optimized for Freqtrade 2025.12
    A high-frequency scalping strategy using Mean Reversion.
    """

    INTERFACE_VERSION = 3

    # Strategy parameters
    timeframe = "1m"
    can_short = False
    
    # Ensures indicators have enough data before strategy starts
    startup_candle_count: int = 50
    process_only_new_candles = True

    # ROI table: 2% profit immediately, 1% after 10m, break-even after 20m
    minimal_roi = {
        "0": 0.02,
        "10": 0.01,
        "20": 0
    }

    stoploss = -0.08

    # Hyperoptable parameters
    base_nb_candles_buy = 20
    base_nb_candles_sell = 20
    low_offset = 0.985
    high_offset = 1.01

    rsi_buy = 35
    rsi_sell = 70

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Buy/Sell Moving Averages
        dataframe["sma_buy"] = ta.sma(dataframe["close"], length=self.base_nb_candles_buy)
        dataframe["sma_sell"] = ta.sma(dataframe["close"], length=self.base_nb_candles_sell)

        # RSI calculation using pandas_ta
        dataframe["rsi"] = ta.rsi(dataframe["close"], length=14)

        # Volume Analysis
        dataframe["volume_mean"] = dataframe["volume"].rolling(window=20).mean()

        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                # Use .shift(1) to ensure we are looking at the last completed candle
                (dataframe["close"].shift(1) < (dataframe["sma_buy"].shift(1) * self.low_offset)) &
                (dataframe["rsi"].shift(1) < self.rsi_buy) &
                (dataframe["volume"].shift(1) > dataframe["volume_mean"].shift(1)) &
                (dataframe["volume"] > 0) # Ensure there is actual liquidity
            ),
            "enter_long",
        ] = 1

        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                # Exit when price recovers above SMA or RSI becomes overbought
                (dataframe["close"].shift(1) > (dataframe["sma_sell"].shift(1) * self.high_offset)) |
                (dataframe["rsi"].shift(1) > self.rsi_sell)
            ),
            "exit_long",
        ] = 1

        return dataframe
