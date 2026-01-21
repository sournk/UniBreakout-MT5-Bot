//+------------------------------------------------------------------+
//|                                                 SessionRange.mq5 |
//|                                                                  |
//|  Indicator displays High and Low of the previous trading session |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      ""
#property version   "1.01"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- Plot Top (Previous Session High)
#property indicator_label1  "SessionTop"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Plot Bottom (Previous Session Low)
#property indicator_label2  "SessionBottom"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Input parameters
input int    StartHour = 9;   // Session Start Hour (inclusive)
input int    StartMin  = 0;   // Session Start Minute (inclusive)
input int    EndHour   = 18;  // Session End Hour (exclusive)
input int    EndMin    = 0;   // Session End Minute (exclusive)

//--- Indicator buffers
double TopBuffer[];
double BottomBuffer[];

//--- Cached session data structure
struct SessionData
{
   datetime sessionDate;    // Date of session start
   double   high;           // Session high
   double   low;            // Session low
};

//--- Cache for calculated sessions
SessionData g_sessionsCache[];
int         g_cacheSize = 0;
int         g_lastProcessedBar = -1;

//+------------------------------------------------------------------+
//| Convert session time to minutes from midnight                     |
//+------------------------------------------------------------------+
int TimeToMinutes(int hour, int minute)
{
   return hour * 60 + minute;
}

//+------------------------------------------------------------------+
//| Get the date part of datetime (midnight of that day)              |
//+------------------------------------------------------------------+
datetime GetDateOnly(datetime time)
{
   return time - (time % 86400);
}

//+------------------------------------------------------------------+
//| Get session identifier date for a bar                             |
//| Returns the date when this bar's session started                  |
//+------------------------------------------------------------------+
datetime GetSessionStartDate(datetime barTime)
{
   MqlDateTime dt;
   TimeToStruct(barTime, dt);
   
   int currentMinutes = TimeToMinutes(dt.hour, dt.min);
   int startMinutes = TimeToMinutes(StartHour, StartMin);
   int endMinutes = TimeToMinutes(EndHour, EndMin);
   
   datetime dateOnly = GetDateOnly(barTime);
   
   // If session crosses midnight (e.g., 22:00 - 06:00)
   if(endMinutes <= startMinutes)
   {
      // If we're after midnight but before session end, session started yesterday
      if(currentMinutes < endMinutes)
      {
         return dateOnly - 86400;
      }
      // If we're before session start, previous session was yesterday
      else if(currentMinutes < startMinutes)
      {
         return dateOnly - 86400;
      }
   }
   else
   {
      // Normal session (same day)
      // If we're before session start, use previous day's session
      if(currentMinutes < startMinutes)
      {
         return dateOnly - 86400;
      }
   }
   
   return dateOnly;
}

//+------------------------------------------------------------------+
//| Check if given time is within session                             |
//+------------------------------------------------------------------+
bool IsWithinSession(datetime time)
{
   MqlDateTime dt;
   TimeToStruct(time, dt);
   
   int currentMinutes = TimeToMinutes(dt.hour, dt.min);
   int startMinutes = TimeToMinutes(StartHour, StartMin);
   int endMinutes = TimeToMinutes(EndHour, EndMin);
   
   // Handle session that doesn't cross midnight
   if(startMinutes < endMinutes)
   {
      return (currentMinutes >= startMinutes && currentMinutes < endMinutes);
   }
   // Handle session that crosses midnight (e.g., 22:00 - 06:00)
   else
   {
      return (currentMinutes >= startMinutes || currentMinutes < endMinutes);
   }
}

//+------------------------------------------------------------------+
//| Find session in cache by date                                     |
//+------------------------------------------------------------------+
int FindInCache(datetime sessionDate)
{
   for(int i = 0; i < g_cacheSize; i++)
   {
      if(g_sessionsCache[i].sessionDate == sessionDate)
         return i;
   }
   return -1;
}

//+------------------------------------------------------------------+
//| Add session to cache                                              |
//+------------------------------------------------------------------+
void AddToCache(datetime sessionDate, double high, double low)
{
   // Check if already exists
   int idx = FindInCache(sessionDate);
   if(idx >= 0)
   {
      g_sessionsCache[idx].high = high;
      g_sessionsCache[idx].low = low;
      return;
   }
   
   // Add new entry
   g_cacheSize++;
   ArrayResize(g_sessionsCache, g_cacheSize, 100);
   g_sessionsCache[g_cacheSize - 1].sessionDate = sessionDate;
   g_sessionsCache[g_cacheSize - 1].high = high;
   g_sessionsCache[g_cacheSize - 1].low = low;
}

//+------------------------------------------------------------------+
//| Calculate session High/Low for a specific date                    |
//+------------------------------------------------------------------+
bool CalculateSessionRange(datetime sessionDate, const datetime &time[], 
                           const double &high[], const double &low[],
                           int rates_total, double &sessionHigh, double &sessionLow)
{
   sessionHigh = EMPTY_VALUE;
   sessionLow = EMPTY_VALUE;
   
   // Build session start and end times
   int startMinutes = TimeToMinutes(StartHour, StartMin);
   int endMinutes = TimeToMinutes(EndHour, EndMin);
   
   datetime sessionStart = sessionDate + StartHour * 3600 + StartMin * 60;
   datetime sessionEnd;
   
   if(endMinutes <= startMinutes)
   {
      // Session crosses midnight
      sessionEnd = sessionDate + 86400 + EndHour * 3600 + EndMin * 60;
   }
   else
   {
      sessionEnd = sessionDate + EndHour * 3600 + EndMin * 60;
   }
   
   bool found = false;
   
   // Scan bars to find session range
   for(int i = 0; i < rates_total; i++)
   {
      datetime barTime = time[i];
      
      // Skip bars outside session time window
      if(barTime < sessionStart)
         continue;
      if(barTime >= sessionEnd)
         break;
      
      // Check if bar is within session
      if(IsWithinSession(barTime))
      {
         if(sessionHigh == EMPTY_VALUE || high[i] > sessionHigh)
            sessionHigh = high[i];
         if(sessionLow == EMPTY_VALUE || low[i] < sessionLow)
            sessionLow = low[i];
         found = true;
      }
   }
   
   return found;
}

//+------------------------------------------------------------------+
//| Get previous session High/Low with caching                        |
//+------------------------------------------------------------------+
bool GetPrevSessionRange(datetime currentSessionDate, const datetime &time[], 
                         const double &high[], const double &low[],
                         int rates_total, double &prevHigh, double &prevLow)
{
   // Try to find previous session (go back up to 7 days for weekends/holidays)
   for(int daysBack = 1; daysBack <= 7; daysBack++)
   {
      datetime prevSessionDate = currentSessionDate - daysBack * 86400;
      
      // Check cache first
      int cacheIdx = FindInCache(prevSessionDate);
      if(cacheIdx >= 0)
      {
         prevHigh = g_sessionsCache[cacheIdx].high;
         prevLow = g_sessionsCache[cacheIdx].low;
         if(prevHigh != EMPTY_VALUE && prevLow != EMPTY_VALUE)
            return true;
         continue; // This date was checked but had no data
      }
      
      // Calculate and cache
      double sessionHigh, sessionLow;
      if(CalculateSessionRange(prevSessionDate, time, high, low, rates_total, sessionHigh, sessionLow))
      {
         AddToCache(prevSessionDate, sessionHigh, sessionLow);
         prevHigh = sessionHigh;
         prevLow = sessionLow;
         return true;
      }
      else
      {
         // Cache empty result to avoid recalculating
         AddToCache(prevSessionDate, EMPTY_VALUE, EMPTY_VALUE);
      }
   }
   
   prevHigh = EMPTY_VALUE;
   prevLow = EMPTY_VALUE;
   return false;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Validate inputs
   if(StartHour < 0 || StartHour > 23 || EndHour < 0 || EndHour > 23)
   {
      Print("Error: Hour must be between 0 and 23");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   if(StartMin < 0 || StartMin > 59 || EndMin < 0 || EndMin > 59)
   {
      Print("Error: Minute must be between 0 and 59");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   //--- Indicator buffers mapping
   SetIndexBuffer(0, TopBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, BottomBuffer, INDICATOR_DATA);
   
   //--- Set empty value
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   
   //--- Reset cache
   ArrayResize(g_sessionsCache, 0);
   g_cacheSize = 0;
   g_lastProcessedBar = -1;
   
   //--- Set indicator name
   string shortName = StringFormat("SessionRange(%02d:%02d-%02d:%02d)", 
                                    StartHour, StartMin, EndHour, EndMin);
   IndicatorSetString(INDICATOR_SHORTNAME, shortName);
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total < 2)
      return 0;
   
   //--- Determine start position
   int start;
   
   if(prev_calculated == 0)
   {
      // First calculation - reset cache
      ArrayResize(g_sessionsCache, 0);
      g_cacheSize = 0;
      g_lastProcessedBar = -1;
      start = 0;
      
      // Initialize buffers
      ArrayInitialize(TopBuffer, EMPTY_VALUE);
      ArrayInitialize(BottomBuffer, EMPTY_VALUE);
   }
   else
   {
      // Only calculate new bars
      start = prev_calculated - 1;
      if(start < 0) start = 0;
   }
   
   //--- Track current session for optimization
   datetime lastSessionDate = 0;
   double currentPrevHigh = EMPTY_VALUE;
   double currentPrevLow = EMPTY_VALUE;
   
   //--- Main calculation loop (from oldest to newest)
   for(int i = start; i < rates_total; i++)
   {
      datetime barTime = time[i];
      datetime sessionDate = GetSessionStartDate(barTime);
      
      //--- Check if session changed
      if(sessionDate != lastSessionDate)
      {
         // Get previous session range
         GetPrevSessionRange(sessionDate, time, high, low, rates_total, 
                            currentPrevHigh, currentPrevLow);
         lastSessionDate = sessionDate;
      }
      
      //--- Set buffer values
      TopBuffer[i] = currentPrevHigh;
      BottomBuffer[i] = currentPrevLow;
   }
   
   g_lastProcessedBar = rates_total - 1;
   
   return rates_total;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Clean up
   ArrayFree(g_sessionsCache);
   g_cacheSize = 0;
   Comment("");
}
//+------------------------------------------------------------------+
