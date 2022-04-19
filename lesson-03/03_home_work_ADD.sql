-- GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
-- Home Work 3.



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