@echo off
REM GeekBrains, BigData
REM Oleg Gladkiy (https://geekbrains.ru/users/3837199)

REM MySQL, Lesson-2

REM 2.2 reLoad dump of the Example-DB into Samle-DB.
    @ECHO .
    @ECHO Load Dump of Example-DB into Samle-DB.
    @echo on

    mysql sample <example_dump.sql

    @ECHO.

