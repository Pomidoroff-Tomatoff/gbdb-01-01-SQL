/*	GeekBrains, BigData, MySQL, Lesson-2
	Oleg Gladkiy (https://geekbrains.ru/users/3837199) 	 */
--	Lesson-2    
--	2.1 Create DB sample
    
	DROP DATABASE IF EXISTS sample;
	CREATE DATABASE sample;
	USE sample;

--	Далее выполняем в среде клиента mysql команду
--  	mysql SOURCE example_dump.sql
--	Либо в терминале: 
--		mysql sample < example_dump.sql
    
	SELECT * FROM users;