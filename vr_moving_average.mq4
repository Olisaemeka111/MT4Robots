//+------------------------------------------------------------------+
//|                                            VR Moving Average.mq4 |
//|                              Copyright 2015, Trading-go Project. |
//|                                             http://trading-go.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Trading-go Project."
#property link      "http://trading-go.ru"
#property version   "15.12" // 14.12.2015
#property strict
#property indicator_chart_window
#property indicator_buffers 3
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
input      int                period = 20;          // Period
input      ENUM_MA_METHOD     method = MODE_EMA;    // Method
input      ENUM_APPLIED_PRICE Price  = PRICE_CLOSE; // Price
input      int                width  = 2;           // Width
input      color              UpLine = clrBlue;     // Up Line
input      color              DwLine = clrRed;      // Dw Line
double     ExtUpBuffer[];
double     ExtDnBuffer[];
double     ExtBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment("");
   SetIndexStyle(0,DRAW_LINE,0,width,UpLine);
   SetIndexStyle(1,DRAW_LINE,0,width,DwLine);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(0,ExtUpBuffer);
   SetIndexBuffer(1,ExtDnBuffer);
   SetIndexBuffer(2,ExtBuffer);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total<period-1 || period<2)
      return(0);

   int limit=0;
   if(prev_calculated==0) // проверка на первый старт
      limit=rates_total-1;
   else
      limit=rates_total-prev_calculated+1;
      
   for(int i=0;i<limit;i++)
      ExtBuffer[i]=iMA(NULL,0,period,0,method,Price,i);

   for(int i=0;i<limit-1;i++)
     {
      if(ExtBuffer[i+1]>ExtBuffer[i])
        {
         ExtDnBuffer[i]=ExtBuffer[i];
         ExtDnBuffer[i+1]=ExtBuffer[i+1];
        }
      else
        {
         ExtUpBuffer[i]=ExtBuffer[i];
         ExtUpBuffer[i+1]=ExtBuffer[i+1];
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
