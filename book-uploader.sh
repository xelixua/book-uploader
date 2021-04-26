#!/bin/bash

# загрузить книгу параметр $1 

# проверить на virustotal
# переменная окружения VIRUSTOTAL_API_KEY

clear
echo -e "Загружаем файл $1 на Virustotal...\n"
echo
fileUploadResult=$(curl --request POST \
    --url https://www.virustotal.com/api/v3/files \
    --header "x-apikey: $VIRUSTOTAL_API_KEY" \
    --form "file=@$1")

analysisId=$(echo $fileUploadResult | jq -r '.data.id')
echo -e "Файл $1 загружен.\nanalysisId=$analysisId\nЗапрашиваем результат проверки...\n"

analysisResult="null"
while [[ analysisResult -eq "null" ]]
do
virustotalOutput=$(curl --request GET \
    --url https://www.virustotal.com/api/v3/analyses/${analysisId} \
    --header "x-apikey: $VIRUSTOTAL_API_KEY")

analysisResult=$(echo $virustotalOutput | jq '.data.attributes.results')

sleep 3
done

analysisResult=$(echo $virustotalOutput | jq '[.data.attributes.results[].result] | any')    
echo Результат проверки: 

if [ "$analysisResult" == "false" ];then
    echo -e "Вирусы не найдены\nОтправляем книгу почтой на устройство"
    echo "No text" | mutt -s "New book" -a $1 -- $KINDLE_EMAIL_ADDRESS

    # отправить на email
else
    echo В файле обнаружен вирус
fi