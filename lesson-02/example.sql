/*	GeekBrains, BigData, MySQL, Lesson-2
	Oleg Gladkiy (https://geekbrains.ru/users/3837199) 	 */

--	Создаём базу с очисткой плацдарма

	DROP DATABASE IF EXISTS example;
	CREATE DATABASE IF NOT EXISTS example;
    
--	Выбираем по умолчанию

	USE example;
    
--	Создаём таблицу

	DROP TABLE IF EXISTS users;
	CREATE TABLE users (
		id SERIAL PRIMARY KEY,
		`name` VARCHAR (255) CHARACTER SET UTF8MB4 COMMENT 'Name of user'
	) COMMENT='User library';

--	Наполяем
    
    INSERT INTO users VALUES
		(default, 'Кошкин'),
        (default, 'Мышкин'),
        (default, 'Курочкин');

--	Выводим...
	SELECT * FROM users;

        