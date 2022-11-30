//+------------------------------------------------------------------+
//|                                                  Velocity_v2.mq4 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//----
#property indicator_separate_window
#property indicator_buffers 2
//----
#property indicator_color1 LightBlue
#property indicator_color2 Tomato
#property indicator_width1 2
#property indicator_width2 1
#property indicator_style2 2
//---- input parameters
extern int VelocityPeriod  =8;
extern int Slow            =5;
extern int MA_Mode         =1;
//---- indicator buffers
double FastBuffer[];
double SlowBuffer[];
double Vel[];
double AvgVel[];
double DbAvgVel[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(5);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(0,FastBuffer);
   SetIndexBuffer(1,SlowBuffer);
   SetIndexBuffer(2,Vel);
   SetIndexBuffer(3,AvgVel);
   SetIndexBuffer(4,DbAvgVel);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   short_name="Velocity("+VelocityPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Fast");
   SetIndexLabel(1,"Slow");
//----
   SetIndexDrawBegin(0,3*VelocityPeriod+Slow);
   SetIndexDrawBegin(1,3*VelocityPeriod+Slow);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Velocity_v2                                                      |
//+------------------------------------------------------------------+
int start()
  {
   int shift;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;
//----
   for(shift=limit;shift>=0;shift--)
      Vel[shift]=(Close[shift]-Close[shift+1])/Point;
   for(shift=limit;shift>=0;shift--)
      AvgVel[shift]=iMAOnArray(Vel,0,VelocityPeriod,0,MA_Mode,shift);
   for(shift=limit;shift>=0;shift--)
      DbAvgVel[shift]=iMAOnArray(AvgVel,0,VelocityPeriod,0,MA_Mode,shift);
   for(shift=limit;shift>=0;shift--)
      FastBuffer[shift]=iMAOnArray(DbAvgVel,0,VelocityPeriod,0,MA_Mode,shift);
   for(shift=limit;shift>=0;shift--)
      SlowBuffer[shift]=iMAOnArray(FastBuffer,0,Slow,0,MA_Mode,shift);
//----
   return(0);
  }
//+------------------------------------------------------------------+
