//+------------------------------------------------------------------+
//|                                                     ATRRange.mq5 |
//|                                    Copyright 2026, Your Name     |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "ATR Range indicator with 3 levels"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6

//--- Plot Top1
#property indicator_label1  "Top1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- Plot Bottom1
#property indicator_label2  "Bottom1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- Plot Top2
#property indicator_label3  "Top2"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- Plot Bottom2
#property indicator_label4  "Bottom2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- Plot Top3
#property indicator_label5  "Top3"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1

//--- Plot Bottom3
#property indicator_label6  "Bottom3"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

//--- Input parameters
input int    InpATRPeriod = 14;    // ATR Period
input double InpMulti1    = 1.0;   // Multi1 (multiplier for buffers 1)
input double InpMulti2    = 2.0;   // Multi2 (multiplier for buffers 2)
input double InpMulti3    = 3.0;   // Multi3 (multiplier for buffers 3)

//--- Indicator buffers
double Top1Buffer[];
double Bottom1Buffer[];
double Top2Buffer[];
double Bottom2Buffer[];
double Top3Buffer[];
double Bottom3Buffer[];

//--- ATR handle
int atrHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Validate inputs
   if(InpATRPeriod < 1)
   {
      Print("Error: ATR Period must be >= 1");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   //--- Create ATR indicator handle
   atrHandle = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
   if(atrHandle == INVALID_HANDLE)
   {
      Print("Error creating ATR indicator handle");
      return(INIT_FAILED);
   }
   
   //--- Set indicator buffers
   SetIndexBuffer(0, Top1Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, Bottom1Buffer, INDICATOR_DATA);
   SetIndexBuffer(2, Top2Buffer, INDICATOR_DATA);
   SetIndexBuffer(3, Bottom2Buffer, INDICATOR_DATA);
   SetIndexBuffer(4, Top3Buffer, INDICATOR_DATA);
   SetIndexBuffer(5, Bottom3Buffer, INDICATOR_DATA);
   
   //--- Set indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME, 
      StringFormat("ATRRange(%d, %.2f, %.2f, %.2f)", 
         InpATRPeriod, InpMulti1, InpMulti2, InpMulti3));
   
   //--- Set number of digits
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release ATR handle
   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);
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
   //--- Check for minimum bars
   if(rates_total < InpATRPeriod)
      return(0);
   
   //--- Get ATR values
   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, false);
   
   int copied = CopyBuffer(atrHandle, 0, 0, rates_total, atrBuffer);
   if(copied <= 0)
   {
      Print("Error copying ATR buffer: ", GetLastError());
      return(0);
   }
   
   //--- Calculate starting position
   int start;
   if(prev_calculated == 0)
      start = InpATRPeriod - 1;
   else
      start = prev_calculated - 1;
   
   //--- Main calculation loop
   for(int i = start; i < rates_total; i++)
   {
      double atr = atrBuffer[i];
      double closePrice = close[i];
      
      //--- Calculate Top/Bottom levels
      Top1Buffer[i]    = closePrice + atr * InpMulti1;
      Bottom1Buffer[i] = closePrice - atr * InpMulti1;
      
      Top2Buffer[i]    = closePrice + atr * InpMulti2;
      Bottom2Buffer[i] = closePrice - atr * InpMulti2;
      
      Top3Buffer[i]    = closePrice + atr * InpMulti3;
      Bottom3Buffer[i] = closePrice - atr * InpMulti3;
   }
   
   //--- Return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
