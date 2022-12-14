//+------------------------------------------------------------------------------------------------------------------+
#property description                                                                       "[!!!-MT4 X-XARDg-TMA+CG]"
#define Version                                                                                       "[XARDg-TMA+CG]"
//+------------------------------------------------------------------------------------------------------------------+
#property link        "https://forex-station.com/viewtopic.php?p=1295409935#p1295409935"
#property description "THIS IS A FREE INDICATOR"
#property description "                                                      "
#property description "Welcome to the World of Forex"
#property description "Let light shine out of darkness and illuminate your world"
#property description "and with this freedom leave behind your cave of denial"
#property indicator_chart_window
#property indicator_buffers 7
//+------------------------------------------------------------------+
enum showCHL { NoLINES, onlyTMA, onlyBANDS, allLINES };
enum calcARR { ArrowsOFF, TrendOCLH, ChangeCOLOR };
extern ENUM_TIMEFRAMES    TimeFrame     = PERIOD_CURRENT; // Time frame to use
extern int                HalfLength    = 56;
extern ENUM_APPLIED_PRICE Price         = PRICE_WEIGHTED;
extern double             Deviations    = 2.;
extern int                LineWidth     = 12;
extern bool               Interpolate   = false;
extern showCHL            ShowTMA       = onlyBANDS;
extern calcARR            CalcArrows    = ArrowsOFF;
extern bool               AlertsOnHiLo  = false;
extern int                SIGNALBAR     =  0;   //На каком баре сигналить....
extern bool               AlertsMessage =  false,   //false,    
                          AlertsSound   =  false,   //false,
                          AlertsEmail   =  false,
                          AlertsMobile  =  false;
extern string             SoundFile     =  "alert2.wav";  //"news.wav";  //"expert.wav";  //   //"stops.wav"   //   //

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double tmBuffer[], upBuffer[], dnBuffer[];
double clrSEL[], clrBUY[];
double arrSEL[], arrBUY[];
double wuBuffer[], wdBuffer[], FLAG[];
//---
string IndikName;
bool calculateTma = false;   bool returnBars  = false;
string  messageUP, messageDN, sufix;  datetime TimeBar=0;  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   HalfLength = MathMax(HalfLength,1);
   IndikName    = WindowExpertName();
   returnBars   = TimeFrame==-99;
   calculateTma = TimeFrame==PERIOD_CURRENT;
   TimeFrame    = MathMax(TimeFrame,_Period);
   //---
   IndicatorBuffers(10);   IndicatorDigits(Digits);
   //---  //enum showCHL { NoLINES, onlyTMA, onlyBANDS, allLINES };
   int TMT = (ShowTMA==1 || ShowTMA==3) ? DRAW_LINE : DRAW_NONE;  
   SetIndexBuffer(0,tmBuffer);  SetIndexStyle(0,TMT);
   int BNT = (ShowTMA==2 || ShowTMA==3) ? DRAW_LINE : DRAW_NONE;  
   SetIndexBuffer(1,upBuffer);  SetIndexStyle(1,BNT,0,LineWidth,C'64,64,64');
   SetIndexBuffer(2,dnBuffer);  SetIndexStyle(2,BNT,0,LineWidth,C'30,144,255');
   SetIndexBuffer(3,arrSEL);    SetIndexStyle(3,DRAW_ARROW);  SetIndexArrow(3,234);
   SetIndexBuffer(4,arrBUY);    SetIndexStyle(4,DRAW_ARROW);  SetIndexArrow(4,233);
   SetIndexBuffer(5,clrSEL);    SetIndexStyle(5,BNT,0,LineWidth,C'255,85,160');
   SetIndexBuffer(6,clrBUY);    SetIndexStyle(6,BNT,0,LineWidth,C'64,64,64');
   SetIndexBuffer(7,wuBuffer);
   SetIndexBuffer(8,wdBuffer);
   SetIndexBuffer(9,FLAG);
   for(int i=0;i<=10;i++){SetIndexEmptyValue(i,0.0);  SetIndexDrawBegin(i,HalfLength);}
   IndicatorShortName(stringMTF(TimeFrame)+": TMA+CG 4C ["+(string)HalfLength+"]");  return(0);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit() { Comment("");  return(0); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   int CountedBars=IndicatorCounted();
   if (CountedBars<0) return(-1);
   if (CountedBars>0) CountedBars--;
   int i, y, x, limit = MathMin(Bars-1,Bars-CountedBars+HalfLength);
   //---
   if (returnBars)  { tmBuffer[0] = limit+1;  return(0); }
   if (calculateTma) { calculateTMA(limit);  return(0); }
   if (TimeFrame > _Period) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,IndikName,-99,0,0)*TimeFrame/_Period));
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
   
   for (i=limit; i>=0; i--)
    {
     y = iBarShift(NULL,TimeFrame,Time[i]);
     x = y;  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);
     //---
     tmBuffer[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,HalfLength,Price,Deviations,0,y);
     upBuffer[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,HalfLength,Price,Deviations,1,y);
     dnBuffer[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,HalfLength,Price,Deviations,2,y);
     FLAG[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,HalfLength,Price,Deviations,9,y);
     //---
     if (!Interpolate) {
         if (x!=y) {
             arrSEL[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,HalfLength,Price,Deviations,3,y);
             arrBUY[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,HalfLength,Price,Deviations,4,y); } 
         //---
         clrSEL[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,HalfLength,Price,Deviations,5,y);
         clrBUY[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,HalfLength,Price,Deviations,6,y); }
     //---
     //---
     if (TimeFrame!=_Period) { if (CalcArrows==1) setupARROWS(i);  setupALERTS(FLAG); }
     //---
     //---
     if (TimeFrame <= _Period || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;
     if (!Interpolate) continue; 
     //---
     datetime time=iTime(NULL,TimeFrame,y);
     for (int n=1; i+n<Bars && Time[i+n]>=time; n++) continue;
     double factor=1.0/n;
     for (int k=1; k<n; k++)
      {
       tmBuffer[i+k] = k*factor*tmBuffer[i+n] + (1.0-k*factor)*tmBuffer[i];
       upBuffer[i+k] = k*factor*upBuffer[i+n] + (1.0-k*factor)*upBuffer[i];
       dnBuffer[i+k] = k*factor*dnBuffer[i+n] + (1.0-k*factor)*dnBuffer[i];
       //clrSEL[i+k] = k*factor*clrSEL[i+n] + (1.0-k*factor)*clrSEL[i];
       //clrBUY[i+k] = k*factor*clrBUY[i+n] + (1.0-k*factor)*clrBUY[i]; 
      }  
//+------------------------------------------------------------------+
    } //*конец цикла*  for (i=limit; i>=0; i--)
//+------------------------------------------------------------------+

   if (Interpolate) { for (i=limit; i>=0; i--) { setupCOLOR(i);  if (CalcArrows==2) setupARROWS(i); } }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//---
return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateTMA(int limit)
{
   int i, j, k;
   double FullLength = 2.0*HalfLength+1.0;
//+------------------------------------------------------------------+

   for (i=limit; i>=0; i--)
    {
     double sum  = (HalfLength+1)*iMA(NULL,0,1,0,MODE_SMA,Price,i);
     double sumw = (HalfLength+1);
     //---
     for (j=1, k=HalfLength; j<=HalfLength; j++, k--)
      {
       sum  += k*iMA(NULL,0,1,0,MODE_SMA,Price,i+j);
       sumw += k;
       //--
       if (j<=i)
        {
         sum  += k*iMA(NULL,0,1,0,MODE_SMA,Price,i-j);
         sumw += k;
        }
      }
     //---
     tmBuffer[i]=sum/sumw;
//+------------------------------------------------------------------+

     double diff = iMA(NULL,0,1,0,MODE_SMA,Price,i)-tmBuffer[i];
     if (i> (Bars-HalfLength-1)) continue;
     if (i==(Bars-HalfLength-1))
      {
       upBuffer[i] = tmBuffer[i];
       dnBuffer[i] = tmBuffer[i];
       //---
       if (diff>=0)
        {
         wuBuffer[i] = MathPow(diff,2);
         wdBuffer[i] = 0;
        }
       //---
       if (diff<0)
        {               
         wdBuffer[i] = MathPow(diff,2);
         wuBuffer[i] = 0;
        }                  
       continue;
      }
//+------------------------------------------------------------------+

     if (diff>=0)
      {
       wuBuffer[i] = (wuBuffer[i+1]*(FullLength-1)+MathPow(diff,2))/FullLength;
       wdBuffer[i] =  wdBuffer[i+1]*(FullLength-1)/FullLength;
      }
     //---
     if (diff<0)
      {
       wdBuffer[i] = (wdBuffer[i+1]*(FullLength-1)+MathPow(diff,2))/FullLength;
       wuBuffer[i] =  wuBuffer[i+1]*(FullLength-1)/FullLength;
      }
//+------------------------------------------------------------------+

     upBuffer[i] = tmBuffer[i] + Deviations*MathSqrt(wuBuffer[i]);
     dnBuffer[i] = tmBuffer[i] - Deviations*MathSqrt(wdBuffer[i]);
//+------------------------------------------------------------------+
     
     FLAG[i]=0;
     //---
     if (AlertsOnHiLo)       
      {
       if (High[i] > upBuffer[i] && High[i+1] < upBuffer[i+1]) { FLAG[i]=-444;  sufix="High"; }
       if (Low[i]  < dnBuffer[i] && Low[i+1]  > dnBuffer[i+1]) { FLAG[i]= 444;  sufix="Low"; }
      }     
     //---
     if (!AlertsOnHiLo)       
      {
       if (Close[i] > upBuffer[i] && Close[i+1] < upBuffer[i+1]) { FLAG[i]=-888;  sufix="Close"; }
       if (Close[i] < dnBuffer[i] && Close[i+1] > dnBuffer[i+1]) { FLAG[i]= 888;  sufix="Close"; }
      }     
//+------------------------------------------------------------------+

     if (TimeFrame==_Period) { setupARROWS(i);  setupALERTS(FLAG); }
     if (!Interpolate) { setupCOLOR(i); }
//+------------------------------------------------------------------+
    } //*конец цикла*
//+------------------------------------------------------------------+
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setupCOLOR(int i)
{
   clrSEL[i]=upBuffer[i];
   clrBUY[i]=dnBuffer[i];
   //---
   if (upBuffer[i] > upBuffer[i+1] && upBuffer[i+1] > upBuffer[i+2]) clrSEL[i+1]=0;
   if (dnBuffer[i] > dnBuffer[i+1] && dnBuffer[i+1] > dnBuffer[i+2]) clrBUY[i+1]=0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setupARROWS(int i)   //enum calcARR { ArrowsOFF, TrendOCLH, ChangeCOLOR };
{
   arrSEL[i]=0;   arrBUY[i]=0;
   //---
   if (CalcArrows==1) {
       if (High[i+1] > upBuffer[i+1] && Close[i+1] > Open[i+1] && Close[i] < Open[i]) arrSEL[i] = High[i]+iATR(NULL,0,48,i);
       if (Low[i+1] < dnBuffer[i+1] && Close[i+1] < Open[i+1] && Close[i] > Open[i]) arrBUY[i] = Low[i]-iATR(NULL,0,48,i); }
   //---
   if (CalcArrows==2) {
       if (upBuffer[i] < upBuffer[i+1] && upBuffer[i+1] > upBuffer[i+2]) arrSEL[i] = High[i]+iATR(NULL,0,48,i);
       if (dnBuffer[i] > dnBuffer[i+1] && dnBuffer[i+1] < dnBuffer[i+2]) arrBUY[i] = Low[i]-iATR(NULL,0,48,i); }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setupALERTS(double& flag[])
{
   if (AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound) 
    {
     messageUP = WindowExpertName()+":  "+_Symbol+", "+stringMTF(_Period)+"  >>  " +sufix+ " touched BandLO  >>  BUY";
     messageDN = WindowExpertName()+":  "+_Symbol+", "+stringMTF(_Period)+"  <<  " +sufix+ " touched BandUP  <<  SELL"; 
   //------
     if (TimeBar!=Time[0] &&  (flag[SIGNALBAR]==444 || flag[SIGNALBAR]==888)) {             
         if (AlertsMessage) Alert(messageUP);  
         if (AlertsEmail)   SendMail(_Symbol,messageUP);  
         if (AlertsMobile)  SendNotification(messageUP);  
         if (AlertsSound)   PlaySound(SoundFile);   //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"  
         TimeBar=Time[0]; } //return(0);
   //------
     else 
     if (TimeBar!=Time[0] &&  (flag[SIGNALBAR]==-444 || flag[SIGNALBAR]==-888)) {     
         if (AlertsMessage) Alert(messageDN);  
         if (AlertsEmail)   SendMail(_Symbol,messageDN);  
         if (AlertsMobile)  SendNotification(messageDN);  
         if (AlertsSound)   PlaySound(SoundFile);   //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"                
         TimeBar=Time[0]; } //return(0); 
    } //*конец* Алертов
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string stringMTF(int perMTF)
{  
   if (perMTF==0)      perMTF=_Period;
   if (perMTF==1)      return("M1");
   if (perMTF==5)      return("M5");
   if (perMTF==15)     return("M15");
   if (perMTF==30)     return("M30");
   if (perMTF==60)     return("H1");
   if (perMTF==240)    return("H4");
   if (perMTF==1440)   return("D1");
   if (perMTF==10080)  return("W1");
   if (perMTF==43200)  return("MN1");
   if (perMTF== 2 || 3  || 4  || 6  || 7  || 8  || 9 ||       /// нестандартные периоды для грфиков Renko
               10 || 11 || 12 || 13 || 14 || 16 || 17 || 18)  return("M"+(string)_Period);
//------
   return("Ошибка периода");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+ 