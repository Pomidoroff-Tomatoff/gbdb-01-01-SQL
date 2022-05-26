--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  Home Work 06
--  Операторы, фильтрация, сортировка и ограничение. Агрегация данных”. 
--  Работаем с БД vk и данными, которые вы сгенерировали ранее:


-- =====================================================================
-- 1. Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, 
--    который больше всех общался с выбранным пользователем (написал ему сообщений).

-- РЕШЕНИЕ
-- используем переменную, для задания отслеживаемого пользователя-получателя
SET @track_user_id = 1;  -- заданный (отслеживаемый) пользователь-получатель

-- посмотрим пользователей, которые писали сообщения к (отслеживаемому) пользователя @track_user_id 
SELECT from_user_id, to_user_id FROM messages WHERE to_user_id = @track_user_id;

-- Сгруппируем сообщения по отправителю для нашего получателя
-- и посчитаем количество сообщений в подгруппах
-- Вариант 1.А
-- Добавив сортировку и ограничение по количеству мы выведем строку 
-- с пользователем, с самым большим количеством сообщений (выполним задание).

SELECT 
    from_user_id,
    to_user_id,
    count(*) AS total_message
FROM messages
WHERE to_user_id = @track_user_id
GROUP BY from_user_id
ORDER BY total_message DESC 
LIMIT 1;
-- Интересно, 
-- а можно-ли здесь использовать функцию нахождения максимального значения?



-- =====================================================================
-- 2. Подсчитать общее количество лайков, которые получили пользователи младше 10 лет..
-- Попытаемся решить задачу...
-- ЧТО У НАС ЕСТЬ?
-- Ингредиенты:
-- 1. лайки (с медиа-айди)
    SELECT * FROM likes;
-- 2. пользователь по его медиа-айди
    SELECT user_id FROM media WHERE id = 1;
-- 3. день рождения для айди-пользователя
    SELECT birthday FROM profiles WHERE user_id = 1;

-- СОБИРАЕМ!
-- сначала получим список пользователей с лайками на их медиа:
SELECT
    id AS like_id,
   (SELECT user_id FROM media WHERE media.id = likes.media_id ) AS to_liked_user_id 
FROM likes;
-- а теперь всё вместе, чтобы получить день рождения лайкнутого пользователя
-- и посмотрим на них (с учётом, что они младше 10 лет):
SELECT 
    id, 
    user_id AS from_user_id,
    media_id,
    (
    SELECT birthday      -- день рождения 
      FROM profiles      -- из профилей
     WHERE user_id =     -- по пользователю, который...
       (
        SELECT 
           user_id       -- а пользователь
          FROM media     -- из таблицы медиа
         WHERE id = likes.media_id 
       )                 -- по медиа из лайков
     ) AS birthday_user
FROM likes
HAVING TIMESTAMPDIFF(YEAR, birthday_user, NOW()) < 10
;

-- ОКОНЧАТЕЛЬНО ВСЁ ПОСЧИТАЕМ!
-- общее количество пользователей младше 10 лет,
-- отправивших сообщения нашему адресату
/* необходимо отказаться от оператора HAVING, 
 * так как с ним не работает агрегационная функция подсчёта выборки (безобразие, конечно...)
 */
SELECT 
    COUNT(id) AS total_senders_less_10_year
FROM likes
WHERE TIMESTAMPDIFF(
    YEAR, 
   (SELECT birthday FROM profiles WHERE user_id = 
   (SELECT user_id FROM media WHERE id = likes.media_id)), 
    NOW()) < 10
;



-- =====================================================================
-- 3. Определить кто больше поставил лайков (всего): мужчины или женщины.
-- РЕШЕНИЕ
-- Что мы имеем?
-- 0. сравнение (? мужчин-лайков > женщин-лайков ?)
    SELECT 'm-likes' > 'f-likes';
-- 1. лайки, вместе с медиа-айди
    SELECT id, media_id FROM likes;
-- 2. пользователь по медиа-айди
    SELECT user_id FROM media WHERE id = 1;
-- 3. пол пользователя из профилей
    SELECT gender FROM profiles WHERE user_id = 1;

-- Соберём и посмотрим на них:
SELECT 
    count(*),
--  id,
--  media_id,
   (SELECT gender FROM profiles 
    WHERE 
        user_id = 
       (SELECT user_id FROM media WHERE id = likes.media_id)
    ) AS gender_liked
FROM likes
GROUP BY gender_liked
;

-- СРАВНЕНИЕ (решение задачи)
-- Болше ли оставили лайков мужчины?
SELECT
(
    (
    SELECT 
        count(*),
       (SELECT gender FROM profiles 
        WHERE 
            user_id = 
           (SELECT user_id FROM media WHERE id = likes.media_id)
        ) AS gender_liked
    FROM likes
    GROUP BY gender_liked
    HAVING gender_liked = 'm' -- МУЖЧИНЫ 
    )
    > -- сравнение
    (
    SELECT 
        count(*),
       (SELECT gender FROM profiles 
        WHERE 
            user_id = 
           (SELECT user_id FROM media WHERE id = likes.media_id)
        ) AS gender_liked
    FROM likes
    GROUP BY gender_liked
    HAVING gender_liked = 'f' -- ЖЕНЩИНЫ 
    )
) AS 'm > f'
;

/*(много получается кода, хорошо бы здесь научиться использовать функции
 * и переменные...)
 */

