clear
*import excel "C:\WorkingDir\data\SIM_2.xlsx", sheet("Sheet1") firstrow clear
*insheet using "C:\Users\columbus\Documents\2018\teaching\4490\code\SIM_2csv.csv" 
*save SIM_2
use SIM_2.dta
tsset OBS /*declare this is a time series dataset*/
*A: plot the sequence against time
line Y1 OBS
*B: verify the first 12 coefficients of the ACF and PACF
corrgram Y1, yw lag(24) /*yw selects the Yule-Walker method for computing correlations */
*ac Y1, lags(24) /*Plot ACF (no yw option)*/
*pac Y1, yw lags(24) /*Plot ACF (no yw option)*/

*C: estimate Model 1
reg Y1 l.Y1, noconstant
predict resid1, residuals /*calculate residuals after estimation and save it as a new variable called resid1*/
corrgram resid1, yw lag(24) /*verify Q stats of residuals*/
display "AIC = "=e(N)*ln(e(rss))+2*e(df_m) /*compute AIC*/
display "SBC = "=e(N)*ln(e(rss))+e(df_m)*ln(e(N)) /*compute SBC*/
set matsize 800
/*Note: here the required matsize should be max(AR, MA+1)^2, which is 169(max(1,13)^2).
Can check first matsize in stata with command: 'query memory' If below the required size then adjust. Refer to
[R]matsize for details.*/
*C: estimate Model 2
arima Y1, noconstant ar(1) ma(12)
predict resid2, residuals
corrgram resid2,yw lag(24) /*verify Q stats of residuals*/
/*Note: STATA applied MLE for estimating ARMA model so coefficients are slightly different from table, but in case of pure AR model, we used OLS.*/
/* Note: To obtain AIC and BIC, we can use the sum of squared residual or the loglikelihood value.
For selecting model using AIC and BIC, we need to calculate these from same formula.
Since STATA does not report SSR autometically in MLE estimation, we need to calculate this directly.*/
gen sr2 = (resid2)^2 /*calculate squred residuals for SSR*/
egen sr22 = sum(sr2) /*calculate sum of squred residuals for SSR*/
egen ssr2 = rowfirst(sr22) /* SSR */
display "AIC = "=e(N)*ln(ssr2)+2*e(df_m) /*compute AIC*/
display "SBC = "=e(N)*ln(ssr2)+e(df_m)*ln(e(N)) /*compute SBC*/
/*You can compute AIC and BIC using the loglikelihood. These results are somewhat different, however.
display "AIC = "=-2*e(ll)+2*e(k)
display "SBC = "=-2*e(ll)+e(k)*ln(e(N))
*/
*D: estimate the series y1 as an AR(2) without an intercept
reg Y1 l.Y1 l2.Y1, noconstant
predict resid3,residuals
corrgram resid3, yw lag(24) /*verify Q stats of residuals*/
display "AIC = "=e(N)*ln(e(rss))+2*e(df_m) /*compute AIC*/
display "SBC = "=e(N)*ln(e(rss))+e(df_m)*ln(e(N)) /*compute SBC*/

*E:estimate the series y1 as an ARMA(1,1) without an intercept
arima Y1,ar(1) ma(1) noconstant
predict resid4,residuals
corrgram resid4, yw lag(24) /*verify Q stats of residuals*/
gen sr4 = (resid4)^2 /*calculate squred residuals for SSR*/
egen sr44 = sum(sr4) /*calculate sum of squred residuals for SSR*/
egen ssr4 = rowfirst(sr44) /* SSR */
display "AIC = "=e(N)*ln(ssr4)+2*e(df_m) /*compute AIC*/
display "SBC = "=e(N)*ln(ssr4)+e(df_m)*ln(e(N)) /*compute SBC*/

