--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  Home Work 10

-- ДОМАШНЕЕ ЗАДАНИЕ:
-- Прислать предварительную версию курсового проекта:
--
--    DDL-команды;
--    Дамп БД (наполнение таблиц данными), не больше 10 строк в каждой таблице.

-- ПРОЕКТ БД: ГОСУСЛУГИ
-- DDL

DROP DATABASE IF EXISTS gos;
CREATE DATABASE IF NOT EXISTS gos;
USE gos;

-- Пользователь
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    firstname varchar(127),
    fathername varchar(127),
    lastname varchar(127),
    email varchar(127),
    phone BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    verification BIT NOT NULL DEFAULT 0 COMMENT 'Подтверждение пользователя в офисе по паспорту',
    pass_hash varchar(100) DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY email (email),
    UNIQUE KEY phone (phone)
) COMMENT='Основные данные пользователя';

-- Справочник городов
DROP TABLE IF EXISTS city;
CREATE TABLE city (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL, 
    UNIQUE city_name(name),
    PRIMARY KEY (id)
) COMMENT='Справочник городов';

-- Пользователь: дополнительная инфа
-- связь один к одному
DROP TABLE IF EXISTS profile;
CREATE TABLE profile (
    user_id BIGINT UNSIGNED NOT NULL,
    birth_day_id date DEFAULT NULL,
--  birth_city_id BIGINT UNSIGNED NOT NULL,     -- город рождения     
    residence_city_id BIGINT UNSIGNED NOT NULL, -- город проживания 
--  CONSTRAINT fk_birth_city_id     FOREIGN KEY (birth_city_id)     REFERENCES city (id),
    CONSTRAINT fk_residence_city_id FOREIGN KEY (residence_city_id) REFERENCES city (id),
    UNIQUE KEY user_id (user_id),
    CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) COMMENT='Дополнительные данные пользователя' ;

-- Услуги: направления деятельности (гуппа)
DROP TABLE IF EXISTS direct;
CREATE TABLE direct (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name varchar(63),
    UNIQUE KEY name (name), 
    PRIMARY KEY id (id)
) COMMENT='Направления (сферы) деятельности';

-- Услуги, все виды
-- связь один ко многим
DROP TABLE IF EXISTS service_type;
CREATE TABLE service_type (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    direct_id BIGINT UNSIGNED NOT NULL, -- группа услуг
    name VARCHAR(63),
    UNIQUE KEY name (direct_id, name),  -- в рамках группы имя должно быть уникальным
    PRIMARY KEY id (id),
    CONSTRAINT fk_dir_id FOREIGN KEY (direct_id) REFERENCES direct(id)
) COMMENT='Услуги';

-- Заказанные услуги и выполненные услуги
-- один ко многим
DROP TABLE IF EXISTS services;
CREATE TABLE servises (
    id bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id bigint UNSIGNED NOT NULL,                 -- гражданин
    service_type_id bigint UNSIGNED NOT NULL,         -- вид услуги
    service_status ENUM ('start', 'production', 'ready', 'complited'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    product_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    complited_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_service_user_id FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_service_type_id FOREIGN KEY (service_type_id) REFERENCES service_type(id),  
    PRIMARY KEY (id)
);



/* ОЦЕНКА ПРЕПОДАВАТЕЛЯ: ОТЛИЧНО (Сдано 18-06-2022; 5:39. Проверено 9:35 MSK)
 * Кирилл Иванов, преподаватель

   Правильно, что пересоздаете БД заново перед работой с ней.
   Правильно, что выбираете БД по умолчанию для скрипта командой USE <db_name>;
   Количество таблиц достаточное.
   Не забудьте наполнить таблицы данными. 
   Также крайне желательно пользоваться пакетной вставкой данных.
   ER-диаграмму можно добавить в виде скриншота или файлом *.mwb из Workbench.
*/

