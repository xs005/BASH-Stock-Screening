reset
set yr [*:]
set xr [-70:0]
set ylabel "Price"
set xlabel "Day"
set terminal pngcairo
set datafile separator ","
stats [0:70] "ticker.csv" u 0:5 nooutput #lastest four month close price data


set output "ticker.png"
set title sprintf("ticker 70 days, R^2 = %3.4f, slope= %3.4f",STATS_correlation**2, STATS_slope*(-1)) 
p "ticker.csv" u ($0*-1):5 w l lw 1 lc rgb "blue" noti, (-1)*STATS_slope*x+STATS_intercept w l lw 3 lc rgb "red" noti
set output
 
