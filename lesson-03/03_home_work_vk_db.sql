-- GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
-- Home Work 3.

DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    PRIMARY KEY (id) ,
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
    firstname VARCHAR(100) ,
    lastname VARCHAR(100) ,
    email VARCHAR(100) UNIQUE ,
    phone BIGINT UNSIGNED UNIQUE ,
    password_hash VARCHAR (256),
    INDEX idx_users_username (
        firstname,
        lastname
    )
) COMMENT 'пользователи';


-- связь 1 x 1

DROP TABLE IF EXISTS profiles; 
CREATE TABLE profiles (
    PRIMARY KEY (user_id) ,
    user_id BIGINT UNSIGNED NOT NULL,
    gender CHAR(1),
    birthday DATE,
    hometown VARCHAR(255),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_profiles_user_id 
    FOREIGN KEY (user_id) REFERENCES users(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
-- ALTER TABLE profiles ADD CONSTRAINT fk_profiles_user_id FOREIGN KEY (user_id) REFERENCES users(id);

-- 1 x M, таблица сообщений

DROP TABLE IF EXISTS messages; 
CREATE TABLE messages (
    id SERIAL,
    from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id   BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(),
    
    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id)   REFERENCES users(id)
);

-- запросы дружбы

DROP TABLE IF EXISTS friend_requests; 
CREATE TABLE friend_requests (
    initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('requested', 'approved', 'declined', 'unfriended'),

    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id),
    CHECK (initiator_user_id != target_user_id) -- инициатор не равен отправителю
);

-- сообщества или группы -- каталог групп: название и админ

DROP TABLE IF EXISTS communities; 
CREATE TABLE communities (
    id SERIAL,   # ???? почему не ключевое?
    name VARCHAR(255),
    admin_user_id BIGINT UNSIGNED NOT NULL,
    
    INDEX (name),
    FOREIGN KEY (admin_user_id) REFERENCES users(id)
);

-- сообщества или группы -- участники
-- M x M (многие ко многим)

DROP TABLE IF EXISTS users_communities; 
CREATE TABLE users_communities (
    user_id BIGINT UNSIGNED NOT NULL ,
    community_id BIGINT UNSIGNED NOT NULL ,
    
    PRIMARY KEY (user_id, community_id), -- не допускаем коллизию данных
    FOREIGN KEY (user_id) REFERENCES users(id) ,
    FOREIGN KEY (community_id) REFERENCES users(id)
);


-- справочник типов медиа-данных

DROP TABLE IF EXISTS media_type; 
CREATE TABLE media_type (
    id SERIAL,
    name VARCHAR(255)  # 'text', 'video', 'music', 'image'
);

-- самая большая таблица (?)... для медийных данных

DROP TABLE IF EXISTS media; 
CREATE TABLE media (
    id            SERIAL,
    user_id       BIGINT UNSIGNED NOT NULL,
    media_type_id BIGINT UNSIGNED NOT NULL,
--  media_type    ENUM ('text', 'video', 'music', 'image'),
    body          VARCHAR(255),
    filename      VARCHAR(255),
--  filebody      BLOB,
    filemetadata  JSON,
    created_at    DATETIME DEFAULT NOW(),
    updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (media_type_id) REFERENCES  media_type(id),
    FOREIGN KEY (user_id)       REFERENCES  users(id) 
);

-- лайки для медиа-данных

DROP TABLE IF EXISTS likes; 
CREATE TABLE likes (
            id SERIAL,
       user_id BIGINT UNSIGNED NOT NULL,
      media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (media_id) REFERENCES media(id),
    FOREIGN KEY (user_id)  REFERENCES users(id)
);




-- ДОМАШНЕЕ ЗАДАНИЕ 
-- добавление 3-х таблиц...

-- лайк пользователю

DROP TABLE IF EXISTS likes_user; 
CREATE TABLE likes_user (
            id SERIAL,                     # зачем нужно это поле???
       user_id BIGINT UNSIGNED NOT NULL,   # инициатор лайка
  like_user_id BIGINT UNSIGNED NOT NULL,   # лайкнутный пользователь
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id, like_user_id),   # толко один раз
          CHECK (user_id <> like_user_id), # и себя лайкать нельзя
    FOREIGN KEY (like_user_id)  REFERENCES users(id),
    FOREIGN KEY (user_id)       REFERENCES users(id)
);

-- лайк сообщению

DROP TABLE IF EXISTS likes_message; 
CREATE TABLE likes_message (
        user_id BIGINT UNSIGNED NOT NULL,   # инициатор лайка
   like_user_id BIGINT UNSIGNED NOT NULL,   # автор сообщения, нужен для проверки
like_message_id BIGINT UNSIGNED NOT NULL,   # лайкнутое сообщение
     created_at DATETIME DEFAULT NOW(),
     updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (user_id, like_message_id), # один пользователь может лайкнуть только 1 раз
          CHECK (user_id <> like_user_id),  # и не может лайкнуть своё сообщение
          
    CONSTRAINT fk_message_id__from_user_id  # как проверить эту конструкцию???
    FOREIGN KEY (like_user_id, like_message_id) REFERENCES messages(from_user_id, id),   

    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- справочник городов (без справочника стран...)

DROP TABLE IF EXISTS town; 
CREATE TABLE town (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
    name VARCHAR(255),
    country ENUM ('RU', 'other') ,
    
    UNIQUE KEY (name, country) ,
    PRIMARY KEY (id)
);
ALTER TABLE profiles DROP COLUMN hometown; 
ALTER TABLE profiles ADD COLUMN hometown_id BIGINT UNSIGNED NOT NULL;
ALTER TABLE profiles ADD CONSTRAINT fk_town_id FOREIGN KEY (hometown_id) REFERENCES town(id);