--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  CRUD операции 
--  HOME WORK 04, ЗАДАНИЯ 02--04

USE vk;

-- 1. Заполнить все таблицы БД vk данными (не больше 10-20 записей в каждой таблице)
--    см. файл "04_home_work__vk_dump_20rec.sql"


-- 2. Написать скрипт, возвращающий список имен (только firstname) 
--    пользователей без повторений в алфавитном порядке

SELECT DISTINCT firstname FROM users ORDER BY firstname;


-- 3. Написать скрипт, отмечающий несовершеннолетних пользователей как неактивных (поле is_active = false). 
--    Предварительно добавить такое поле в таблицу profiles со значением по умолчанию = true (или 1)

ALTER TABLE profiles DROP COLUMN is_active; -- на всякий случай...
ALTER TABLE profiles ADD COLUMN (is_active BOOLEAN DEFAULT TRUE);
UPDATE profiles SET is_active = TRUE; -- выполняем на всякий случай...
UPDATE profiles SET is_active = FALSE
    WHERE timestampdiff(YEAR, birthday, current_date()) < 18 ;

-- проверка
SELECT users.id, firstname, is_active, (timestampdiff(YEAR, birthday, current_date())) as age 
	FROM users, profiles 
    WHERE users.id=profiles.user_id
    ORDER BY age;


-- 4. Написать скрипт, удаляющий сообщения «из будущего» (дата больше сегодняшней)

-- находим сообщения "из будущего" (не разбираемся с временными зонами):
SELECT from_user_id, created_at FROM messages WHERE created_at > current_timestamp();

-- удаляем их:
DELETE FROM messages WHERE created_at > current_timestamp();


-- 5. Написать название темы курсового проекта (в комментарии)
--    планирую, что ГОСУСЛУГИ, но ещё думаю -- не знаю как подступиться...

