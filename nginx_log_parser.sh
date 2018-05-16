#!/bin/bash

# variables
LOGFILE="/bin/vlad/access.log"
LOGFILE_GZ="/var/log/nginx/access.log.*"
RESPONSE_CODE="200"

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
$0 — представляет всю строку текста (запись).
$1 —  remote adress первое поле.
$2 — ? второе поле.
$3 - ?
$4  - [Time local
$5  - отставания
$6  - тип запроса (метод обработки данных) -GET -POST  -PUT  -DELETE
$7  - линк куда ломимся
$8  - протокол
$9  - код ответа сервера
$10 - размер (кол-во переданных байт)
$11 - реферальная ссылка
$12 - юзер агент
... - поля юзер агента
$20
$n — n-ное поле.
HELP

# functions по тз не используется, но пусть будет...
 # отобрать все ответы содержащие указанный "код ответа"
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
#
request_ips(){
awk '{print $1}'
}

request_method(){
awk '{print $6}' \
| cut -d'"' -f2
}

request_pages(){
awk '{print $7}'
}

wordcount(){
sort \
| uniq -c
}

sort_desc(){
sort -rn
}

return_kv(){
awk '{print $1, $2}'
}

request_pages(){
awk '{print $7}'
}

return_top_ten(){
head -10
}

## actions
get_request_ips(){
echo ""
echo "Top 10 Request IP's:"
echo "===================="

cat $LOGFILE \
| filters \
| request_ips \
| wordcount \
| sort_desc \
| return_kv \
| return_top_ten
echo ""
}

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

get_request_pages_404(){
echo "Top 10: 404 Page Responses:"
echo "==========================="
zgrep '-' $LOGFILE $LOGFILE_GZ\
| filters_404 \
| request_pages \
| wordcount \
| sort_desc \
| return_kv \
| return_top_ten
echo ""
}


get_request_pages(){
echo "Top 10 Request Pages:"
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

get_request_pages_all(){
echo "Top 10 Request Pages from All Logs:"
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

# executing
get_request_ips
get_request_methods
get_request_pages
get_request_pages_all
get_request_pages_404
