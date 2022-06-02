--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  Home Work 08 (Join для 06)
--  Операторы, фильтрация, сортировка и ограничение. Агрегация данных”. 
--  JOIN-решение для всех заданий


-- =====================================================================
-- 1. Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, 
--    который больше всех общался с выбранным пользователем (написал ему сообщений).

-- РЕШЕНИЕ
-- Вариант А-1: однотабличный запрос
-- Для решения этой задачи не нужно применять ни вложенные запросы, 
-- ни многотабличные или Join-соединения
-- Действия:
-- Сгруппируем сообщения по отправителю для выбранного получателя
-- и посчитаем количество сообщений в подгруппах введя агрегационную функцию...
-- Добавив сортировку (по убыванию) с ограничением по количеству записей (в 1-цу) мы выведем строку
-- с отправителем, имеющим самое большое количество сообщений для выбранного адресата.

SELECT 
    count(*) AS max_from,
    from_user_id AS from_id,
    to_user_id AS to_id
FROM messages
WHERE to_user_id = 1  -- выбранный (отслеживаемый) получатель
GROUP BY from_user_id
ORDER BY max_from DESC 
LIMIT 1;

-- 1. УСЛОЖЕНИЕ ЗАДАНИЯ: 
-- А теперь вместо заданного одного конкретного получателя мы хотим найти
-- для всех имеющихся получателей их максимальных отправителей.

-- Вариант 1.А-2: вложенный запрос

SELECT (
        SELECT COUNT_from
           FROM (
                SELECT count(from_user_id) AS COUNT_from, from_user_id, to_user_id
                  FROM messages
                 WHERE to_user_id = ur.id
                 GROUP BY to_user_id, from_user_id
                 ORDER BY to_user_id, COUNT_from DESC, from_user_id 
                 LIMIT 1
                ) AS max_from
       ) AS max_from
     , ( 
        SELECT from_user_id
           FROM (
                SELECT count(from_user_id) AS COUNT_from, from_user_id, to_user_id
                  FROM messages
                 WHERE to_user_id = ur.id
                 GROUP BY to_user_id, from_user_id
                 ORDER BY to_user_id, COUNT_from DESC, from_user_id 
                 LIMIT 1
                ) AS max_from
       ) AS from_id
     , ur.id AS 'to_id'       
  FROM users AS ur
 ORDER BY ur.id
;

-- Вариант 1.Б: многотабличный запрос (если возможно)
-- пока не придумал
-- Но мы добавим строки в сообщения, для контроля и уверенности

INSERT INTO messages VALUES 
    (DEFAULT, 34, 11, 'Hi', DEFAULT, TRUE),
    (DEFAULT,  2, 11, 'Hi ываплыжвад', DEFAULT, TRUE),
    (DEFAULT, 34, 11, 'дывлоадылв а', DEFAULT, TRUE),
    (DEFAULT, 34, 11, 'дылвоадылов адылова ывадло', DEFAULT, TRUE),
    (DEFAULT, 34, 11, 'ыдва ыдвло дывлоцдлвоыв', DEFAULT, TRUE),
    (DEFAULT, 99, 87, '1 ыдаоыдвал', DEFAULT, TRUE),
    (DEFAULT, 99, 87, 'sdfjh sdjkhfks dksjdfskfd sdkjfhs', DEFAULT, TRUE);

-- Вариант 1.В: Join-запрос ??? НЕПОНЯТНО КАК РАБОТАЕТ, ТРЕБУЕТСЯ ПЕРЕДЕЛКА ???
-- Функция max() возвращает всю строку, для которой актуально максимальное значение (в отличии от count(), для которой остальные поля принимают любые значения группировки)
SELECT max(max_from.COUNT_from) AS max_me, max_from.from_user_id /*, max_from.to_user_id*/, ur.id
  FROM (
        SELECT count(from_user_id) AS COUNT_from,
               from_user_id,
               to_user_id
          FROM messages
        GROUP BY to_user_id, from_user_id
        ORDER BY to_user_id, COUNT_from DESC , from_user_id
       ) AS max_from
 RIGHT JOIN users AS ur ON ur.id = max_from.to_user_id -- AND max_from.COUNT_from = 9
GROUP BY ur.id 
; 


-- =====================================================================
-- 2. Подсчитать общее количество лайков, которые получили пользователи 
--    младше 10 лет..
USE vk;
-- Решение-2-А: вложенные запросы
-- повтор урока 6 для наглядности...

SELECT COUNT(id) AS total_senders_less_10_year
  FROM likes
 WHERE TIMESTAMPDIFF(
       YEAR, 
      (SELECT birthday FROM profiles WHERE user_id = 
             (SELECT user_id FROM media WHERE id = likes.media_id)), 
       NOW()) < 10 ;

-- Решение-2-Б: многотабличный запрос (дался легче, чем join...)
-- действуем интуитивно, помогая себе опытом с вложенными запросами

SELECT count(li.id) AS 'total_senders_less_10_year'
  FROM likes AS li,
       media AS me,
       profiles AS pro
 WHERE li.media_id = me.id       -- связь лайков и медиа
   AND me.user_id = pro.user_id  -- связь медиа и профиля
   AND timestampdiff(YEAR, pro.birthday, now()) < 10;

-- Решение-2-В: JOIN-запрос
-- Главное: ищем общую таблицу для всех, а уже к ней привязывем остальных  
   
SELECT count(li.id) AS 'total_senders_less_10_year'
  FROM media AS me
  JOIN likes AS li ON li.media_id = me.id
  JOIN profiles AS pro ON pro.user_id = me.user_id
 WHERE timestampdiff(YEAR, pro.birthday, now()) < 10
;
 

-- =====================================================================
-- 3. Определить кто больше поставил лайков (всего): мужчины или женщины.
--    Моё допущение: пусть результатом будет строка, 
--    с указанием пола с указанием количества лайков для этой группы
 
-- Решение-3-А: вложенные запросы (повтор 6-ого  урока с упрощением)

SELECT count(*) AS cnt,
      (SELECT gender FROM profiles WHERE user_id = 
             (SELECT user_id FROM media WHERE id = likes.media_id)
        ) AS gen
  FROM likes
GROUP BY gen
ORDER BY cnt DESC 
LIMIT 1;

-- Решение-3-Б: многотабличный запрос

SELECT count(li.id) AS cnt, 
       CASE pro.gender
        WHEN 'f' THEN 'Женщина'
        WHEN 'm' THEN 'Мужчина'
        ELSE 'бот'
       END AS gen
  FROM likes AS li, media AS me, profiles AS pro
 WHERE li.media_id = me.id
   AND me.user_id = pro.user_id
GROUP BY gen 
ORDER BY cnt DESC 
LIMIT 1;

-- Решение-3-В: JOIN-запрос-соединение

SELECT count(li.id) AS cnt,
       CASE pro.gender
        WHEN 'f' THEN 'Женщина'
        WHEN 'm' THEN 'Мужчина'
        ELSE 'бот'
       END AS gen
  FROM media AS me 
  JOIN likes AS li ON li.media_id = me.id
  JOIN profiles AS pro ON pro.user_id = me.user_id 
GROUP BY gen 
ORDER BY cnt DESC 
LIMIT 1;


ОЦЕНКА ПРЕПОДАВАТЕЛЯ: ОТЛИЧНО (2022-06-01; 02:08 MSK отправлено и 12:30 проверено)

Кирилл Иванов・Преподаватель

Можно было обойтись в решении без внешних объединений, используя только INNER JOIN.
Решение предполагало использование только объединения таблиц (оператор JOIN), без вложенных запросов.
Хорошо, что стараетесь придерживаться стандартов кодирования, принятых в SQL. Полный список их можно найти по ссылке в комментариях к 3 уроку.
В следующем вебинаре (урок 10) будет разбор этого ДЗ и сравнение с решением, использующим вложенные запросы.
