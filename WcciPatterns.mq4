#property copyright "(C)2005, Yuri Ershtad"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 MediumSeaGreen
#property indicator_color2 OrangeRed
#property indicator_color3 DeepSkyBlue
#property indicator_color4 IndianRed
#property indicator_color5 Tomato
#property indicator_color6 LimeGreen
#property indicator_color7 Coral
#property indicator_color8 Red

//////////////////////////////////////////////////////////////////////
// Пареметы
//////////////////////////////////////////////////////////////////////

extern int fastPeriod  = 6;
extern int slowPeriod  = 14;

//////////////////////////////////////////////////////////////////////
// Буферы данных
//////////////////////////////////////////////////////////////////////
 
double ZlrBuffer[];     // 1. Zero-line Reject (ZLR)      -- trend 
double ShamuBuffer[];   // 2. Shamu Trade                 -- counter
double TlbBuffer[];     // 3. Trend Line Break (TLB/HTLB) -- both
double VegasBuffer[];   // 4. Vegas Trade (VT)			    -- counter
double GhostBuffer[];   // 5. Ghost Trade                 -- counter
double RevdevBuffer[];  // 6. Reverse Divergence          -- trend
double HooksBuffer[];   // 7. Hook from Extremes (HFE)    -- counter
double ExitBuffer[];    // 8. Exit signals

//////////////////////////////////////////////////////////////////////
// Инициализация
//////////////////////////////////////////////////////////////////////

int init()
{
   string short_name;
   IndicatorBuffers(8);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   ///////////////////////////////////////////////////////////////
   // Сигналы обозначаються цифрами от 1 до 8.  
   // Для сигналов к торговле по тренду используется зеленая гамма, 
   // против тренда красная, синяя - для TLB и HTLB
   // ----
   short_name="Woodies CCI Paterns ("+fastPeriod+","+slowPeriod+")";
   IndicatorShortName(short_name);
   // Zero-line Reject (ZLR), trend
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, MediumSeaGreen);
   SetIndexBuffer(0, ZlrBuffer);    
   SetIndexArrow(0, 140);
   SetIndexLabel(0,"Zero-line Reject (ZLR), trend");
   SetIndexEmptyValue(0, EMPTY_VALUE);      
   SetIndexDrawBegin(0, slowPeriod);
   // Shamu Trade, counter-trend
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, OrangeRed);
   SetIndexBuffer(1, ShamuBuffer);    
   SetIndexArrow(1, 141);
   SetIndexLabel(1,"Shamu Trade, counter-trend");
   SetIndexEmptyValue(1, EMPTY_VALUE);      
   SetIndexDrawBegin(1, slowPeriod);
   // Trend Line Break (TLB), both
   SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, DeepSkyBlue);
   SetIndexBuffer(2, TlbBuffer);    
   SetIndexArrow(2, 142);
   SetIndexLabel(2,"Trend Line Break (TLB), both");
   SetIndexEmptyValue(2, EMPTY_VALUE);      
   SetIndexDrawBegin(2, slowPeriod);
   // Vegas Trade (VT), counter-trend
   SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, IndianRed);
   SetIndexBuffer(3, VegasBuffer);    
   SetIndexArrow(3, 143);
   SetIndexLabel(3,"Vegas Trade (VT), counter-trend");
   SetIndexEmptyValue(3, EMPTY_VALUE);      
   SetIndexDrawBegin(3, slowPeriod);
   // Ghost Trade, counter-trend
   SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, Tomato);
   SetIndexBuffer(4, GhostBuffer);    
   SetIndexArrow(4, 144);
   SetIndexLabel(4,"Ghost Trade, counter-trend");
   SetIndexEmptyValue(4, EMPTY_VALUE);      
   SetIndexDrawBegin(4, slowPeriod);
   // Reverse Divergence, trend
   SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, LimeGreen);
   SetIndexBuffer(5, RevdevBuffer);    
   SetIndexArrow(5, 145);
   SetIndexLabel(5,"Reverse Divergence, trend");
   SetIndexEmptyValue(5, EMPTY_VALUE);      
   SetIndexDrawBegin(5, slowPeriod);
   // Hook from Extremes (HFE), counter-trend
   SetIndexStyle(6, DRAW_ARROW, EMPTY, 1, Coral);
   SetIndexBuffer(6, HooksBuffer);    
   SetIndexArrow(6, 146);
   SetIndexLabel(6,"Hook from Extremes (HFE), counter-trend");
   SetIndexEmptyValue(6, EMPTY_VALUE);      
   SetIndexDrawBegin(6, slowPeriod);
   // Exit signal
   SetIndexStyle(7, DRAW_ARROW, EMPTY, 1, RoyalBlue);
   SetIndexBuffer(7, ExitBuffer);    
   SetIndexArrow(7, 251);
   SetIndexLabel(7,"Exit signal");
   SetIndexEmptyValue(7, EMPTY_VALUE);      
   SetIndexDrawBegin(7, slowPeriod);
   //----
   return(0);
}
  
//////////////////////////////////////////////////////////////////////
// Custor indicator deinitialization function                       
//////////////////////////////////////////////////////////////////////

int deinit()
{
   // TODO: add your code here
   return(0);
}

//////////////////////////////////////////////////////////////////////
// Custom indicator iteration function                              
//////////////////////////////////////////////////////////////////////

int start()
{
   string symbolName;
   int i, shift, checksum, counted_bars=IndicatorCounted();
   if (Bars<slowPeriod) return(0); 
   // check for possible errors
   if (counted_bars<0) return(-1);
   // last counted bar will be recounted
   if (counted_bars>0) counted_bars++;
   int limit=Bars-slowPeriod-counted_bars;
   if (counted_bars<1 || checksum!=(fastPeriod+slowPeriod+Period()) || symbolName!=Symbol())
   {
      // Параметры изменены, проводим реинициализацию 
      for(i=1;i<=slowPeriod;i++) ZlrBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) ShamuBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) TlbBuffer[Bars-i]=EMPTY_VALUE;  
      for(i=1;i<=slowPeriod;i++) VegasBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) GhostBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) RevdevBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) HooksBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) ExitBuffer[Bars-i]=EMPTY_VALUE;      
      checksum = fastPeriod+slowPeriod+Period(); 
      symbolName=Symbol();
      limit=Bars-slowPeriod; 
   }
   for (shift=limit; shift>=0; shift--)
   {
      ///////////////////////////////////////////////////////////////
      //	Заполнение массива точек и определение тренда
      ///////////////////////////////////////////////////////////////

      int delta=25,level=100;
      double slowCCI[20], fastCCI[20];        
      int a, up=0, dn=0, upnt=5,dpnt=5;
      for (a=0;a<20;a++)
      {  
         fastCCI[a]=iCCI(NULL,0,fastPeriod,PRICE_TYPICAL,shift+a);       
         slowCCI[a]=iCCI(NULL,0,slowPeriod,PRICE_TYPICAL,shift+a);      
         if (a<8) {
            if (slowCCI[a]>0) up++;
            if (slowCCI[a]<=0) dn++;
         }
		}
	   
      ///////////////////////////////////////////////////////////////
      // Паттерн № 1 - Отскок от нулевой линии (ZLR)
      // -----------------------------------------------------------
      // Паттерн "Отскок от нулевой линии" (ZLR)" представляет собой 
      // сильный отскок CCI от нулевой линии (ZL) или от уровня, 
      // находящегося близко к ней. При этом CCI может отскакивать от 
      // значений в пределах от +100 до -100  как  для  длинных,  
      // так и для коротких позиций. Некоторые трейдеры любят сужать 
      // диапазон до +/-50, считая, что он может обеспечить лучший 
      // отскок. Позиция открывается на первом баре, который отклоняется 
      // или отскакивает от нулевой линии.
      // Рыночная психология в использовании паттерна ZLR системой 
      // Woodies CCI состоит в том, что этот паттерн позволяет трейдерам 
      // покупать при падении и продавать на подъеме. Ни один из 
      // индикаторов, используемых при торговле, не может этого сделать, 
      // кроме CCI.
      // Для большей эффективности, чтобы усилить сигнал на вход, 
      // Вы можете объединить использование паттерна ZLR с паттерном 
      // "Пробой Линии Тренда (TLB)". При использовании ZLR совместно 
      // с TLB для открытия позиции Вы ждете пересечения кривой CCI 
      // паттерна TLB. Торговля с использованием паттерна 
      // ZLR - торговля по тренду. Фактически этот способ торговли 
      // может быть единственным торговым паттерном системы Woodies CCI, 
      // который используется трейдером, давая при этом превосходную 
      // прибыль.
      // ----
      delta=20;  // фильтр биения (|ССI[1]-ССI[2]|>delta)
      level=80; // модуль границы патерна
      ZlrBuffer[shift]=EMPTY_VALUE;
      // ---- ZLR в нисходящем тренде
      if ( dn>=6 && 
      slowCCI[0]<slowCCI[1] && slowCCI[2]<slowCCI[1] && 
      MathAbs(slowCCI[0])<level && MathAbs(slowCCI[1])<level &&
      MathAbs(slowCCI[1]-slowCCI[2])>delta )
	   {
         ZlrBuffer[shift]=High[shift]+upnt*Point; 
         upnt=upnt+5;
	   }
	   // ZLR в восходящем тренде
      if ( up>=6 	   
      && slowCCI[0]>slowCCI[1] && slowCCI[2]>slowCCI[1] && 
      MathAbs(slowCCI[0])<level && MathAbs(slowCCI[1])<level &&
      MathAbs(slowCCI[1]-slowCCI[2])>delta )
	   {
         ZlrBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
	   }	   

      ///////////////////////////////////////////////////////////////
      // Паттерн № 2 - Шаму (shamu trade) 
      // -----------------------------------------------------------      
      // Паттерн "Шаму (shamu trade)" формируется, когда CCI пересекает 
      // нулевую линию (ZL), затем разворачивается назад и снова 
      // пересекает нулевую линию (ZL) в противоположном направлении, 
      // затем еще раз разворачивается и пересекает нулевую линию, 
      // продолжая движение в первоначальном направлении. 
      // Это - вид зигзагообразного паттерна вокруг ZL. 
      // Он не обязательно возникает непосредственно на нулевой линии, 
      // но лучшие паттерны Шаму формируются при возникновении зигзага 
      // CCI в пределах значений +/-50.
      // Торговый паттерн Шаму - это неудавшийся паттерн ZLR. 
      // Первоначально это был паттерн ZLR. Но ZLR развернулся в 
      // противоположном направлении и не сформировался, так что мы 
      // должны выходить. Вот почему Вы не ждете разворота в надежде на то, 
      // что торговля вернется в нужное русло. Если во всех этих торговых 
      // случаях Вы изначально открываете позицию по паттерну ZLR, 
      // то зависит от Вас, и если Вы вовремя не вышли, то можете понести 
      // потенциально большие потери. 
      // Торговля с использованием паттерна Шаму - по сути является 
      // противотрендовой, и была развита как способ торговли по принципу 
      // stop-and-reverse (SAR) к неудавшемуся ZLR. Новички, только 
      // начавшие изучать систему Woodies CCI, не должны использовать 
      // этот способ торговли. Однако обратите на него внимание и 
      // изучайте по мере продвижения в освоении системы.
      // ----
      delta=15; level=50;
      ShamuBuffer[shift]=EMPTY_VALUE;
      // шаму в нисходящем тренде
      if (dn>=6 &&
	   slowCCI[0]>slowCCI[1]+delta && 
	   slowCCI[1]<slowCCI[2] && slowCCI[2]>slowCCI[3] && 
	   slowCCI[1]<=level && slowCCI[1]>=-level && 
	   slowCCI[2]<=level && slowCCI[2]>=-level) 
	   {
         ShamuBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
	   }
	   // шаму в восходящем тренде
	   if (up>=6 && 
	   slowCCI[0]<slowCCI[1]-delta && 
	   slowCCI[1]>slowCCI[2] && slowCCI[2]<slowCCI[3] && 
	   slowCCI[1]>=-level && slowCCI[1]<=level && 
	   slowCCI[2]>=-level && slowCCI[2]<=level)
	   {
         ShamuBuffer[shift]=High[shift]+upnt*Point; 
         upnt=upnt+5;
	   }

      ///////////////////////////////////////////////////////////////
      // Паттерн № 3 - Пробой Линии Тренда (TLB)
      // -----------------------------------------------------------  
      // Паттерн "Пробой Линии Тренда (TLB)" использует два или более 
      // приличных размеров пика или впадины, образуемых CCI или TCCI 
      // для того, чтобы провести через них линию тренда. При пересечении 
      // или пробитии CCI этой линии тренда (tl), возникает сигнал для 
      // открытия позиции. При этом, чтобы сигнал был действительным, 
      // один конец линии тренда должен располагаться на уровне +/-100 
      // CCI или более. Чем больше точек касания имеет такая линия тренда, 
      // тем более значимой она является. Использование только двух точек 
      // касания является нормальным и создает отлично действующий 
      // паттерн TLB. Также возможно совместное использование касаний 
      // CCI и TCCI для каждой линии тренда. Этот паттерн также используется 
      // как один из сигналов выхода или как CCI сигнал подтверждения. 
      // Это весьма удобно и широко используется в системе Woodies CCI.
      // Торговля с использованием паттерна TLB может проводиться как 
      // по тренду, так и против тренда. Новички, использующие систему 
      // Woodies CCI, должны торговать с помощью паттерна TLB только по 
      // тренду. Однако присмотритесь к нему и изучайте его по мере 
      // продвижения в освоении системы.
      // Вы можете комбинировать использование паттерна "Откат от 
      // нулевой линии (ZLR)" и паттерна "Обратная дивергенция (rev diver)" 
      // с паттерном "Пробой Линии Тренда (TLB)" для усиления сигнала и 
      // большей вероятности успеха. При их совместном использовании Вы 
      // открываете позицию при прорыве линии тренда, поскольку это 
      // произойдет в последнюю очередь.
      // Другой метод входа в торговлю по TLB состоит в использовании 
      // сигнала подтверждения от CCI, - пересечение им уровня +/-100. 
      // Это дает больший шанс успешности сделки. Вы можете не использовать 
      // этот метод и, тем не менее, получить большую прибыль при торговле 
      // по TLB, если Вы входите задолго до этого уровня. Однако если Вы 
      // не добавите подтверждение CCI в виде пересечения им уровня +/-100, 
      // тогда ваша торговля по TLB может часто не срабатывать. Выберите 
      // способ входа и придерживайтесь его. Не меняйте его ежедневно.
      // Вы очень часто будете находить возникающими совместно паттерны TLB и 
      // ZLR. Иногда вместе с ними будет также появляться паттерн "rev diver". 
      // Вы должны начать различать, когда CCI паттерны следуют один за другим, 
      // а когда формируются вместе, что усиливает сигналы. Пусть Вас это не 
      // смущает. Вам необходим только один CCI паттерн, чтобы открыть позицию. 
      // Однако если возникает комбинация из нескольких сигналов, то вероятность 
      // успеха этой сделки увеличивается.
      // -----------------------------------------------------------        
      // Пробой Горизонтальной Линии Тренда (HTLB)
      // -----------------------------------------------------------        
      // При торговле на пробое горизонтальной линии тренда (HTLB) - 
      // линия тренда проводится горизонтально через вершины отскоков 
      // CCI и TCCI от нулевой горизонтальной линии, которые выстраиваются 
      // в хороший прямой ряд, но наиболее часто в этих паттернах 
      // используется CCI.
      // Линию тренда можно провести через внутренние или внешние точки 
      // отката по любую сторону от нулевой линии. Однако все точки отката 
      // должны располагаться на одной стороне от нулевой линии. Лучший 
      // результат может быть достигнут при пробое горизонтальной 
      // линии тренда, расположенной в пределах +/-50.
      // В идеале горизонтальная линия тренда строится через три и более 
      // точки отката, но может быть проведена и через две точки. 
      // Каждый откат на один и тот же горизонтальный уровень показывает, 
      // что в этой области располагается своего рода зона поддержки или 
      // сопротивления. При прорыве этой линии можно ожидать сильное 
      // движение и, соответственно, хорошую прибыль. Этот паттерн часто 
      // можно встретить на консолидирующемся рынке. 
      // Торговля на пробое горизонтальной линии тренда может вестись 
      // как по тренду, так и против тренда. Сигналы на выход те же самые, 
      // что и при любом другом способе торговли. 
      // ----           
      
      delta=25; level=100;
      // ----
      TlbBuffer[shift]=EMPTY_VALUE;      
      int min1=0,min2=0,min3=0,max1=0,max2=0,max3=0;        // значения мин/мах 
      int tmin1=0,tmin2=0,tmin3=0,tmax1=0,tmax2=0,tmax3=0;  // время мин/мах
      double kmin=0,kmax=0; // линейный коэффициент
      double line; 
      //	Определение мин/макс и построение линии тренда
      for (a=0;a<=17;a++)
      { 
         // определение максимумов
         if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
			{
            if (max1!=0 && max2==0)
				{
					max2=slowCCI[a+1];
					tmax2=Time[a+1+shift];
					kmax=100*(max2-max1)/(tmax2-tmax1);
				}
				if (max1==0)
				{
					max1=slowCCI[a+1];
					tmax1=Time[a+1+shift];
				}
			}
         // определение минимумов
         if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
			{
				if (min1!=0 && min2==0)
				{
					min2=slowCCI[a+1];
					tmin2=Time[a+1+shift];
					kmin=100*(min2-min1)/(tmin2-tmin1);
				}
				if (min1==0)
				{
					min1=slowCCI[a+1];
					tmin1=Time[a+1+shift];
				}
			}
      }

      // TLB ctr в нисходящем тренде
      if (kmax!=0 && dn>=6 && (max1<-level || max2<-level))
      {
		   line=(Time[shift]-tmax1)*kmax/100+max1;
		   if (slowCCI[1]<line && slowCCI[0]>=line) 
		   {
		      TlbBuffer[shift]=Low[shift]-dpnt*Point;
            dpnt=dpnt+5;
		   }
      }
      //  TLB ctr в восходящем тренде
      if (kmin!=0 && up>=6 && (min1>level || min2>level))	
      {
		   line=(Time[shift]-tmin1)*kmin/100+min1;
         if (slowCCI[1]>line && slowCCI[0]<=line) 
         {
            TlbBuffer[shift]=High[shift]+upnt*Point;
            upnt=upnt+5;
         }
      }
      // TLB tr в нисходящем тренде
	   if (kmin!=0 && dn >=6 && (min1<-level || min2<-level))
      {
         line=(Time[shift]-tmin1)*kmin/100+min1;
         if (slowCCI[1]>line && slowCCI[0]<line) 
         {
            TlbBuffer[shift]=High[shift]+upnt*Point;
            upnt=upnt+5;
         }
		}	
      //  TLB tr в восходящем тренде
      if (kmax!=0 && up>=6 && (max1>level || max2>level))
      {
		   line=(Time[shift]-tmax1)*kmax/100+max1;
         if (slowCCI[1]<line && slowCCI[0]>line) 
         {
            TlbBuffer[shift]=Low[shift]-dpnt*Point;
            dpnt=dpnt+5;
         }
      } 
      
      ///////////////////////////////////////////////////////////////
      // Паттерн № 4 - Вегас (VT)
      // -----------------------------------------------------------  
      // Паттерн Вегас (VT) является комбинацией нескольких вещей. 
      // Во-первых, должен возникнуть CCI паттерн "Экстремальный Крюк (HFE)", 
      // после этого должен появиться набор CCI баров в виде частично 
      // закругленного или округлого паттерна. Таких округлых баров должно 
      // быть как минимум 3 бара по направлению к нулевой линии или от нее. 
      // Другими словами, закругление может быть в любом направлении в 
      // зависимости от того, на какой стороне от нулевой линии (ZL) формируется 
      // входной паттерн. Однако входной паттерн VT должен сформироваться 
      // только на одной стороне от нулевой линии. Это означает, что первая 
      // часть (от крюка CCI) колебания паттерна high/low не является закругленной 
      // частью паттерна. Более сильный сигнал возникает, когда колебание 
      // паттерна high/low становится закругленной частью. Также паттерн может 
      // иметь несколько колебаний high/low. Закругление очень важно для 
      // паттерна в целом и указывает на борьбу, которая вполне может привести 
      // к сильному развороту тренда.
      // Последняя часть паттерна - линия тренда, проведенная прямо через 
      // верх или низ недавнего колебания. Прорыв вверх или вниз этого уровня - 
      // наш вход в торговлю.
      // ----
      // Обычно полный паттерн "Вегас (VT)" формируется где-нибудь за период 
      // от 8 до 12 баров и более, но если он становится слишком широким до 
      // появления сигнала на вход, тогда вероятность успеха снижается, и сила 
      // движения может быть меньше. Паттерн "Вегас (VT)"  указывает на 
      // потенциальную возможность очень сильного изменения тренда.
      // Woodie настоятельно рекомендует использовать 25-lsma индикатор 
      // как дополнительный критерий входа по паттерну "Вегас (VT)". 
      // Когда 25-lsma индикатор показывает, что цена находится на стороне 
      // направления входа по паттерну "Вегас (VT)", существует большая 
      // вероятность того, что торговля будет успешной. Аббревиатура 
      // скользящей средней LSMA означает Least Squares Moving Average, 
      // и такая скользящая средняя может быть найдена в некоторых 
      // графических пакетах под именем "Кривая линейной регрессии" 
      // (Linear Regression Curve).
      // Другими словами, если паттерн "Вегас (VT)" формируется для 
      // длинного входа, необходимо, чтобы цена была выше 25-lsma индикатора 
      // и, по возможности, 25-lsma также был направлен вверх. Если паттерн 
      // VT формируется для короткого входа, необходимо, чтобы цена была 
      // ниже 25-lsma и, желательно, чтобы 25-lsma также был направлен вниз. 
      // Так как мы не используем цены, чтобы торговать по системе Woodies CCI, 
      // то рекомендуется на графике цены отображать только 25-lsma индикатор. 
      // А лучше использовать 25-lsma индикатор, размещенный на одном графике 
      // с CCI, чтобы отдельным цветом показать эти четыре условия.
      // Торговля с использованием паттерна "Вегас" по сути - торговля 
      // против тренда. 
      // ----      
      delta=10; limit=200;
      // ----  
      max1=0; max2=0; tmax1=0; tmax2=0;
      min1=0; min2=0; tmin1=0; tmin2=0;
      VegasBuffer[shift]=EMPTY_VALUE;        
      // определение точек
      if  (dn>=6)
      {
         for (a=13;a>=1;a--)
         {
            if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2] && 
            min1!=0 && max1==0)
            {
               max1=slowCCI[a+1];
					tmax1=a+1;
			   }
            if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2] &&
             min1==0 && slowCCI[a+1]<=-limit && a+1>=5)
            {				
					min1=slowCCI[a+1];
					tmin1=a+1;
            }
         }
	   }
      //  Определение точек.
      if (up>=6) 
      {
         for (a=13;a>=1;a--)
         {
			   if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2] && 
			   min2!=0 && max2==0)
            {
					min2=slowCCI[a+1];
					tmin2=a+1;
            }
            if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2] && 
            max2==0 && slowCCI[a+1]>=limit && a+1>=5)
            {				
               max2=slowCCI[a+1];
               tmax2=a+1;
            }
         }
      }      

      // Vegas в нисходящем тренде
      if (dn>=6 && max1!=0 && slowCCI[1]<max1 && slowCCI[0]>=max1 && 
      slowCCI[0]-delta>slowCCI[1] /* && slowCCI[0]>slowCCI[1] && !(slowCCI[1]-delta>slowCCI[2]) */)
      {
		   VegasBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;	
      }
      //  Vegas в восходящем тренде
      if (up >=6 && min2!=0 && slowCCI[1]>min2 && slowCCI[0]<=min2 &&
      slowCCI[0]+delta<slowCCI[1] 
		/* && slowCCI[0]<slowCCI[1] && !(slowCCI[1]+delta<slowCCI[2]) */)
      {
			VegasBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;			
      }
      
      ///////////////////////////////////////////////////////////////
      // Паттерн № 5 - Призрак (Ghost)
      // -----------------------------------------------------------  
      // Паттерн "Призрак" формируется 3 вершинами, которые последовательно 
      // образуют: одну руку, голову и затем другую руку. (Наверное, 
      // точнее будет сказать: "Голова и плечи"). Эти фигуры могут быть 
      // сформированы как CCI, так и TCCI. Тем не менее, большинство 
      // трейдеров используют CCI для определения этого паттерна. 
      // Желательно, чтобы голова была больше плеч. Для определения 
      // точки входа по нижним точкам паттерна "Призрак" - линии 
      // шеи - проводится линия тренда.
      // Вы можете рассчитать ожидаемое движение CCI для паттерна "Призрак", 
      // измеряя расстояние от вершины головы до линии шеи, и оно будет 
      // равно расстоянию от линии шеи до головы в противоположном 
      // направлении. В принципе Вы можете не высчитывать возможное 
      // потенциальное движение CCI от линии шеи, так как Вы должны 
      // закрыть позицию, как только CCI даст сигнал на выход. Все, 
      // что Вы должны делать - следовать за сигналами выхода, 
      // определенными системой Woodies CCI.
      // Заметьте, что, когда Вы проводите линию шеи (линия тренда) 
      // на паттерне "Призрак", Вы объединяете паттерн "Прорыв линии 
      // тренда (TLB)" с паттерном "Призрак", что усиливает сигнал и 
      // увеличивает вероятность успеха. Иногда линия шеи наклонена 
      // по направлению к нулевой линии. Это - более предпочтительный 
      // вариант паттерна "Призрак" по сравнению с тем, при котором 
      // линия шеи отклоняется от нулевой линии. В любом случае оба 
      // варианта могут быть использованы для торговли.
      // Торговля с использованием паттерна "Призрак" по сути - торговля 
      // против тренда. 
      // -----
      delta=15; level=50;
      max1=0; max2=0; max3=0; tmax1=0; tmax2=0; tmax3=0;
      min1=0; min2=0; min3=0; tmin1=0; tmin2=0; tmin3=0;
      // -----  
      GhostBuffer[shift]=EMPTY_VALUE;        
      // определение максимумов
      if (up>=6) for (a=0;a<=17;a++)
      { 
         if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
			{
				if (max2!=0 && max3==0) max3=slowCCI[a+1];
				if (max1!=0 && max2==0) max2=slowCCI[a+1];
				if (max1==0) max1=slowCCI[a+1];
			}
      }
      // определение минимумов
      if (dn>=6) for (a=0;a<=17;a++) 
      {     
         if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
			{
				if (min2!=0 && min3==0) min3=slowCCI[a+1];
				if (min1!=0 && min2==0) min2=slowCCI[a+1];
				if (min1==0) min1=slowCCI[a+1];
			}
      }
      // Ghost в нисходящем тренде
	   if (dn>=6 && 
	   min3!=0 && min1>min2 && min3>min2+delta && min1<0 &&
		slowCCI[0]-delta>min1 && slowCCI[0]>slowCCI[1] && 
   /* min3<0 && max1<=0 && max1>=-level && max2<=level && max2>=-level */
      !(slowCCI[1]-delta>min1))
      {		
		   GhostBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;			
      }
      // Ghost в восходящем тренде
      if (up>=6 && 
      max3!=0 && max1<max2 && max3<max2-delta && max1>0 && 
      slowCCI[0]+delta<max1 && slowCCI[0]<slowCCI[1] && 
   /* max3>0 && min1<=level && min1>=0 && min2<=level && min2>=-level */
		!(slowCCI[1]+delta<max1))
      {
         GhostBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;			
      }

      ///////////////////////////////////////////////////////////////
      // Паттерн № 6 - Разворотная дивергенция Woodies CCI (Rev Diver)
      // -----------------------------------------------------------  
      // Разворотная дивергенция Woodies CCI (Rev Diver) - очень простой 
      // паттерн торговли по тренду, который определяется двумя 
      // отскоками CCI, последний из которых находится ближе к нулевой линии. 
      // Под словом отскок мы подразумеваем пики и впадины, образуемые 
      // движением CCI вверх и вниз. Мы говорим внутренние отскоки, 
      // имея в виду пики и впадины, которые расположены ближе к нулевой линии. 
      // Мы никогда не используем экстремумы, чтобы определить паттерн Rev Diver.
      // ---- 
      // Следующие два правила - это все, что необходимо для определения 
      // паттерна Rev Diver:
      // * Rev Diver на покупку - CCI выше нулевой линии в течение последних 
      //   6 и более баров, два из которых - понижающиеся пиковые впадины
      // * Rev Diver на продажу - CCI ниже нулевой линии в течение последних 
      //   6 и более баров, два из которых - повышающиеся пики к нулевой линии
      // ---- 
      // Паттерн "Разворотная дивергенция" - паттерн торговли по тренду. 
      // Вы можете объединить торговлю с использованием Rev Diver с паттернами 
      // "Отскок от нулевой линии (ZLR)" или "Пробой линии тренда (TLB)" 
      // для уверенности и получения большей прибыльности сделки. Вы практически 
      // всегда будете находить сочетание паттерна ZLR с паттерном Rev Diver. 
      // Фактически у Вас обычно будет два паттерна ZLR, которые образуют Rev Diver, 
      // так как обычно пики или впадины образуются в пределах +/-100  шкалы CCI. 
      // Внутренние пики или впадины фактически представляют паттерн CCI ZLR. 
      // Посмотрите графики внимательно, и Вы увидите их оба на каждом графике.
      // ---- 
      delta=20; level=70;
      // ----       
      max1=0; max2=0; tmax1=0; tmax2=0;
      min1=0; min2=0; tmin1=0; tmin2=0;
      // -----  
      RevdevBuffer[shift]=EMPTY_VALUE;        
      // определение максимумов
      if (dn>=6) for (a=0;a<=17;a++)
      { 
         if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
			{
				if (max1!=0 && tmax1<3 && max2==0)
				{
					max2=slowCCI[a+1];
					tmax2=a+1;
				}
				if (max1==0)
				{
					max1=slowCCI[a+1];
					tmax1=a+1;
				}
			}
      }
      // определение минимумов
      if (up>=6) for (a=0;a<=17;a++) 
      {     
         if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
			{
				if (min1!=0 && tmin1<3 && min2==0)
				{
					min2=slowCCI[a+1];
					tmin2=a+1;
				}
				if (min1==0)
				{
					min1=slowCCI[a+1];
					tmin1=a+1;
				}
			}
      }
      // Revdiv в нисходящем тренде
	   if (dn>=6 && 
	   max1<=0 && max2!=0 && max1>max2 && max1>=-level && tmax2-tmax1>=3 &&
   /* max2<=level && max2>=-level && */
	   slowCCI[0]+delta<max1 && slowCCI[0]<slowCCI[1] && !(slowCCI[1]+delta<max1) )
      {
         RevdevBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;			
      }
      // Revdiv в восходящем тренде
	   if (up>=6 && 
	   min1>=0 && min2!=0 && min1<min2 && min1<=level && tmin2-tmin1>=3 &&
   /* pmn2<=level && pmn2>=-level && */
      slowCCI[0]-delta>min1 && slowCCI[0]>slowCCI[1] && !(slowCCI[1]-delta>min1) )
      {	
         RevdevBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
      }

      ///////////////////////////////////////////////////////////////
      // Паттерн № 7 - Экстремальный Крюк (HFE)
      // -----------------------------------------------------------        
      // Этот паттерн формируется, когда CCI уходит за пределы +/-200, 
      // а затем разворачивается назад к нулевой линии. Эта - очень 
      // трудный способ торговли. Паттерн HFE является также одним из 
      // Woodies CCI сигналов выхода.
      // ----      
      // Торговля по этому паттерну происходит очень быстро. Как только 
      // крюк разворачивается назад к нулевой линии, входите. Установите 
      // близкие ордера стоп-лосс сразу же при входе в рынок, поскольку 
      // торговый сигнал может развернуться очень быстро. Как только 
      // появился сигнал к выходу - выходите немедленно.
      // Торговля будет останавливаться часто, и это может случиться, 
      // даже если нет CCI сигнала на выход. Вероятность успешной 
      // торговли составляет приблизительно 50%, если торговать при 
      // каждом сигнале HFE. Однако потенциальная прибыль будет больше 
      // убытков, если Вы будете использовать близкие стоп-лосс ордера.
      // Торговля при развороте от экстремумов по сути является 
      // противотрендовой, поэтому с осторожностью относитесть к 
      // этому паттерну. 
      // ----      
      // Для большей эффективности Вы можете объединить торговлю по 
      // HFE-паттерну с прорывом линии тренда или с пересечением CCI 
      // уровня +/-100, которые являются сигналами подтверждения. 
      // ----
      delta=10; level=200;
      HooksBuffer[shift]=EMPTY_VALUE;        
      // HFE в нисходящем тренде
      if (dn>=6 && 
      slowCCI[1]<=-level && slowCCI[0]>-level && slowCCI[1]<slowCCI[0]-delta)
      {
         HooksBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
      }
      // HFE восходящем тренде
      if (up>=6 && 
      slowCCI[1]>=level && slowCCI[0]<level && slowCCI[1]>slowCCI[0]-delta)
      {
         HooksBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;
      } 
     
      ///////////////////////////////////////////////////////////////
      // Сигнал на выход
      // -----------------------------------------------------------
      // 1. Разворот (CCI(14) образует крюк) или плоское движение CCI	
      // 2. Пробой CCI линии тренда (TLB)		
      // 3. CCI(6) пересекает CCI(14) вовнутрь		
      // 4. CCI пересекает нулевую линию (ZLC).
      // 5. Когда CCI 14 образует крюк около уровня +/-200 или за ним
      // 6. CCI (без движения нет успеха)
      // -----------------------------------------------------------

      // 1. Разворот (CCI(14) образует крюк) или плоское движение CCI
	   if (HooksBuffer[shift]!=EMPTY_VALUE)
      { 	
         if (up>=6)
	      { 
		      ExitBuffer[shift]=High[shift]+upnt*Point;
            upnt=upnt+5;
		   }
	      if (dn>=6)
	      { 
		      ExitBuffer[shift]=Low[shift]-dpnt*Point;
            dpnt=dpnt+5;
		   }
		}
      // 2. Пробой CCI линии тренда (против тренда)
      if (TlbBuffer[shift]!=EMPTY_VALUE) 
      { 	
         if (up>=6 && TlbBuffer[shift]>High[shift])
	      { 
		      ExitBuffer[shift]=High[shift]+upnt*Point;
            upnt=upnt+5;
		   }
	      if (dn>=6 && TlbBuffer[shift]<Low[shift])
	      { 
		      ExitBuffer[shift]=Low[shift]-dpnt*Point;
            dpnt=dpnt+5;
		   }
		}
		/*
      // 3. CCI(6) пересекает CCI(14) вовнутрь	
      if (up>=6 && fastCCI[1]>=slowCCI[1] && fastCCI[0]<=slowCCI[0])
	   { 
		   ExitBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;
		}
	   if (dn>=6 && TlbBuffer[shift]<Low[shift])
	   { 
		   ExitBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
		} */     
      
/*
      delta=10; level=100;
      // ----
      ExitBuffer[shift]=EMPTY_VALUE;  
      min1=0; max1=0; // значения мин/мах 
      //	Определение мин/макс и построение линии тренда
      for (a=0;a<=17;a++)
      { 
         // определение максимумов
         if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
			{
				if (max1==0) max1=slowCCI[a+1];
			}
         // определение минимумов
         if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
			{
				if (min1==0) min1=slowCCI[a+1];
			}
      }
      // выход в нисходящем тренде
	   if (min1!=0 && slowCCI[0]-delta>min1 && !(slowCCI[1]-delta>min1) && MathAbs(slowCCI[0])>level)
      {
		   ExitBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
	   }
      // выход в восходящем тренде
      if (max1!=0 && slowCCI[0]+delta<max1 && !(slowCCI[1]+delta<max1) && MathAbs(slowCCI[0])>level) 
      {
		   ExitBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;
      }
*/
   }    
   return(0);
}


