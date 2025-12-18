# --- Do not remove these libs ---
from freqtrade.strategy import IStrategy
from typing import Dict, List
from functools import reduce
from pandas import DataFrame
# --------------------------------
import talib.abstract as ta
import numpy as np
import freqtrade.vendor.qtpylib.indicators as qtpylib
import datetime
from freqtrade.persistence import Trade
from freqtrade.strategy import DecimalParameter, IntParameter, BooleanParameter

class TheSnapScalper(IStrategy):
    """
    SMAOffsetStrategy - Famous Community Scalper
    Optimized for 1m and 5m timeframes.
    """
    INTERFACE_VERSION = 3

    # ROI table:
    minimal_roi = {
        "0": 0.05,      # 5% 
        "10": 0.01,     # 1% after 10 mins
        "20": 0.005,    # 0.5% after 20 mins
        "40": 0         # Exit at break-even after 40 mins
    }

    stoploss = -0.10
    timeframe = '1m'

    # SMAOffset parameters
    base_nb_candles_buy = 20
    base_nb_candles_sell = 20
    low_offset = 0.98  # Buy 2% below SMA
    high_offset = 1.01 # Sell 1% above SMA

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Calculate SMAs
        dataframe['sma_buy'] = ta.SMA(dataframe, timeperiod=self.base_nb_candles_buy)
        dataframe['sma_sell'] = ta.SMA(dataframe, timeperiod=self.base_nb_candles_sell)
        
        # Required for SMAOffset logic
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
