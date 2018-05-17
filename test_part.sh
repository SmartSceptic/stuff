LOGFILE="/bin/vlad/access.log"

count_send_data(){
  IFS=$'\n'
for string in $(tail $LOGFILE | awk '{print $1 ,$10}')
  do
    IFS=' '
    for value in $string
      do

      done
  done
}
cat $LOGFILE |awk '{print $1 ;print $10}' |sort |uniq -c |sort -n |tail
count_send_data
