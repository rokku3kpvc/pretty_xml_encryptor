# PrettyXMLEncryptor

PrettyXMLEncryptor является результатом выполнения лабораторной работы по дисциплине "Информационная Безопасность".  
Программа демонстрирует шифрование/дешифрование полей XML файла с помощью симметричного ключа.  
В качестве алгоритма использован [Advanced Encryption Standard](https://ru.wikipedia.org/wiki/Advanced_Encryption_Standard) в режиме [Cipher Block Chaining](https://ru.wikipedia.org/wiki/%D0%A0%D0%B5%D0%B6%D0%B8%D0%BC_%D1%88%D0%B8%D1%84%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F#Cipher_Block_Chaining_(CBC)

## Зависимости

Необходимая версия ЯП Ruby содержится в файле `.ruby-version`.  
В качестве инструкций по установке можно использовать данную [документацию](https://www.ruby-lang.org/ru/documentation/installation/).  
Программа также использует гем [Nori](https://github.com/savonrb/nori) для работы с XML документом.  
Дополнительные библиотеки, которые были использованы: `openssl, digest/sha2, base64, yaml`.  

## Использование
Для шифрования (в корневой папке репозитория):
```bash
ruby pretty_xml_encryptor.rb encode path/to/file.xml
```

После успешного выполнения программа отправит в консоль сообщение, в котором содержится секретный ключ:
```bash
Ключ шифрования: "dtbQa9zrPgGWuTsyuvhx06o4pXwo_w2nHSR0IvqOKOM=".
Используйте его для дешифрования документа.
```

Также программа создаст файл вида `enc_original.xml` и заполнит его зашфированными данными.  
До:
```xml
<?xml version="1.0"?>
<PRIVATE>
  <PERSON>
    <NUMBER>+79991112233</NUMBER>
    <NAME>Vladimir</NAME>
    <COUNTRY>Russia</COUNTRY>
    <CITY>Moscow</CITY>
    <YEAR>1952</YEAR>
    <CREDIT_CARD>5492537333607674</CREDIT_CARD>
  </PERSON>
</PRIVATE>
```

После:
```xml
<?xml version="1.0"?>
<PRIVATE>
  <PERSON>
    <NUMBER>uS68buEDjWjzwo9NOOSlfQ==</NUMBER>
    <NAME>oXxCOVQqOdF3UTfYHVwvwg==</NAME>
    <COUNTRY>QC80MnvPD6Hev8nRSDQPuA==</COUNTRY>
    <CITY>ttG9uvZBmG_rOugLwvctJw==</CITY>
    <YEAR>l1GP1JRK1HVRWsZBl_qGVA==</YEAR>
    <CREDIT_CARD>2UX4uCAumnZPItV_DBPhGWqIAdk9HdbrDZ1pDr7Qtw8=</CREDIT_CARD>
  </PERSON>
</PRIVATE>
```

Для расшифровки документа необходимо указать секретный ключ:
```bash
ruby pretty_xml_encryptor.rb decode path/to/enc_file.xml my_secret_key
```

## TODO
1) Считывать XML файл через курсоры, не заполняя ОЗУ (см. [Nokogiri::XML::Reader](https://nokogiri.org/rdoc/Nokogiri/XML/Reader.html)).
2) Вынести классы и модули в отдельные файлы, создать единую точку входа с подгрузкой всех зависимостей.
3) Обработать поведение при возникновении дополнительных неожиданных исключений (например, при ошибке декодирования).

## Содействие
Пользование PrettyXMLEncryptor покрывается лицензией [MIT](https://ru.wikipedia.org/wiki/%D0%9B%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D1%8F_MIT). Вы можете использовать исходный код программы под собственным авторским именем только после оформления и последующего утверждения мною PR с изменениями, которые затрагивают работу внутренних алгоритмов программы, влияют на структуру и итоговую производительность кода. Идеи для PR можно взять, например, из блока **TODO**.
