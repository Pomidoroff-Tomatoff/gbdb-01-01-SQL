--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  Home Work 07
-- 
-- 1. Составьте список пользователей users, которые осуществили 
--     хотя бы один заказ orders в интернет магазине.

-- Что мы имеем?
SELECT * FROM users;
SELECT * FROM orders;

-- РешениеECT задачи простое
SELECT *
  FROM users
 WHERE EXISTS (SELECT * FROM orders WHERE user_id = users.id);

-- Решение задачи с подсчётом заказов
SELECT users.id, users.name, count(orders.id) AS cnt
  FROM users, orders
 WHERE users.id = orders.user_id
GROUP BY users.id;

-- Решение задачи JOIN-соединением
SELECT users.id, users.name, count(orders.id) AS cnt
  FROM users
  JOIN orders
    ON users.id = orders.user_id
GROUP BY users.id


-- 2. Выведите список товаров products и разделов catalogs, 
--    который соответствует товару.

-- Имеем
SELECT * FROM products;
SELECT * FROM catalogs;

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


-- (по желанию) 
-- 3. Пусть имеется таблица рейсов flights (id, from, to) 
--    и таблица городов cities (label, name). 
--    Поля from, to и label содержат английские названия городов, поле name — русское. 
--    Выведите список рейсов flights с русскими названиями городов.

-- Сначала создадим и наполним таблицы.

CREATE DATABASE airport;
USE airport; 
DROP TABLE IF EXISTS cities;
CREATE TABLE IF NOT EXISTS cities (
    `label` VARCHAR(128) NOT NULL PRIMARY KEY,
    `name`  VARCHAR(128) NOT NULL,
    UNIQUE KEY uni_name(`name`)
) ;
DESCRIBE cities;

DROP TABLE IF EXISTS flights;
CREATE TABLE IF NOT EXISTS flights (
    `id`   SERIAL PRIMARY KEY,
    `from` VARCHAR(128) NOT NULL, 
    `to`   VARCHAR(128) NOT NULL,
    CONSTRAINT fk_flights_cities_from FOREIGN KEY (`from`) REFERENCES cities(`label`),
    CONSTRAINT fk_flights_cities_to FOREIGN KEY (`to`)   REFERENCES cities(`label`)
);
DESCRIBE flights;

INSERT INTO cities (`label`, `name`) VALUES 
    ('moscow',   'Москва'),
    ('irkutsk',  'Иркутск'),
    ('novgorod', 'Новгород'),
    ('kazan',    'Казань'),
    ('omsk',     'Омск');
SELECT * FROM cities;

INSERT INTO flights (`from`, `to`) VALUES 
    ('moscow',   'omsk'),
    ('novgorod', 'kazan'),
    ('irkutsk',  'moscow'),
    ('omsk',     'irkutsk'),
    ('moscow',   'kazan');
SELECT * FROM flights;

-- ALTER TABLE flights ADD CONSTRAINTS fk_flights_cities_from FOREIGN KEY (`from`) REFERENCES cities(`label`);
-- ALTER TABLE flights ADD CONSTRAINTS fk_flights_cities_to FOREIGN KEY (`to`) REFERENCES cities(`label`);

-- Вариант-А: вложенный запрос
SELECT `name` FROM cities;

SELECT 
    id,
    (SELECT `name` FROM cities WHERE `label` = f.`from`) AS `вылет`,
    (SELECT `name` FROM cities WHERE `label` = f.`to`) AS `прилёт`
FROM flights AS f;

SELECT id, c.`name`
  FROM flights AS f, cities AS c 
 WHERE f.`from` = c.`label`
ORDER BY id;


SELECT id, `from`, `to` 
  FROM flights JOIN cities ON cities.`label` = flights.`from`

;

      flights JOIN cities ON cities.`label` = flights.`from`) AS fl_from
    JOIN cities
    ON cities.`label` = fl.`to`
;











