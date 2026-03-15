//+------------------------------------------------------------------+
//|                                     CleanSessionVerticals.mq5  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property indicator_chart_window
#property indicator_plots 0

// Nustatymai
input string Asia_Start   = "00:00";
input string Europe_Start = "09:00";
input string USA_Start    = "15:00";

input color  Asia_Clr     = clrSkyBlue;
input color  Europe_Clr   = clrLimeGreen;
input color  USA_Clr      = clrOrangeRed;

input ENUM_LINE_STYLE LineStyle = STYLE_DOT;
input int             LineWidth = 1;

//+------------------------------------------------------------------+
int OnInit() { return(INIT_SUCCEEDED); }

//+------------------------------------------------------------------+
void OnDeinit(const int reason) { ObjectsDeleteAll(0, "VLINE_"); }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[])
{
   int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;

   for(int i = start; i < rates_total; i++)
   {
      MqlDateTime dt;
      TimeToStruct(time[i], dt);
      string currentTime = StringFormat("%02d:%02d", dt.hour, dt.min);
      string datePrefix = TimeToString(time[i], TIME_DATE);

      // Braižome linijas
      if(currentTime == Asia_Start)   CreateLine("VLINE_Asia_"   + datePrefix, time[i], Asia_Clr, "Asia");
      if(currentTime == Europe_Start) CreateLine("VLINE_Europe_" + datePrefix, time[i], Europe_Clr, "Europe");
      if(currentTime == USA_Start)    CreateLine("VLINE_USA_"    + datePrefix, time[i], USA_Clr, "USA");
   }
   return(rates_total);
}

//+------------------------------------------------------------------+
void CreateLine(string name, datetime t, color clr, string label)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_VLINE, 0, t, 0);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, LineStyle);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, LineWidth);
      ObjectSetString(0, name, OBJPROP_TOOLTIP, label + " Session Start");
   }
}
