--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  Home Work 07
-- 
-- 1. Составьте список пользователей users, которые осуществили 
--     хотя бы один заказ orders в интернет магазине.
USE shop;
-- Что мы имеем?
SELECT * FROM users;
SELECT * FROM orders;

-- РЕШЕНИЕ

-- Вариант-А 
-- Вложенный запрос (простое решение задачи)
SELECT *
  FROM users
 WHERE EXISTS (SELECT * FROM orders WHERE user_id = users.id);

-- Вариант-Б /включая подсчёт этих заказов
-- многотабличный запрос
SELECT users.id, 
       users.name, 
       count(orders.id) AS cnt
  FROM users, 
       orders
 WHERE users.id = orders.user_id
GROUP BY users.id;

-- Вариант-В /включая подсчёт этих заказов
-- Join-соединение
SELECT users.id, 
       users.name, 
       count(orders.id) AS cnt
  FROM users
  JOIN orders
    ON users.id = orders.user_id
GROUP BY users.id


-- ========================================================
-- 2. Выведите список товаров products и разделов catalogs, 
--    который соответствует товару.
-- Вот что мы имеем:
SELECT * FROM products;
SELECT * FROM catalogs;

-- РЕШЕНИЕ

-- Вариант-А: вложенный под-запрос
SELECT 
    id, name, price, 
   (SELECT name FROM catalogs WHERE id = products.catalog_id) AS cName
FROM 
    products;

-- Вариант-Б: много-табличный запрос 
SELECT 
    p.id, p.name, p.price, c.name
  FROM 
    products AS p, 
    catalogs AS c
 WHERE 
    p.catalog_id = c.id ;

-- Вариант-В: join-соединение
-- самый эффективный вариант (но проверить пока не удалось)
SELECT p.id, p.name, p.price, c.name
  FROM products AS p
  JOIN catalogs AS c
    ON p.catalog_id = c.id ;


-- (по желанию)==========================================
-- 3. Пусть имеется таблица рейсов flights (id, from, to) 
--    и таблица городов cities (label, name). 
--    Поля from, to и label содержат английские названия городов, поле name — русское. 
--    Выведите список рейсов flights с русскими названиями городов.

-- Сначала создадим и наполним таблицы.

CREATE DATABASE IF NOT EXISTS airport;
USE airport; 
DROP TABLE IF EXISTS cities;
CREATE TABLE IF NOT EXISTS cities (
    `label` VARCHAR(128) NOT NULL PRIMARY KEY,
    `name`  VARCHAR(128) NOT NULL,
    UNIQUE KEY uni_name(`name`),
    UNIQUE KEY uni_label_name(`label`, `name`)
);
DESCRIBE cities; -- поверим нашу структуру

DROP TABLE IF EXISTS flights;
CREATE TABLE IF NOT EXISTS flights (
    `id`   SERIAL PRIMARY KEY,
    `from` VARCHAR(128) NOT NULL, 
    `to`   VARCHAR(128) NOT NULL,
    CONSTRAINT fk_flights_cities_from FOREIGN KEY (`from`) REFERENCES cities(`label`),
    CONSTRAINT fk_flights_cities_to FOREIGN KEY (`to`) REFERENCES cities(`label`)
);
DESCRIBE flights; -- проверим...

-- внесём необходимые данные (обращая особое внимание на ключевое поле)
-- рейсы:
INSERT INTO cities (`label`, `name`) VALUES 
    ('moscow',   'Москва'),
    ('irkutsk',  'Иркутск'),
    ('novgorod', 'Новгород'),
    ('kazan',    'Казань'),
    ('omsk',     'Омск');
-- проверим:
SELECT * FROM cities;
-- справочник городов на русском языке:
INSERT INTO flights (`from`, `to`) VALUES 
    ('moscow',   'omsk'),
    ('novgorod', 'kazan'),
    ('irkutsk',  'moscow'),
    ('omsk',     'irkutsk'),
    ('moscow',   'kazan');
-- проверим и здесь:
SELECT * FROM flights;

-- РЕШЕНИЕ

-- Вариант-А 
-- Вложенный запрос -- "изготовить" относительно просто (даже я справился за несколько подходов)
SELECT id,
      (SELECT `name` FROM cities WHERE `label` = f.`from`) AS 'Вылет',
      (SELECT `name` FROM cities WHERE `label` = f.`to`)   AS 'Прилёт'
  FROM flights AS f
ORDER BY id;

-- Вариант-Б 
-- Много-табличный запрос -- правильно я его называю?
SELECT f.id, 
       c_FR.`name` AS 'Вылет', -- "дурацкие" псевдонимы
       c_to.`name` AS 'Прилёт' -- для красоты таблички (но не более)
  FROM flights AS f, 
       cities AS c_FR, -- называем по разному для Вылета
       cities AS c_to  -- и дригим именем для Прилёта
 WHERE c_FR.`label` = f.`from`
   AND c_to.`label` = f.`to`
ORDER BY f.id;

-- Вариант-В
-- Join-соединения (их много!): 
-- обращаемся к справочнику "cities" под разными именами (псевдонимами)!
SELECT id, 
       cFR.`name` AS 'Вылет', 
       cto.`name` AS 'Прилёт' 
  FROM flights AS f
       INNER JOIN cities AS cFR ON cFR.`label` = f.`from` -- он же для Вылета
       INNER JOIN cities AS cto ON cto.`label` = f.`to`   -- он же для Прилёта
ORDER BY id;

-- заметаем следы (рыжим хвостом)...
DROP DATABASE IF EXISTS airport;

-- P.S. 
-- Последнее задание, простое на первый взгляд, оказалось твёрдым орешком
-- для меня, при попытках решения как много-табличным запросом, так и join-соединением... 
-- Но очень полезным!


-- ОЦЕНКА ПРЕПОДАВАТЕЛЯ: ОТЛИЧНО (2022-05-29; 18:44 MSK)
-- Кирилл Иванов, преподаватель
-- 
-- Правильно, что используете запросы с объединением таблиц (JOIN) 
-- вместо вложенных запросов.


