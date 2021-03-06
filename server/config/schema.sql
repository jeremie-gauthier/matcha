DROP DATABASE IF EXISTS matchadb;
CREATE DATABASE matchadb;
USE matchadb;

-- TABLES

-- GENDERS + POPULATE
CREATE TABLE genders (
  id INT UNSIGNED AUTO_INCREMENT,
  gender VARCHAR(20) NOT NULL,
  PRIMARY KEY (id)
) ENGINE="InnoDB";

INSERT INTO
  genders (
    gender
  )
VALUES
  ("Homme"),
  ("Femme"),
  ("Non-binaire");

CREATE UNIQUE INDEX
  index_genders
ON
  genders (
    id,
    gender
  );

-- USERS
CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT,
  id_genders INT UNSIGNED NOT NULL,
  email VARCHAR(255) NOT NULL,
  uname VARCHAR(20) NOT NULL,
  password VARCHAR(255) NOT NULL,
  firstname VARCHAR(40) NOT NULL,
  lastname VARCHAR(40) NOT NULL,
  description VARCHAR(255) DEFAULT "",
  age INT UNSIGNED,
  pscore INT UNSIGNED,
  latitude FLOAT,
  longitude FLOAT,
  verified BOOLEAN NOT NULL DEFAULT FALSE,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  hash VARCHAR(255),
  last_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (id),
  FOREIGN KEY (id_genders) REFERENCES genders(id)
) ENGINE="InnoDB";

-- ORIENTATION [USERS, GENDERS]
CREATE TABLE user_orientation (
  id_users INT UNSIGNED NOT NULL,
  id_genders INT UNSIGNED NOT NULL,
  FOREIGN KEY (id_users) REFERENCES users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (id_genders) REFERENCES genders(id)
    ON DELETE CASCADE
) ENGINE="InnoDB";

-- INTERESTS + POPULATE
CREATE TABLE interests (
  id INT UNSIGNED AUTO_INCREMENT,
  interest VARCHAR(20) NOT NULL,
  PRIMARY KEY (id)
) ENGINE="InnoDB";

INSERT INTO
  interests (
    interest
  )
VALUES
  ("bio"),
  ("geek"),
  ("piercing"),
  ("vegan"),
  ("PHP"),
  ("dinosaures"),
  ("programmation"),
  ("chat"),
  ("tattoo"),
  ("lunettes"),
  ("jeux"),
  ("FF7"),
  ("escapegames"),
  ("42"),
  ("nofilter"),
  ("terry"),
  ("blond"),
  ("brun"),
  ("roux"),
  ("blonde"),
  ("brune"),
  ("rousse"),
  ("chien"),
  ("foot"),
  ("basket");

CREATE UNIQUE INDEX
  index_interests
ON
  interests (
    interest
  );

-- USERS_INTERESTS [USERS, INTERESTS]
CREATE TABLE user_interest (
  id_users INT UNSIGNED NOT NULL,
  id_interests INT UNSIGNED NOT NULL,
  FOREIGN KEY (id_users) REFERENCES users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (id_interests) REFERENCES interests(id)
    ON DELETE CASCADE
) ENGINE="InnoDB";

CREATE TABLE pictures (
  id INT UNSIGNED AUTO_INCREMENT,
  id_users INT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (id_users) REFERENCES users(id)
) ENGINE="InnoDB";

CREATE TABLE likes (
  origin INT UNSIGNED NOT NULL,
  target INT UNSIGNED NOT NULL,
  FOREIGN KEY (origin) REFERENCES users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (target) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE="InnoDB";

CREATE TABLE matches (
  id_users1 INT UNSIGNED NOT NULL,
  id_users2 INT UNSIGNED NOT NULL,
  FOREIGN KEY (id_users1) REFERENCES users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (id_users2) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE="InnoDB";

CREATE TABLE notifications (
  origin INT UNSIGNED NOT NULL,
  target INT UNSIGNED NOT NULL,
  type SET("like", "visit", "message", "match", "unmatch"),
  FOREIGN KEY (origin) REFERENCES users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (target) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE="InnoDB";

CREATE TABLE blacklist (
  origin INT UNSIGNED NOT NULL,
  target INT UNSIGNED NOT NULL,
  FOREIGN KEY (origin) REFERENCES users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (target) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE="InnoDB";

CREATE TABLE reports (
  origin INT UNSIGNED NOT NULL,
  target INT UNSIGNED NOT NULL,
  FOREIGN KEY (origin) REFERENCES users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (target) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE="InnoDB";

-- STORED PROCEDURES

DELIMITER $$

-- Procedure that should be called after each insertion in likes table
-- `id_users1` is `target` from the likes insertion
-- `id_users2` is `origin` from the likes insertion
CREATE PROCEDURE insert_match_if_exists(id_users1 INT UNSIGNED, id_users2 INT UNSIGNED)
BEGIN
  IF EXISTS (SELECT * FROM likes WHERE origin = id_users1 AND target = id_users2)
  THEN
    BEGIN
      -- Create new match
      INSERT INTO matches (id_users1, id_users2)
      VALUES (id_users1, id_users2);
      -- Create match notification
      INSERT INTO notifications (origin, target, type)
      VALUES
        (id_users1, id_users2, "match"),
        (id_users2, id_users1, "match");
      -- Delete likes
      DELETE FROM likes WHERE target = id_users1 AND origin = id_users2;
      DELETE FROM likes WHERE target = id_users2 AND origin = id_users1;
    END;
  END IF;
END;

$$

CREATE PROCEDURE block_user(origin INT UNSIGNED, target INT UNSIGNED)
BEGIN
  -- Delete match if exists
  DELETE FROM matches WHERE
    (id_users1 = origin AND id_users2 = target)
    OR (id_users1 = target AND id_users2 = origin);
  -- Delete notifications
  DELETE FROM notifications WHERE
    (notifications.origin = origin AND notifications.target = target)
    OR (notifications.origin = target AND notifications.target = origin);
  -- Delete likes
  DELETE FROM likes WHERE
    (likes.origin = origin AND likes.target = target)
    OR (likes.origin = target AND likes.target = origin);
END;

$$

-- TRIGGERS

CREATE TRIGGER before_insert_users
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
  IF EXISTS (SELECT email FROM users WHERE email = NEW.email)
  THEN
    BEGIN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = "Cette adresse email est deja reliee a un compte.";
    END;
  END IF;

  IF EXISTS (SELECT uname FROM users WHERE uname = NEW.uname)
  THEN
    BEGIN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = "Ce nom d'utilisateur est deja pris.";
    END;
  END IF;
END;

$$

CREATE TRIGGER before_insert_blacklist
BEFORE INSERT ON blacklist
FOR EACH ROW
BEGIN
  CALL block_user(NEW.origin, NEW.target);
END

$$

CREATE TRIGGER before_insert_reports
BEFORE INSERT ON reports
FOR EACH ROW
BEGIN
  CALL block_user(NEW.origin, NEW.target);
END

$$

DELIMITER ;


-- DATA SAMPLE
INSERT INTO
  users (id_genders, email, uname, password, firstname, lastname)
VALUES
(1, 'jeremiegthr@gmail.com', 'jergauth', 'abc123', 'jeremie', 'gauthier'),
(2, 'cmoulini@student.42.fr', 'cmoulini', '123abc', 'caroline', 'moulinier'),
(3, 'example@email.com', 't-rex', '123abc', 'Monsieur', 'REX');

INSERT INTO likes (target, origin) VALUES (1, 2), (2, 1), (1, 3), (2, 3);
CALL insert_match_if_exists(1, 2);
