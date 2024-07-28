clear
import excel "C:\MyDir\UNRATE_1948Q1_2019_Q4.xls", sheet("FRED Graph") cellrange(A11:B299) firstrow

gen obs =_n
gen time=tq(1948q1)+_n-1 /* create time(i.e.,date) variable in quarterly format */
format %tq time
tsset time
*drop observation_date
*drop if obs>288

line UNRATE time
*save urate, replace