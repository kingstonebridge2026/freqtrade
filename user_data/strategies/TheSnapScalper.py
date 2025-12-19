
from freqtrade.strategy import IStrategy
from pandas import DataFrame
import freqtrade.vendor.qtpylib.indicators as qtpylib

class TheSnapScalper(IStrategy):
    INTERFACE_VERSION = 3
    timeframe = '1m'
    can_short = False
    stoploss = -0.10
    minimal_roi = {"0": 0.05}

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe['rsi'] = qtpylib.rsi(dataframe['close'], window=14)
        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[(dataframe['rsi'] < 30), 'enter_long'] = 1
        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[(dataframe['rsi'] > 70), 'exit_long'] = 1
        return dataframe
