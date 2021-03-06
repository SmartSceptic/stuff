#!/bin/bash

## variables
LOGFILE="/home/vlad/Desktop/access_log-20170726"
TOP="5"
#LOGFILE="/bin/vlad/access.log"
#LOGFILE_GZ="/var/log/nginx/access.log.*"
RESPONSE_CODE="200"
#declare -a TOPIP
tmp=""
TIME_SEPARATOR="60"
tmpd=''
: << HELP
вывести с выравниваем столбцов можно так:
  awk '{print $0}' /bin/vlad/access.log |column -t
а вывисти с подписыванием полей - так:
    request_ips(){
      for (( i = 0; i < 29; i++ ))
        do
          eval " tail -1 $LOGFILE | awk '{print \"Field $i\" \" =      \" \$$i}'"
        done
    }
log_format  main  '$remote_addr - $remote_user [$time_local] "$request" ' '$status $body_bytes_sent "$http_referer" ' '"$http_user_agent" "$http_x_forwarded_for"';
$0 —                представляет всю строку текста (запись).
$1  - $remote_adressip  adress вопрошающего первое поле.
$2  - $remote_logname   имя отклюено по умолчанию (рисует тире) пока не поменять IdentityCheck на On
$3  - $remote_user      пользователь
$4  - [$time_local      время когда пришел запрос
$5  - $time_local]      отставания от utc(гринвич)
$6  - "$request         тип запроса (метод обработки данных) -GET -POST  -PUT  -DELETE
$7  - $request          линк куда ломимся
$8  - $request"         протокол
$9  - $status           код ответа сервера
$10 - $body_bytes_sent  размер (кол-во переданных байт)
$11 - "$http_referer"   реферальная ссылка
$12 - "$http_user_agent"здесь и далее поля юзер агента
... - поля юзер агента см здесь https://www.nginx.com/resources/wiki/modules/user_agent/#syntax
$20 - продолжаются поля юзер агентов, см здесь https://habr.com/post/39715/
$n — n-ное поле.
массивы обьявляются и выводятся например так
  declare -a arr=("element1" "element2" "element3")
  do
     echo "$i"
  done
HELP

## functions
#по тз не используется, но пусть будет...
#отобрать все ответы содержащие указанный "код ответа"
filters(){
grep $RESPONSE_CODE \
| grep -v "\/rss\/" \
| grep -v robots.txt \
| grep -v "\.css" \
| grep -v "\.jss*" \
| grep -v "\.png" \
| grep -v "\.ico"
}
#Отобрать все чоч ошибки
filters_404(){
grep "404"
}
#Функция отбора ip-адресов
request_ips(){
awk '{print $1}'
}
#Тип запроса (метод обработки данных) -GET -POST  -PUT  -DELETE
#Отбираем в формате: "GET ,
#Например, второе поле (cам метод без кавычек)в каждой строке входа,
#которые отделены друг от друга двойными кавычками (разделители - двойные кавычки):
request_method(){
awk '{print $6}' \
| cut -d'"' -f2
}
#Отобрать все линки на которые ломится юзер
request_pages(){
awk '{print $7}'
}
#Отсортировать все входящие значения в лексикографичесском порядке
#и отобрать из них уникальные значения (ключ -с покажет сколько раз встретилась строка)
wordcount(){
sort \
| uniq -c
}
#Используем числовую сортировку (-n) по убыванию (-r) - делаем топ всех
sort_desc(){
sort -rn
}
#вывести только первые 2 поля после сортировки: количество обращений и саму метрику
#зачастую нужно для красивого вывода
return_kv(){
awk '{print $1, $2}'
}
return_only_version(){
awk '{print $2}'
}
# Вывести только топ n строк списка
return_top_ten(){
head -$TOP
}
## actions
#получаем топ ip по количеству запросов
get_request_ips(){
echo ""
echo "Top Request IP's:"
echo "===================="
#!!!при реальном использовании помести эту строку в конвеер
#если хочешь проанализировать вывод без хлама и с заданным кодом ответа (200) !!!
#| filters \
cat $LOGFILE \
| request_ips \
| wordcount \
| sort_desc \
| return_kv \
| return_top_ten
echo " "
}
#Топ по количеству вызовов разных методов (GET POST)
get_request_methods(){
echo "Top Request Methods:"
echo "===================="
cat $LOGFILE \
| filters \
| request_method \
| wordcount \
| return_kv
echo ""
}
# Top страниц с 404 по количеству ошибок
get_request_pages_404(){
echo "Top 404 Page Responses:"
echo "==========================="
cat $LOGFILE \
| filters_404 \
| request_pages \
| wordcount \
| sort_desc \
| return_kv \
| return_top_ten
echo ""
}
# Топ n запрашиваемых страниц с указанного лога
get_request_pages(){
echo "Top Request Pages:"
echo "====================="
cat $LOGFILE \
| filters \
| request_pages \
| wordcount \
| sort_desc \
| return_kv \
| return_top_ten
echo ""
}
# Топ n всех запрашиваемых страниц с всех!!! указанных логов
get_request_pages_all(){
echo "Top Request Pages from All Logs:"
echo "==================================="
zgrep '-' --no-filename $LOGFILE $LOGFILE_GZ \
| filters \
| request_pages \
| wordcount \
| sort_desc \
| return_kv \
| return_top_ten
echo ""
}
#Помещаем топ всех N айпишников в массив TOPIP
get_top_to_var(){
TOPIP=($(
cat $LOGFILE \
| request_ips \
| wordcount \
| sort_desc \
| return_only_version \
| return_top_ten ))
}
#Получить список наичастейших айпишников (в массив TOPIP) и посчитат сколько
#байт каждый из них сотворил
get_ips_send_data(){
get_top_to_var
echo "How match data use Top IPS"
echo "==================================="
for i in "${TOPIP[@]}"
  do
    echo " "
    echo "This agent: $i"
    #awk '{if (NF==4 && (index($2,"x.y.z")==1)) stats[$2]+=$4; else if (NF==2) print $2 "\t" stats[$1]}' $1 file-users
    #echo 'hi' |awk -v iip="$i" -v var2="2" '{print iip}'
    #cat $LOGFILE |awk '{BEGIN { sum=0 } {if ( \$5 ~ $i) { sum+=\$10 } } END {print sum}'
    #eval "cat $LOGFILE |awk '{if (\$2=="$i") {sum+=\$10}} END {print sum}'"
  cat $LOGFILE |awk -v cip="$i" '{{if (cip==$1) { sum+=$10 }}}END {print "sent " sum " bytes.."}'
  done
}

get_timestamp_from_log(){
echo ""
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
|awk -v ts=$TIME_SEPARATOR -v tm=$tmp '{if ($0 <= tm){{counter++}} else { {print "за период до " tm " было совершено : " counter " обращений"  }{tm+=ts} {counter=0} }}  END{print counter}'
# {print "CURENT " $0 " less then" ft+ts " counter =" counter}
}

#for ((i=0; i<
#10000; i++)){
#  echo " $i "
#}



#get numbers of requests per hour код кости работает быстрее моего
get_req(){
day=$(cat $LOGFILE |awk '{print $4}' | cut -c 2-3 | sort | uniq)
min_h="00"
max_h="23"
i="$min_h"
h="00"
for gr in $day
do
echo "--------------------Day $gr------------------"
while [ $i -le $max_h ]; do
reqs=$(cat $LOGFILE | grep "\["$gr | awk -F ":" '{print $2}' | grep "$h" | wc -l)
echo "In time $h" " - " "$reqs request"
i=$[i+1]
if [ $i -le 10 ] && [ $i -ne 00 ]; then
h=$(printf "%02d" $i); else
h="$i"
fi
done
i="00"
h="00"
done
}





## executing


#get_request_ips

#сколько данных отослали ip из top 5
#get_ips_send_data

#код кости hаботает быстрее :(
#get_req

#количество запросов за еденицу времени (TIME_SEPARATOR)
count_number_of_requests_per_hour


: << ADITIONAL_FITURES
get_request_methods
get_request_pages
#get_request_pages_all
get_request_pages_404
ADITIONAL_FITURES
