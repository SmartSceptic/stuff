LOGFILE="/bin/vlad/access.log"
tmp=""
get_timestamp_from_log(){
echo ""
## убрать sed засунуть его функционал в awk
#cat $LOGFILE |awk '{print $4}' |sed -e 's/^.//' -e 's,/,-,g' -e 's,:, ,'|date -f - +"%s"
# cтрока должна переводить в таймштамп авк $
awk 'BEGIN{FS="[][]"}{system("date \"+%s\" -d \""gensub("/", " ", "G", gensub(":", " ", "1", $2))"\"")}'
}
count_number_of_requests_per_hour(){
cat $LOGFILE \
|get_timestamp_from_log\
|awk '{}'
}
count_number_of_requests_per_hour
#get_timestamp_from_log
