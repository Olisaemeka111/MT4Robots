//------------------------------------------------------------------
// original idea and first version using hull by sohocool
// this version by mladen
// changed to price median mrtools and added comments
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  LimeGreen
#property indicator_color2  OrangeRed
#property indicator_color3  OrangeRed
#property indicator_color4  LimeGreen
#property indicator_color5  OrangeRed
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  1
#property indicator_width5  1

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern int    atrPeriod       = 10;
extern double atrMultiplier   = 1.7;
extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;
extern bool   alertsNotify    = true;


//
//
//
//
//

double Trend[];
double TrendDa[];
double TrendDb[];
double arUp[];
double arDn[];
double Up[];
double Dn[];
double Direction[];

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(8);
      SetIndexBuffer(0,Trend);
      SetIndexBuffer(1,TrendDa);
      SetIndexBuffer(2,TrendDb);
      SetIndexBuffer(3,arUp); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,159);
      SetIndexBuffer(4,arDn); SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,159);
      SetIndexBuffer(5,Up);
      SetIndexBuffer(6,Dn);
      SetIndexBuffer(7,Direction);
      
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
return(0);
}
int deinit() { return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { Trend[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
      if (Direction[limit]==-1) CleanPoint(limit,TrendDa,TrendDb);
      for(int i=limit; i>=0; i--)
      {
         double atr    = iATR(NULL,0,atrPeriod,i);
         double cprice = Close[i];
         double mprice = iMA(NULL,0,1,0,MODE_SMA,PRICE_MEDIAN,i);
                Up[i]  = mprice+atrMultiplier*atr;
                Dn[i]  = mprice-atrMultiplier*atr;
         
         //
         //
         //
         //
         //

         TrendDa[i] = EMPTY_VALUE;
         TrendDb[i] = EMPTY_VALUE;
         arUp[i]    = EMPTY_VALUE;
         arDn[i]    = EMPTY_VALUE;
         Direction[i] = Direction[i+1];
            if (cprice > Up[i+1]) Direction[i] =  1;
            if (cprice < Dn[i+1]) Direction[i] = -1;
            if (Direction[i] > 0) { Dn[i] = MathMax(Dn[i],Dn[i+1]); Trend[i] = Dn[i]; }
            else                  { Up[i] = MathMin(Up[i],Up[i+1]); Trend[i] = Up[i]; }
            if (Direction[i]==-1) PlotPoint(i,TrendDa,TrendDb,Trend);
            if (Direction[i]!=Direction[i+1])
               if (Direction[i]==1)
                     arUp[i] = Trend[i]-atr*.5;
               else  arDn[i] = Trend[i]+atr*.5;
      }
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (Direction[limit]==-1) CleanPoint(limit,TrendDa,TrendDb);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         Trend[i]     = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",atrPeriod,atrMultiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,0,y);
         Direction[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",atrPeriod,atrMultiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,7,y);
         TrendDa[i]   = EMPTY_VALUE;
         TrendDb[i]   = EMPTY_VALUE;
         arUp[i]      = EMPTY_VALUE;
         arDn[i]     = EMPTY_VALUE;
         atr = iATR(NULL,0,atrPeriod,i);
         if (Direction[i]==-1) PlotPoint(i,TrendDa,TrendDb,Trend);
         if (Direction[i]!=Direction[i+1])
               if (Direction[i]==1)
                     arUp[i] = Trend[i]-atr*.5;
               else  arDn[i] = Trend[i]+atr*.5;
   }
   return(0);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
      if (first[i+2] == EMPTY_VALUE) {
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
         }
      else {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
         }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar=0;
      if (Direction[whichBar] != Direction[whichBar+1])
      {
         if (Direction[whichBar] ==  1) doAlert("sloping up"  );
         if (Direction[whichBar] == -1) doAlert("sloping down");
      }
   }
}

//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," - ",timeFrameToString(timeFrame)+" xSuperTrend ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(Symbol()+" xSuperTrend",message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

