//+------------------------------------------------------------------------------------------------------------------+
#property description                                                                       "[!!!-MT4 X-XARDg-RSIOMA]"
#define Version                                                                                       "[XARDg-RSIOMA]"
//+------------------------------------------------------------------------------------------------------------------+
#property link        "https://forex-station.com/viewtopic.php?p=1295409935#p1295409935"
#property description "THIS IS A FREE INDICATOR"
#property description "                                                      "
#property description "Welcome to the World of Forex"
#property description "Let light shine out of darkness and illuminate your world"
#property description "and with this freedom leave behind your cave of denial"
#property indicator_separate_window
#property indicator_buffers   8
#property indicator_minimum -20
#property indicator_maximum  105
#property indicator_level1 50
#property indicator_levelcolor clrSilver
#property indicator_levelstyle 1
string ID = "Brax>";
//+------------------------------------------------------------------------------------------------------------------+
   extern string RS01                       = "====================================================";
   extern string RS02                       = "<<<==== [01] RSIOMA Settings ====>>>";
   extern string RS03                       = "====================================================";
             int RSIOMA                     = 5,
                 RSIOMA_MODE                = MODE_EMA,
                 RSIOMA_PRICE               = PRICE_CLOSE;
             int Ma_RSIOMA                  = 8,
                 Ma_RSIOMA_MODE             = MODE_EMA,
                 BarsToCount                = 2000;
          double BuyTrigger                 = 20.00,
                 SellTrigger                = 80.00;
    extern color BuyTriggerColor            = clrHotPink,
                 SellTriggerColor           = clrDodgerBlue,
                 MainTrendLongColor         = clrDodgerBlue,
                 MainTrendShortColor        = clrHotPink;
    extern color marsiomaXupSigColor        = clrAqua,
                 marsiomaXdnSigColor        = clrDeepPink;
          double MainTrendLong=10.00,MainTrendShort=90.00,MajorTrend=50;
   extern string SL01                       = "====================================================";
   extern string SL02                       = "<<<==== [02] Line Settings ====>>>";
   extern string SL03                       = "====================================================";
            bool ShowLines                  = true;
   extern string LinesIdentifier            = "rsioma lines";
    extern color LinesColorForUp            = clrLimeGreen,
                 LinesColorForDown          = clrRed;
      extern int LinesStyle                 = STYLE_DASH;
   extern string AL01                       = "====================================================";
   extern string AL02                       = "<<<==== [03] Alert Settings ====>>>";
   extern string AL03                       = "====================================================";
            bool alertsOn                   = true,
                 alertsOnCurrent            = TRUE,
                 alertsMessage              = TRUE,
                 alertsPushNotif            = TRUE,
                 alertsSound                = FALSE,
                 alertsEmail                = FALSE,
                 alertsNotify               = FALSE;
   extern string soundFile                  = "alert2.wav";
   extern string TF01                       = "====================================================";
   extern string TF02                       = "<<<==== [04] TF Period Chart Settings ====>>>";
   extern string TF03                       = "====================================================";
   extern string note_Choose_TimeFrames     = "TF as in MT4 Periodicity bar:";
   extern string as_Periods                 = "(M1;M5;M15;M30;H1;H4;D1;W1;MN; or:)";
   extern string or_Minutes                 = "(1,5,15,30,60,240,1440,10080,43200)";
   extern string CurrentTF_0                = "Current TF = 0 (Zero)";
   extern string Timeframe                  = "0",
                 TimeFrames_Periods         = "M1;M5;M15;M30;H1;H4;D1;W1;MN";
   extern string BT01                       = "====================================================";
   extern string BT02                       = "<<<==== [05] BOXtext on 1Hr Chart Settings ====>>>";
   extern string BT03                       = "====================================================";
     extern bool showBOXtext                = true;
      extern int PanelBorderWidth           = 1;
    extern color PanelBorderColor           = C'120,120,120'; string BOXtxt; color BOXclr;
//+------------------------------------------------------------------------------------------------------------------+
   double MABuffer1[],RSIBuffer1[],marsioma1[];
   double RSIBuffer[],bdn[],bup[],sdn[],sup[];
   double marsioma[],marsiomaXupSig[],marsiomaXdnSig[];
   int correction,TimeFrame;  datetime lastBarTime,TimeArray[];  string short_name;  bool DiferentTimeFrame;
//+------------------------------------------------------------------------------------------------------------------+
   int init(){ short_name=StringConcatenate("    ");  IndicatorShortName(short_name);
   if(Period()==PERIOD_M1)Timeframe="5";   if(Period()==PERIOD_M5)Timeframe="15";
   if(Period()==PERIOD_M15)Timeframe="30"; if(Period()==PERIOD_M30)Timeframe="60";
   if(Period()==PERIOD_H1)Timeframe="60";  if(Period()>=PERIOD_H4)Timeframe="1440";
   SetIndexBuffer(0,RSIBuffer);        SetIndexStyle(0,DRAW_LINE,EMPTY,2,clrDodgerBlue);
   SetIndexBuffer(2,bup);              SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,7,C'96,170,204');
   SetIndexBuffer(1,bdn);              SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,7,C'255,140,255');
   SetIndexBuffer(3,sdn);              SetIndexStyle(3,DRAW_NONE,EMPTY,2,clrRed);
   SetIndexBuffer(4,sup);              SetIndexStyle(4,DRAW_NONE,EMPTY,2,clrGreen);
   SetIndexBuffer(5,marsioma);         SetIndexStyle(5,DRAW_LINE,EMPTY,2,clrRed);
   SetIndexBuffer(6,marsiomaXupSig);   SetIndexStyle(6,DRAW_ARROW,EMPTY,4,clrLimeGreen); SetIndexArrow(6,159);
   SetIndexBuffer(7,marsiomaXdnSig);   SetIndexStyle(7,DRAW_ARROW,EMPTY,4,clrRed);       SetIndexArrow(7,159);
   for(int Bufx=0;Bufx<indicator_buffers;Bufx++){SetIndexLabel(Bufx,NULL);}
//+------------------------------------------------------------------------------------------------------------------+
      TimeFrame         = stringToTimeFrame(Timeframe);
      DiferentTimeFrame = (TimeFrame!=Period());
      correction        = RSIOMA+RSIOMA+Ma_RSIOMA;
      BarsToCount       = MathMin(Bars,MathMax(BarsToCount,300));
          ArrayResize( MABuffer1 ,BarsToCount+correction);
          ArrayResize( RSIBuffer1,BarsToCount+correction);
          ArrayResize( marsioma1 ,BarsToCount+correction);
          ArraySetAsSeries(MABuffer1 ,true);  ArraySetAsSeries(RSIBuffer1,true);
          ArraySetAsSeries(marsioma1 ,true);  lastBarTime = EMPTY_VALUE;  return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   int deinit(){CleanUpIsle1(ID); int lookForLength = StringLen(LinesIdentifier);
   for (int i=ObjectsTotal(); i>=0; i--){ string name = ObjectName(i);
   if(StringSubstr(name,0,lookForLength)==LinesIdentifier) ObjectDelete(name);}  return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   int start(){ static bool init=false;  int counted_bars=IndicatorCounted();  int limit,i,y;
   if(!init){ init=true;
      drawLine(BuyTrigger,"BuyTrigger", BuyTriggerColor);
      drawLine(SellTrigger,"SellTrigger", SellTriggerColor);}
      //drawLine(MainTrendLong,"MainTrendLong", MainTrendLongColor);
      //drawLine(MainTrendShort,"MainTrendShort",MainTrendShortColor);}
//+------------------------------------------------------------------------------------------------------------------+
   if(counted_bars<0) return(-1);
   if(lastBarTime != Time[0]){ lastBarTime = Time[0];  counted_bars = 0;}
   if(counted_bars>0) counted_bars--;  limit=Bars-counted_bars;
   limit=MathMin(MathMax(TimeFrame/Period(),limit),BarsToCount+correction);
   ArrayCopySeries(TimeArray ,MODE_TIME ,NULL,TimeFrame);
//+------------------------------------------------------------------------------------------------------------------+
   for(i=limit;i>=0;i--)  MABuffer1[i]= iMA(Symbol(),TimeFrame,RSIOMA,0,RSIOMA_MODE,RSIOMA_PRICE,i);
   for(i=limit;i>=0;i--) RSIBuffer1[i]= iRSIOnArray(MABuffer1,0,RSIOMA,i);
   for(i=limit;i>=0;i--)  marsioma1[i]= iMAOnArray(RSIBuffer1,0,Ma_RSIOMA,0,Ma_RSIOMA_MODE,i);
   for(i=0,y=0;i<limit;i++){if(DiferentTimeFrame){if(Time[i]<TimeArray[y]) y++;}  else y = i;
                          RSIBuffer[i]= RSIBuffer1[y];
                           marsioma[i]= marsioma1[y];}
//+------------------------------------------------------------------------------------------------------------------+
   for(i=limit;i>=0;i--){ bup[i]= EMPTY_VALUE; bdn[i]= EMPTY_VALUE; marsiomaXupSig[i]= EMPTY_VALUE;
                          sup[i]= EMPTY_VALUE; sdn[i]= EMPTY_VALUE; marsiomaXdnSig[i]= EMPTY_VALUE;
//+------------------------------------------------------------------------------------------------------------------+
   if(RSIBuffer[i]<=50.) bdn[i]=-12;
   if(RSIBuffer[i]> 50.) bup[i]= 12;
//+------------------------------------------------------------------------------------------------------------------+
 //if(RSIBuffer[i+1]<=marsioma[i+1]&&RSIBuffer[i]>marsioma[i]) marsiomaXupSig[i]=-7;
 //if(RSIBuffer[i+1]>=marsioma[i+1]&&RSIBuffer[i]<marsioma[i]) marsiomaXdnSig[i]= 6;
   if(RSIBuffer[i+1]<=50. && RSIBuffer[i]>50.) marsiomaXupSig[i]=-7;
   if(RSIBuffer[i+1]>=50. && RSIBuffer[i]<50.) marsiomaXdnSig[i]= 6;
//+---BOXtext Display------------------------------------------------------------------------------------------------+
                                                     BOXtxt="  WAITING..."; BOXclr=C'40,40,40';
   if(RSIBuffer[i]<=marsioma[i] && RSIBuffer[i]<50.){BOXtxt="SELLS ONLY";   BOXclr= clrRed;}
   if(RSIBuffer[i]>=marsioma[i] && RSIBuffer[i]>50.){BOXtxt=" BUYS ONLY";   BOXclr=clrBlue;}
   if(Period()<=PERIOD_D1){
   if(showBOXtext){SetPanel(0,ID+"Brax1",1,0,4,6,136,22,BOXclr,PanelBorderColor,PanelBorderWidth,false);
           ObjectSetInteger(0,ID+"Brax1",OBJPROP_BGCOLOR,BOXclr);
                   SetLabel(0,ID+"Brax2",1,0,8,6,BOXtxt,16,"Arial Bold",clrSilver,0,false,true,0,ANCHOR_LEFT_UPPER);}}  
//+------------------------------------------------------------------------------------------------------------------+
   if(ShowLines){ deleteLine(i);
   if(marsiomaXupSig[i]!= marsiomaXupSig[i+1] || marsiomaXdnSig[i]!= marsiomaXdnSig[i+1]){
   if(marsiomaXupSig[i+1] == EMPTY_VALUE && marsiomaXupSig[i] != EMPTY_VALUE) drawVLine(i,LinesColorForUp);
   if(marsiomaXdnSig[i+1] == EMPTY_VALUE && marsiomaXdnSig[i] != EMPTY_VALUE) drawVLine(i,LinesColorForDown);}}}
   for (i=0;i<indicator_buffers;i++) SetIndexDrawBegin(i,Bars-BarsToCount);
//+------------------------------------------------------------------------------------------------------------------+
   if(alertsOn){int whichBar=1; if(alertsOnCurrent) whichBar=0;
   if(marsiomaXupSig[whichBar+1]==EMPTY_VALUE && marsiomaXupSig[whichBar]!=EMPTY_VALUE)doAlert(whichBar,"RSi UP");
   if(marsiomaXdnSig[whichBar+1]==EMPTY_VALUE && marsiomaXdnSig[whichBar]!=EMPTY_VALUE)doAlert(whichBar,"RSi DN");  
   } return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   void drawLine(double lvl,string name,color Col){ ObjectDelete(name);
   ObjectCreate(name,OBJ_HLINE, WindowFind(short_name),Time[0],lvl,Time[0],lvl);
      ObjectSet(name,OBJPROP_STYLE,STYLE_DOT);
      ObjectSet(name,OBJPROP_COLOR,Col);
      ObjectSet(name,OBJPROP_WIDTH,1);}
//+------------------------------------------------------------------------------------------------------------------+
   int stringToTimeFrame(string tfs){ int tf=0;  tfs = StringUpperCase(tfs);
      if(tfs=="M1" ||tfs=="1")       tf=PERIOD_M1;
      if(tfs=="M5" ||tfs=="5")       tf=PERIOD_M5;
      if(tfs=="M15"||tfs=="15")      tf=PERIOD_M15;
      if(tfs=="M30"||tfs=="30")      tf=PERIOD_M30;
      if(tfs=="H1" ||tfs=="60")      tf=PERIOD_H1;
      if(tfs=="H4" ||tfs=="240")     tf=PERIOD_H4;
      if(tfs=="D1" ||tfs=="1440")    tf=PERIOD_D1;
      if(tfs=="W1" ||tfs=="10080")   tf=PERIOD_W1;
      if(tfs=="MN" ||tfs=="43200")   tf=PERIOD_MN1;  return(tf);}
//+------------------------------------------------------------------------------------------------------------------+
   string TimeFrameToString(int tf){ string tfs="0";  switch(tf){
      case PERIOD_M1:  tfs="Period M1"  ; break;
      case PERIOD_M5:  tfs="Period M5"  ; break;
      case PERIOD_M15: tfs="Period M15" ; break;
      case PERIOD_M30: tfs="Period M30" ; break;
      case PERIOD_H1:  tfs="Period H1"  ; break;
      case PERIOD_H4:  tfs="Period H4"  ; break;
      case PERIOD_D1:  tfs="Period D1"  ; break;
      case PERIOD_W1:  tfs="Period W1"  ; break;
      case PERIOD_MN1: tfs="Period MN1";}  return(tfs);}
//+------------------------------------------------------------------------------------------------------------------+
   string StringUpperCase(string str){ string s = str;  int lenght = StringLen(str) -1;  int tchar;
   while(lenght >= 0){ tchar = StringGetChar(s, lenght);
   if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))  s = StringSetChar(s, lenght, tchar - 32); else
   if(tchar > -33 && tchar < 0) s = StringSetChar(s, lenght, tchar + 224);  lenght--;}  return(s);}
//+------------------------------------------------------------------------------------------------------------------+
   void deleteLine(int i){ ObjectDelete(LinesIdentifier+":"+Time[i]);}
//+------------------------------------------------------------------------------------------------------------------+
   void drawVLine(int i, color theColor){ string name = LinesIdentifier+":"+Time[i];
   if(ObjectFind(name)<0)
    ObjectCreate(name,OBJ_VLINE,0,Time[i],0);
       ObjectSet(name,OBJPROP_COLOR,theColor);
       ObjectSet(name,OBJPROP_BACK,true);
       ObjectSet(name,OBJPROP_STYLE,LinesStyle);}
//+----SetPanel Function---------------------------------------------------------------------------------------------+
   void SetPanel(long IDchart=0,string name="Panel",int window=0,int corner=0,int PosX=0,int PosY=0,int width=0,int height=0,
   int bg_color=0,int border_color=0,int border_width=1,bool bg=true,bool del=false){if(StringLen(name)<1)return;
   if(del) ObjectDelete(IDchart,name); window=MathMax(window,0);
   if(bg_color<0) bg_color=White; if(border_color<0) border_color=White;
   if (ObjectCreate(IDchart,name,OBJ_RECTANGLE_LABEL,window,0,0)){
   ObjectSetInteger(IDchart,name,OBJPROP_XDISTANCE,PosX);
   ObjectSetInteger(IDchart,name,OBJPROP_YDISTANCE,PosY);
   ObjectSetInteger(IDchart,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(IDchart,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(IDchart,name,OBJPROP_COLOR,border_color);
   ObjectSetInteger(IDchart,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(IDchart,name,OBJPROP_WIDTH,border_width);
   ObjectSetInteger(IDchart,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(IDchart,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(IDchart,name,OBJPROP_BACK,bg);
   ObjectSetInteger(IDchart,name,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(IDchart,name,OBJPROP_SELECTED,0);
   ObjectSetInteger(IDchart,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(IDchart,name,OBJPROP_ZORDER,0);
   ObjectSetInteger(IDchart,name,OBJPROP_BGCOLOR,bg_color);}}
//+----SetLabel Function---------------------------------------------------------------------------------------------+
   void SetLabel(long IDchart=0,string name="Label",int window=0,int corner=0,int PosX=0,int PosY=0,string thetext=" ",
   int fontsize=12,string fontname="Arial",int colour=0,double angle=0,bool back=true,bool del=false,int vis=0,
   int align=ANCHOR_LEFT_UPPER,bool HideObjects=true){if(del) ObjectDelete(IDchart,name);
   corner=MathMax(corner,0);  window=MathMax(window,0);
   if(colour<0) colour = White;
   if(fontsize==0) fontsize = 8;
   if(fontname=="")  fontname = "Arial";
      if(ObjectFind(IDchart,name) < 0)
       ObjectCreate(IDchart,name,OBJ_LABEL,window,0,0,0,0);
   ObjectSetInteger(IDchart,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(IDchart,name,OBJPROP_XDISTANCE,PosX);
   ObjectSetInteger(IDchart,name,OBJPROP_YDISTANCE,PosY);
    ObjectSetString(IDchart,name, OBJPROP_TEXT, thetext);
   ObjectSetInteger(IDchart,name,OBJPROP_FONTSIZE,fontsize);
    ObjectSetString(IDchart,name, OBJPROP_FONT, fontname);
   ObjectSetInteger(IDchart,name,OBJPROP_COLOR,colour);
    ObjectSetDouble(IDchart,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(IDchart,name,OBJPROP_BACK,back);
   ObjectSetInteger(IDchart,name,OBJPROP_TIMEFRAMES,vis);
   ObjectSetInteger(IDchart,name,OBJPROP_ANCHOR,align);
   ObjectSetInteger(IDchart,name,OBJPROP_HIDDEN,HideObjects);}
//+------------------------------------------------------------------------------------------------------------------+
   void doAlert(int forBar, string doWhat){
   static string previousAlert="nothing"; static datetime previousTime; string msg;
   if(previousAlert != doWhat || previousTime != Time[forBar]){ previousAlert = doWhat; previousTime = Time[forBar];
   msg=StringConcatenate(Symbol()," ",doWhat+" at ",TimeToStr(TimeLocal(),TIME_MINUTES));
   if(alertsMessage) Alert(msg); if(alertsEmail) SendMail(StringConcatenate(Symbol(),Period()," RSIOMA "),msg);
   if(alertsNotify)  SendNotification(msg);  if(alertsSound) PlaySound(soundFile);}}
//+----Clean Chart Function------------------------------------------------------------------------------------------+
   void CleanUpIsle1(string nature){int obj_total= ObjectsTotal(); for(int i=obj_total; i>=0; i--){
   string name=ObjectName(i); if(StringSubstr(name,0,5)==(nature)) ObjectDelete(name);}}//End CleanUpIsle1
//+------------------------------------------------------------------------------------------------------------------+