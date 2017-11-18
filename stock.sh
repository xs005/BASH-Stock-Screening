#Download Historical Data of Stocks from Google Finance
#Because Google is not allowed to download contiously
#The script takes a nap after downloading 1000 stocks
sum=0
for i in `cat ticker.dat`;do
wget -O ${i}.csv "https://www.google.com/finance/historical?output=csv&q=${i}"
#delete the empty files 
find ${i}.csv -size 0 -delete 
#sleep for a while after downloading 1000 stocks
((sum++))
if (( $sum == 1000 ));then
	sleep 2000
	sum=0
fi
done

#Calculate the slope of the curve for each stock using linear regression
echo "#Ticker Slope R2" > stats.log

for i in `ls -lrtx1 *.csv`; do
	name=`echo $i | rev | cut -f2- -d"." | rev`

	#choose the one have enough data more than 85 days
	#use "stats" in GNUPLOT for the linear fitting
	line=`cat $i | wc -l`
	if (( $line > 86 )); then
		gsed s/ticker/${name}/g stats.gnu > temp.gnu
		gnuplot temp.gnu
	fi
done

#sort the results based on the R2 from the linear regression
rm temp.gnu
cat stats.log | sort -n -k3 | grep -v "-" > stats_sorted.log
a=(`cat stats_sorted.log | awk '{print $1}'`) #get the name of the stock
b=(`cat stats_sorted.log | awk '{print $2}'`) #get the value of slope
c=(`cat stats_sorted.log | awk '{print $3}'`) #get the value of R2


#find the ones that R2 >= 0.8 and slope >= 0.1, and save to stats_sorted_trimed.log
num=`cat stats_sorted.log | wc -l`
((num= $num - 1))

rm -f stats_sorted_trimed.log

for ((i=$num;i>=0;i--));do
	if (( $(echo "${c[$i]} >= 0.8" | bc -l) )) && (( $(echo "${b[$i]} >= 0.1" | bc -l))); then
		echo ${a[$i]} ${b[$i]} ${c[$i]} >> stats_sorted_trimed.log
	fi

	echo $i	

	if (( $(echo "${c[$i]} < 0.8" | bc -l) )); then
		break
	fi
done


#plot the histrical data of selected stocks with the fitting lines
for i in `cat stats_sorted_trimed.log | awk '{print $1}'`;do
	gsed s/ticker/${i}/g plot.gnu > temp.gnu
	gnuplot temp.gnu
done
rm temp.gnu	
