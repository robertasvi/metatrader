//+------------------------------------------------------------------+
//|                                         CleanSessionsVisual.mq5  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property indicator_chart_window
#property indicator_plots 0  // Nurodome, kad linijų nebus, tik objektai

// Sesijų nustatymai (Serverio laikas)
input string Asia_Start   = "00:00";
input string Asia_End     = "09:00";
input color  Asia_Color   = clrSkyBlue;

input string Europe_Start = "09:00";
input string Europe_End   = "18:00";
input color  Europe_Color = clrLightGreen;

input string USA_Start    = "15:00";
input string USA_End      = "23:59";
input color  USA_Color    = clrLightCoral;

input int    Transparency = 180; // Stačiakampių užpildymas (0-255)

//+------------------------------------------------------------------+
int OnInit() {
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, "SESS_"); // Išvalome grafiką išjungus
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[])
{
   // Skaičiuojame tik paskutinius 500 barų, kad neapkrautume PC
   int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;
   if(rates_total - start > 500) start = rates_total - 500;

   for(int i = start; i < rates_total; i++)
   {
      MqlDateTime dt;
      TimeToStruct(time[i], dt);
      string barTimeStr = StringFormat("%02d:%02d", dt.hour, dt.min);
      string dateStr = StringFormat("%04d.%02d.%02d", dt.year, dt.mon, dt.day);

      CheckAndDraw("Asia",   Asia_Start,   Asia_End,   Asia_Color,   time[i], high[i], low[i], dateStr);
      CheckAndDraw("Europe", Europe_Start, Europe_End, Europe_Color, time[i], high[i], low[i], dateStr);
      CheckAndDraw("USA",    USA_Start,    USA_End,    USA_Color,    time[i], high[i], low[i], dateStr);
   }
   return(rates_total);
}

//+------------------------------------------------------------------+
void CheckAndDraw(string name, string start, string end, color clr, datetime barTime, double hi, double lo, string date)
{
   string barTimeStr = TimeToString(barTime, TIME_MINUTES);

   if(barTimeStr >= start && barTimeStr <= end)
   {
      string objName = "SESS_" + name + "_" + date;

      if(ObjectFind(0, objName) < 0)
      {
         ObjectCreate(0, objName, OBJ_RECTANGLE, 0, barTime, hi, barTime, lo);
         ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, objName, OBJPROP_FILL, true);
         ObjectSetInteger(0, objName, OBJPROP_BACK, true);
         ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      }
      else
      {
         // Atnaujiname esamos sesijos rėmus
         double currentHi = ObjectGetDouble(0, objName, OBJPROP_PRICE, 0);
         double currentLo = ObjectGetDouble(0, objName, OBJPROP_PRICE, 1);
         datetime timeStart = (datetime)ObjectGetInteger(0, objName, OBJPROP_TIME, 0);

         ObjectSetInteger(0, objName, OBJPROP_TIME, 1, barTime);
         ObjectSetDouble(0, objName, OBJPROP_PRICE, 0, MathMax(currentHi, hi));
         ObjectSetDouble(0, objName, OBJPROP_PRICE, 1, MathMin(currentLo, lo));
      }
   }
}
