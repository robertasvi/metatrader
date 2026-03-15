#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plot DailyHigh
#property indicator_label1  "Daily High"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- plot DailyLow
#property indicator_label2  "Daily Low"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrTomato
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- Buffers
double HighBuffer[];
double LowBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, HighBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, LowBuffer, INDICATOR_DATA);

   IndicatorSetString(INDICATOR_SHORTNAME, "Daily Tunnel");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   // We start from the previous calculation point or the beginning
   int start = prev_calculated - 1;
   if(start < 0) start = 0;

   for(int i = start; i < rates_total; i++)
   {
      // Get the start of the day for the current bar being processed
      datetime day_start = time[i] - (time[i] % 86400);

      // Find the index of the first bar of the current day
      int first_bar_of_day = i;
      while(first_bar_of_day > 0 && time[first_bar_of_day] >= day_start)
      {
         first_bar_of_day--;
      }

      // Calculate High and Low from the start of the day to the current bar
      double daily_h = high[i];
      double daily_l = low[i];

      for(int j = i; j > first_bar_of_day && time[j] >= day_start; j--)
      {
         if(high[j] > daily_h) daily_h = high[j];
         if(low[j] < daily_l)  daily_l = low[j];
      }

      HighBuffer[i] = daily_h;
      LowBuffer[i] = daily_l;
   }

   return(rates_total);
}
