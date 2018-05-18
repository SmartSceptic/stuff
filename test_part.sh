LOGFILE="/home/vlad/Desktop/access_log-20170726"
tmp=""
TIME_SEPARATOR="3600"
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
tmp=$(($first_timestamp+$TIME_SEPARATOR))
cat $LOGFILE \
|get_timestamp_from_log\
|awk -v ts=$TIME_SEPARATOR -v tm=$tmp '{if ($0 <= tm){{counter++}} else { {tm+=ts} {print "за период до " tm " было совершено : " counter " обращений"  }}}  END{print counter}'
# {print "CURENT " $0 " less then" ft+ts " counter =" counter}
}
#for ((i=0; i<
#10000; i++)){
#  echo " $i "
#}

count_number_of_requests_per_hour
#get_timestamp_from_log
