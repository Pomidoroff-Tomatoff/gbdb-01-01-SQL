--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  Home Work 08 (Join для 06)
--  Операторы, фильтрация, сортировка и ограничение. Агрегация данных”. 
--  JOIN-решение для всех заданий
--  ДОПОЛНИТЕЛЬНЫЕ РЕШЕНИЯ

-- =====================================================================
-- 2. Подсчитать общее количество лайков, которые получили пользователи 
--    младше 10 лет..
-- УЛОЖНЯЕМ ЗАДАЧУ: для общего списка добавим ИМЯ лайкнутого пользователя
-- это означает подключение ещё одно таблицы, "users"

-- 2-Решение-А-доб: вложенный запрос.
-- большая конструкция -- целое большое дерево...
SELECT 
    id, 
    user_id AS from_user_id,
    media_id,
   (SELECT firstname
      FROM users
     WHERE id = 
        (SELECT user_id
           FROM media
          WHERE id = likes.media_id
        )
    ) AS firstname,
    (
    SELECT birthday      -- день рождения 
      FROM profiles      -- из профилей
     WHERE user_id =     -- по пользователю, 
       (                 -- который...
        SELECT 
           user_id       -- а пользователь
          FROM media     -- из таблицы медиа
         WHERE id = likes.media_id 
       )                 -- по медиа из лайков
     ) AS birthday_user
FROM likes
HAVING TIMESTAMPDIFF(YEAR, birthday_user, NOW()) < 10
;

-- 2-Решение-Б-доб: многотабличный запрос. 
-- хотим ещё увидеть имя пользователя, получившего лайки
-- Это усложение: ещё одна связь...  
 
SELECT li.id AS like_id, li.media_id, me.user_id, ur.firstname, timestampdiff(YEAR, pro.birthday, now()) AS age
  FROM likes AS li,
       media AS me,
       profiles AS pro,
       users AS ur
 WHERE li.media_id = me.id       -- связь лайков и медиа
   AND me.user_id = pro.user_id  -- связь медиа и профиля
   AND pro.user_id = ur.id       -- связь профиля и пользователя
   AND timestampdiff(YEAR, pro.birthday, now()) < 10
ORDER BY li.id
;

-- 2-Решение-В-доб: JOIN-запрос
-- Главное: ищем общую таблицу для всех, а уже к ней привязывем остальных
-- И добавление ещё одной связи никак не утяжеляет конструкцию

SELECT li.id AS like_id, li.media_id, me.user_id, usr.firstname, timestampdiff(YEAR, pro.birthday, now()) AS age
  FROM media AS me
  JOIN likes AS li ON li.media_id = me.id
  JOIN profiles AS pro ON pro.user_id = me.user_id
  JOIN users AS usr ON usr.id = me.user_id
HAVING age < 10 -- WHERE не работает с псевдонимом age, но подойдёт далее для подсчёта count()
ORDER BY li.id 
;


-- =====================================================================
-- 3. Определить кто больше поставил лайков (всего): мужчины или женщины.
--    Моё допущение: пусть результатом будет строка, 
--    с указанием пола с указанием количества лайков для этой группы
 
-- Решение-В-доб-1: JOIN-запрос-соединение
-- задаём временную переменную и получаем для неё минимальное значение лайков
SET @likes_min = (
    SELECT min(cnt)
      FROM (
            SELECT count(li.id) AS cnt, pro.gender AS gen
              FROM likes AS li, media AS me, profiles AS pro
             WHERE li.media_id = me.id
               AND me.user_id = pro.user_id
             GROUP BY gen
            ) 
        AS likes_all
);
-- а теперь выводим всю строку с этим минимальным значением
SELECT count(li.id) AS cnt, pro.gender AS gen
  FROM likes AS li, media AS me, profiles AS pro
 WHERE li.media_id = me.id
   AND me.user_id = pro.user_id
GROUP BY gen
HAVING cnt = @likes_min ;

-- Решение-В-доб-2:
-- задаём соединение между полным запросом и 
-- запросом, в которм присутствует только поле с минимумом

SELECT likes_all_data.cnt AS cnt_col, likes_all_data.gen
  FROM (
        SELECT count(li.id) AS cnt, pro.gender AS gen
          FROM likes AS li, media AS me, profiles AS pro
         WHERE li.media_id = me.id
           AND me.user_id = pro.user_id
         GROUP BY gen
       ) AS likes_all_data
  JOIN (
        SELECT min(cnt) AS li_min
          FROM (
                SELECT count(li.id) AS cnt, pro.gender AS gen
                  FROM likes AS li, media AS me, profiles AS pro
                 WHERE li.media_id = me.id
                   AND me.user_id = pro.user_id
                 GROUP BY gen
                ) AS likes_grp_count
       ) AS likes_grp_min
    ON likes_all_data.cnt = likes_grp_min.li_min
;

