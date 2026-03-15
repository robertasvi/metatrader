//+------------------------------------------------------------------+
//|                                     ForexResistanceLevel.mq5     |
//|                                  Copyright 2024, Trading AI      |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      "https://www.mql5.com"
#property version   "1.20"
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_NONE
#property indicator_type2   DRAW_NONE

// Įvesties parametrai
input int InpLookback = 20;            // Žvakių skaičius paieškai
input color InpResColor = clrRed;      // Pasipriešinimo spalva
input color InpSupColor = clrLime;     // Palaikymo spalva
input int InpWidth = 2;                // Linijų storis
input int InpFontSize = 9;             // Teksto dydis
input color InpTextColor = clrWhite;   // Teksto spalva

// Buferiai
double resBuffer[];
double supBuffer[];

// Kintamieji
double lastResistance = 0;
double lastSupport = 0;

int OnInit()
{
   SetIndexBuffer(0, resBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, supBuffer, INDICATOR_DATA);
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
   if(rates_total < InpLookback * 2) return(0);

   int start = rates_total - InpLookback * 2;

   // 1. Surandame Pasipriešinimą
   int highestIdx = ArrayMaximum(high, start, InpLookback * 2);
   if(highestIdx != -1)
   {
      double currentHigh = high[highestIdx];
      if(currentHigh != lastResistance)
      {
         lastResistance = currentHigh;
         UpdateLine("ResistanceLine", lastResistance, InpResColor);
      }
   }

   // 2. Surandame Palaikymą
   int lowestIdx = ArrayMinimum(low, start, InpLookback * 2);
   if(lowestIdx != -1)
   {
      double currentLow = low[lowestIdx];
      if(currentLow != lastSupport)
      {
         lastSupport = currentLow;
         UpdateLine("SupportLine", lastSupport, InpSupColor);
      }
   }

   // 3. Atnaujiname atstumo rodymą
   UpdateDistanceLabel();

   return(rates_total);
}

void UpdateLine(string name, double price, color clr)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, InpWidth);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   else
   {
      ObjectMove(0, name, 0, 0, price);
   }
}

void UpdateDistanceLabel()
{
   if(lastResistance == 0 || lastSupport == 0 || lastSupport == lastResistance) return;

   // 1. Skaičiuojame pipsus
   double pipsValue = (lastResistance - lastSupport) / (_Digits == 3 || _Digits == 5 ? 10 * _Point : _Point);

   // 2. Skaičiuojame procentinį skirtumą (nuo palaikymo lygio)
   double percentage = ((lastResistance - lastSupport) / lastSupport) * 100;

   string labelName = "PipsDistance";
   // Suformuojame tekstą: "120.5 (0.85%)"
   string displayText = DoubleToString(pipsValue, 1) + " " + DoubleToString(percentage, 2) + "%";

   if(ObjectFind(0, labelName) < 0)
   {
      ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 65);
      ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, 4);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, InpTextColor);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetString(0, labelName, OBJPROP_FONT, "Trebuchet MS");
   }

   ObjectSetString(0, labelName, OBJPROP_TEXT, displayText);
   ChartRedraw();
}


void OnDeinit(const int reason)
{
   ObjectDelete(0, "ResistanceLine");
   ObjectDelete(0, "SupportLine");
   ObjectDelete(0, "PipsDistance");
}
