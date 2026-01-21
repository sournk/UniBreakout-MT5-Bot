//+------------------------------------------------------------------+
//|                                                        CiMAChannel.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//|                                                                  |
//| Based on: https://www.mql5.com/en/forum/335975                   |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"


#define INDICATOR_NAME "MAChannel-MT5-Ind"
#define INDICATOR_BUFFER_COUNT 3
#define INITIAL_BUFFER_SIZE 2048

class CiMAChannel : public CiCustom {
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
                            ENUM_APPLIED_PRICE _apply_to,
                            uint _offset_top_pnt,
                            uint _offset_bot_pnt
                            ); 
                            
  virtual double     MA(int index) { return this.GetData(0, index); }
  virtual double     MATop(int index) { return this.GetData(1, index); }
  virtual double     MABottom(int index) { return this.GetData(2, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiMAChannel::Create(string _symbol, 
                         ENUM_TIMEFRAMES _period, 
                         uint _ma_period, 
                         uint _ma_shift, 
                         ENUM_MA_METHOD _ma_method,
                         ENUM_APPLIED_PRICE _apply_to,
                         uint _offset_top_pnt,
                         uint _offset_bot_pnt) {  
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(INDICATOR_NAME, TYPE_STRING)
         .Set(_ma_period, TYPE_UINT)
         .Set(_ma_shift, TYPE_UINT)
         .Set(_ma_method, TYPE_INT)
         .Set(_apply_to, TYPE_INT)
         .Set(_offset_top_pnt, TYPE_UINT)
         .Set(_offset_bot_pnt, TYPE_UINT);
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
bool CiMAChannel::Initialize(const string symbol, 
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