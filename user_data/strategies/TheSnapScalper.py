# --- Do not remove these libs ---
import numpy as np
import pandas as pd
from pandas import DataFrame
from freqtrade.strategy import IStrategy, IntParameter, DecimalParameter
import talib.abstract as ta
import freqtrade.vendor.qtpylib.indicators as qtpylib

class TheSnapScalper(IStrategy):
    """
    SMAOffsetStrategy - Community HFT Scalper
    """
    INTERFACE_VERSION = 3
    timeframe = '1m'
    can_short = False
    
    # ROI table: Optimized for quick HFT exits
    minimal_roi = {
        "0": 0.05,
        "10": 0.01,
        "20": 0.005,
        "40": 0
    }

    stoploss = -0.10

    # Strategy Parameters
    base_nb_candles_buy = 20
    base_nb_candles_sell = 20
    low_offset = 0.98
    high_offset = 1.01

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Calculate SMAs
        dataframe['sma_buy'] = ta.SMA(dataframe, timeperiod=self.base_nb_candles_buy)
        dataframe['sma_sell'] = ta.SMA(dataframe, timeperiod=self.base_nb_candles_sell)
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=14)
        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['close'] < (dataframe['sma_buy'] * self.low_offset)) &
                (dataframe['rsi'] < 35) &
                (dataframe['volume'] > 0)
            ),
            'enter_long'] = 1
        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['close'] > (dataframe['sma_sell'] * self.high_offset))
            ),
            'exit_long'] = 1
        return dataframe

