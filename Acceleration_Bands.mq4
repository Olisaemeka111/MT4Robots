//+------------------------------------------------------------------+
//|                                      i_fm_Acceleration_Bands.mq4 |
//|                                                                * |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright "*"
#property link      "*"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
//---- input parameters
extern double    Factor=2;// ширина полос
extern int       smPeriod=20;// период сглаживания полос
extern int       smMethod=0;// метод сглаживания полос. 0 - SMA, 1 - EMA, 2 - SMMA, 3 - LWMA
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(6);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer6);  
  
   SetIndexBuffer(3,ExtMapBuffer3);
   SetIndexBuffer(4,ExtMapBuffer4);  
   SetIndexBuffer(5,ExtMapBuffer5); 
  
   SetIndexDrawBegin(0,smPeriod);
   SetIndexDrawBegin(1,smPeriod);  
   SetIndexDrawBegin(2,smPeriod);  
  
   SetIndexLabel(0,"AB Upper");
   SetIndexLabel(1,"AB Lower");  
   SetIndexLabel(2,"AB Central");    
//----
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
   int    limit=Bars-IndicatorCounted();  
  
   for(int i=limit-1;i>=0;i--){
      ExtMapBuffer3[i]=High[i]*(1+Factor*(High[i]-Low[i])/((High[i]+Low[i])/2));
      ExtMapBuffer4[i]=Low[i]*(1-Factor*(High[i]-Low[i])/((High[i]+Low[i])/2));
      ExtMapBuffer5[i]=(ExtMapBuffer3[i]+ExtMapBuffer4[i])/2;
   }
  
   for(i=limit-1;i>=0;i--){
      ExtMapBuffer1[i]=iMAOnArray(ExtMapBuffer3,0,smPeriod,0,smMethod,i);
      ExtMapBuffer2[i]=iMAOnArray(ExtMapBuffer4,0,smPeriod,0,smMethod,i);
      ExtMapBuffer6[i]=(ExtMapBuffer1[i]+ExtMapBuffer2[i])/2;
   }  
   return(0);
  }
//+------------------------------------------------------------------+