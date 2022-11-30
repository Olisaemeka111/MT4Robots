//+------------------------------------------------------------------+
//|                                                   UpDownBars.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window

#property indicator_buffers 1               // Number of buffers
#property indicator_color1 Red

extern int period = 20;

double UpDown[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
    SetIndexBuffer(0,UpDown);
    SetIndexStyle (0,DRAW_HISTOGRAM);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if(Bars<=period) return(0);
   
   int i;
   int    counted_bars=IndicatorCounted();
   
   double bar, ups, downs, upsDivide, downsDivide;
   int upsCount, downsCount;
   
   int limit=Bars-counted_bars;
//---- macd counted in the 1-st buffer
   for(i=0; i<limit; i++)
   {
      ups = 0;
      downs = 0;
      bar = 0;
      upsCount = 0;
      downsCount = 0;
      upsDivide=0;
      downsDivide=0;
      for(int j=period;j>=0;j--)
      {
         bar=(Close[i+j]-Open[i+j])*100000;
         if(bar>0)
         {
            ups+=(MathSqrt(bar)*((period+1-j)));
            upsCount++;
         }
         if(bar<0)
         {
            downs+=(MathSqrt(-bar)*((period+1-j)));
            downsCount++;
         }
      }
      if(upsCount!=0)
         upsDivide = ups/upsCount;
         
      if(downsCount!=0)
         downsDivide = downs/downsCount;
         
      UpDown[i]=NormalizeDouble(((upsDivide)-(downsDivide)),3);
   }
   return(0);
}
//+------------------------------------------------------------------+