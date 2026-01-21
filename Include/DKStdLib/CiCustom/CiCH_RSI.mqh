//+------------------------------------------------------------------+
//|                                                     CiCH_RSI.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//|                                                                  |
//| Based on: https://www.mql5.com/en/forum/335975                   |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"


#define INDICATOR_NAME "ch_rsi"
#define INDICATOR_BUFFER_COUNT 7
#define INITIAL_BUFFER_SIZE 2048

class CiCH_RSI : public CiCustom {
protected:
   virtual bool      Initialize(const string symbol, 
                                const ENUM_TIMEFRAMES period, 
                                const int num_params, 
                                const MqlParam &params[]
                     ) override;  
public:
   virtual bool      Create(string _symbol, 
                            ENUM_TIMEFRAMES _period, 
                            uint _IND_PER,                  // Period // 100 {x>0}
                            uint _IND_PER_RSI,              // RSI Period // 14 {x>0}
                            double _IND_UP,                   // UP // 70.0 {x>0.0}
                            double _IND_DN                   // DN // 30.0 {x>0.0}
                            ); 
                            
  virtual double     UP(int index) { return this.GetData(0, index); }
  virtual double     DN(int index) { return this.GetData(1, index); }  
  virtual double     MID(int index) { return this.GetData(2, index); }  
  virtual double     BUY(int index) { return this.GetData(4, index); }
  virtual double     SELL(int index) { return this.GetData(5, index); }  
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiCH_RSI::Create(string _symbol, 
                         ENUM_TIMEFRAMES _period, 
                         uint _IND_PER,                  // Period // 100 {x>0}
                         uint _IND_PER_RSI,              // RSI Period // 14 {x>0}
                         double _IND_UP,                   // UP // 70.0 {x>0.0}
                         double _IND_DN) {                  // DN // 30.0 {x>0.0}) {  
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(INDICATOR_NAME, TYPE_STRING)
         .Set(_IND_PER, TYPE_UINT)
         .Set(_IND_PER_RSI, TYPE_UINT)
         .Set(_IND_UP, TYPE_DOUBLE)
         .Set(_IND_DN, TYPE_DOUBLE);
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiCH_RSI::Initialize(const string symbol, 
                             const ENUM_TIMEFRAMES period, 
                             const int num_params, 
                             const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(INDICATOR_BUFFER_COUNT))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}