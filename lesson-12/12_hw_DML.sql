-- DML
-- наполняем таблицы данными...

-- ПОЛЬЗОВАТЕЛИ, основное
INSERT INTO users 
    (firstname, fathername, lastname, email, phone)
VALUES 
    ('Иван',     'Петрович',     'Мышкин',    'little@mouse.rr',      79000000001),
    ('Анна',     'Cергеевна',    'Лесникова', 'a.forest@mail.mm',     79000000002),
    ('Захар',    'Валентинович', 'Громов',    'lsdkfj@email.ff',      79000000003),
    ('Петр',     'Иванович',     'Кузькин',   'ku@mail.mm',           79000000004),
    ('Мария',    'Cергеевна',    'Лесникова', 'm.forest@mail.mm',     79000000005),
    ('Кузьма',   'Борисович',    'Телегин',   'telega@mail.mm',       79000000006),
    ('Светлана', 'Алексеевна',   'Телегина',  's.telega@mail.mm',     79000000007),
    ('Иван',     'Иваныч',       'Мышкин',    'i.little@mouse.rr',    79000000008);

-- Проверка работы тригеров для таблицы users
-- так же на обновление и удаление (вставка выше)
INSERT INTO users 
    (id, verification)
VALUES 
    (1, 1), (5, 1) AS news(i, v)
ON DUPLICATE KEY UPDATE 
    id = news.i,
    verification = news.v;

UPDATE users SET verification = 1 WHERE id = 7;
DELETE FROM users WHERE id = 8;

-- ГОРОДА (справочник)
INSERT INTO city (id, name)
VALUES 
    (1, 'Москва'),
    (2, 'Санкт-Петербург'),
    (3, 'Архангельск'),
    (4, 'Кёнигсберг'),
    (5, 'Владивосток')
AS news(id, name)    
ON duplicate KEY UPDATE 
    id = news.id,
    name = news.name;

-- ПОЛЬЗОВАТЕЛИ, дополнительные данные
INSERT INTO profile 
    (user_id, birth_day, birth_city_id, residence_city_id)
VALUES 
    (1, '2000-01-01', 3, 1), 
    (2, '1975-01-01', 3, 3),
    (3, '2005-01-01', 5, 5),
    (4, '1995-02-27', 3, 5),
    (5, '2008-12-30', 1, 5),
    (6, '1987-06-21', 1, 1),
    (7, '2000-06-21', 1, 1)
AS news(user_id, birth_day, birth_city_id, residence_city_id)
ON DUPLICATE KEY UPDATE 
    user_id = news.user_id, 
    birth_day = news.birth_day,
    birth_city_id = news.birth_city_id,
    residence_city_id = news.residence_city_id;

-- Направления деятельности

INSERT INTO direct (id, name)
VALUES 
    (1, 'Справки'),
    (2, 'Документы, удостоверяющие личность')
AS news(id, name)
ON duplicate KEY UPDATE 
    id = news.id,
    name = news.name;









