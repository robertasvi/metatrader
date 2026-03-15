#property version   "1.00"
#property indicator_chart_window

// Indikatorių „rankenos“
int handleEMA200_H1;
int handleEMA50_H1;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Sukuriame H1 laiko intervalo EMA indikatorius
   handleEMA200_H1 = iMA(_Symbol, PERIOD_H1, 200, 0, MODE_EMA, PRICE_CLOSE);
   handleEMA50_H1  = iMA(_Symbol, PERIOD_H1, 50, 0, MODE_EMA, PRICE_CLOSE);

   if(handleEMA200_H1 == INVALID_HANDLE || handleEMA50_H1 == INVALID_HANDLE)
   {
      Print("Klaida: Nepavyko užkrauti H1 EMA indikatorių.");
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Main Calculation (Tikrinama kiekvienu kainos pokyčiu)            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   double ema200H1[], ema50H1[];

   // Kopijuojame paskutines reikšmes (indeksas 0 yra naujausia užsidariusi žvakė arba esama)
   if(CopyBuffer(handleEMA200_H1, 0, 0, 1, ema200H1) < 0 ||
      CopyBuffer(handleEMA50_H1, 0, 0, 1, ema50H1) < 0) return(0);

   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   string signal = "NO TREND";
   color textColor = clrGray;

   // 1 sąlyga: Kaina virš EMA 200 IR virš EMA 50 -> STIPRUS PIRKIMAS
   if(currentPrice > ema200H1[0] && currentPrice > ema50H1[0])
   {
      signal = "BULLISH TREND (BUY)";
      textColor = clrDodgerBlue;
   }
   // 2 sąlyga: Kaina po EMA 200 IR po EMA 50 -> STIPRUS PARDAVIMAS
   else if(currentPrice < ema200H1[0] && currentPrice < ema50H1[0])
   {
      signal = "BEARISH TREND (SELL)";
      textColor = clrTomato;
   }

   UpdateLabel(signal, textColor);

   return(rates_total);
}

// Pagalbinė funkcija teksto atvaizdavimui
void UpdateLabel(string text, color textColor)
{
   string objName = "DayTrendLabel";
   if(ObjectFind(0, objName) < 0)
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);

   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, 50);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 16);
}

void OnDeinit(const int reason)
{
   ObjectDelete(0, "DayTrendLabel");
}
