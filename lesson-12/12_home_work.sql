--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  Home Work 12, курсовой проект

-- ПРОЕКТ БД: ГОСУСЛУГИ
-- Решаемые задачи: 
-- А) выдача справок и документов
-- Б) поддержание учётной записи пользователя

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
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
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
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

-- Заказанные услуги и состояние их выполнения
-- связь: 1--M
DROP TABLE IF EXISTS services;
CREATE TABLE services (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,             -- гражданин
    service_type_id BIGINT UNSIGNED NOT NULL,     -- вид услуги
    service_status ENUM ('start', 'production', 'ready', 'complited') DEFAULT 'start',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_service_user_id FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_service_type_id FOREIGN KEY (service_type_id) REFERENCES service_type(id),  
    PRIMARY KEY (id)
);

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
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
) comment = 'Журнал регистрации изменений таблицы users' ENGINE = Archive;

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


-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
-- ПРЕДСТАВЛЕНИЯ
-- Пользователи (Join-соединения)
DROP VIEW IF EXISTS user_view ;
CREATE OR REPLACE ALGORITHM=MERGE VIEW user_view AS
    SELECT usr.id AS `N`, usr.firstname AS `Name`, pro.birth_day AS Birthday, cty.name AS `City`, 
           (CASE usr.verification 
                WHEN 1 then 'да'
                WHEN 0 then '-'
                ELSE '-'
            END ) AS `Verify`
      FROM users as usr
      LEFT JOIN profiles as pro ON usr.id = pro.user_id        -- если в профиле записи нет, 
      LEFT JOIN city as cty ON pro.residence_city_id = cty.id -- то строку с пользователем не теряем!  
; #user_view/end
-- SELECT * FROM user_view ; -- WHERE n IN (5, 4, 7) ORDER BY field(n, 5, 4, 7) ;

-- Услуги (вложенные запросы)
DROP VIEW IF EXISTS srv_type_view ;
CREATE OR REPLACE ALGORITHM=MERGE VIEW srv_type_view AS
    SELECT id AS n, 
          (SELECT name FROM direct WHERE id = st.direct_id) AS dir, 
           name 
      FROM service_type AS st
; #service_view/end;
-- SELECT * FROM srv_type_view ; -- WHERE dir = 'Справки' ;

-- Услуги: состояние принятых заданий от граждан
DROP VIEW IF EXISTS srv_view ;
CREATE OR REPLACE ALGORITHM=MERGE VIEW srv_view AS
    SELECT srv.id AS n, 
           usr.firstname AS Name, 
           dir.name AS Direct, 
           stp.name AS Document, 
           service_status AS status, 
           srv.updated_at AS updated 
      FROM services AS srv
      LEFT JOIN users AS usr ON srv.user_id = usr.id
      LEFT JOIN service_type AS stp ON stp.id = srv.service_type_id
      LEFT JOIN direct AS dir ON dir.id = stp.direct_id 
; # srv_view/end
-- SELECT * FROM srv_view ORDER BY updated ;


-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
-- DML
-- наполняем таблицы данными...

USE gos;

-- ПОЛЬЗОВАТЕЛИ-1, основное
-- все пользователи не подтверждены (поле verification в нуле)
INSERT INTO users 
    (id, firstname, fathername, lastname, email, phone)
VALUES 
    (1, 'Иван',     'Петрович',     'Мышкин',    'little@mouse.rr',   79260000001),
    (2, 'Анна',     'Cергеевна',    'Лесникова', 'a.forest@mail.mm',  79000000002),
    (3, 'Захар',    'Валентинович', 'Громов',    'lsdkfj@email.ff',   79030000003),
    (4, 'Петр',     'Иванович',     'Кузькин',   'ku@mail.mm',        79000000004),
    (5, 'Мария',    'Cергеевна',    'Лесникова', 'm.forest@mail.mm',  79000000005),
    (6, 'Кузьма',   'Борисович',    'Телегин',   'telega@mail.mm',    79100000006),
    (7, 'Светлана', 'Алексеевна',   'Телегина',  's.telega@mail.mm',  79100000007),
    (8, 'Иван',     'Иваныч',       'Мышкин',    'i.little@mouse.rr', 79160000008)
AS new_values
    (id, firstname, fathername, lastname, email, phone)
ON DUPLICATE KEY UPDATE
    id = new_values.id,
    firstname = new_values.firstname, 
    fathername = new_values.fathername,
    lastname = new_values.lastname,
    email = new_values.email,
    phone = new_values.phone
; #users/end

-- ПОЛЬЗОВАТЕЛИ-2а: подтверждение пользователя в офисе
-- Проверка работы тригеров на обновление (конструкция INSERT--ON-UPDATE)
INSERT INTO users 
    (id, verification)
VALUES 
    (1, 1), (4, 1) AS new_values(i, v)
ON DUPLICATE KEY UPDATE 
    id = new_values.i,
    verification = new_values.v
; #update-test/end

-- ПОЛЬЗОВАТЕЛИ-2б: подтверждение пользователя в офисе 
-- проверка работы тригеров на обновление (UPDATE)
UPDATE users SET verification = 1 WHERE id = 7;

-- ГОРОДА (справочник)
INSERT INTO city (id, name)
VALUES 
    (1, 'Москва'),
    (2, 'Санкт-Петербург'),
    (3, 'Архангельск'),
    (4, 'Кёнигсберг'),
    (5, 'Владивосток')
AS new_values(id, name)    
ON duplicate KEY UPDATE 
    id = new_values.id,
    name = new_values.name
; #city/end

-- ПОЛЬЗОВАТЕЛИ, дополнительные данные
INSERT INTO profiles 
    (user_id, birth_day, birth_city_id, residence_city_id)
VALUES 
    (1, date('2000-01-01'), 3, 1), 
    (2, date('1975-01-01'), 3, 3),
    (3, date('2005-01-01'), 5, 5),
    (4, date('1995-02-27'), 3, 5),
--  (5, date('2008-12-30'), 1, 5), -- "теряем" эту доп. информацию, но не должны потерять всего пользователя в представлениях...
    (6, date('1987-06-21'), 1, 1),
    (7, date('2000-06-21'), 1, 1),
    (8, date('2003-08-16'), 1, 1)   -- эта запись должна быть удалена каскадом, правильно?
AS new_values(user_id, birth_day, birth_city_id, residence_city_id)
ON DUPLICATE KEY UPDATE 
    user_id = new_values.user_id, 
    birth_day = new_values.birth_day,
    birth_city_id = new_values.birth_city_id,
    residence_city_id = new_values.residence_city_id
; #profiles/END

-- ПОЛЬЗОВАТЕЛИ: удаление 
-- проверка работы тригера на удаление (DELETE) записи 
-- и целостности базы для таблицы profiles: каскадом в ней должна быть удалена запись с id=8
-- SELECT * FROM profiles; 
DELETE FROM users WHERE id = 8;
/* ЦЕЛОСТНОСТЬ БД: проверка на дочерней таблице profiles
 * -- а теперь попробуем вставить "нелегально" запись с id=8, 
 * -- только-что удалённую в родительской таблице users 
 * -- причём без соответствующего «ответа» в главной таблице users.
INSERT INTO profiles 
    (user_id, birth_day, birth_city_id, residence_city_id)
VALUES 
    (NULL, date('2003-08-16'), 1, 1),   -- нелегальная запись, правильно?
    (   8, date('2003-08-16'), 1, 1)
; -- Ура! Контроль целостности БД сработал -- не получилось вставить ошибку!!!  */

-- УСЛУГИ
-- Направления деятельности
INSERT INTO direct (id, name)
VALUES 
    (1, 'Справки'),
    (2, 'Документы, удостоверяющие личность')
AS new_values(id, name)
ON DUPLICATE KEY UPDATE 
    id = new_values.id,
    name = new_values.name 
; #dir/end

-- Список всех услуг по направлениям деятельности
INSERT INTO service_type 
    (id, direct_id, name)
VALUES 
    (1, 1, 'Справка по форме \"А-1\"'),
    (2, 1, 'Справка по форме \"А-2\"'),
    (3, 1, 'Справка по форме \"В-1\"'),
    (4, 2, 'Паспорт гражданина РФ'),
    (5, 2, 'Паспорт заграничный')
AS new_values
    (id, direct_id, name)
ON DUPLICATE KEY UPDATE
    id = new_values.id,
    direct_id = new_values.direct_id,
    name = new_values.name 
; #service_type/end

INSERT INTO services
    (id, user_id, service_type_id, service_status, created_at, updated_at)
VALUES
    ( 1, 2, 4, 'complited',  '2020-03-26 12:12:00', '2020-05-01 12:12:00'),
    ( 2, 3, 4, 'complited',  '2020-04-01 12:12:00', '2020-04-12 09:12:00'),
    ( 3, 1, 1, 'production', '2021-03-26 12:12:00', '2021-05-11 11:45:00'),
    ( 4, 2, 1, 'complited',  '2021-03-26 12:12:00', '2021-05-10 13:12:01'),
    ( 5, 2, 2, 'start',      '2021-04-03 12:12:00', '2021-05-14 17:31:00'),
    ( 6, 2, 3, 'complited',  '2021-04-03 12:12:00', '2020-03-27 12:59:00'),
    ( 7, 5, 4, 'production', '2021-11-10 12:12:00', '2021-12-15 12:12:00'),
    ( 8, 6, 4, 'ready',      '2022-03-11 12:12:00', '2022-04-01 11:30:00'),
    ( 9, 7, 4, 'production', '2022-04-03 12:12:00', '2022-04-27 10:12:00'),
    (10, 7, 5, 'complited',  '2022-05-03 12:12:00', '2022-05-24 09:30:00'),
    (11, 5, 1, 'start',       now(), now() ),
    (12, 5, 2, 'start',       now(), now() )
AS new_values
    (id, user_id, service_type_id, service_status, created_at, updated_at)
ON DUPLICATE KEY UPDATE
    id = new_values.id, 
    user_id = new_values.user_id, 
    service_type_id = new_values.service_type_id, 
    service_status = new_values.service_status, 
    created_at = new_values.created_at, 
    updated_at = new_values.updated_at
; #services/END

-- ВНИМАНИЕ! 
-- УСЛУГИ: НЕЛЕГАЛЬНАЯ запись!
-- Целостность ключа не проверяется на значение NULL, попробуем его вставить!
/*
INSERT INTO services
    (id, user_id, service_type_id, service_status, created_at, updated_at)
VALUES
    (13, NULL, NULL, 'start',       '2022-05-03 12:12:00', '2022-05-24 09:30:00') -- попытка вставить нелегальную запись!
AS new_values
    (id, user_id, service_type_id, service_status, created_at, updated_at)
ON DUPLICATE KEY UPDATE
    id = new_values.id, 
    user_id = new_values.user_id, 
    service_type_id = new_values.service_type_id, 
    service_status = new_values.service_status, 
    created_at = new_values.created_at, 
    updated_at = new_values.updated_at
; #services/END
*/

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- ПРОВЕРКИ

-- Пользователи
SELECT * FROM profiles;
SELECT * FROM user_view;
-- SELECT * FROM user_view WHERE n IN (5, 4, 7) ORDER BY field(n, 5, 4, 7) ;

-- Виды услуг
SELECT * FROM srv_type_view ;
-- SELECT * FROM srv_type_view WHERE dir = 'Справки' ;

-- Услуги в работе
-- находящиеся в работе задания или выполненные, но не сданные:

SELECT * FROM srv_view ORDER BY n;
-- SELECT * FROM srv_view WHERE status != 'complited' ORDER BY updated DESC, n DESC;
-- SELECT * FROM services;

-- Журнал изменений основных данных пользователя
SELECT * FROM logs_users ;


# End of project "GOS"


-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
/* ОЦЕНКА ПРЕПОДАВАТЕЛЯ: ОТЛИЧНО (Сдано 2022-06-21; 03:43 MSK. Проверено: 09:32 MSK)
 * Кирилл Иванов, преподаватель
 
   Хорошо, что позаботились об индексах.
   В SQL в общем случае принято именовать поля таблиц в единственном числе, а таблицы можно называть во множественном числе. важно придерживаться выбранного стиля (все в ед.ч. либо все в мн.ч.).
   Наиболее популярные запросы (часто исполняемые) есть смысл сохранить в виде представлений.
   Хорошо, что реализовали представления, хранимые процедуры, триггеры, не все до этого доходят.
   Успехов в дальнейшем обучении!
**/


/* Мои замечания (2022-06-21; 11:23):
 * -- Не хватает запроса с рядом расположенными офисами Госуслуг
 *    тогда нужна таблица офисов... Можно добавить и представление
 * 
 * -- Не хватает таблицы с чатом между специалистами Госуслуг и пользователем,
 *    так как где-то здесь может появитья таблица многие-ко-многим.
 * 
 * -- Полномочия: Не понятно, как пользователь получает доступ к представлению, 
 *    но не получает доступ к таблице... не продумано мной.
 * 
 * -- Полномочия: Если у пользователя есть доступ и полномочия и вообще он зарегестрированный и всё хорошо,
 * -- то для каждого пользователя таблицы users нужно заводить нового пользователя MySQL?
 * 
 * -- Функции: что-то у меня не получилось... 
**/

