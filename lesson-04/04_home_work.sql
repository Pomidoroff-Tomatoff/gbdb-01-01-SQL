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
ALTER TABLE profiles ADD COLUMN (is_active BIT DEFAULT TRUE);
UPDATE profiles SET is_active = TRUE; -- выполняем на всякий случай...

/* неправильное решение, то есть ошибка с том, что день рождения наступает сразу в 1 января
UPDATE profiles SET is_active = FALSE
    WHERE TIMESTAMPDIFF(YEAR, birthday, current_date()) < 18 ; */

-- учитываем в том числе и месяц и день рождения (полная дата)
UPDATE profiles SET is_active = FALSE                        -- совершеннолетие в будующем,
    WHERE TIMESTAMPADD(YEAR, 18, birthday) > current_date(); -- ещё не наступило! 
    
-- или при помощи оператора INTERVAL:
UPDATE profiles SET is_active = FALSE                        
    WHERE (birthday INTERVAL 18 YEAR) > current_date()       -- совершеннолетие в будующем

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

-- ещё более популярным решением является отметка об удалении, а не физическое удаление


-- 5. Написать название темы курсового проекта (в комментарии)
--    планирую, что ГОСУСЛУГИ, но ещё думаю -- не знаю как подступиться...

-- ОЦЕНКА ПРЕПОДАВАТЕЛЯ
-- Кирилл Иванов, преподаватель
-- 
-- Правильно, что используете пакетную вставку данных (одним запросом несколько строк).
-- Выводить уникальные значения полей можно также с помощью группировки данных (GROUP BY) в запросе SELECT.
-- Поле is_active - логическое, т.е. должно принимать только значения "да", "нет". Поэтому для него в MySQL в качестве типа данных разумнее выбирать BIT.
--
-- Отлично