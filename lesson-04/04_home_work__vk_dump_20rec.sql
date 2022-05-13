--  GeekBrains, BigData, Oleg Gladkiy (https://geekbrains.ru/users/3837199)
--  CRUD операции 
--  HOME WORK 04, ЗАДАНИЕ-1

-- На основе дампа, приложенного к уроку (на 100 записей):
--
-- Generation time: Wed, 28 Oct 2020 17:08:59 +0000
-- Host: mysql.hostinger.ro
-- DB name: u574849695_24
--
-- ИЗМЕНЕНИЯ от оригинала, указанного выше:
-- КОЛИЧЕСТВО ЗАПИСЕЙ:
-- * во всех операциях добавления данных количество строк уменьшено до 20
--   с соответствующим исправлением счётчика AUTO_INCREMENT = 21
-- ТАБЛИЦА ЛАЙКОВ (CREATE TABLE likes...), ДОБАВЛЕНИЯ:
-- * внешний ключ для пользователей
-- * внешний ключ для медиа...
-- ТАБЛИЦА СООБЩЕНИЙ, ДОБАВЛЕНИЕ ДАННЫХ (INSERT INTO `messages`...) ИЗМЕНЕНИЯ:
-- * 4-е последние сообщения "из будущего"
-- ТАБЛИЦА ПОЛЬЗОВАТЕЛЕЙ (INSERT INTO `users`...), ИЗМЕНЕНИЯ:
-- * имена исправлены на повторяющиеся


DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

/*!40030 SET NAMES UTF8 */;
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP TABLE IF EXISTS `communities`;
CREATE TABLE `communities` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8_unicode_ci DEFAULT NULL,
  `admin_user_id` bigint(20) unsigned NOT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `communities_name_idx` (`name`),
  KEY `admin_user_id` (`admin_user_id`),
  CONSTRAINT `communities_ibfk_1` FOREIGN KEY (`admin_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `communities` VALUES 
('1','sint','1'),
('2','vel','2'),
('3','nesciunt','3'),
('4','fuga','4'),
('5','illo','5'),
('6','non','6'),
('7','reiciendis','7'),
('8','molestiae','8'),
('9','sint','9'),
('10','distinctio','10'),
('11','ea','11'),
('12','nulla','12'),
('13','enim','13'),
('14','non','14'),
('15','consequatur','15'),
('16','dolor','16'),
('17','possimus','17'),
('18','dolor','18'),
('19','mollitia','19'),
('20','ea','20'); 


DROP TABLE IF EXISTS `friend_requests`;
CREATE TABLE `friend_requests` (
  `initiator_user_id` bigint(20) unsigned NOT NULL,
  `target_user_id` bigint(20) unsigned NOT NULL,
  `status` enum('requested','approved','unfriended','declined') COLLATE utf8_unicode_ci DEFAULT NULL,
  `requested_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`initiator_user_id`,`target_user_id`),
  KEY `target_user_id` (`target_user_id`),
  CONSTRAINT `friend_requests_ibfk_1` FOREIGN KEY (`initiator_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `friend_requests_ibfk_2` FOREIGN KEY (`target_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `friend_requests` VALUES 
('1','1','requested','1986-04-20 17:01:49','1998-02-23 02:50:02'),
('2','2','declined','1999-10-21 19:09:48','1995-06-01 12:45:33'),
('3','3','requested','1988-09-10 19:37:10','1995-11-02 02:18:28'),
('4','4','declined','2002-08-09 13:11:34','2001-08-17 11:58:56'),
('5','5','unfriended','2010-11-22 08:19:31','2018-02-14 06:25:03'),
('6','6','declined','2003-11-12 04:37:05','1985-03-31 17:13:11'),
('7','7','unfriended','2020-04-30 18:50:29','2013-12-18 12:44:58'),
('8','8','requested','2008-07-23 22:58:22','1989-08-26 17:25:16'),
('9','9','approved','1988-09-11 02:04:43','2018-05-08 16:41:15'),
('10','10','requested','1995-02-07 13:17:08','1987-08-24 13:45:43'),
('11','11','requested','2018-04-03 01:26:05','1978-11-06 04:06:52'),
('12','12','unfriended','1997-07-11 15:04:50','2001-02-28 07:05:32'),
('13','13','approved','1974-02-28 10:08:27','2020-02-17 21:54:48'),
('14','14','unfriended','1983-02-24 19:50:35','2013-03-07 13:27:48'),
('15','15','declined','1974-10-24 21:31:12','1970-04-08 04:39:56'),
('16','16','approved','2008-11-17 13:09:34','1987-02-02 05:34:33'),
('17','17','unfriended','1984-08-29 15:59:49','1998-11-27 00:22:55'),
('18','18','requested','2014-08-20 22:27:13','2015-03-06 16:35:22'),
('19','19','requested','1989-12-16 19:38:39','2018-06-21 00:49:33'),
('20','20','unfriended','1974-01-13 20:41:35','1979-05-24 08:43:32'); 

-- ??????????????????????????????????????????????????????????????????????????????

DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `media_id` bigint(20) unsigned NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  UNIQUE KEY `id` (`id`),
-- добавленные мною строки:  
-- * внешний ключ для пользователей
-- * внешний ключ для медиа...
  KEY `user_id` (`user_id`),
  KEY `media_id` (`media_id`),
  CONSTRAINT likes_idxfk_users_id FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT likes_idxfk_media_id FOREIGN KEY (user_id) REFERENCES media(id)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `likes` VALUES 
('1','1','1','1970-09-25 19:54:11'),
('2','2','2','1977-07-13 14:33:35'),
('3','3','3','1988-11-15 14:07:59'),
('4','4','4','1997-12-10 15:47:27'),
('5','5','5','1975-07-08 06:14:33'),
('6','6','6','2015-09-10 06:39:40'),
('7','7','7','1986-10-21 01:20:16'),
('8','8','8','1997-05-08 01:56:36'),
('9','9','9','1973-03-12 19:39:22'),
('10','10','10','1983-08-05 21:24:24'),
('11','11','11','2019-10-24 14:27:11'),
('12','12','12','2010-06-19 09:45:53'),
('13','13','13','1990-10-09 20:52:33'),
('14','14','14','1992-08-15 09:43:05'),
('15','15','15','1984-02-12 21:13:23'),
('16','16','16','2006-07-13 23:15:47'),
('17','17','17','1979-05-04 12:22:15'),
('18','18','18','1986-02-11 14:17:08'),
('19','19','19','2012-01-26 04:19:36'),
('20','20','20','2005-10-31 14:10:46'); 


DROP TABLE IF EXISTS `media`;
CREATE TABLE `media` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `media_type_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `body` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  UNIQUE KEY `id` (`id`),
  KEY `user_id` (`user_id`),
  KEY `media_type_id` (`media_type_id`),
  CONSTRAINT `media_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `media_ibfk_2` FOREIGN KEY (`media_type_id`) REFERENCES `media_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `media` VALUES 
('1','1','1','Architecto est animi facere. Esse quas unde omnis. Corporis et velit sint deserunt.','corrupti','6401',NULL,'1987-03-12 22:24:37','1979-08-29 05:32:34'),
('2','2','2','Temporibus est dignissimos omnis. Recusandae odit facere autem molestiae quis et saepe. Laboriosam et eum iste modi facere maxime. Et non praesentium neque id aspernatur ut et.','ad','318954689',NULL,'2002-05-25 21:39:07','2007-06-06 17:44:42'),
('3','3','3','Aut iure itaque voluptate quaerat odio nisi est qui. Voluptatem quia tenetur dolores ab voluptatem et est. Fugiat vel temporibus quis.','repellat','20',NULL,'2013-06-20 01:35:36','2011-11-28 20:04:34'),
('4','4','4','Velit porro aut dolorum qui consectetur aliquid error. Nemo ea error occaecati ea modi. Voluptas impedit sequi eaque consequuntur accusantium. Facilis reprehenderit rerum ut omnis sint doloremque sunt aut. Nostrum animi sint tempora voluptate.','et','3763348',NULL,'2004-08-07 08:07:37','1985-04-14 22:19:09'),
('5','1','5','Perspiciatis eius autem placeat optio. Voluptatibus et temporibus neque placeat quo necessitatibus. Nobis aut iusto sunt officiis quae accusantium. Velit qui et non iure quia commodi soluta.','aut','9',NULL,'1992-10-10 08:36:26','1985-10-02 16:07:06'),
('6','2','6','Ab occaecati sequi quas explicabo cum laborum. Eligendi nobis sapiente minus aliquam nesciunt unde. Sed sunt expedita voluptatum iusto similique ut.','consequatur','983803906',NULL,'1989-06-30 03:25:19','1980-12-04 05:09:54'),
('7','3','7','Tenetur architecto dolorem voluptates. Blanditiis ut ut quia aliquam voluptatem. Necessitatibus et quos molestiae. Quis ad vero consequuntur occaecati fugiat assumenda sapiente.','reprehenderit','4',NULL,'1972-07-01 22:56:45','1992-06-11 20:36:49'),
('8','4','8','Sunt quia omnis cumque autem vel facilis. Autem doloremque ab ut dolores. Incidunt dolores eum ipsam dolores deserunt rerum hic. Optio voluptates molestias consequuntur aut fugit est fugiat.','odit','96',NULL,'1990-01-29 18:47:01','1991-10-28 22:56:16'),
('9','1','9','Est suscipit iure laboriosam eligendi laborum commodi. Aut fuga deserunt sit et praesentium cupiditate.','recusandae','87723',NULL,'2010-01-12 05:04:04','1986-10-02 19:57:15'),
('10','2','10','Qui facere ratione explicabo quidem. Earum enim eligendi vel magnam.','nam','913',NULL,'1986-06-10 03:28:03','1972-09-24 22:09:31'),
('11','3','11','Et excepturi ab in. Rerum et debitis et voluptatum ut ab. Dolorum illo odit omnis ea quo natus. Natus praesentium et dolorem qui. Molestiae omnis laboriosam dolore odio repellat et architecto.','qui','69979914',NULL,'1979-06-04 07:20:21','2007-05-07 01:10:56'),
('12','4','12','Laborum culpa nulla explicabo. Consequatur amet enim aliquid beatae magni. Doloremque in non consequatur accusantium voluptate pariatur.','cum','61384201',NULL,'1982-12-19 09:08:06','1993-08-10 18:19:44'),
('13','1','13','Quo et doloribus facilis cupiditate ipsum qui. Laboriosam et repellendus debitis itaque. Nesciunt et amet autem aut quia excepturi.','rerum','88881392',NULL,'1999-04-06 18:58:45','1982-12-17 00:45:11'),
('14','2','14','Aliquid quia fugiat alias dolor molestias consectetur dignissimos. Suscipit voluptate in porro quod. Tempore asperiores ab unde atque minima eligendi. Voluptatem neque provident sunt quod quis nobis.','laudantium','38424017',NULL,'1988-06-21 00:27:05','1972-07-27 10:57:03'),
('15','3','15','At ut dolores voluptatem eum beatae omnis cupiditate qui. Dolorum et culpa fugit explicabo necessitatibus. Consequuntur sed similique consequatur.','modi','0',NULL,'2004-12-13 15:58:20','2011-06-22 07:28:28'),
('16','4','16','Ipsum eum qui quia ex facilis praesentium. Suscipit aut quae culpa. Deleniti enim explicabo perspiciatis dolorem beatae odit molestiae dolores.','fuga','449469',NULL,'2002-07-03 21:19:49','1991-10-05 23:47:00'),
('17','1','17','Ducimus voluptatibus voluptas iure suscipit mollitia. Non optio quod magnam ad quia. Perspiciatis ut fugit illo quibusdam.','ratione','9',NULL,'2002-06-08 07:07:32','2008-12-20 07:12:36'),
('18','2','18','Dolore officia quos qui molestiae qui quia dolor. Qui ipsa error voluptas et. Culpa et nostrum qui corporis. Ut cumque nam laboriosam et illo dolores aliquid.','consectetur','3305',NULL,'1986-04-02 00:21:18','1978-08-10 20:36:54'),
('19','3','19','Repudiandae consequatur commodi molestiae assumenda labore. Asperiores doloribus corrupti sequi blanditiis modi. Expedita ea consequatur qui nihil dignissimos praesentium deleniti. Est ipsam et inventore quia sed similique. Nam deserunt minima magnam pariatur consectetur minus non.','dolores','50455',NULL,'2007-06-07 13:19:05','1983-07-20 14:25:22'),
('20','4','20','Magnam quis numquam sit consequatur. Vitae sint qui eveniet molestiae distinctio non fuga. Eligendi aut accusamus molestiae delectus et iste quae.','deserunt','0',NULL,'1978-11-22 12:47:16','1988-09-12 09:20:01')
; 

DROP TABLE IF EXISTS `media_types`;
CREATE TABLE `media_types` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `media_types` VALUES 
('1','eius','1974-07-12 17:44:08','1986-04-29 15:56:08'),
('2','occaecati','1976-03-13 21:25:30','2013-11-18 22:12:58'),
('3','deserunt','1972-04-27 09:29:42','1992-06-23 16:33:54'),
('4','tempora','1974-10-27 09:47:06','1976-02-06 12:26:26'); 


DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `from_user_id` bigint(20) unsigned NOT NULL,
  `to_user_id` bigint(20) unsigned NOT NULL,
  `body` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  UNIQUE KEY `id` (`id`),
  KEY `from_user_id` (`from_user_id`),
  KEY `to_user_id` (`to_user_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`from_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`to_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `messages` VALUES 
('1','1','1','Provident soluta tempore omnis qui repellat dolorum. Vitae aut eligendi voluptatum officiis architecto veritatis. Doloremque rerum molestiae labore autem et nostrum quam. Ut accusamus amet doloremque velit praesentium maxime ratione. Ut ut sit eius quia est autem reprehenderit.','1982-08-19 10:49:08'),
('2','2','2','Praesentium hic adipisci aut quisquam ut qui amet. Sint magni ea ut officiis. Molestiae fuga ipsam exercitationem est temporibus. Placeat magnam eius voluptates voluptas corporis.','2018-10-16 05:18:07'),
('3','3','3','Laudantium quasi et sit nam aliquid maiores sint. Quibusdam sunt molestiae totam odio quae. Voluptatem inventore odit ducimus porro exercitationem et qui possimus.','2018-02-18 04:44:58'),
('4','4','4','Qui praesentium quidem quam doloribus nemo magni in. Voluptatem velit nam aut at neque corporis. Et cupiditate et esse consequatur inventore. Sint temporibus dolores commodi.','1993-02-26 01:35:53'),
('5','5','5','Facere laborum veniam et dolores iusto non accusamus dolorem. Similique vel tenetur aliquam officiis atque ut. Est aut autem perspiciatis aut.','1987-04-21 18:35:21'),
('6','6','6','Minima et magni aut aut qui id laudantium. Enim quia aspernatur repellat vero aliquam magnam id. Minima qui perspiciatis sed et vel accusantium.','1990-05-14 23:46:57'),
('7','7','7','Non reprehenderit error ut exercitationem molestiae asperiores. Et id accusantium similique consequatur iste magni consequuntur. Suscipit ullam earum optio laborum. Consequatur et id alias quia.','2015-06-03 14:34:09'),
('8','8','8','Aut omnis quia non. Vero sint cumque alias quas.','2002-04-28 01:30:51'),
('9','9','9','Laboriosam eligendi tenetur est. Hic harum est sint ut quo excepturi. Voluptates qui dolores rerum porro ad veritatis. Ratione nulla consequatur rerum officia dolorem.','2010-09-03 14:05:50'),
('10','10','10','Explicabo vel et aperiam inventore. Ut dolore est libero cum commodi vitae ea. Sapiente ullam commodi est expedita magni.','2006-01-12 15:48:19'),
('11','11','11','Cupiditate veritatis non nihil eaque. Voluptate ipsam delectus consequatur consequatur consectetur ut quia qui. Impedit et quod maxime magnam tenetur. Optio repellat sed minus magnam. Asperiores quis dolores repellat hic.','1976-05-11 00:06:49'),
('12','12','12','Voluptate et non labore. Omnis sunt enim reprehenderit. Hic enim perferendis eum consectetur.','1982-07-23 06:23:46'),
('13','13','13','Est vero cum officiis qui pariatur. Quaerat consequatur vel qui sint perferendis. Illum voluptate vel ab aliquid mollitia qui amet.','1994-10-08 14:39:48'),
('14','14','14','Accusantium numquam provident ut ea quae aut. Qui repudiandae quas officia aut maiores provident nihil. Sed dolor ducimus distinctio rerum iusto.','2019-06-16 12:00:46'),
('15','15','15','Non ipsum deserunt corrupti. Sint maiores est omnis ducimus. Dolor dignissimos eum ipsa id ut deleniti.','1980-08-01 04:53:54'),
('16','16','16','Dolorem ad ad velit saepe fuga enim. Corrupti saepe ducimus aperiam voluptatem repellendus. Quas harum voluptatem et adipisci sit porro nihil.','1999-11-25 17:10:56'),
-- СООБЩЕНИЕ ИЗ БУДУЩЕГО:
('17','17','17','Pariatur et iure animi animi molestiae alias voluptatum. Molestiae voluptas et alias. Alias sunt magni numquam architecto minus dolore.', current_timestamp() + INTERVAL 1 YEAR),
('18','18','18','Earum maiores consequatur debitis laudantium et. Eveniet accusantium voluptas reprehenderit qui dolores eveniet. Dignissimos non unde dolorem numquam neque molestias dignissimos iure.', '1985-04-28 14:19:29' + INTERVAL 50 YEAR),
('19','19','19','Excepturi magni omnis commodi. Reprehenderit non animi dolor amet labore aliquid quam repellendus. Tempora aut et ut hic accusantium sed sit.', '2006-03-06 17:50:55' + INTERVAL 20 YEAR),
('20','20','20','Sit blanditiis quam sit dignissimos labore. Nobis recusandae voluptatem exercitationem sit et. Ex harum atque voluptate vitae.', current_timestamp() + INTERVAL '1-10' YEAR_MONTH)
;


DROP TABLE IF EXISTS `photo_albums`;
CREATE TABLE `photo_albums` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `photo_albums_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `photo_albums` VALUES 
('1','deserunt','1'),
('2','maiores','2'),
('3','tempora','3'),
('4','facere','4'),
('5','accusamus','5'),
('6','blanditiis','6'),
('7','a','7'),
('8','sed','8'),
('9','eum','9'),
('10','tempora','10'),
('11','eum','11'),
('12','laborum','12'),
('13','voluptate','13'),
('14','sed','14'),
('15','voluptatibus','15'),
('16','dignissimos','16'),
('17','doloremque','17'),
('18','id','18'),
('19','enim','19'),
('20','minus','20')
; 


DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `album_id` bigint(20) unsigned NOT NULL,
  `media_id` bigint(20) unsigned NOT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `album_id` (`album_id`),
  KEY `media_id` (`media_id`),
  CONSTRAINT `photos_ibfk_1` FOREIGN KEY (`album_id`) REFERENCES `photo_albums` (`id`),
  CONSTRAINT `photos_ibfk_2` FOREIGN KEY (`media_id`) REFERENCES `media` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `photos` VALUES 
('1','1','1'),
('2','2','2'),
('3','3','3'),
('4','4','4'),
('5','5','5'),
('6','6','6'),
('7','7','7'),
('8','8','8'),
('9','9','9'),
('10','10','10'),
('11','11','11'),
('12','12','12'),
('13','13','13'),
('14','14','14'),
('15','15','15'),
('16','16','16'),
('17','17','17'),
('18','18','18'),
('19','19','19'),
('20','20','20')
; 


DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
  `user_id` bigint(20) unsigned NOT NULL,
  `gender` char(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `photo_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `hometown` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `profiles` VALUES 
('1',NULL,'1996-05-18','1','1997-05-08 20:35:23',NULL),
('2',NULL,'2015-04-25','2','1977-11-05 20:03:53',NULL),
('3',NULL,'1974-02-07','3','1973-11-09 06:38:39',NULL),
('4',NULL,'1980-03-15','4','1971-04-16 17:28:04',NULL),
('5',NULL,'1992-05-05','5','1995-12-03 09:19:25',NULL),
('6',NULL,'1979-07-07','6','1972-10-04 22:32:53',NULL),
('7',NULL,'1995-10-05','7','1976-03-10 17:04:12',NULL),
('8',NULL,'2013-07-10','8','2004-07-01 00:23:16',NULL),
('9',NULL,'1993-05-22','9','1997-10-10 07:21:00',NULL),
('10',NULL,'1971-11-18','10','1980-06-02 12:17:02',NULL),
('11',NULL,'1991-03-13','11','1995-08-18 21:13:45',NULL),
('12',NULL,'1975-03-30','12','1979-08-25 07:32:56',NULL),
('13',NULL,'1994-04-02','13','1998-09-09 11:03:49',NULL),
('14',NULL,'1980-03-21','14','1982-02-20 20:42:39',NULL),
('15',NULL,'2005-02-15','15','1978-04-05 01:18:38',NULL),
('16',NULL,'1992-11-23','16','1989-09-09 22:47:06',NULL),
('17',NULL,'1979-04-29','17','2019-06-18 13:07:50',NULL),
('18',NULL,'1990-02-15','18','1990-10-29 08:29:01',NULL),
('19',NULL,'1996-11-04','19','1976-10-29 05:16:31',NULL),
('20',NULL,'1982-05-12','20','1994-03-26 11:21:56',NULL)
; 


DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `firstname` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lastname` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Фамиль',
  `email` varchar(120) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password_hash` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  KEY `users_firstname_lastname_idx` (`firstname`,`lastname`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='юзеры';

INSERT INTO `users` VALUES 
('1','Alexandre','Jakubowski','trey62@example.net','38515893c796660bb1307410f6aed138988b97d1','89676723604'),
('2','Alexandre','Ratke','rrolfson@example.org','84f259f5415b6f0cd20c6d4aff1a4868ac3ff0ae','89339101296'),
('3','Jacey','Fritsch','stone96@example.com','b9fd1bbdc3f7caccb0923003ea81acdab2b59610','89802518644'),
('4','Whitney','Jerde','jonathon.feil@example.com','06292d6942f52879745960fcf6b1f1074875e53a','89397268208'),
('5','Ryann','Lynch','ckuhic@example.org','e3e4d5c8e9c84cd665be208849c4e066ae2f8849','89585747656'),
('6','Karlee','Kunde','syost@example.org','46b15aca372c290f92cc7bd49a842b2cede3e1f8','89125986482'),
('7','Ryann','Prosacco','malvina.toy@example.net','856f6b5f9c993da0c5048e83570de7dccf6c188a','89334895548'),
('8','Ona','Schumm','adelia91@example.com','6cba3682da29e775f84f14c16d6fc511248a5b7d','89838377175'),
('9','Alexandre','Gaylord','alphonso71@example.com','62ed6ae488aa4374d644cd571e3ae7d95959ce3d','89777246849'),
('10','Alexandre','Rowe','esipes@example.net','06e3c0a3e879a95c24452691d4f323f62756e367','89230775666'),
('11','Laurie','Green','mnicolas@example.net','27581f7eb9026f5405a80656aa9fda6650b1217e','89532268940'),
('12','Rahsaan','Schowalter','gerhold.savanah@example.net','4db9fabc3c5aa912a50679ce56faa11363576595','89858737516'),
('13','David','Carter','anderson.shields@example.net','1e6e57306457b0762d6dd682675965e47cf2e389','89591339172'),
('14','Lea','Hilpert','mccullough.jed@example.net','283f4cd28dccd8c1c800a6e0809f70ec199f64e2','89893980394'),
('15','Christ','Reilly','kautzer.citlalli@example.com','ee346d5764c08594ed468720535f4e443cdf3f50','89893222707'),
('16','Alexandre','Conroy','joanie.predovic@example.org','3b1134c5476816eaae31793b562c26b0b2922744','89663964178'),
('17','Luisa','Weber','gerda.o\'keefe@example.net','9bfe5c91a849f638194e4e098a14f4a96dcee0dd','89781923197'),
('18','Rubye','Upton','ray48@example.com','5b3a18db69cda93cab0032a4e46e9584d5614cbc','89999819313'),
('19','Mikayla','Cole','jessica73@example.com','798671cbdd6b2303dbcbaaf1a9159b82a5f7ded3','89030626823'),
('20','Ryann','Zemlak','ukuvalis@example.net','bdb3af73709058338dce533807ef764604574541','89180780906')
; 


DROP TABLE IF EXISTS `users_communities`;
CREATE TABLE `users_communities` (
  `user_id` bigint(20) unsigned NOT NULL,
  `community_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`community_id`),
  KEY `community_id` (`community_id`),
  CONSTRAINT `users_communities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `users_communities_ibfk_2` FOREIGN KEY (`community_id`) REFERENCES `communities` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `users_communities` VALUES 
('1','1'),
('2','2'),
('3','3'),
('4','4'),
('5','5'),
('6','6'),
('7','7'),
('8','8'),
('9','9'),
('10','10'),
('11','11'),
('12','12'),
('13','13'),
('14','14'),
('15','15'),
('16','16'),
('17','17'),
('18','18'),
('19','19'),
('20','20'); 



/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

