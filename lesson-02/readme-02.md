GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
Lesson-2, домашнее задание 

my.cnf
-- Windows-7, path of config file: c:\winsows


example.sql
-- info:    Create DB Example with table User
-- command: ...manual...


example_dump.sql
-- info:    Drop DB Example
-- command: mysqldrop --result-file=example_dump.sql example


sample_createDB.sql
-- info:    Create DB Sample and load the dump file back into the server:.
-- command: mysql < sample_createDB.sql
            mysql sample < example_dump.sql
