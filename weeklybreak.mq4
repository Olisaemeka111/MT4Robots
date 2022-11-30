//+------------------------------------------------------------------+
//|                                                 5dayBreakout.mq4 |
//|                                                        Bill Sica |
//|                                         http://www.tetsuyama.com |
//+------------------------------------------------------------------+
#property copyright "Bill Sica"
#property link      "http://www.tetsuyama.com"

#property indicator_chart_window
//---- input parameters
extern int       DAYS=5;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
//---- indicators

//---- indicators

   

//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double daily_high1[20];
   double daily_low1[20];
   double yesterday_close;
   double phigh,plow;
   int i=1;

//---- TODO: add your code here
ArrayResize(daily_high1,DAYS);
ArrayResize(daily_low1,DAYS);
ArrayInitialize(daily_high1,0);
ArrayInitialize(daily_low1,0);

ArrayCopySeries(daily_low1, MODE_LOW, Symbol(), PERIOD_W1);
ArrayCopySeries(daily_high1, MODE_HIGH, Symbol(), PERIOD_W1);

/* initialise */
plow=daily_low1[1];
phigh=daily_high1[1];

for(i=1;i<DAYS;i++)
{
   if(plow>daily_low1[i])
   {
      plow =daily_low1[i];
   }
}

for(i=1;i<DAYS;i++)
{
   if(phigh<daily_high1[i])
   {
      phigh =daily_high1[i];
   }
}

Comment("\n5dayH ",phigh,"\n5dayL ",plow);

ObjectDelete("5dayHigh1");
ObjectDelete("5dayLow1");

ObjectCreate("5dayHigh1", OBJ_HLINE,0, CurTime(),phigh);
ObjectSet("5dayHigh1",OBJPROP_COLOR,Yellow);
ObjectSet("5dayHigh1",OBJPROP_STYLE,STYLE_SOLID);

ObjectCreate("5dayLow1", OBJ_HLINE,0, CurTime(),plow);
ObjectSet("5dayLow1",OBJPROP_COLOR,Yellow);
ObjectSet("5dayLow1",OBJPROP_STYLE,STYLE_SOLID);

ObjectsRedraw();

   return(0);
  }
//+------------------------------------------------------------------