//+------------------------------------------------------------------+
//|                                      CiPivotPointsOnCustomTF.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"


#define PivotPointsOnCustomTF_INDICATOR_NAME "PivotPointsOnCustomTF-MT5-Ind"
#define PivotPointsOnCustomTF_INDICATOR_BUFFER_COUNT 7
#define PivotPointsOnCustomTF_INITIAL_BUFFER_SIZE 2048

class CiPivotPointsOnCustomTF : public CiCustom {
protected:
   virtual bool      Initialize(const string symbol, 
                                const ENUM_TIMEFRAMES period, 
                                const int num_params, 
                                const MqlParam &params[]
                     ) override;  
public:
   virtual bool      Create(string _symbol, 
                            ENUM_TIMEFRAMES _period, 
                            ENUM_TIMEFRAMES _tf
                            ); 
                            
  virtual double     PP(int index) { return this.GetData(0, index); }
  virtual double     S1(int index) { return this.GetData(1, index); }
  virtual double     S2(int index) { return this.GetData(2, index); }
  virtual double     S3(int index) { return this.GetData(3, index); }
  virtual double     R1(int index) { return this.GetData(4, index); }
  virtual double     R2(int index) { return this.GetData(5, index); }
  virtual double     R3(int index) { return this.GetData(6, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiPivotPointsOnCustomTF::Create(string _symbol, 
                         ENUM_TIMEFRAMES _period, 
                         ENUM_TIMEFRAMES _tf) {  
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(PivotPointsOnCustomTF_INDICATOR_NAME, TYPE_STRING)
         .Set(_tf, TYPE_UINT);
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(PivotPointsOnCustomTF_INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiPivotPointsOnCustomTF::Initialize(const string symbol, 
                             const ENUM_TIMEFRAMES period, 
                             const int num_params, 
                             const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(PivotPointsOnCustomTF_INDICATOR_BUFFER_COUNT))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}