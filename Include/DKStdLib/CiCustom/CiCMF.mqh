//+------------------------------------------------------------------+
//|                                                        CiCMF.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//|                                                                  |
//| Based on: https://www.mql5.com/en/forum/335975                   |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "Include/MqlParams/MqlParams.mqh"


#define INDICATOR_NAME "ChaikinMoneyFlow-MT5-Ind"
#define INDICATOR_BUFFER_COUNT 1
#define INITIAL_BUFFER_SIZE 2048

class CiCMF : public CiCustom {
protected:
   virtual bool      Initialize(const string symbol, 
                                const ENUM_TIMEFRAMES period, 
                                const int num_params, 
                                const MqlParam &params[]
                     ) override;  
public:
   virtual bool      Create(string _symbol, 
                            ENUM_TIMEFRAMES period, 
                            uint _ma_period, 
                            ENUM_APPLIED_VOLUME _vol); 
                            
  virtual double     Main(int index) { return this.GetData(0, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiCMF::Create(string _symbol, 
                          ENUM_TIMEFRAMES period, 
                          uint _ma_period, 
                          ENUM_APPLIED_VOLUME _vol) {
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(INDICATOR_NAME, TYPE_STRING)
         .Set(_ma_period, TYPE_UINT)
         .Set(_vol, TYPE_INT);
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiCMF::Initialize(const string symbol, 
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