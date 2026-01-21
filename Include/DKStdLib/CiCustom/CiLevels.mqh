//+------------------------------------------------------------------+
//|                                                   CiLevels.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//|                                                                  |
//| Based on: https://www.mql5.com/en/forum/335975                   |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"

#define LEVELS_INDICATOR_NAME "levels"
#define LEVELS_INDICATOR_BUFFER_COUNT 1
#define LEVELS_INITIAL_BUFFER_SIZE 2048

class CiLevels : public CiCustom {
protected:
  virtual bool      Initialize(const string symbol, 
                               const ENUM_TIMEFRAMES period, 
                               const int num_params, 
                               const MqlParam &params[]
                    ) override;  
public:
  virtual bool      Create(string _symbol, 
                           ENUM_TIMEFRAMES _period,
                           uint _IND_LEV_PER
                           ); 
                            
  virtual double     Levelel(int index) { return this.GetData(0, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiLevels::Create(string _symbol, 
                         ENUM_TIMEFRAMES _period, 
                         uint _IND_LEV_PER) {
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(LEVELS_INDICATOR_NAME, TYPE_STRING)
         .Set(_IND_LEV_PER, TYPE_UINT);
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(LEVELS_INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiLevels::Initialize(const string symbol, 
                             const ENUM_TIMEFRAMES period, 
                             const int num_params, 
                             const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(LEVELS_INDICATOR_BUFFER_COUNT))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}