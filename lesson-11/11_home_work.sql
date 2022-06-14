--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  Home Work 11
--  Практическое задание по теме 
--  ОПТИМИЗАЦИЯ ЗАПРОСОВ

-- 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах 
--    users, catalogs и products в таблицу logs помещается время и дата создания записи, 
--    название таблицы, идентификатор первичного ключа и содержимое поля name.

USE shop;

-- Таблица для журналирования

DROP TABLE IF EXISTS logs;
CREATE TABLE IF NOT EXISTS logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    insert_at DATETIME DEFAULT current_timestamp,
    table_name varchar(127),
    record_id BIGINT UNSIGNED,
    record_name varchar(255) 
) comment = 'Журнал регистрации создания записей' ENGINE = Archive;

-- Процедура (общая) записи строки в журнал (logs)

DELIMITER //

DROP PROCEDURE IF EXISTS insert_logs // 

CREATE PROCEDURE insert_logs(
    IN table_name varchar(127), 
    IN record_id bigint UNSIGNED, 
    IN record_name varchar(255))  
BEGIN
    INSERT INTO shop.logs 
                (table_name, record_id, record_name) 
         VALUES (table_name, record_id, record_name);
END //

-- Тригеры для каждой из 3-х таблиц, отвечающие за добавление данных

DROP TRIGGER IF EXISTS tr_ins_users //
CREATE TRIGGER tr_ins_users AFTER INSERT ON users
FOR EACH ROW 
BEGIN 
    CALL insert_logs('users', NEW.id, NEW.name);
END //

DROP TRIGGER IF EXISTS tr_ins_catalogs //
CREATE TRIGGER tr_ins_catalogs AFTER INSERT ON catalogs
FOR EACH ROW 
BEGIN 
    CALL insert_logs('catalogs', NEW.id, NEW.name);
END //

DROP TRIGGER IF EXISTS tr_ins_products //
CREATE TRIGGER tr_ins_products AFTER INSERT ON products
FOR EACH ROW 
BEGIN 
    CALL insert_logs('products', NEW.id, NEW.name);
END //

DELIMITER ;

-- Проверка: вставляем записи в целевые таблицы и проверяем отражение этих действий в журнале 

INSERT INTO users (name, birthday_at) VALUES ('Barabas', '1950-01-01');
SELECT sleep(3);
INSERT INTO catalogs (name) VALUES ('Освящение');
SELECT sleep(3);
INSERT INTO products (name, catalog_id) VALUES ('Клавиатура Logitech K118', last_insert_id());

SELECT * FROM logs LIMIT 100;



--  ОПТИМИЗАЦИЯ ЗАПРОСОВ
-- 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.

USE shop;

delimiter //

DROP PROCEDURE IF EXISTS add_test_records //
CREATE PROCEDURE add_test_records(IN i_max BIGINT UNSIGNED)
BEGIN
    DECLARE i BIGINT UNSIGNED DEFAULT 0;

    WHILE (i < i_max) DO
        INSERT INTO users(name, birthday_at) VALUES (SUBSTRING(MD5(RAND()), 1, 12), '2000-01-01'); -- LEFT(uuid(), 64);
        SET i := i + 1;
    END WHILE;
END //

delimiter ;


-- Запускаем процесс вставки миллиона записей 
-- (с журналированием в таблицу logs посредством триггеров)...
CALL add_test_records(1000000);


-- Проверяем
SELECT * FROM users ORDER BY id DESC LIMIT 5;
SELECT * FROM logs  ORDER BY id DESC LIMIT 5;
-- Возвращаем в исходное состояние
-- Удаляем лишние записи из таблицы users
DELETE FROM users WHERE birthday_at = '2000-01-01';
-- Удалить из таблицы logs не получиться, так как она архивного типа и её надо будет удалить всю.


/*
 * ОЦЕНКА ПРЕПОДАВАТЕЛЯ: ОТЛИЧНО (сдано 2022-06-14; 03:25 msk. Проверено 2022-06-14; 13:46 MSK)
 *
 * Кирилл Иванов, преподаватель
 *
 * Альтернативный способ добавления записей в таблицу с логами (вместо триггера) 
 * - отдельная хранимая процедура, которая вставляет сначала запись в нужную таблицу 
 * (users, catalogs, products), а потом уже - в логи.
 * Ссылка на видео с разбором ДЗ - в комментариях к следующему уроку.
 * 
 */

