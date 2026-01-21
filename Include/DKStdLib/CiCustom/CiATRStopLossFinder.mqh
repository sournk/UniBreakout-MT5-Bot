//+------------------------------------------------------------------+
//|                                          CiATRStopLossFinder.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//|                                                                  |
//| Based on: https://www.mql5.com/en/forum/335975                   |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"


#define CH_ATRSTOPLOSSFINDER_INDICATOR_NAME "Market/ATR Stop Loss Finder"
#define CH_ATRSTOPLOSSFINDER_INDICATOR_BUFFER_COUNT 4
#define CH_ATRSTOPLOSSFINDER_INITIAL_BUFFER_SIZE 2048

enum ENUM_ATR_STOPLOSS_FINDER_SMOOTHING {
  RMA,
  SMA,
  EMA,
  WMA,
};

class CiATRStopLossFinder : public CiCustom {
protected:
  virtual bool      Initialize(const string symbol, 
                               const ENUM_TIMEFRAMES period, 
                               const int num_params, 
                               const MqlParam &params[]
                    ) override;  
public:
  virtual bool      Create(string _symbol, 
                           ENUM_TIMEFRAMES _period, 
                           
                           const int _length, 
                           const ENUM_ATR_STOPLOSS_FINDER_SMOOTHING _smoothing,
                           const double _multi1,
                           const double _multi2,
                           const ENUM_APPLIED_PRICE _high,
                           const ENUM_APPLIED_PRICE _low,
                           const bool _show_lines,
                           const color _low_clr,
                           const color _high_clr
                           ); 
                            
  virtual double     ATRLongSL1(int index) { return this.GetData(0, index); }
  virtual double     ATRShortSL1(int index) { return this.GetData(1, index); }  
  virtual double     ATRLongSL2(int index) { return this.GetData(2, index); }  
  virtual double     ATRShortSL2(int index) { return this.GetData(3, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiATRStopLossFinder::Create(string _symbol, 
                                 ENUM_TIMEFRAMES _period, 
                                 const int _length, 
                                 const ENUM_ATR_STOPLOSS_FINDER_SMOOTHING _smoothing,
                                 const double _multi1,
                                 const double _multi2,
                                 const ENUM_APPLIED_PRICE _high,
                                 const ENUM_APPLIED_PRICE _low,
                                 const bool _show_lines,
                                 const color _low_clr,
                                 const color _high_clr) {
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(CH_ATRSTOPLOSSFINDER_INDICATOR_NAME, TYPE_STRING)
         .Set(_length, TYPE_INT)
         .Set(_smoothing, TYPE_INT)
         .Set(_multi1, TYPE_DOUBLE)
         .Set(_multi2, TYPE_DOUBLE)
         .Set(_high, TYPE_INT)
         .Set(_low, TYPE_INT)
         .Set(_show_lines, TYPE_BOOL)
         .Set(_low_clr, TYPE_INT)
         .Set(_high_clr, TYPE_INT);
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(CH_ATRSTOPLOSSFINDER_INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiATRStopLossFinder::Initialize(const string symbol, 
                             const ENUM_TIMEFRAMES period, 
                             const int num_params, 
                             const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(CH_ATRSTOPLOSSFINDER_INDICATOR_BUFFER_COUNT))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}