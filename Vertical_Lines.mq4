//+------------------------------------------------------------------+
//|                                        Vertical Lines Sample.mq4 |
//|                                   Copyright © 2005, Jason Rivera |
//|                                      http://www.jasonerivera.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Jason Rivera"
#property link      "http://www.jasonerivera.com"

#property indicator_chart_window

extern int No_Bars_To_Calculate = 1000;
extern int Start=8;
extern int Finish=17;
extern int BeginDay = 0;

string objNames[0];
int array_count = 0;
int TimeStart = 0;
int TimeFinish=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   //resize the index of the Array to the expected number of objects to be created
   ArrayResize(objNames, No_Bars_To_Calculate);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
  int items=ArrayRange(objNames,0)-1; Print(items, " objects to delete");
  int i = 0;
//---- 
   //make sure to delete all objects created when unloading this indicator
   //this routine cycles thru the stored list of unique vertical line names 
   //and deletes the objects with that name
   for (i=items; i>=0;i--)
   {
      //all valid object names will have at least one character, so skip empty strings
      if(objNames[i] != "")
      {
         Print("Deleted: ",objNames[i]);
         ObjectDelete(objNames[i]);
      }      
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int pos = Bars-1;
   int i = 0;

      

//---- 
   if(Bars - counted_bars == 1) return(0);
   
   pos = (No_Bars_To_Calculate);
   
   //initialize all elements of the array to empty string
   for (i=ArrayRange(objNames,0); i>=0;i--)
   {
      objNames[i] = "";
   }
      
   while(pos>=0)
   {            
      //we will create a vertical line everyday at 9pm server time or 21:00 hours 
      //for as many bars back as we wish to calculate, default is set at 100 bars (about 4 bars on a 1 hour chart)
      //string min = TimeToStr(TimeMinute(Time[pos]));
      //string hour = TimeToStr(TimeHour(Time[pos]));
      //Comment(min);
      
         if(TimeMonth(Time[pos])>3 && TimeMonth(Time[pos])<11) 
            {
            //TimeStart = Start;
            //TimeFinish = Finish;
            TimeStart = Start - 1;
            TimeFinish = Finish -1;
            } else {
            TimeStart = Start;
            TimeFinish = Finish;
            }
  
      if((TimeHour(Time[pos]) == TimeStart && TimeMinute(Time[pos]) == 0))
      //if(TimeMinute(Time[pos]) == 15 && TimeHour(Time[pos] == 8))
      {
         if(ObjectFind(TimeToStr(Time[pos]))==-1)
         {
            if(!ObjectCreate(TimeToStr(Time[pos]), OBJ_VLINE, 0, Time[pos], 0))
            {
               Print("error: can't create vertical line object! code #",GetLastError());
               return(0);
            }else {
                               
               //stores the unique name of each vertical line object as it is created so we can delete it when indicator is unloaded
               objNames[array_count] = TimeToStr(Time[pos]);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_STYLE, STYLE_DOT);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_COLOR, DodgerBlue);
                
               Print("Object created: ", objNames[array_count]); 
               
               //keep track of how many items are in the array
               array_count++;       
            }
         }
         else 
            {
            Print("object ", TimeToStr(Time[pos]), " already exists!");
            } 
         }
         
      if((TimeHour(Time[pos]) == TimeFinish && TimeMinute(Time[pos]) == 0))
      {
         if(ObjectFind(TimeToStr(Time[pos]))==-1)
         {
            if(!ObjectCreate(TimeToStr(Time[pos]), OBJ_VLINE, 0, Time[pos], 0))
            {
               Print("error: can't create vertical line object! code #",GetLastError());
               return(0);
            }else {
                               
               //stores the unique name of each vertical line object as it is created so we can delete it when indicator is unloaded
               objNames[array_count] = TimeToStr(Time[pos]);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_STYLE, STYLE_DOT);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_COLOR, Red);
                
               Print("Object created: ", objNames[array_count]); 
               
               //keep track of how many items are in the array
               array_count++;       
            }
         }else {
            Print("object ", TimeToStr(Time[pos]), " already exists!");
         } 
      }
 //     
      if((TimeHour(Time[pos]) == BeginDay && TimeMinute(Time[pos]) == 0))
      {
         if(ObjectFind(TimeToStr(Time[pos]))==-1)
         {
            if(!ObjectCreate(TimeToStr(Time[pos]), OBJ_VLINE, 0, Time[pos], 0))
            {
               Print("error: can't create vertical line object! code #",GetLastError());
               return(0);
            }else {
                               
               //stores the unique name of each vertical line object as it is created so we can delete it when indicator is unloaded
               objNames[array_count] = TimeToStr(Time[pos]);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_STYLE, STYLE_DASH);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_COLOR, Gainsboro);
                
               Print("Object created: ", objNames[array_count]); 
               
               //keep track of how many items are in the array
               array_count++;       
            }
         }else {
            Print("object ", TimeToStr(Time[pos]), " already exists!");
         } 
      }
      
      
 //     
      if((TimeHour(Time[pos]) == 13 && TimeMinute(Time[pos]) == 0))
      {
         if(ObjectFind(TimeToStr(Time[pos]))==-1)
         {
            if(!ObjectCreate(TimeToStr(Time[pos]), OBJ_VLINE, 0, Time[pos], 0))
            {
               Print("error: can't create vertical line object! code #",GetLastError());
               return(0);
            }else {
                               
               //stores the unique name of each vertical line object as it is created so we can delete it when indicator is unloaded
               objNames[array_count] = TimeToStr(Time[pos]);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_STYLE, STYLE_DOT);
               ObjectSet(TimeToStr(Time[pos]), OBJPROP_COLOR, Gainsboro);
                
               Print("Object created: ", objNames[array_count]); 
               
               //keep track of how many items are in the array
               array_count++;       
            }
         }else {
            Print("object ", TimeToStr(Time[pos]), " already exists!");
         } 
      }
            
      pos--;
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+