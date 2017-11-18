reset
set print "stats.log" append
set datafile separator ","
stats [0:70] "ticker.csv" u 0:5 nooutput #lastest two month close price data
print "ticker ", STATS_slope*(-1), STATS_correlation**2
