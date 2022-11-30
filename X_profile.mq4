//+------------------------------------------------------------------+
//|                                                    X_profile.mq4 |
//|                                Copyright © 2005, Trading Studio. |
//|                                          http://www.bluechips.it |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Trading Studio."
#property link      "http://www.bluechips.it"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Yellow
#property indicator_color3 Green
#property indicator_color4 Yellow
#property indicator_color5 Green


double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double parziale;

extern datetime  DataInizio=D'2005.08.01 04:30';

//+------------------------------------------------------------------+
//| inizializzazione                         |
//+------------------------------------------------------------------+
int init()
  {

Print("sei nell_indicatore");

//---- settaggio indicatore
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,buffer1);
SetIndexBuffer(1,buffer2);
SetIndexBuffer(2,buffer3);
SetIndexBuffer(3,buffer4);
SetIndexBuffer(4,buffer5);
IndicatorShortName("31Prova3");
if(!SetIndexBuffer(0,buffer1) && !SetIndexBuffer(1,buffer2) && !SetIndexBuffer(2,buffer3) && !SetIndexBuffer(3,buffer4) && !SetIndexBuffer(4,buffer5))
   Print("buffer non settato");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| deinizializzazione
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| iterazione
//+------------------------------------------------------------------+
int start()
  {
  
   double array_price[][6];
   int cont;
   double deviazione;
   
   ArrayInitialize(array_price,0);
   ArrayCopyRates(array_price,(Symbol()));
   

for (int j = Bars-1; j >= 0; j--) {

if (Time[j]>=DataInizio) {
   for (int i = j; i >= 0; i--) 
   {
      cont++;
         parziale=parziale+array_price[i][4];
         buffer1[i]=parziale/cont;
         deviazione=iStdDev(NULL,0,cont,MODE_SMA,0,PRICE_CLOSE,0);
         buffer2[i]=buffer1[i]+deviazione;
         buffer3[i]=buffer1[i]+(2*deviazione);
         buffer4[i]=buffer1[i]-deviazione;
         buffer5[i]=buffer1[i]-(2*deviazione);      
   }
   break;
} 
}
   return(0);
  }
//+------------------------------------------------------------------+