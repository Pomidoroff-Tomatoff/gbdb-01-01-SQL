--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  05 Home Work
--  05.A Операторы, фильтрация, сортировка и ограничение
--  05.B Агрегация данных


-- =========================================================================================================+
-- 05.A ОПЕРАТОРЫ, ФИЛЬТРАЦИЯ, СОРТИРОВКА И ОГРАНИЧЕНИЕ
-- =========================================================================================================+

-- 05.A.1. =================================================================================================+ 
-- ЗАДАНИЕ: 
-- Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
-- Заполните их текущими датой и временем.

-- РЕШЕНИЕ
-- 05.A.1. -- 1-ПОДГОТОВКА: структура таблицы
-- Подготовка таблицы к выполнению задания:
-- Удалим (чтобы начать заново) и вновь созадим поля создания и обновления записи типа DATETIME:

ALTER TABLE users DROP created_at; 
ALTER TABLE users DROP updated_at;

ALTER TABLE users ADD COLUMN created_at DATETIME ;
ALTER TABLE users ADD COLUMN updated_at DATETIME ;

-- 05.A.1. -- 2-ПОДГОТОВКА: занесём возможные данные
-- Занесём некую "исходную информацию": 
-- пусть у нас будут все возможные комбинации данных времени 
-- похожих на реальность, как-то попавших в базу...

UPDATE users SET created_at = TIMESTAMPADD(YEAR, -2, NOW()) WHERE (id % 2) > 0 AND id > 5;
UPDATE users SET updated_at = TIMESTAMPADD(YEAR, -2, NOW()) WHERE ((id+1) % 2) > 0;
UPDATE users SET 
    created_at = TIMESTAMPADD(YEAR, -25, NOW()), 
    updated_at = NOW() 
WHERE id IN(1, 6, 9);

SELECT id, firstname, created_at, updated_at FROM users ;

-- 05.A.1. -- 3-РЕШЕНИЕ: сохранение имеющихся данных
-- (ранее мы подготовили таблицу и некие данные, которые мы будем теперь "спасать")
-- Сначала пытаемся найти данные и сохранить их.

UPDATE users SET              -- есть информация ТОЛЬКО в поле created_at:
    updated_at = created_at   -- заполняем им пустое поле updated_at,
WHERE updated_at IS NULL      -- то есть зададим, что это поле не обновлялось после создания
  AND created_at IS NOT NULL; -- и данные этой записи хорошо бы проверить в дальнейшем...

UPDATE users SET              -- есть информация ТОЛЬКО в поле update_at:
    created_at = updated_at   -- заполняем им пустое    
WHERE created_at IS NULL      -- поле created_at...
  AND updated_at IS NOT NULL;

-- 05.A.1. -- 3-РЕШЕНИЕ: выполнение задания
-- Теперь, когда попытка сохранения данных проведена,
-- необходимо преобразовать параметры полей created_at и updated_at так, 
-- чтобы они заполнялись значениями по умолчанию самой БД,
-- чтобы не эта история не повторилась ещё раз...
  
ALTER TABLE users MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE users MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- А теперь необходимо обратить внимание на записи, в которых не было данных для возможного сохранения,
-- то есть оба поля даты были пустыми (null): их необходимо заполнить текущей датой.

UPDATE users SET           -- При этом поле updated_at обновиться текущей датой автоматически  
    created_at = now()     -- при обновлении записи.
WHERE created_at IS NULL ;

UPDATE users SET           -- Если же в процессе работы мы почему-то потеряли контроль   
    updated_at = now()     -- на полем updated_at (в процессе подготовки модели данных),
WHERE updated_at IS NULL ; -- то обновим его (на всякий случай). 

-- 05.A.1. -- 4 (жирная точка)
-- Окончательно исправляем струтуру таблицы так,
-- чтобы пустые данные в полях с датой там больше не появлялись,
-- введя ограничение на пустое значение:

ALTER TABLE users MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE users MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL;
SELECT id, firstname, created_at, updated_at FROM users ;

-- 05.A.1. -- 5 (END)
-- Проверяем: 
-- > запросы на обновление не должны выполниться и привести к ошибке!
-- > выборка записей, с не заполненными полями даты должена быть путой.

UPDATE users SET created_at = NULL ;
UPDATE users SET updated_at = NULL ;

SELECT id, firstname, created_at, updated_at FROM users WHERE created_at IS NULL OR updated_at IS NULL ;


-- 05.A.2. =================================================================================================+
-- ЗАДАНИЕ: 
-- Таблица users была неудачно спроектирована. 
-- Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время 
-- помещались значения в формате "20.10.2017 8:10". 
-- Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.

-- РЕШЕНИЕ
-- 05.A.2. -- 1-ПОДГОТОВКА: сформируем данные
-- Поля created_at и updated_at заполнены в предыдущем задании.
-- Нам нужно их преобразовать к нестандартому виду, как в образце ("20.10.2017 8:10") 

-- преобразуем дату-время в строку формата "20.10.2017 8:10"
-- материал дат берём из предыдущего задания, но добавляем исходное значение "20.10.2017 8:10", 
-- которое мне не удалось сгенерировать программным путём (имею ввиду количество символов для часов)...

-- преобразуем поля с датами к строковому виду, для возможности размещения туда даты специального формата 
ALTER TABLE users MODIFY COLUMN created_at VARCHAR(256);
ALTER TABLE users MODIFY COLUMN updated_at VARCHAR(256);
-- поле created_at: преобразуем строки с датами в специальный формат
UPDATE users SET created_at = DATE_FORMAT(created_at, '%e.%c.%Y %k:%i') WHERE created_at IS NOT NULL;
UPDATE users SET created_at = DATE_FORMAT(now(), '%e.%c.%Y %k:%i') WHERE created_at IS NULL;
-- ... и добавим строку данных, как в задании (сгенерировать такой формат не получилось!!!)
UPDATE users SET created_at = '20.10.2017 8:10' WHERE id IN (1, 6, 9);  
-- поле updated_at: так же...
UPDATE users SET updated_at = DATE_FORMAT(updated_at, '%e.%c.%Y %k:%i') WHERE updated_at IS NOT NULL;
UPDATE users SET updated_at = DATE_FORMAT(now(), '%e.%c.%Y %k:%i') WHERE updated_at IS NULL;
-- ... и добавим строку-образец даты...
UPDATE users SET updated_at = '20.10.2017 8:10' WHERE id IN (1, 6, 9);

SELECT * FROM users;
SELECT id, firstname, created_at, updated_at FROM users;

-- 05.A.2. -- 2-РЕШЕНИЕ: конвертируем исп. ф-цию STR_TO_DATE(). 
-- Время в строковом типе и нестандартном формате 
-- преобразуем к типу DATETIME и заносим в новое поле типа DATETIME...  

-- поле created_at: из строки в тип datatime
ALTER TABLE users ADD COLUMN temp_datetime DATETIME;
UPDATE users SET temp_datetime = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i'); -- день и месяц в формате зададим 2-я символами (посмотрим, что получиться!)
ALTER TABLE users DROP COLUMN created_at;
ALTER TABLE users RENAME COLUMN temp_datetime TO created_at;
ALTER TABLE users MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;

-- поле updated_at: так же...
ALTER TABLE users ADD COLUMN temp_datetime DATETIME;
UPDATE users SET temp_datetime = STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');
ALTER TABLE users DROP COLUMN updated_at;
ALTER TABLE users RENAME COLUMN temp_datetime TO updated_at;
ALTER TABLE users MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL;

-- Проверка
SELECT * FROM users;
SELECT id, firstname, created_at, updated_at FROM users;


-- 05.A.3. =================================================================================================+
-- ЗАДАНИЕ: 
-- В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
-- 0, если товар закончился и выше нуля, если на складе имеются запасы. 
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
-- Однако, нулевые запасы должны выводиться в конце, после всех записей.

-- РЕШЕНИЕ
-- 05.A.3. -- 1-ПОДГОТОВКА: данные

USE shop;
ALTER TABLE storehouses_products MODIFY COLUMN storehouse_id BIGINT UNSIGNED NOT NULL;
ALTER TABLE storehouses_products MODIFY COLUMN product_id BIGINT UNSIGNED NOT NULL;
ALTER TABLE storehouses ADD CONSTRAINT uniq_name UNIQUE (name);
ALTER TABLE storehouses_products 
    ADD CONSTRAINT fk_storehouse_id 
    FOREIGN KEY (storehouse_id) 
    REFERENCES storehouses(id);
ALTER TABLE storehouses_products 
    ADD CONSTRAINT fk_product_id 
    FOREIGN KEY (product_id) 
    REFERENCES products(id);

INSERT INTO storehouses (name) VALUES 
    ('Центральный'),
    ('Удалённый');

TRUNCATE storehouses_products;
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES 
    (1, 1, 142),
    (1, 2, 0),
    (1, 3, 1024),
    (1, 4, 1024),
    (1, 5, 0),
    (1, 6, 256),
    (1, 7, 0);

-- 05.A.3. -- 2-РЕШЕНИЕ: 
-- подменим на сортировке значение поля value равное 0 так, чтобы вместо него 
-- оказалось бы самое большое число BIGINT (UNSIGNED) = 18446744073709551615
 
SELECT value FROM storehouses_products ORDER BY IF((value > 0), value, 18446744073709551615);


-- 05.A.4. (по желанию) =================================================================================================+ 
-- ЗАДАНИЕ:
-- Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
-- Месяцы заданы в виде списка английских названий ('may', 'august')

-- 05.A.4. 
-- РЕШЕНИЕ-A-4--1: подготовка
-- добавим в таблицу users поле дня рождения в произвольном формате со строчным месяцем

USE vk;
ALTER TABLE users ADD COLUMN birthday_EN varchar(64);
UPDATE users SET birthday_EN = (SELECT DATE_FORMAT(birthday, '%e %M %Y') FROM profiles WHERE user_id = users.id);

-- 05.A.4. 
-- РЕШЕНИЕ РЕШЕНИЕ-A-4--2: найдём заданных пользователей

-- при помощи функции INSTR() -- поиска подстроки в строке
SELECT firstname, birthday_EN FROM users 
    WHERE INSTR(birthday_EN, 'may') 
       OR INSTR(birthday_EN, 'august');
-- или
-- при помощи оператора выборки похожих элементов LIKE 
SELECT firstname, birthday_EN FROM users 
    WHERE birthday_EN LIKE '%may%' 
       OR birthday_EN LIKE '%august%';
-- или
-- при помощи оператора расширенной выборки похожих элементов RLIKE
SELECT firstname, birthday_EN FROM users 
 WHERE birthday_EN RLIKE 'may|august';


-- 05.A.5. (по желанию) =================================================================================================+
-- ЗАДАНИЕ-A-5
-- Из таблицы catalogs извлекаются записи при помощи запроса 
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
-- Отсортируйте записи в порядке, заданном в списке IN.
 
-- РЕШЕНИЕ-A-5
-- Используем интересную функцию FIELD() типа INT, 
-- которая возвращает поцизию первого аргумента (id) в списке следующих далее аргументов (... 5, 1, 2)
-- Такой подход нагляден, так как сохраняет список IN() в списке аргументов FIELD():

USE shop;
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2);

-- Но! 
-- Интересно было бы представить списко позиций в виде строки и использовать его как переменную...
-- Например, исп. функцию FIND_IN_SET('b', 'a,b,c,d')...


-- =========================================================================================================+
-- 05.B АГРЕГАЦИЯ ДАННЫХ
-- =========================================================================================================+

-- 05.B.1. =================================================================================================+
-- ЗАДАНИЕ-B-1:
-- Подсчитайте средний возраст пользователей в таблице users

-- 05.B.1. РЕШЕНИЕ-1--1
-- Для подсчёта возраста используем функцию TIMESTAMPDIFF()
USE shop;
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, now())) FROM users;

-- ВАРИАНТ НЕТОЧНОГО РЕШЕНИЯ:
-- Использование функции YEAR() в данной задаче может привести к неточности, так как в таком случае 
-- мы отбрасываем дату и месяц, что приводит к фактическому сравнению дат на 1 января...
-- Результатом может быть увеличение на год возраста для претендентов, которые ещё "не родились" в этом году, 
-- то есть у них день рождения позже текущей даты, так как отбрасывая месяц и день мы считаем, что они уже родились.
-- Вот разница, получющаяся в годах:
SELECT TIMESTAMPDIFF(YEAR, birthday_at, now()), YEAR(NOW()) - YEAR(birthday_at) FROM users;
-- ... разница среднего значения (оно больше):
SELECT AVG(YEAR(NOW()) - YEAR(birthday_at)) AS BD_Y FROM users;

-- 05.B.2. =================================================================================================+
-- ЗАДАНИЕ-B-2:
-- Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.

-- 05.B.2. РЕШЕНИЕ-2--1
-- Получим день рождения в текущем году. Для этого нам необходимо
-- разделить дату рождения на составляющие (день, месяц, год) и заменить год на текущий
-- * Для этого используем функции DAY(дата рождения), MONTH(дата рождения), YEAR(текущая дата).
-- * Обединим полученные составляющие в одну строку с разделителем "точка" (на всякий случай)
-- * Преобразуем строку дня рождения этого года в формат даты,
--   используя функцию STR_TO_DATE() с указаниме формата преобразования '%d.%m.%Y'
-- Определим праздничные дни недели DAYNAME() для найденных дат и
-- Выполним группировку с подсчётом запрошенных значений.

SELECT COUNT(*), 
       DAYNAME(
          STR_TO_DATE(
              CONCAT_WS('.', DAY(birthday_at), MONTH(birthday_at), YEAR(NOW())), 
              '%d.%m.%Y'
          )
       ) 
    AS birthday_currentYEAR_dayname 
  FROM users 
  GROUP BY 
       birthday_currentYEAR_dayname
;


-- 05.B.3.(по желанию)  =====================================================================================+
-- ЗАДАНИЕ-3:
-- Подсчитайте произведение чисел в столбце таблицы

-- 05.B.3. РЕШЕНИЕ-3--1
-- так как логорифм произведения равен сумме логарифмов:
-- ln(2*3*4*5) = ln(2) + ln(3) + ln(4) + ln(5)
-- то если применить обратную к натуральному логарифму функцию экспоненты, то мы получим произведение всех 
-- 2*3*4*5 = exp(ln(2*3*4*5))=exp(ln(2) + ln(3) + ln(4) + ln(5))

SELECT EXP(SUM(LOG(id))) FROM (
    VALUES ROW (1), ROW (2), ROW(3), ROW(4), ROW(5) 
    ) temp(id) -- используем конструктор табличных данных
    WHERE id > 0 ;


-- 05 Home Work 
-- END


-- ОЦЕНКА ПРЕПОДАВАТЕЛЯ: ОТЛИЧНО (2022-05-22; 16:11. Воскресенье)
-- Кирилл Иванов, преподаватель 
--
-- Текущую дату и время одинаково возвращают функции now() и CURRENT_TIMESTAMP.
-- Несколько трюков с сортировкой: 
-- https://www.simplecoding.org/sortirovka-v-mysql-neskolko-redko-ispolzuemyx-vozmozhnostej.html
--
-- Подробный список параметров форматирования даты в функции STR_TO_DATE можно глянуть тут: 
-- https://www.w3schools.com/sql/func_mysql_str_to_date.asp