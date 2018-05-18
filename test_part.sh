LOGFILE="/bin/vlad/access.log"
tmp=""
count_send_data(){
echo ""
## убрать sed засунуть его функционал в awk
tail -100 $LOGFILE |awk '{print $4}' |sed -e 's/^.//' -e 's,/,-,g' -e 's,:, ,'|date -f - +"%s"
#$ awk 'BEGIN{FS="[][]"}{system("date \"+%s\" -d \""gensub("/", " ", "G", gensub(":", " ", "1", $2))"\"")}' file
#echo " июль семнадцатого"
date -d "26-Jul-2017 03:35:22" +"%s"
#echo " Today"
#date +"%s"
}

count_send_data
