# --- Do not remove these libs ---
import numpy as np
import pandas as pd
from pandas import DataFrame
from freqtrade.strategy import IStrategy
import freqtrade.vendor.qtpylib.indicators as qtpylib


class TheSnapScalper(IStrategy):
    """
    TheSnapScalper
    Freqtrade 2025.12 / Railway SAFE
    """

    INTERFACE_VERSION = 3

    timeframe = "1m"
    can_short = False

    startup_candle_count = 50
    process_only_new_candles = True

    # === RISK ===
    minimal_roi = {
        "0": 0.02,
        "10": 0.01,
        "20": 0
    }

    stoploss = -0.08

    # === INDICATOR SETTINGS ===
    base_nb_candles_buy = 20
    base_nb_candles_sell = 20
    low_offset = 0.985
    high_offset = 1.01

    rsi_buy = 35
    rsi_sell = 70

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe["sma_buy"] = qtpylib.sma(
            dataframe["close"], self.base_nb_candles_buy
        )

        dataframe["sma_sell"] = qtpylib.sma(
            dataframe["close"], self.base_nb_candles_sell
        )

        dataframe["rsi"] = qtpylib.rsi(
            dataframe["close"], period=14
        )

        dataframe["volume_mean"] = dataframe["volume"].rolling(20).mean()

        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe["close"] < dataframe["sma_buy"] * self.low_offset) &
                (dataframe["rsi"] < self.rsi_buy) &
                (dataframe["volume"] > dataframe["volume_mean"]) &
                (dataframe["volume"] > 0)
            ),
            "enter_long",
        ] = 1

        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe["close"] > dataframe["sma_sell"] * self.high_offset) |
                (dataframe["rsi"] > self.rsi_sell)
            ),
            "exit_long",
        ] = 1

        return dataframe

