//+------------------------------------------------------------------+
//|                                            MqlParams_example.mq5 |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link      "www.reddit.com/u/nicholishenFX"
#property version   "1.00"
#include <MqlParams.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Before();
   After();
  }
//+------------------------------------------------------------------+
void After()
{
   CMqlParams params;
   int      h_MA,h_MACD;
   
   //--- method chaining to add n params *automatically sizes params array 
   params.Set(8,TYPE_INT).Set(0,TYPE_INT).Set(MODE_EMA,TYPE_INT).Set(PRICE_CLOSE,TYPE_INT);
   
   h_MA=IndicatorCreate("EURUSD",PERIOD_M15,IND_MA,params.Total(),params.params); 
   
   params.Clear()
         .Set(12,TYPE_INT)
         .Set(26,TYPE_INT)
         .Set(9,TYPE_INT)
         .Set(h_MA,TYPE_INT);
   
   h_MACD=IndicatorCreate("EURUSD",PERIOD_M15,IND_MACD,params.Total(),params.params);
   
   IndicatorRelease(h_MACD); 
   IndicatorRelease(h_MA); 

//---example get method
   
   int param2 = params.Get<int>(1);
   
   for(int i=0;i<params.Total();i++)
      Print("#",i+1," param = ",params.Get<string>(i));

//---more examples of set method chaining
   params.Clear()
         .Set("String Param",TYPE_STRING)
         .Set(0.343,TYPE_DOUBLE)
         .Set(clrBlue,TYPE_COLOR)
         .Set(MODE_EMA,TYPE_INT)
         .Set(21,TYPE_INT)
         .Set("example",TYPE_STRING);
}
//+------------------------------------------------------------------+
void Before()
{
   MqlParam params[]; 
   int      h_MA,h_MACD; 
//--- create iMA("EURUSD",PERIOD_M15,8,0,MODE_EMA,PRICE_CLOSE); 
   ArrayResize(params,4); 
//--- set ma_period 
   params[0].type         =TYPE_INT; 
   params[0].integer_value=8; 
//--- set ma_shift 
   params[1].type         =TYPE_INT; 
   params[1].integer_value=0; 
//--- set ma_method 
   params[2].type         =TYPE_INT; 
   params[2].integer_value=MODE_EMA; 
//--- set applied_price 
   params[3].type         =TYPE_INT; 
   params[3].integer_value=PRICE_CLOSE; 
//--- create MA 
   h_MA=IndicatorCreate("EURUSD",PERIOD_M15,IND_MA,4,params); 
//--- create iMACD("EURUSD",PERIOD_M15,12,26,9,h_MA); 
   ArrayResize(params,4); 
//--- set fast ma_period 
   params[0].type         =TYPE_INT; 
   params[0].integer_value=12; 
//--- set slow ma_period 
   params[1].type         =TYPE_INT; 
   params[1].integer_value=26; 
//--- set smooth period for difference 
   params[2].type         =TYPE_INT; 
   params[2].integer_value=9; 
//--- set indicator handle as applied_price 
   params[3].type         =TYPE_INT; 
   params[3].integer_value=h_MA; 
//--- create MACD based on moving average 
   h_MACD=IndicatorCreate("EURUSD",PERIOD_M15,IND_MACD,4,params); 
//--- use indicators 
//--- . . . 
//--- release indicators (first h_MACD) 
   IndicatorRelease(h_MACD); 
   IndicatorRelease(h_MA); 
}