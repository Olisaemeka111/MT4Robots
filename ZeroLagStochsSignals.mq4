#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 Red
//---- input parameters
extern int a=14;
extern int alerty=0;  // 0 for alerts 1 for no alerts
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double b4zls,nowzls,nowzlsmain;
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
SetIndexStyle(0,DRAW_ARROW,EMPTY);
SetIndexArrow(0,233);
SetIndexBuffer(0, ExtMapBuffer1);

SetIndexStyle(1,DRAW_ARROW,EMPTY);
SetIndexArrow(1,234);
SetIndexBuffer(1, ExtMapBuffer2);
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//---- TODO: add your code here
//ObjectDelete(""); 
//ObjectDelete("down cross"); 
//ObjectDelete(0,233);
//ObjectDeleteEx(0, DRAW_ARROW,0,0,0);

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
int limit;
int counted_bars=IndicatorCounted();
//---- check for possible errors
if(counted_bars<0) return(-1);

//---- last counted bar will be recounted
if(counted_bars>0) counted_bars--;
limit=1000-counted_bars;
//---- macd counted in the 1-st buffer

 for(int i=limit; i>=0; i--)
{  
   b4zls=iCustom(NULL,0,"ZeroLagStochs",0,i+1);
      
   nowzls=iCustom(NULL,0,"ZeroLagStochs",0,i);
   nowzlsmain=iCustom(NULL,0,"ZeroLagStochs",1,i);
 
 if(b4zls>nowzlsmain &&
         nowzls<nowzlsmain)
    
          {
            ExtMapBuffer2[i]=High[i]+7*Point;
      if (alerty==0 && i<2 ) Alert(Symbol()," ",Period()," ZeroLagStochs Cross SELL");
         }
 
    if(b4zls<nowzlsmain &&
         nowzls>nowzlsmain)
       {
            ExtMapBuffer1[i]=Low[i]-5*Point;
        if (alerty==0 && i<2) Alert(Symbol()," ",Period()," ZeroLagStochs Cross BUY");
       }
}
//----
return(0);
}

