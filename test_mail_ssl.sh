host=mail.partsid.com
#host=vladlen-ch.devzone.net
for domain  in mail.partsid.com mail.onyx.com mail.onyxenterprises.com somedomain.com
do
        echo ""
        echo "============================="
        echo "== Test Servername : $domain on: $host  ===="
        echo "============================="
        echo "==== SMTP 25 STARTTLS ===="
        echo "Q" | openssl s_client -showcerts -connect ${host}:25 -starttls smtp -servername $domain |&  openssl x509 -noout -subject -enddate
        echo "==== SMTPS 465 ===="
        echo "Q" | openssl s_client -showcerts -connect ${host}:465 -servername $domain |&  openssl x509 -noout -subject -enddate
        echo "==== POP3 110 STARTTLS ===="
        echo "Q" | openssl s_client -showcerts -connect ${host}:110 -starttls pop3 -servername $domain |&  openssl x509 -noout -subject -enddate
        echo "==== POP3S 995 ===="
        echo "Q" | openssl s_client -showcerts -connect ${host}:995 -servername $domain |&  openssl x509 -noout -subject -enddate
        echo "==== IMAP 143 STARTTLS ===="
        echo "Q" | openssl s_client -showcerts -connect ${host}:143 -starttls imap -servername $domain |&  openssl x509 -noout -subject -enddate
        echo "==== IMAPS 993 ===="
        echo "Q" | openssl s_client -showcerts -connect ${host}:993 -servername $domain |&  openssl x509 -noout -subject -enddate

done
