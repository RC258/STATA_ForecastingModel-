clear
use urate
*A: plot the sequence against time
line UNRATE time
*B: verify the first 50 coefficients of the ACF and PACF
corrgram UNRATE, yw lag(50) /*yw selects the Yule-Walker method for computing correlations */
ac UNRATE, lags(50) /*Plot ACF (no yw option)*/
pac UNRATE, yw lags(50) /*Plot ACF (no yw option)*/

*C: estimate Model 1 as an AR(1)
reg UNRATE l.UNRATE
predict resid1, residuals /*calculate residuals after estimation and save it as a new variable called resid1*/
corrgram resid1, yw lag(50) /*verify Q stats of residuals*/
ac resid1, lags(50) /*Plot ACF (no yw option)*/
pac resid1, yw lags(50) /*Plot ACF (no yw option)*/
display "AIC = "=e(N)*ln(e(rss))+2*e(df_m) /*compute AIC*/
display "SBC = "=e(N)*ln(e(rss))+e(df_m)*ln(e(N)) /*compute SBC*/
*C: estimate Model 2 as an AR(2) 
reg UNRATE l.UNRATE l2.UNRATE
predict resid2,residuals
corrgram resid2, yw lag(50) /*verify Q stats of residuals*/
ac resid2, lags(50) /*Plot ACF (no yw option)*/
pac resid2, yw lags(50) /*Plot ACF (no yw option)*/
*D: Calculate selection criterion
display "AIC = "=e(N)*ln(e(rss))+2*e(df_m) /*compute AIC*/
display "SBC = "=e(N)*ln(e(rss))+e(df_m)*ln(e(N)) /*compute SBC*/

*F: Forecast 8-step ahead
*save estimates from AR(2) model
estimates store AR2
*Create a new forecast model
forecast create model2
*Add estimation result to current model
forecast estimates AR2
* add obs to ts dataset (i.e., out-of-sample forecast)
tsappend, add(8)
* store forecast on hat_[variablename]
forecast solve, begin(q(2020q1)) prefix(hat) periods(8)
* plot forecast along with data
line hatUNRATE UNRATE time
