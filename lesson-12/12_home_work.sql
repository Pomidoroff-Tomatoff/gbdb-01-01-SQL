--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  Home Work 12, курсовой проект

-- ПРОЕКТ БД: ГОСУСЛУГИ
-- Решаемые задачи: 
-- А) выдача справок и документов
-- Б) поддержание учётной записи пользователя

-- 1. DDL

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

-- Пользователь: дополнительные данные
-- связь: 1--1
DROP TABLE IF EXISTS profile;
CREATE TABLE profile (
    user_id BIGINT UNSIGNED NOT NULL,
    birth_day DATE NOT NULL,
    birth_city_id BIGINT UNSIGNED NOT NULL,       -- город рождения     
    residence_city_id BIGINT UNSIGNED NOT NULL,   -- город проживания 
    CONSTRAINT fk_birth_city_id     FOREIGN KEY (birth_city_id)     REFERENCES city (id),
    CONSTRAINT fk_residence_city_id FOREIGN KEY (residence_city_id) REFERENCES city (id),
    UNIQUE KEY user_id (user_id),
    CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) COMMENT='Дополнительные данные пользователя' ;

-- Услуги: направления деятельности (группа)
DROP TABLE IF EXISTS direct;
CREATE TABLE direct (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name varchar(63),
    UNIQUE KEY name (name), 
    PRIMARY KEY id (id)
) COMMENT='Направления (сферы) деятельности';

-- Услуги, все виды
-- связь: 1--M
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
-- связь: 1--M
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

-- ЖУРНАЛИРОВАНИИЕ: отслеживание изменений данных пользователя

-- Таблица для журналирования
DROP TABLE IF EXISTS logs_users;
CREATE TABLE IF NOT EXISTS logs_users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    correct_at DATETIME DEFAULT current_timestamp,
    log_command ENUM ('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    log_id BIGINT UNSIGNED DEFAULT NULL,
    log_firstname varchar(127) DEFAULT NULL,
    log_fathername varchar(127) DEFAULT NULL,
    log_lastname varchar(127) DEFAULT NULL,
    log_email varchar(127) DEFAULT NULL,
    log_phone BIGINT DEFAULT NULL,
    log_verification BIT DEFAULT NULL
) comment = 'Журнал регистрации создания записей' ENGINE = Archive;

-- Процедура (общая) записи строки в журнал (logs)

DELIMITER //

DROP PROCEDURE IF EXISTS logs_users_modification // 
CREATE PROCEDURE logs_users_modification(
    IN log_command varchar(127), 
    IN log_id bigint UNSIGNED, 
    IN log_firstname varchar(127),
    IN log_fathername varchar(127),
    IN log_lastname varchar(127),
    IN log_email varchar(127),
    IN log_phone BIGINT,
    IN log_verification INT 
    )  
BEGIN
    INSERT INTO logs_users 
                (log_command, log_id, log_firstname, log_fathername, log_lastname, log_email, log_phone, log_verification) 
         VALUES (log_command, log_id, log_firstname, log_fathername, log_lastname, log_email, log_phone, log_verification);
END //

-- Тригеры-инициаторы записей изменений в журнал изменений (logs_users)
-- для всех трёх событий: вставки, обновления, удаления:

DROP TRIGGER IF EXISTS 
    tr_users_INSERT //
CREATE TRIGGER 
    tr_users_INSERT AFTER INSERT ON users
FOR EACH ROW 
BEGIN 
   CALL logs_users_modification('INSERT', 
    NEW.id, 
    NEW.firstname, 
    NEW.fathername, 
    NEW.lastname, 
    NEW.email, 
    NEW.phone, 
    NEW.verification);
END //

DROP TRIGGER IF EXISTS 
    tr_users_UPDATE //
CREATE TRIGGER 
    tr_users_UPDATE AFTER UPDATE ON users
FOR EACH ROW 
BEGIN 
   CALL logs_users_modification('UPDATE', 
    NEW.id, 
    NEW.firstname, 
    NEW.fathername, 
    NEW.lastname, 
    NEW.email, 
    NEW.phone, 
    NEW.verification);
END //

DROP TRIGGER IF EXISTS 
    tr_users_DELETE //
CREATE TRIGGER 
    tr_users_DELETE BEFORE DELETE ON users
FOR EACH ROW 
BEGIN 
   CALL logs_users_modification('DELETE', 
    OLD.id, 
    OLD.firstname, 
    OLD.fathername, 
    OLD.lastname, 
    OLD.email, 
    OLD.phone, 
    OLD.verification);
END //
 
DELIMITER ;

