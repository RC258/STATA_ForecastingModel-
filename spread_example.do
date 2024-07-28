clear
*insheet using "C:\Workingdir\quarterly_csv.csv"
*gen obs=_n
*tsset obs
*save quarterly
use quarterly.dta

*0. Plot data, ACF and PACF of the spread
line sr5 time in 1/212
line sr10 time in 1/212
* Examine the spread series
gen y = sr5
ac y, lags(12)
pac y, yw lags(12)

*A. Estimate series
*Model 1
arima y in 8/212, ar(1 2 3 4 5 6 7)		/* AR(7), mle */
reg y L(1/7).y in 8/212				/* AR(7), ols */
predict resid_ar7, resid
corrgram resid_ar7,yw lag(12)
*A1: Calculate selection criterion
*SSR
display "SSR = "e(rss)
display "AIC = "=e(N)*ln(e(rss))+2*e(df_m) /*compute AIC*/
display "SBC = "=e(N)*ln(e(rss))+e(df_m)*ln(e(N)) /*compute SBC*/
*Model 2
arima y in 8/212, ar(1/6)			/* AR(6), mle */
*selection criterion for ARIMA
predict resid2, resid
corrgram resid2,yw lag(12)
gen sr2 = (resid2)^2 /*calculate squred residuals for SSR*/
egen sr22 = sum(sr2) /*calculate sum of squred residuals for SSR*/
egen ssr2 = rowfirst(sr22) /* SSR */
display "SSR = "ssr2
display "AIC = "=e(N)*ln(ssr2)+2*e(df_m) /*compute AIC*/
display "SBC = "=e(N)*ln(ssr2)+e(df_m)*ln(e(N)) /*compute SBC*/
*Model 3
arima y in 8/212, ar(1 2)			/* AR(2), mle */
*reg y l.y l2.y in 8/212				/* AR(2), ols */
predict resid_ar2, resid
corrgram resid_ar2,yw lag(12)
gen sr3 = (resid_ar2)^2 /*calculate squred residuals for SSR*/
egen sr33 = sum(sr3) /*calculate sum of squred residuals for SSR*/
egen ssr3 = rowfirst(sr33) /* SSR */
display "SSR = "ssr3
display "AIC = "=e(N)*ln(ssr3)+2*e(df_m) /*compute AIC*/
display "SBC = "=e(N)*ln(ssr3)+e(df_m)*ln(e(N)) /*compute SBC*/
*Model 4
arima y in 8/212, ar(1/2,7)			/* AR(p=1,2,and 7) */
*Model 5
arima y in 8/212, ar(1) ma(1)			/* ARMA(1,1) */
*Model 6
arima y in 8/212, ar(1/2) ma(1)			/* ARMA(2,1) */
*
predict resid_arma21, resid
corrgram resid_arma21,yw lag(12)
*Model 7
arima y in 8/212, ar(1/2) ma(1,7)			/* AR(2),MA(1,7) */
predict resid_mod7, resid
corrgram resid_mod7,yw lag(12)
gen sr4 = (resid_mod7)^2 /*calculate squred residuals for SSR*/
egen sr44 = sum(sr4) /*calculate sum of squred residuals for SSR*/
egen ssr4 = rowfirst(sr44) /* SSR */
display "SSR = "ssr4
display "AIC = "=e(N)*ln(ssr4)+2*e(df_m) /*compute AIC*/
display "SBC = "=e(N)*ln(ssr4)+e(df_m)*ln(e(N)) /*compute SBC*/
* Q: Which model has the best fit? Which other one is the next best?

*B. out of sample forecast and test
*Model 1
arima y if obs<=162, ar(1 2 3 4 5 6 7)
predict f_ar7 in 163/212
reg y f_ar7 in 163/212				/* cofficient test */
test (_cons=0)(f_ar7=1)
* Q: What do you conclude regarding model 1?
* Model 7
arima y if obs<=162, ar(1/2) ma(1,7)			/* AR(2),MA(1,7) */
predict f_mod7 in 163/212
reg y f_mod7 in 163/212				/* cofficient test */
test (_cons=0)(f_mod7=1)
* Q: What do you conclude regarding model 7?

* Model 5
arima y if obs<=162, ar(1) ma(1)
predict f_arma in 163/212
reg y f_arma in 163/212				/* cofficient test */
test (_cons=0)(f_arma=1)
* Q: What do you conclude regarding model 5?

* Forecast error diagnotics
gen err_ar7  = y - f_ar7
gen err_mod7  = y - f_mod7
summ err_ar7, detail
summ err_mod7, detail
corrgram err_ar7
ac err_ar7, lags(12)
pac err_ar7, lags(12)
corrgram err_mod7
ac err_mod7, lags(12)
pac err_mod7, lags(12)
* Tests
*C. Granger-Newbold test
gen xt=err_ar7+err_mod7
gen zt=err_ar7-err_mod7
cor xt zt
display "G-N stat = "=r(rho)/sqrt((1-(r(rho))^2)/49)
* Q: What is your conclusion from this test?
*D. Diebold-Mariano (DM) test
gen d = (err_ar7)^4 - abs(err_mod7)^4
summ d,detail
display "D-M stat = "=r(mean)/sqrt(r(Var)/(r(N)-1))
* Q: What conclusion you draw from this test?

* additional tests

gen err_arma = y - f_arma
summ err_ar7, detail
summ err_arma, detail
corrgram err_ar7
corrgram err_arma
ac err_ar7, lags(12)
ac err_arma, lags(12)

*C. Granger-Newbold test
gen xt=err_ar7+err_arma
gen zt=err_ar7-err_arma
cor xt zt
display "GN stat="=r(rho)/sqrt((1-(r(rho))^2)/49)

*D. Diebold-Mariano (DM) test
gen d = (err_ar7)^4 - abs(err_arma)^4
summ d,detail
display "DM stat="=r(mean)/sqrt(r(Var)/(r(N)-1))



