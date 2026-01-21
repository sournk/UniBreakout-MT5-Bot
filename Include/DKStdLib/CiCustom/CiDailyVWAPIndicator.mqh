//+------------------------------------------------------------------+
//|                                         CiDailyVWAPIndicator.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"

#define DailyVWAPIndicator_INDICATOR_NAME "Market/Daily VWAP Indicator"
#define DailyVWAPIndicator_INDICATOR_BUFFER_COUNT 1
#define DailyVWAPIndicator_INITIAL_BUFFER_SIZE 2048

class CiDailyVWAPIndicator : public CiCustom {
protected:
  virtual bool      Initialize(const string symbol, 
                               const ENUM_TIMEFRAMES period, 
                               const int num_params, 
                               const MqlParam &params[]
                    ) override;  
public:
  virtual bool      Create(string _symbol, 
                           ENUM_TIMEFRAMES _period,
                           ENUM_APPLIED_PRICE _price_type,
                           ENUM_APPLIED_VOLUME _volume_type
                           ); 
                            
  virtual double    Main(int index) { return this.GetData(0, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiDailyVWAPIndicator::Create(string _symbol, 
                                  ENUM_TIMEFRAMES _period, 
                                  ENUM_APPLIED_PRICE _price_type,
                                  ENUM_APPLIED_VOLUME _volume_type
                                  ) {
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(DailyVWAPIndicator_INDICATOR_NAME, TYPE_STRING)
         .Set(_price_type, TYPE_UINT)
         .Set(_volume_type, TYPE_UINT);
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(DailyVWAPIndicator_INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiDailyVWAPIndicator::Initialize(const string symbol, 
                             const ENUM_TIMEFRAMES period, 
                             const int num_params, 
                             const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(DailyVWAPIndicator_INDICATOR_BUFFER_COUNT))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}