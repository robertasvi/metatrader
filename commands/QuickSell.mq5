#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                     QuickSell.mq5|
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

input double Lots = 0.20;
input int StopLoss = 80;
input int TakeProfit = 160;

void OnStart()
{
   CTrade trade;
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = price + StopLoss * _Point;
   double tp = price - TakeProfit * _Point;

   if(!trade.Sell(Lots, _Symbol, price, sl, tp))
      Print("Error opening sell position: ", trade.ResultRetcodeDescription());
}
