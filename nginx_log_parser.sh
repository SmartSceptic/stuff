#!/bin/bash

## variables
#/home/vlad/Desktop/access_log-20170726
LOGFILE="/bin/vlad/access.log"
#LOGFILE_GZ="/var/log/nginx/access.log.*"
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
#Используем числовую сортировку (-n) по убыванию (-r) -делаем топ всех
sort_desc(){
sort -rn
}
#вывести первые 2 поля после сортировки количество обращений и саму метрику
#зачастую нужно для красивого вывода
return_kv(){
awk '{print $1, $2}'
}
# Вывести только топ n строк списка
return_top_ten(){
head -10
}

## actions
#получаем топ ip по количеству запросов
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
echo "Top 10: 404 Page Responses:"
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
# Топ n всех запрашиваемых страниц с всех!!! указанных логов
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

## executing
get_request_ips


get_request_methods
get_request_pages
get_request_pages_all
get_request_pages_404
