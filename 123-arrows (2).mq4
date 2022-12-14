#property strict

#property indicator_separate_window
#property indicator_level1  50
#property indicator_level2  50
#property indicator_level3  0
#property indicator_buffers 2
#property indicator_color1  clrWhite
#property indicator_color2  clrGreen
#property indicator_width2  2
#property indicator_levelcolor clrSilver
#property indicator_levelstyle 2
//+------------------------------------------------------------------+
enum MODE
{
PTS,    //Points
PARTS,  //Parts
PRC,    //Percents
};
//+------------------------------------------------------------------+
extern MODE               Output            = PRC;
extern bool               Close_Price_Based = false;
extern int                iPeriod           = 60;
input ENUM_APPLIED_PRICE  Signal            = PRICE_CLOSE;
extern int                Smooth            = 14;
extern int                Level_up          = 61;
extern int                Level_down        = -61;
extern int                LIMIT             = 2000;
extern int                Arr_otstup        = 0;           // Отступ стрелок
extern int                Arr_width         = 1;           // Размер стрелок
extern color              Arr_Up_col        = clrLime;     // Цвет стрелки Up
extern color              Arr_Dn_col        = clrRed;      // Цвет стрелки Dn
extern bool               AlertsMessage     = true;        // Alert Message
extern bool               AlertsSound       = false;       // Alert Sound
extern bool               AlertsEmail       = false;       // Alert Email
extern bool               AlertsMobile      = false;       // Alert Mobile
extern int                SignalBar         = 0;           // Signal Bar
//+------------------------------------------------------------------+
double result[],MA[];
datetime TimeBar;
#define PREFIX "123"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   if(iPeriod < 2) iPeriod=2;
   if(LIMIT<10) LIMIT=Bars-iPeriod-Smooth;

   SetIndexBuffer(0,result);   
   SetIndexStyle (0,DRAW_LINE);// Line style
   
   SetIndexBuffer(1,MA);   
   SetIndexStyle (1,DRAW_LINE);// Line style
   
   SetLevelValue(0,Level_up);
   SetLevelValue(1,Level_down);
   
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"   Zero");
   
   if(Output==PARTS)
    {
     IndicatorSetDouble(INDICATOR_MAXIMUM,+1.1);
     IndicatorSetDouble(INDICATOR_MINIMUM,-1.1);
    }
   if(Output==PRC)
    {
     IndicatorSetDouble(INDICATOR_MAXIMUM,+105);
     IndicatorSetDouble(INDICATOR_MINIMUM,-105);
    }
 /*  if(Output==PTS)
    {
     IndicatorSetDouble(INDICATOR_MAXIMUM,0,0);
     IndicatorSetDouble(INDICATOR_MINIMUM,0,0);
    }*/

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  
  {                                     
    ObjectsDeleteAll(0,PREFIX,-1,-1);
  }
//+------------------------------------------------------------------+
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

   int limit;

   if(prev_calculated>rates_total || prev_calculated<=0) {
      limit=rates_total-1;
   }
   else limit=rates_total-prev_calculated;
   
   if(limit>LIMIT) limit=LIMIT;
   
   double hst,lst,curr;
   
   if(Output!=PTS)
   for (int i=limit; i>=0 && !IsStopped(); i--) 
    {
      hst  = Close_Price_Based?Close[iHighest(NULL, 0, MODE_CLOSE, iPeriod, i)]:High[iHighest(NULL, 0, MODE_HIGH, iPeriod, i)];
      lst  = Close_Price_Based?Close[iLowest (NULL, 0, MODE_CLOSE, iPeriod, i)]:Low [iLowest (NULL, 0, MODE_LOW , iPeriod, i)];
      curr = iMA(NULL,0,1,0,MODE_SMA,Signal,i);
      if(hst!=lst) result[i] = (curr-lst)/(hst-lst)*200-100;
      if(Output==PARTS) result[i]/=100;
      if(Smooth<2) continue;
      MA[i]=0;//iMAOnArray(result,0,Smooth,0,Mode,i);
      for (int k=i; k<i+Smooth; k++) MA[i]+=result[k];
       MA[i]/=Smooth;
    }
   else
   for (int i=limit; i>=0 && !IsStopped(); i--) 
    {
      hst  = Close_Price_Based?Close[iHighest(NULL, 0, MODE_CLOSE, iPeriod, i)]:High[iHighest(NULL, 0, MODE_HIGH, iPeriod, i)];
      lst  = Close_Price_Based?Close[iLowest (NULL, 0, MODE_CLOSE, iPeriod, i)]:Low [iLowest (NULL, 0, MODE_LOW , iPeriod, i)];
      curr = iMA(NULL,0,1,0,MODE_SMA,Signal,i);
      result[i]=(curr-(hst+lst)/2)/Point;//((curr-hst)+(curr-lst))/Point;
      
      if(Smooth<2) continue;
      MA[i]=0;//iMAOnArray(result,0,Smooth,0,Mode,i);
      for (int k=i; k<i+Smooth; k++) MA[i]+=result[k];
       MA[i]/=Smooth;
    }

   for (int i=limit; i>=0 && !IsStopped(); i--) 
    {
      if(result[i+1]<Level_down && result[i]>MA[i] && result[i+1]<MA[i+1])
        arrows_wind(i,"Up",Arr_otstup ,233,Arr_Up_col,Arr_width,false);   
       else
        ObjectDelete(PREFIX+"Up"+TimeToStr(Time[i]));
        
      if(result[i+1]>Level_up && result[i]<MA[i] && result[i+1]>MA[i+1])
        arrows_wind(i,"Dn",Arr_otstup ,234,Arr_Dn_col,Arr_width,true);
       else
        ObjectDelete(PREFIX + "Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
    }
//---
   if(AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
    { 
     string message1 = (WindowExpertName()+" - "+Symbol()+"  "+PeriodString()+" - Signal Up");
     string message2 = (WindowExpertName()+" - "+Symbol()+"  "+PeriodString()+" - Signal Dn");
       
      if(TimeBar!=Time[0] && result[SignalBar+1]<Level_down && result[SignalBar]>MA[SignalBar] && result[SignalBar+1]<MA[SignalBar+1])
       { 
          if (AlertsMessage) Alert(message1);
          if (AlertsEmail)   SendMail(Symbol()+" - "+WindowExpertName()+" - ",message1);
          if (AlertsMobile)  SendNotification(message1);
          if (AlertsSound)   PlaySound("alert2.wav");
          TimeBar = Time[0];
       }
    
      if(TimeBar!=Time[0] && result[SignalBar+1]>Level_up && result[SignalBar]<MA[SignalBar] && result[SignalBar+1]>MA[SignalBar+1])
       { 
          if (AlertsMessage) Alert(message2);
          if (AlertsEmail)   SendMail(Symbol()+" - "+WindowExpertName()+" - ",message2);
          if (AlertsMobile)  SendNotification(message2);
          if (AlertsSound)   PlaySound("alert2.wav");
          TimeBar = Time[0];
      }
    }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| arrows wind                                                      |
//+------------------------------------------------------------------+
void arrows_wind(int k, string N,int ots,int code,color clr, int size,bool up)
  {           
    string name = PREFIX+N+TimeToStr(Time[k]);  
    double gap = ots*Point;
   
    ObjectCreate(name,OBJ_ARROW,0,Time[k],0);
    ObjectSetInteger(0,name,OBJPROP_COLOR, clr);  
    ObjectSetInteger(0,name,OBJPROP_ARROWCODE,code);
    ObjectSetInteger(0,name,OBJPROP_WIDTH,size);  
    ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
    if (up)
     {
       ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
       ObjectSetDouble (0,name,OBJPROP_PRICE1,High[k]+gap);
     }else{  
       ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_TOP);
       ObjectSetDouble (0,name,OBJPROP_PRICE1,Low[k]-gap);
     }
  }
//+------------------------------------------------------------------+
//| Period to String                                                 |
//+------------------------------------------------------------------+
string PeriodString()
  {
    switch (_Period) 
     {
        case PERIOD_M1:  return("M1");
        case PERIOD_M5:  return("M5");
        case PERIOD_M15: return("M15");
        case PERIOD_M30: return("M30");
        case PERIOD_H1:  return("H1");
        case PERIOD_H4:  return("H4");
        case PERIOD_D1:  return("D1");
        case PERIOD_W1:  return("W1");
        case PERIOD_MN1: return("MN1");
     }    
    return("M" + string(_Period));
  }
//+------------------------------------------------------------------+ 