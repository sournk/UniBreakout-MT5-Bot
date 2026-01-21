//+------------------------------------------------------------------+
//|                                        CiCustomMAInputsColor.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"


#define MACUSTOMINPUTCOLOR_INDICATOR_NAME "Custom Moving Average Input Color"
#define MACUSTOMINPUTCOLOR_INDICATOR_BUFFER_COUNT 1
#define MACUSTOMINPUTCOLOR_INITIAL_BUFFER_SIZE 2048

class CiCustomMAInputColor : public CiCustom {
protected:
   virtual bool      Initialize(const string symbol, 
                                const ENUM_TIMEFRAMES period, 
                                const int num_params, 
                                const MqlParam &params[]
                     ) override;  
public:
   virtual bool      Create(string _symbol, 
                            ENUM_TIMEFRAMES _period, 
                            uint _ma_period, 
                            uint _ma_shift, 
                            ENUM_MA_METHOD _ma_method,
                            color _clr
                            ); 
                            
  virtual double     Main(int index) { return this.GetData(0, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiCustomMAInputColor::Create(string _symbol, 
                         ENUM_TIMEFRAMES _period, 
                         uint _ma_period, 
                         uint _ma_shift, 
                         ENUM_MA_METHOD _ma_method,
                         color _clr) {  
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(MACUSTOMINPUTCOLOR_INDICATOR_NAME, TYPE_STRING)
         .Set(_ma_period, TYPE_UINT)
         .Set(_ma_shift, TYPE_UINT)
         .Set(_ma_method, TYPE_INT)
         .Set(_clr, TYPE_COLOR);
         
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
      
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(MACUSTOMINPUTCOLOR_INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiCustomMAInputColor::Initialize(const string symbol, 
                             const ENUM_TIMEFRAMES period, 
                             const int num_params, 
                             const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(MACUSTOMINPUTCOLOR_INDICATOR_BUFFER_COUNT))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}