/*	GeekBrains, BigData, MySQL, Lesson-2
	Oleg Gladkiy (https://geekbrains.ru/users/3837199) 	 */

-- Задание 2
-- Создаём базу "example" с очисткой плацдарма

	DROP DATABASE IF EXISTS example;
	CREATE DATABASE IF NOT EXISTS example;
    
--	Выбираем "example" БД по умолчанию

	USE example;
    
--	Создаём таблицу

	DROP TABLE IF EXISTS users;
	CREATE TABLE users (
		id SERIAL PRIMARY KEY,
		`name` VARCHAR (255) CHARACTER SET UTF8MB4 COMMENT 'Name of user'
	) COMMENT='User library';

--	Наполняем
    
    INSERT INTO users VALUES
		(default, 'Кошкин'),
		(default, 'Мышкин'),
		(default, 'Курочкин');

--	Выводим...
	SELECT * FROM users;      