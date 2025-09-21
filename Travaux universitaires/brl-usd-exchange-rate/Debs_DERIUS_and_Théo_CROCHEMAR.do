 import excel "C:\Users\deriu\Downloads\devoir.xlsx", sheet("Feuil1") firstrow clear
(8 vars, 21 obs)

. save "C:\Users\deriu\Downloads\new_devoir.dta", replace
(file C:\Users\deriu\Downloads\new_devoir.dta not found)
file C:\Users\deriu\Downloads\new_devoir.dta saved

. browse

. 
. tsset Année

Time variable: Année, 2000 to 2020
        Delta: 1 unit
*  Lets do some descriptive statistics and graphics
/*   Lets do some descriptive statistics and graphics */
. tsline TXdechanBra
variable TXdechanBra not found
r(111);

. tsline TxdechanBra

. tsline TxdechanBra expBra TxdinteretBra ImpBra PibBra IdeBra TxdinteretUSA

. *From the graph, GDP appears to have no relationship with the dependent variable. It would be better to consider GDP growth, which more effectively captures fluctuations or economic cycles.
*On the other hand, exports and imports have a strong relationship, they fluctuate in the same way, with a potential correlation risk to verify.
/* On the other hand, exports and imports have a strong relationship, they fluctuate in the same way, with a potential correlation risk to verify. */
. gen CrPib= 100 * (D.PibBra/ L.PibBra)
(1 missing value generated)


* After adding this new variable, exports and imports remain strongly correlated with each other, but FDI does not have a strong relationship with the dependent variable, which is the exchange rate. All other variables have a strong correlation with the exchange rate.
/* After adding this new variable, exports and imports remain strongly correlated with each other, but FDI does not have a strong relationship with the dependent variable, which is the exchange rate. All other variables have a strong correlation with the exchange rate. */
 . tsline  TxdechanBra expBra TxdinteretBra ImpBra CrPib IdeBra TxdinteretUSA



.* summarize

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       Année |         21        2010    6.204837       2000       2020
 TxdechanBra |         21    2.673773    .8922786   1.672829   5.155179
      expBra |         21    2.00e+11    8.09e+10   6.68e+10   3.03e+11
Txdinteret~a |         21     35.9832     8.99176   18.49884   48.50473
      ImpBra |         21    2.05e+11    9.55e+10   6.83e+10   3.47e+11
-------------+---------------------------------------------------------
      PibBra |         21    1.56e+12    7.08e+11   5.10e+11   2.62e+12
      IdeBra |         21    5.22e+10    2.94e+10   1.01e+10   1.02e+11
Txdinteret~A |         21    2.844892    1.434602   1.162899   6.813792
       CrPib |         20    5.564223    17.56163  -26.62133   33.22097



. hist TxdechanBra
(bin=4, start=1.6728288, width=.87058751)



. hist CrPib
(bin=4, start=-26.62133, width=14.960574)

. hist TxdinteretUSA
(bin=4, start=1.1628987, width=1.4127235)

.
. hist TxdinteretBra
(bin=4, start=18.498844, width=7.5014709)
.
. hist expBra
(bin=4, start=6.678e+10, width=5.906e+10)

. . hist ImpBra
(bin=4, start=6.825e+10, width=6.976e+10)

.  hist IdeBra
(bin=4, start=1.012e+10, width=2.308e+10)

* Now we do the linear regression
/* Now we do the linear regression   */

. reg TxdechanBra CrPib expBra ImpBra IdeBra TxdinteretUSA TxdinteretBra

      Source |       SS           df       MS      Number of obs   =        20
-------------+----------------------------------   F(6, 13)        =      5.13
       Model |  10.6688674         6  1.77814457   Prob > F        =    0.0066
    Residual |  4.50578242        13  .346598648   R-squared       =    0.7031
-------------+----------------------------------   Adj R-squared   =    0.5660
       Total |  15.1746498        19   .79866578   Root MSE        =    .58873

-------------------------------------------------------------------------------
  TxdechanBra | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
        CrPib |  -.0387203   .0083756    -4.62   0.000    -.0568148   -.0206258
       expBra |   3.28e-11   8.32e-12     3.94   0.002     1.49e-11    5.08e-11
       ImpBra |  -3.35e-11   1.17e-11    -2.87   0.013    -5.87e-11   -8.32e-12
       IdeBra |   3.08e-12   1.69e-11     0.18   0.858    -3.35e-11    3.96e-11
TxdinteretUSA |  -.1779665   .1419636    -1.25   0.232    -.4846603    .1287273
TxdinteretBra |  -.0439383   .0419104    -1.05   0.314    -.1344802    .0466036
        _cons |   5.093416   2.342845     2.17   0.049     .0320077    10.15482
-------------------------------------------------------------------------------

* We remove the variable "IdeBra" because it is the variable with the highest value added. It is the most insignificant variable.
/*  We remove the variable "IdeBra" because it is the variable with the highest value added. It is the most insignificant variable. */

.  reg TxdechanBra CrPib expBra ImpBra  TxdinteretUSA TxdinteretBra

      Source |       SS           df       MS      Number of obs   =        20
-------------+----------------------------------   F(5, 14)        =      6.61
       Model |  10.6573865         5  2.13147731   Prob > F        =    0.0023
    Residual |   4.5172633        14  .322661664   R-squared       =    0.7023
-------------+----------------------------------   Adj R-squared   =    0.5960
       Total |  15.1746498        19   .79866578   Root MSE        =    .56803

-------------------------------------------------------------------------------
  TxdechanBra | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
        CrPib |  -.0385574    .008035    -4.80   0.000    -.0557907   -.0213241
       expBra |   3.25e-11   7.88e-12     4.13   0.001     1.56e-11    4.94e-11
       ImpBra |  -3.19e-11   7.60e-12    -4.20   0.001    -4.82e-11   -1.56e-11
TxdinteretUSA |  -.1777113   .1369671    -1.30   0.215    -.4714765    .1160538
TxdinteretBra |  -.0387587   .0296849    -1.31   0.213    -.1024265    .0249091
        _cons |   4.802959   1.654941     2.90   0.012     1.253464    8.352454
-------------------------------------------------------------------------------
**We decided to keep "TxdinteretUSA" and "TxdinteretBra," although insignificant at the 5% threshold. Since the number of observations is small (20), we might omit important variables. We will decide if it is worth it after the various tests.
/* *We decided to keep "TxdinteretUSA" and "TxdinteretBra," although insignificant at the 5% threshold. Since the number of observations is small (20), we might omit important variables. We will decide if it is worth it after the various tests. */

***Detection of outliers
/* **Detection of outliers */
. predict res


. *hist res

. hist res
(bin=4, start=1.4719526, width=.84198698)

.**Detection of outliers

. rvfplot, msize(medium) mlabsize(small) mlabel(TxdechanBra) yline(0,lcolor(red))

. rvfplot, msize(medium) mlabsize(small) mlabel(TxdechanBra)

. graph save "Graph" "C:\Users\deriu\Downloads\Graph18.gph"
file C:\Users\deriu\Downloads\Graph18.gph saved

. lvr2plot, msize(small) yline(0.03) xline(0.005) mlabel(TxdechanBra)

. graph save "Graph" "C:\Users\deriu\Downloads\Graph19.gph"
file C:\Users\deriu\Downloads\Graph19.gph saved
****Multicolinearity test
/* ***Multicolinearity test */
. vif

    Variable |       VIF       1/VIF  
-------------+----------------------
      ImpBra |     29.82    0.033538
      expBra |     21.61    0.046272
Txdinteret~a |      3.97    0.252109
Txdinteret~A |      1.43    0.698543
       CrPib |      1.17    0.852897
-------------+----------------------
    Mean VIF |     11.60
***Correction of multicollinearity by transforming the two correlated variables into a trade balance. Economically, it makes sense
/* **Correction of multicollinearity by transforming the two correlated variables into a trade balance. Economically, it makes sense. */
. gen solde_com= expBra-ImpBra
 
. reg TxdechanBra CrPib solde_com  TxdinteretUSA TxdinteretBra

      Source |       SS           df       MS      Number of obs   =        20
-------------+----------------------------------   F(4, 15)        =      8.81
       Model |  10.6442237         4  2.66105593   Prob > F        =    0.0007
    Residual |  4.53042611        15  .302028408   R-squared       =    0.7014
-------------+----------------------------------   Adj R-squared   =    0.6218
       Total |  15.1746498        19   .79866578   Root MSE        =    .54957

-------------------------------------------------------------------------------
  TxdechanBra | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
        CrPib |  -.0382991   .0076747    -4.99   0.000    -.0546573   -.0219408
    solde_com |   3.21e-11   7.32e-12     4.39   0.001     1.65e-11    4.77e-11
TxdinteretUSA |  -.1847874    .128107    -1.44   0.170    -.4578411    .0882662
TxdinteretBra |  -.0429792   .0203991    -2.11   0.052    -.0864588    .0005004
        _cons |   5.092798   .7975564     6.39   0.000     3.392847    6.792749
-------------------------------------------------------------------------------

. vif

    Variable |       VIF       1/VIF  
-------------+----------------------
   solde_com |      2.33    0.428269
Txdinteret~a |      2.00    0.499734
Txdinteret~A |      1.34    0.747447
       CrPib |      1.14    0.875069
-------------+----------------------
    Mean VIF |      1.70
*****No multicollinearity
/* ****No multicollinearity */

**Heteroskedasticity test
/* *Heteroskedaticity test */
. estat hettest

Breusch–Pagan/Cook–Weisberg test for heteroskedasticity 
Assumption: Normal error terms
Variable: Fitted values of TxdechanBra

H0: Constant variance

    chi2(1) =   0.00
Prob > chi2 = 0.9492

. 
. hettest

Breusch–Pagan/Cook–Weisberg test for heteroskedasticity 
Assumption: Normal error terms
Variable: Fitted values of TxdechanBra

H0: Constant variance

    chi2(1) =   0.00
Prob > chi2 = 0.9492

. 
. estat imtest, white

White's test
H0: Homoskedasticity
Ha: Unrestricted heteroskedasticity

   chi2(14) =  14.47
Prob > chi2 = 0.4150

Cameron & Trivedi's decomposition of IM-test

--------------------------------------------------
              Source |       chi2     df         p
---------------------+----------------------------
  Heteroskedasticity |      14.47     14    0.4150
            Skewness |       4.44      4    0.3503
            Kurtosis |       0.97      1    0.3248
---------------------+----------------------------
               Total |      19.88     19    0.4019
--------------------------------------------------

. *No proof of heteroskedasticity


***Autocorrelation test
/* **Autocorrelationtest */
. predict r
(option xb assumed; fitted values)
(1 missing value generated)

. estat dwatson

Durbin–Watson d-statistic(  5,    20) =  1.733364

. 
. scalar rho = 1-(1.021169/2)

. 
. display rho
.4894155

. scalar rho = 1-(1.733364/2)

. diplay rho
command diplay is unrecognized
r(199);

. display rho
.133318

. * No autocorrelation



***Chow test considering the year 2010 as a break
/* **Chow test considering the year 2010 as a break */



. gen break = Année > 2010
variable break already defined
r(110);

. gen break1 = Année> 2010

. gen avant_break = Année <= 2010



**Regression for the period after 2010
/* *Regression for the period after 2010 */

. regress TxdechanBra solde_com CrPib TxdinteretUSA TxdinteretBra if break1 == 1

      Source |       SS           df       MS      Number of obs   =        10
-------------+----------------------------------   F(4, 5)         =     13.45
       Model |  9.38440784         4  2.34610196   Prob > F        =    0.0069
    Residual |  .872447659         5  .174489532   R-squared       =    0.9149
-------------+----------------------------------   Adj R-squared   =    0.8469
       Total |  10.2568555         9  1.13965061   Root MSE        =    .41772

-------------------------------------------------------------------------------
  TxdechanBra | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
    solde_com |   2.82e-11   7.46e-12     3.78   0.013     9.03e-12    4.74e-11
        CrPib |  -.0190147   .0122661    -1.55   0.182    -.0505458    .0125164
TxdinteretUSA |   .6759994   .2508877     2.69   0.043     .0310719    1.320927
TxdinteretBra |  -.0693651   .0275133    -2.52   0.053    -.1400903    .0013602
        _cons |   4.195997   .9816559     4.27   0.008      1.67257    6.719424
-------------------------------------------------------------------------------

*Store the estimated coefficients
/* Store the estimated coefficients

 */
. estimates store A

. 
. 
. ***Regression before 2010
. regress TxdechanBra solde_com TxdinteretUSA TxdinteretBra if avant_break == 1

      Source |       SS           df       MS      Number of obs   =        11
-------------+----------------------------------   F(3, 7)         =     18.81
       Model |  2.10148763         3  .700495875   Prob > F        =    0.0010
    Residual |   .26061866         7  .037231237   R-squared       =    0.8897
-------------+----------------------------------   Adj R-squared   =    0.8424
       Total |  2.36210629        10  .236210629   Root MSE        =    .19295

-------------------------------------------------------------------------------
  TxdechanBra | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
    solde_com |   5.23e-12   3.43e-12     1.52   0.172    -2.89e-12    1.33e-11
TxdinteretUSA |  -.1945838   .0401645    -4.84   0.002    -.2895578   -.0996099
TxdinteretBra |   .0567754   .0101161     5.61   0.001     .0328546    .0806962
        _cons |   .6161933   .3976589     1.55   0.165    -.3241205    1.556507
-------------------------------------------------------------------------------

. 
. estimates store B


**Compare the 2 regression models
/* *Compare the 2 regression models */
. suest A B

Simultaneous results for A, B                               Number of obs = 20

-------------------------------------------------------------------------------
              |               Robust
              | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
--------------+----------------------------------------------------------------
A_mean        |
    solde_com |   2.82e-11   6.02e-12     4.69   0.000     1.64e-11    4.00e-11
        CrPib |  -.0190147   .0041989    -4.53   0.000    -.0272444    -.010785
TxdinteretUSA |   .6759994   .1324585     5.10   0.000     .4163855    .9356133
TxdinteretBra |  -.0693651   .0143074    -4.85   0.000     -.097407   -.0413232
        _cons |   4.195997   .5895533     7.12   0.000     3.040494      5.3515
--------------+----------------------------------------------------------------
A_lnvar       |
        _cons |  -1.745891   .2382229    -7.33   0.000    -2.212799   -1.278982
--------------+----------------------------------------------------------------
B_mean        |
    solde_com |   6.25e-12   3.92e-12     1.60   0.110    -1.43e-12    1.39e-11
        CrPib |  -.0047093   .0054793    -0.86   0.390    -.0154485    .0060299
TxdinteretUSA |  -.1677973   .0373483    -4.49   0.000    -.2409987    -.094596
TxdinteretBra |   .0523494   .0152167     3.44   0.001     .0225253    .0821735
        _cons |   .7823852   .6798076     1.15   0.250    -.5500132    2.114784
--------------+----------------------------------------------------------------
B_lnvar       |
        _cons |  -3.278898   .2185157   -15.01   0.000    -3.707181   -2.850615
-------------------------------------------------------------------------------

.**H₀ (first hypothesis) : the coefficient are identical in both regression process.

**H₁ (alternative) : At least one coefficient is different. 
/* *H₁ (alternative) : At least one coefficient is different.  */
. test [A_mean= B_mean]

 ( 1)  [A_mean]solde_com - [B_mean]solde_com = 0
 ( 2)  [A_mean]CrPib - [B_mean]CrPib = 0
 ( 3)  [A_mean]TxdinteretUSA - [B_mean]TxdinteretUSA = 0
 ( 4)  [A_mean]TxdinteretBra - [B_mean]TxdinteretBra = 0
       Constraint 1 dropped

           chi2(  3) =   75.88
         Prob > chi2 =    0.0000

. * There is a break obsevable in 2010 we reject H0
. 
****Take into account the break in 2010 by introducing a dummy variable that takes the value of 1 for observations after 2010 and 0 for those before.
/* ***ake into account the break in 2010 by introducing a dummy variable that takes the value of 1 for observations after 2010 and 0 for those before. */
. gen ruptur2010 = (Année >= 2010)

*** Take into account the interactions to test if the effect of the explanatory variables changes before and after the break.
/* **Take into account the interactions to test if the effect of the explanatory variables changes before and after the break. */
. gen interaction2010 = solde_com * ruptur2010

. gen interaction1=ruptur2010*CrPib
(1 missing value generated)

.  gen interaction2=ruptur2010*TxdinteretUSA

.  gen interaction3=ruptur2010*TxdinteretBra

.  


. reg TxdechanBra CrPib solde_com  TxdinteretUSA TxdinteretBra interaction2010 interaction1 interact
> ion2 interaction3 ruptur2010

      Source |       SS           df       MS      Number of obs   =        20
-------------+----------------------------------   F(9, 10)        =     13.67
       Model |  14.0341057         9  1.55934508   Prob > F        =    0.0002
    Residual |   1.1405441        10   .11405441   R-squared       =    0.9248
-------------+----------------------------------   Adj R-squared   =    0.8572
       Total |  15.1746498        19   .79866578   Root MSE        =    .33772

---------------------------------------------------------------------------------
    TxdechanBra | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
----------------+----------------------------------------------------------------
          CrPib |  -.0121956   .0181691    -0.67   0.517    -.0526789    .0282877
      solde_com |   1.43e-11   1.83e-11     0.78   0.453    -2.65e-11    5.51e-11
  TxdinteretUSA |  -.1633692   .1038165    -1.57   0.147    -.3946867    .0679483
  TxdinteretBra |   .0458789   .0368502     1.25   0.242    -.0362284    .1279862
interaction2010 |   1.33e-11   1.93e-11     0.69   0.506    -2.96e-11    5.62e-11
   interaction1 |  -.0139319   .0194862    -0.71   0.491    -.0573498     .029486
   interaction2 |   .7832375   .2211002     3.54   0.005     .2905955     1.27588
   interaction3 |  -.1071759   .0423085    -2.53   0.030    -.2014451   -.0129067
     ruptur2010 |   2.981618   1.887132     1.58   0.145    -1.223175     7.18641
          _cons |   1.032245   1.721438     0.60   0.562    -2.803358    4.867848
---------------------------------------------------------------------------------


***Remove the insignificant variables
/* **Remove the insignificant variables */

.  reg TxdechanBra CrPib solde_com  TxdinteretUSA   interaction2 interaction3

      Source |       SS           df       MS      Number of obs   =        20
-------------+----------------------------------   F(5, 14)        =     25.79
       Model |  13.6887506         5  2.73775013   Prob > F        =    0.0000
    Residual |  1.48589919        14  .106135656   R-squared       =    0.9021
-------------+----------------------------------   Adj R-squared   =    0.8671
       Total |  15.1746498        19   .79866578   Root MSE        =    .32578

-------------------------------------------------------------------------------
  TxdechanBra | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
        CrPib |     -.0262   .0049255    -5.32   0.000    -.0367642   -.0156358
    solde_com |   2.42e-11   3.47e-12     6.99   0.000     1.68e-11    3.17e-11
TxdinteretUSA |  -.2581868   .0849947    -3.04   0.009    -.4404824   -.0758912
 interaction2 |   .9612298   .1740229     5.52   0.000     .5879879    1.334472
 interaction3 |  -.0472991   .0128969    -3.67   0.003    -.0749602    -.019638
        _cons |   3.343123    .286783    11.66   0.000     2.728035    3.958211
-------------------------------------------------------------------------------
***We perform a test of multicollinearity for the new model 
/* **We perform a test of multicollinearity for the new model */

*** Two variables are the cause of the multicollinearity: a result that we were expecting since the new variables that we added to the model are deduced from previous ones(they're the product of former variables by the indicator variable) so we have a problem of imperfect multicollinearity.
/* ** Two variables are the cause of the multicollinearity: a result that we were expecting since the new variables that we added to the model are deduced from previous ones(they're the product of former variables by the indicator variable) so we have a problem of imperfect multicollinearity. */
. vif

    Variable |       VIF       1/VIF  
-------------+----------------------
interaction3 |      7.95    0.125780
interaction2 |      7.52    0.132902
Txdinteret~A |      1.68    0.596699
   solde_com |      1.49    0.671147
       CrPib |      1.34    0.746569
-------------+----------------------
    Mean VIF |      4.00
**Heteroskedasticity test of the new model 
/* *Heteroskedasticity test of the new model */
. estat hettest

Breusch–Pagan/Cook–Weisberg test for heteroskedasticity 
Assumption: Normal error terms
Variable: Fitted values of TxdechanBra

H0: Constant variance

    chi2(1) =   0.25
Prob > chi2 = 0.6202

. estat imtest, white

White's test
H0: Homoskedasticity
Ha: Unrestricted heteroskedasticity

   chi2(18) =  19.88
Prob > chi2 = 0.3398

Cameron & Trivedi's decomposition of IM-test

--------------------------------------------------
              Source |       chi2     df         p
---------------------+----------------------------
  Heteroskedasticity |      19.88     18    0.3398
            Skewness |       8.33      5    0.1392
            Kurtosis |       0.00      1    0.9499
---------------------+----------------------------
               Total |      28.21     24    0.2514
--------------------------------------------------

. * No heteroskedasticity
***Autocorrelation test 
/* **Autocorrelation test */
. estat dwatson

Durbin–Watson d-statistic(  6,    20) =  1.997006

. scalar rho = 1-(1.997006/2)

. display rho
.001497

. *No autocorrelation

.
. 