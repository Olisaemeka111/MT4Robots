//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    ARSIS +2X Smooth X10 MTF TT                       %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#property copyright   ""   
#property link        "" 
////#property strict
//------
#property indicator_chart_window
#property indicator_buffers 10
//------
#property indicator_color1 clrLimeGreen  //Yellow
#property indicator_color2 clrLime  //Green  //Gold
#property indicator_color3 clrLightGreen  //SeaGreen  //Orange
#property indicator_color4 clrGreenYellow   //DarkOrange
#property indicator_color5 clrYellow  //OrangeRed
#property indicator_color6 clrGold  //Yellow
#property indicator_color7 clrDarkOrange  //SeaGreen
#property indicator_color8 clrOrangeRed  //MediumSeaGreen  //clrDeepSkyBlue   //clrAqua
#property indicator_color9 clrRed  //LimeGreen   //clrMagenta
#property indicator_color10 clrCrimson  //Lime  //clrLightCyan
//-------
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 2
#property indicator_width8 2
#property indicator_width9 2
#property indicator_width10 2
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                 Custom indicator input parameters                    %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

extern int               History = 1440;  //288=D1/M5 //576=D2/M5; //864=D3/M5; //1152=D4/M5;  //1440=D5/M5;
extern ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;  // ТФ для расчёта Индекса (MTF)
extern int              BBSmooth = 5;
extern bool       BBSmothForARSI = false;
extern int             QQESmooth = 5;
extern ENUM_MA_METHOD    QQEMode = MODE_EMA;    
//------
extern int  Arsis1 = 2, Arsis2 = 2, Arsis3 = 2, Arsis4 = 2, Arsis5 = 2, 
            Arsis6 = 2, Arsis7 = 2, Arsis8 = 2, Arsis9 = 2, Arsis10 = 2 ;
extern double ArsisKOEF = 2.0;
//------
extern bool ChartAboveLines = false;
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                     Custom indicator buffers                         %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
double BSM0[], BSM1[], BSM2[], BSM3[], BSM4[], BSM5[], BSM6[], BSM7[], BSM8[], BSM9[];
double QQE0[], QQE1[], QQE2[], QQE3[], QQE4[], QQE5[], QQE6[], QQE7[], QQE8[], QQE9[];
double ARSI0[], ARSI1[], ARSI2[], ARSI3[], ARSI4[], ARSI5[], ARSI6[], ARSI7[], ARSI8[], ARSI9[]; 
int MAX;
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%              Custom indicator initialization function                %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int init()
{
   TimeFrame=MathMax(TimeFrame,_Period);   ///if (TimeFrame <= Period()) TimeFrame=PERIOD_CURRENT; 
//------
   BBSmooth = MathMax(BBSmooth,1);
   QQESmooth = MathMax(QQESmooth,1);
//------
   Arsis1 = MathMax(Arsis1,1);  Arsis2 = MathMax(Arsis2,1);
   Arsis3 = MathMax(Arsis3,1);  Arsis4 = MathMax(Arsis4,1);
   Arsis5 = MathMax(Arsis5,1);  Arsis6 = MathMax(Arsis6,1);
   Arsis7 = MathMax(Arsis7,1);  Arsis8 = MathMax(Arsis8,1);
   Arsis9 = MathMax(Arsis9,1);  Arsis10 = MathMax(Arsis10,1);
//------
   ArsisKOEF = MathMax(ArsisKOEF,0.1);
//------
   MAX = MathMax(MathMax(BBSmooth,QQESmooth),MathMax(MathMax(Arsis1,Arsis3),MathMax(Arsis6,Arsis10)));
//------
   for (int i=0; i<11; i++) {
        SetIndexStyle(i,DRAW_LINE);                //--- настройка параметров отрисовки
        SetIndexEmptyValue(i,0.0);                    //--- значение 0 отображаться не будет 
        if (History<=MAX) SetIndexDrawBegin(i,MAX+MAX);  //--- пропуск отрисовки первых баров
        else SetIndexDrawBegin(i,Bars-History); }           //--- пропуск отрисовки первых баров
//------   
//------   
   IndicatorBuffers(20);      
   IndicatorDigits(_Digits+1);  //if (Digits==3 || Digits==5) IndicatorDigits(Digits-1);
//------ 30 распределенных буфера индикатора 
   IndicatorBuffers(30);   
//------
   SetIndexBuffer(0,BSM0);  SetIndexBuffer(1,BSM1);   
   SetIndexBuffer(2,BSM2);  SetIndexBuffer(3,BSM3);   
   SetIndexBuffer(4,BSM4);  SetIndexBuffer(5,BSM5);   
   SetIndexBuffer(6,BSM6);  SetIndexBuffer(7,BSM7);   
   SetIndexBuffer(8,BSM8);  SetIndexBuffer(9,BSM9);   
//------
   SetIndexBuffer(10,QQE0);  SetIndexBuffer(11,QQE1);   
   SetIndexBuffer(12,QQE2);  SetIndexBuffer(13,QQE3);   
   SetIndexBuffer(14,QQE4);  SetIndexBuffer(15,QQE5);   
   SetIndexBuffer(16,QQE6);  SetIndexBuffer(17,QQE7);   
   SetIndexBuffer(18,QQE8);  SetIndexBuffer(19,QQE9);   
//------
   SetIndexBuffer(20,ARSI0);  SetIndexBuffer(21,ARSI1);   
   SetIndexBuffer(22,ARSI2);  SetIndexBuffer(23,ARSI3);
   SetIndexBuffer(24,ARSI4);  SetIndexBuffer(25,ARSI5);
   SetIndexBuffer(26,ARSI6);  SetIndexBuffer(27,ARSI7);
   SetIndexBuffer(28,ARSI8);  SetIndexBuffer(29,ARSI9);  
//------
//------ отображение в DataWindow 
   SetIndexLabel(0,stringMTF(TimeFrame)+":  ARSIS_1  ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis1+"]");
   SetIndexLabel(1,stringMTF(TimeFrame)+":  ARSIS_2  ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis2+"]");
   SetIndexLabel(2,stringMTF(TimeFrame)+":  ARSIS_3  ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis3+"]");
   SetIndexLabel(3,stringMTF(TimeFrame)+":  ARSIS_4  ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis4+"]");
   SetIndexLabel(4,stringMTF(TimeFrame)+":  ARSIS_5  ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis5+"]");
   SetIndexLabel(5,stringMTF(TimeFrame)+":  ARSIS_6  ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis6+"]");
   SetIndexLabel(6,stringMTF(TimeFrame)+":  ARSIS_7  ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis7+"]");
   SetIndexLabel(7,stringMTF(TimeFrame)+":  ARSIS_8  ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis8+"]");
   SetIndexLabel(8,stringMTF(TimeFrame)+":  ARSIS_9  ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis9+"]");
   SetIndexLabel(9,stringMTF(TimeFrame)+":  ARSIS_10  ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis10+"]");

//------ "короткое имя" для DataWindow и подокна индикатора 
   IndicatorShortName(stringMTF(TimeFrame)+": ARSIS 2X X10 TT ["+(string)BBSmooth+"*"+(string)QQESmooth+"*"+(string)Arsis1+"*"+DoubleToStr(ArsisKOEF,2)+"]");
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//------
return(0); 
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    ARSIS +2X Smooth X10 MTF TT                       %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
string stringMTF(int perMTF)
{  
   if (perMTF==0)     perMTF=_Period;
   if (perMTF==1)     return("M1");
   if (perMTF==5)     return("M5");
   if (perMTF==15)    return("M15");
   if (perMTF==30)    return("M30");
   if (perMTF==60)    return("H1");
   if (perMTF==240)   return("H4");
   if (perMTF==1440)  return("D1");
   if (perMTF==10080) return("W1");
   if (perMTF==43200) return("MN1");
   if (perMTF== 2 || 3  || 4  || 6  || 7  || 8  || 9 ||  /// нестандартные периоды для грфиков Renko
               10 || 11 || 12 || 13 || 14 || 16 || 17 || 18) return("M"+(string)_Period);
//------
   return("Ошибка периода");
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%              Custom indicator deinitialization function              &&&
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int deinit()  { return(0); }
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                 Custom indicator iteration function                  %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int start()
{
   int i, y, limit;
   int CountedBars=IndicatorCounted();   
   if (CountedBars<0) return(-1);       //Стандарт-Вариант!!!
   if (CountedBars>0) CountedBars--;
   if (History<=MAX)  limit=Bars-CountedBars-1-MAX;    /// WindowFirstVisibleBar()+MATHMAX;   //
   if (History>MAX)   limit=History;   ///+MAX*25;
   if (limit>=Bars-1) limit=Bars-1-MAX;
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    ARSIS +2X Smooth X10 MTF TT                       %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   for (i=limit+MAX*33; i>=0; i--)
    {
     y = iBarShift(NULL,TimeFrame,Time[i],false);
     //------
     double sc0 = MathAbs(iRSI(NULL, TimeFrame, Arsis1, PRICE_CLOSE, y) / 100 - 0.5) * ArsisKOEF;   ///* 2;
     double sc1 = MathAbs(iRSI(NULL, TimeFrame, Arsis2, PRICE_CLOSE, y) / 100 - 0.5) * ArsisKOEF;   ///* 2;
     double sc2 = MathAbs(iRSI(NULL, TimeFrame, Arsis3, PRICE_CLOSE, y) / 100 - 0.5) * ArsisKOEF;   ///* 2;
     double sc3 = MathAbs(iRSI(NULL, TimeFrame, Arsis4, PRICE_CLOSE, y) / 100 - 0.5) * ArsisKOEF;   ///* 2;
     double sc4 = MathAbs(iRSI(NULL, TimeFrame, Arsis5, PRICE_CLOSE, y) / 100 - 0.5) * ArsisKOEF;   ///* 2;
     double sc5 = MathAbs(iRSI(NULL, TimeFrame, Arsis6, PRICE_CLOSE, y) / 100 - 0.5) * ArsisKOEF;   ///* 2;
     double sc6 = MathAbs(iRSI(NULL, TimeFrame, Arsis7, PRICE_CLOSE, y) / 100 - 0.5) * ArsisKOEF;   ///* 2;
     double sc7 = MathAbs(iRSI(NULL, TimeFrame, Arsis8, PRICE_CLOSE, y) / 100 - 0.5) * ArsisKOEF;   ///* 2;
     double sc8 = MathAbs(iRSI(NULL, TimeFrame, Arsis9, PRICE_CLOSE, y) / 100 - 0.5) * ArsisKOEF;   ///* 2;
     double sc9 = MathAbs(iRSI(NULL, TimeFrame, Arsis10, PRICE_CLOSE, y) / 100 - 0.5) * ArsisKOEF;   ///* 2;
     //------
     ARSI0[i] = ARSI0[i+1] + sc0 * (iClose(NULL,TimeFrame,y)-ARSI0[i+1]);
     ARSI1[i] = ARSI1[i+1] + sc1 * (ARSI0[i] - ARSI1[i+1]);
     ARSI2[i] = ARSI2[i+1] + sc2 * (ARSI1[i] - ARSI2[i+1]);
     ARSI3[i] = ARSI3[i+1] + sc3 * (ARSI2[i] - ARSI3[i+1]);
     ARSI4[i] = ARSI4[i+1] + sc4 * (ARSI3[i] - ARSI4[i+1]);
     ARSI5[i] = ARSI5[i+1] + sc5 * (ARSI4[i] - ARSI5[i+1]);
     ARSI6[i] = ARSI6[i+1] + sc6 * (ARSI5[i] - ARSI6[i+1]);
     ARSI7[i] = ARSI7[i+1] + sc7 * (ARSI6[i] - ARSI7[i+1]);
     ARSI8[i] = ARSI8[i+1] + sc8 * (ARSI7[i] - ARSI8[i+1]);
     ARSI9[i] = ARSI9[i+1] + sc9 * (ARSI8[i] - ARSI9[i+1]);
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    } //*конец цикла* for (i=limit; i>=0; i--)
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    ARSIS +2X Smooth X10 MTF TT                       %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   for (i=limit+MAX*3; i>=0; i--)
    {
     QQE0[i] = iMAOnArray(ARSI0,0,QQESmooth,0,QQEMode,i);
     QQE1[i] = iMAOnArray(ARSI1,0,QQESmooth,0,QQEMode,i);
     QQE2[i] = iMAOnArray(ARSI2,0,QQESmooth,0,QQEMode,i);
     QQE3[i] = iMAOnArray(ARSI3,0,QQESmooth,0,QQEMode,i);
     QQE4[i] = iMAOnArray(ARSI4,0,QQESmooth,0,QQEMode,i);
     QQE5[i] = iMAOnArray(ARSI5,0,QQESmooth,0,QQEMode,i);
     QQE6[i] = iMAOnArray(ARSI6,0,QQESmooth,0,QQEMode,i);
     QQE7[i] = iMAOnArray(ARSI7,0,QQESmooth,0,QQEMode,i);
     QQE8[i] = iMAOnArray(ARSI8,0,QQESmooth,0,QQEMode,i);
     QQE9[i] = iMAOnArray(ARSI9,0,QQESmooth,0,QQEMode,i);
     //------
     BSM0[i] = iSsm(QQE0[i],BBSmooth,i,0);
     BSM1[i] = iSsm(QQE1[i],BBSmooth,i,2);
     BSM2[i] = iSsm(QQE2[i],BBSmooth,i,4);
     BSM3[i] = iSsm(QQE3[i],BBSmooth,i,6);
     BSM4[i] = iSsm(QQE4[i],BBSmooth,i,8);
     BSM5[i] = iSsm(QQE5[i],BBSmooth,i,10);
     BSM6[i] = iSsm(QQE6[i],BBSmooth,i,12);
     BSM7[i] = iSsm(QQE7[i],BBSmooth,i,14);
     BSM8[i] = iSsm(QQE8[i],BBSmooth,i,16);
     BSM9[i] = iSsm(QQE9[i],BBSmooth,i,18);
     //------
     if (BBSmothForARSI) {
       BSM0[i] = iSsm(ARSI0[i],BBSmooth,i,0);
       BSM1[i] = iSsm(ARSI1[i],BBSmooth,i,2);
       BSM2[i] = iSsm(ARSI2[i],BBSmooth,i,4);
       BSM3[i] = iSsm(ARSI3[i],BBSmooth,i,6);
       BSM4[i] = iSsm(ARSI4[i],BBSmooth,i,8);
       BSM5[i] = iSsm(ARSI5[i],BBSmooth,i,10);
       BSM6[i] = iSsm(ARSI6[i],BBSmooth,i,12);
       BSM7[i] = iSsm(ARSI7[i],BBSmooth,i,14);
       BSM8[i] = iSsm(ARSI8[i],BBSmooth,i,16);
       BSM9[i] = iSsm(ARSI9[i],BBSmooth,i,18); }
     
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    } //*конец цикла* for (i=limit; i>=0; i--)
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    ARSIS +2X Smooth X10 MTF TT                       %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (ChartAboveLines)  ChartSetInteger(0,CHART_FOREGROUND,0,true);   
   else                  ChartSetInteger(0,CHART_FOREGROUND,0,false);   
                         Sleep(500);  ChartRedraw(); 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-------
return(0);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    ARSIS +2X Smooth X10 MTF TT                       %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#define Pi 3.14159265358979323846264338327950288
double workSsm[][40];
#define _tprice  0
#define _ssm     1
//-------
double workSsmCoeffs[][4];
#define _speriod 0
#define _sc1    1
#define _sc2    2
#define _sc3    3
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
double iSsm(double price, double period, int i, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
//-------
   if (workSsmCoeffs[instanceNo][_speriod] != period)
    {
     workSsmCoeffs[instanceNo][_speriod] = period;
     double a1 = MathExp(-1.414*Pi/period);
     double b1 = 2.0*a1*MathCos(1.414*Pi/period);
     //------
     workSsmCoeffs[instanceNo][_sc2] = b1;
     workSsmCoeffs[instanceNo][_sc3] = -a1*a1;
     workSsmCoeffs[instanceNo][_sc1] = 1.0 - workSsmCoeffs[instanceNo][_sc2] - workSsmCoeffs[instanceNo][_sc3];
    }
//-------
//-------
   int s = instanceNo*2; i=Bars-i-1;
   workSsm[i][s+_ssm]    = price;
   workSsm[i][s+_tprice] = price;
//-------
   if (i>1)
    {  
     workSsm[i][s+_ssm] = workSsmCoeffs[instanceNo][_sc1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_tprice])/2.0 + 
                          workSsmCoeffs[instanceNo][_sc2]*workSsm[i-1][s+_ssm]                                + 
                          workSsmCoeffs[instanceNo][_sc3]*workSsm[i-2][s+_ssm]; 
    }
//-------
return(workSsm[i][s+_ssm]);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    ARSIS +2X Smooth X10 MTF TT                       %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%