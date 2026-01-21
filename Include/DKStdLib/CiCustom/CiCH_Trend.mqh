//+------------------------------------------------------------------+
//|                                                   CiCH_Trend.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//|                                                                  |
//| Based on: https://www.mql5.com/en/forum/335975                   |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"


#define CH_TREND_INDICATOR_NAME "ch_trend"
#define CH_TREND_INDICATOR_BUFFER_COUNT 6
#define CH_TREND_INITIAL_BUFFER_SIZE 2048

class CiCH_Trend : public CiCustom {
protected:
  virtual bool      Initialize(const string symbol, 
                               const ENUM_TIMEFRAMES period, 
                               const int num_params, 
                               const MqlParam &params[]
                    ) override;  
public:
  virtual bool      Create(string _symbol, 
                           ENUM_TIMEFRAMES _period,
                           uint _IND_CH_PER
                           ); 
                            
  virtual double     Signal(int index) { return this.GetData(0, index); }
  virtual double     Color(int index) { return this.GetData(1, index); }  
  virtual double     Upper(int index) { return this.GetData(2, index); }  
  virtual double     Lower(int index) { return this.GetData(3, index); }
  virtual double     Max(int index) { return this.GetData(4, index); }  
  virtual double     Min(int index) { return this.GetData(5, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiCH_Trend::Create(string _symbol, 
                         ENUM_TIMEFRAMES _period, 
                         uint _IND_CH_PER) {
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(CH_TREND_INDICATOR_NAME, TYPE_STRING)
         .Set(_IND_CH_PER, TYPE_UINT);
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(CH_TREND_INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiCH_Trend::Initialize(const string symbol, 
                             const ENUM_TIMEFRAMES period, 
                             const int num_params, 
                             const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(CH_TREND_INDICATOR_BUFFER_COUNT))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}