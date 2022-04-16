GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
Lesson-2, домашнее задание 

my.cnf
-- Windows-7, path of config file: c:\winsows

.my.cnf
-- Linux, path of config file: ~


example.sql
-- info:    Create DB "example" with table "user"
-- command: сам файл и есть команда

example_dump.sql
-- info:    Dump DB Example
-- command: mysqldump --result-file=example_dump.sql example


sample.sql
-- info:    Create DB Sample and load the dump file back into the server:.
-- command: mysql < sample.sql
            mysql sample < example_dump.sql


mysql_dump.sql
-- info:    Dump DB Example, first 100 resords
-- command: mysqldump --databases mysql --tables help_keyword --where="true limit 100" > mysql_help_keywords_dump.sql

