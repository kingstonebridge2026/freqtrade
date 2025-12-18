from freqtrade.strategy import IStrategy
from pandas import DataFrame
import talib.abstract as ta
import freqtrade.vendor.qtpylib.indicators as qtpylib

class TheSnapScalper(IStrategy):
    INTERFACE_VERSION = 3
    timeframe = '1m' # Set to 1m for High Frequency

    # ROI: Very aggressive. Exit at 1% or after 5 mins to free up slots.
    minimal_roi = {
        "0": 0.01,      # 1% profit
        "5": 0.005      # 0.5% profit after 5 mins
    }
    
    stoploss = -0.015   # 1.5% Stoploss

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Use a wide Bollinger Band (2.5 Std Dev) to find true extremes
        bollinger = qtpylib.bollinger_bands(dataframe['close'], window=20, stds=2.5)
        dataframe['bb_lower'] = bollinger['lower']
        dataframe['bb_mid'] = bollinger['mid']
        
        # Fast RSI (7) to capture micro-momentum
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=7)
        
        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['close'] < dataframe['bb_lower']) &  # Price touched extreme bottom
                (dataframe['rsi'] < 20) &                      # Deeply oversold
                (dataframe['close'] > dataframe['close'].shift(1)) # Price is ticking up
            ),
            'enter_long'] = 1
        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['close'] > dataframe['bb_mid']) |    # Exit at the mean price
                (dataframe['rsi'] > 70)                         # Or if momentum spikes
            ),
            'exit_long'] = 1
        return dataframe
