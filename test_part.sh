LOGFILE="/bin/vlad/access.log"
tmp=""
TIME_SEPARATOR="1000"
get_timestamp_from_log(){
echo ""
## убрать sed засунуть его функционал в awk
#cat $LOGFILE |awk '{print $4}' |sed -e 's/^.//' -e 's,/,-,g' -e 's,:, ,'|date -f - +"%s"
# cтрока должна переводить в таймштамп авк $
awk 'BEGIN{FS="[][]"}{system("date \"+%s\" -d \""gensub("/", " ", "G", gensub(":", " ", "1", $2))"\"")}'
}
count_number_of_requests_per_hour(){
#нужно убрать греп первого таймштампа отсюда и сделать его более адекватно
first_timestamp=$(head -1 $LOGFILE |awk 'BEGIN{FS="[][]"}{system("date \"+%s\" -d \""gensub("/", " ", "G", gensub(":", " ", "1", $2))"\"")}')
#tmp=$(($first_timestamp + $TIME_SEPARATOR))
cat $LOGFILE \
|get_timestamp_from_log\
|awk -v ts=$TIME_SEPARATOR -v ft=$first_timestamp '{if ($0 <= ft+ts){{counter++}{print "CURENT " $0 " less then" ft+ts " counter =" counter}} else{print "oops" $0}}  END{print counter}'
}
#for ((i=0; i<10000; i++)){
#  echo " $i "
#}

count_number_of_requests_per_hour
#get_timestamp_from_log
