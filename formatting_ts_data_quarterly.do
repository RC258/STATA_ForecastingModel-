clear
import excel "C:\MyDir\quarterly.xls", sheet("TB3MS") firstrow allstring
*save quarterly
*use quarterly
gen obs =_n
gen time=tq(1960q1)+_n-1 /* create time(i.e.,date) variable in quarterly format */
format %tq time
tsset time
gen R10 = real(r10)
gen tbill = real(Tbill)
gen ffr=real(FFR)
gen R5=real(r5)
gen sr5 = R5 - tbill
label var sr5 "5-year interest rate spread"
gen sr10 = R10 - tbill
label var sr10 "10-year interest rate spread"
save quarterly, replace