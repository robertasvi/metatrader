#property copyright ""
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "VolumeMomentumBuy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "VolumeMomentumSell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrTomato
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input int    MomentumPeriod      = 10;    // Bars used for momentum comparison
input int    VolumeMAPeriod      = 20;    // Period for average tick volume
input double MinMomentumPoints   = 120.0; // Minimum momentum in points
input double MinVolumeRatio      = 1.50;  // Current volume / avg volume
input bool   UseClosedBar        = true;  // If true, signal only on closed bars
input int    ArrowOffsetPoints   = 50;    // Arrow distance from candle
input bool   EnablePopupAlert    = true;
input bool   EnablePushAlert     = false;
input bool   EnableEmailAlert    = false;

double BuySignalBuffer[];
double SellSignalBuffer[];

double GetVolumeAverage(const long &tick_volume[], const int index, const int period, const int rates_total)
{
   double sum = 0.0;
   int count = 0;

   for(int j = index; j < index + period && j < rates_total; j++)
   {
      sum += (double)tick_volume[j];
      count++;
   }

   if(count == 0)
      return 0.0;

   return sum / (double)count;
}

void SendSignalAlert(const bool isBuy, const string symbol, const int timeframe, const datetime barTime)
{
   string direction = isBuy ? "BUY" : "SELL";
   string msg = symbol + " " + direction + " volume+momentum signal on TF " + IntegerToString(timeframe) +
                " at " + TimeToString(barTime, TIME_DATE | TIME_MINUTES);

   if(EnablePopupAlert)
      Alert(msg);

   if(EnablePushAlert)
      SendNotification(msg);

   if(EnableEmailAlert)
      SendMail("MT5 Volume+Momentum Signal", msg);
}

int OnInit()
{
   SetIndexBuffer(0, BuySignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SellSignalBuffer, INDICATOR_DATA);

   ArraySetAsSeries(BuySignalBuffer, true);
   ArraySetAsSeries(SellSignalBuffer, true);

   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME, "Volume+Momentum Signal");

   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int requiredBars = MathMax(MomentumPeriod, VolumeMAPeriod) + 2;
   if(rates_total < requiredBars)
      return 0;

   ArrayInitialize(BuySignalBuffer, EMPTY_VALUE);
   ArrayInitialize(SellSignalBuffer, EMPTY_VALUE);

   int signalShift = UseClosedBar ? 1 : 0;
   int oldestIndex = rates_total - 1 - MathMax(MomentumPeriod, VolumeMAPeriod);

   for(int i = oldestIndex; i >= signalShift; i--)
   {
      double avgVolume = GetVolumeAverage(tick_volume, i, VolumeMAPeriod, rates_total);
      if(avgVolume <= 0.0)
         continue;

      double volumeRatio = (double)tick_volume[i] / avgVolume;
      double momentumPoints = (close[i] - close[i + MomentumPeriod]) / _Point;

      if(volumeRatio >= MinVolumeRatio)
      {
         if(momentumPoints >= MinMomentumPoints)
            BuySignalBuffer[i] = low[i] - (ArrowOffsetPoints * _Point);
         else if(momentumPoints <= -MinMomentumPoints)
            SellSignalBuffer[i] = high[i] + (ArrowOffsetPoints * _Point);
      }
   }

   static datetime lastAlertBarTime = 0;
   if(signalShift < rates_total)
   {
      bool buySignal = (BuySignalBuffer[signalShift] != EMPTY_VALUE);
      bool sellSignal = (SellSignalBuffer[signalShift] != EMPTY_VALUE);

      if((buySignal || sellSignal) && time[signalShift] != lastAlertBarTime)
      {
         SendSignalAlert(buySignal, _Symbol, Period(), time[signalShift]);
         lastAlertBarTime = time[signalShift];
      }
   }

   return rates_total;
}

