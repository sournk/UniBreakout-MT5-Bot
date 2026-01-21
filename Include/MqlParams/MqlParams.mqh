//+------------------------------------------------------------------+
//|                                                    MqlParams.mqh |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link      "www.reddit.com/u/nicholishenFX"
#property version   "1.00"
#property strict
#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMqlParams : public CObject
{
protected:
   int               m_data_total;
public:
                     CMqlParams();
   MqlParam          params[];
   
   template<typename T>
   CMqlParams*       Set(T data,ENUM_DATATYPE type = TYPE_LONG);
   
   template<typename T>
   T                 Get(int index);
   
   ENUM_DATATYPE     Type(int index){ return params[index].type; }
   int               Total() { return m_data_total; }
   CMqlParams*       Clear() { ::ArrayFree(params); m_data_total = 0; return &this;}
                     
protected:
   CMqlParams*       Long(long,ENUM_DATATYPE);
   CMqlParams*       String(string,ENUM_DATATYPE);
   CMqlParams*       Double(double,ENUM_DATATYPE);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMqlParams::CMqlParams():m_data_total(0)
{
}
//+------------------------------------------------------------------+
template<typename T>
CMqlParams*  CMqlParams::Set(T param,ENUM_DATATYPE type = TYPE_LONG)
{
   if(type == TYPE_FLOAT || type == TYPE_DOUBLE)
      return Double((double)param,type);
   if(type == TYPE_STRING)
      return String((string)param,type);
   return Long((long)param,type);
}
//+------------------------------------------------------------------+
template<typename T>
T CMqlParams::Get(int index)
{
   if(params[index].type == TYPE_FLOAT || params[index].type == TYPE_DOUBLE)
      return (T)params[index].double_value;
   if(params[index].type == TYPE_STRING)
      return (T)params[index].string_value;
   return (T)params[index].integer_value;
}
//+------------------------------------------------------------------+
CMqlParams* CMqlParams::Long(long param,ENUM_DATATYPE type)
{
   int index = ::ArrayResize(params,++m_data_total)-1;
   params[index].type = type;
   params[index].integer_value = param; 
   return &this;
}
//+------------------------------------------------------------------+
CMqlParams* CMqlParams::String(string param,ENUM_DATATYPE type)
{
   int index = ::ArrayResize(params,++m_data_total)-1;
   params[index].type = type;
   params[index].string_value = param; 
   return &this;
}
//+------------------------------------------------------------------+
CMqlParams* CMqlParams::Double(double param,ENUM_DATATYPE type)
{
   int index = ::ArrayResize(params,++m_data_total)-1;
   params[index].type = type;
   params[index].double_value = param; 
   return &this;
}