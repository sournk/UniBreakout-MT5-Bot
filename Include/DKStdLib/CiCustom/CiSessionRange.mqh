//+------------------------------------------------------------------+
//|                                               CiSessionRange.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"


#define INDICATOR_NAME_SessionRange "SessionRange-MT5-Ind"
#define INDICATOR_BUFFER_COUNT_SessionRange 3
#define INITIAL_BUFFER_SIZE_SessionRange 2048

enum ENUM_SESSION_MODE {
  SESSION_MODE_CURR = +0, // Current Day
  SESSION_MODE_PREV = -1, // Previuos Day
};

class CiSessionRange : public CiCustom {
protected:
   virtual bool      Initialize(const string symbol, 
                                const ENUM_TIMEFRAMES period, 
                                const int num_params, 
                                const MqlParam &params[]
                     ) override;  
public:
  virtual bool      Create(string _symbol, 
                           ENUM_TIMEFRAMES _period, 
                           uint _start_hour, 
                           uint _start_min, 
                           uint _end_hour, 
                           uint _end_min,   
                           ENUM_SESSION_MODE _mode
                           ); 
                            
  virtual double     Top(int index) { return this.GetData(0, index); }
  virtual double     Middle(int index) { return this.GetData(1, index); }
  virtual double     Bottom(int index) { return this.GetData(2, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiSessionRange::Create(string _symbol, 
                            ENUM_TIMEFRAMES _period, 
                            uint _start_hour, 
                            uint _start_min, 
                            uint _end_hour, 
                            uint _end_min,   
                            ENUM_SESSION_MODE _mode) {  
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(INDICATOR_NAME_SessionRange, TYPE_STRING)
         .Set(_start_hour, TYPE_UINT)
         .Set(_start_min, TYPE_INT)
         .Set(_end_hour, TYPE_INT)
         .Set(_end_min, TYPE_INT)
         .Set(_mode, TYPE_INT);
         
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(INITIAL_BUFFER_SIZE_SessionRange))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiSessionRange::Initialize(const string symbol, 
                             const ENUM_TIMEFRAMES period, 
                             const int num_params, 
                             const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(INDICATOR_BUFFER_COUNT_SessionRange))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}