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

-- INSERT INTO
--   users (id_genders, email, uname, password, firstname, lastname)
-- VALUES
-- (1, 'jeremiegthr@gmail.com', 'jergauth', 'abc123', 'jeremie', 'gauthier'),
-- (2, 'cmoulini@student.42.fr', 'cmoulini', '123abc', 'caroline', 'moulinier'),
-- (1, 'jeremiegthr@gmail.com', 'jergauth', 'abc123', 'jeremie', 'gauthier');

-- ORIENTATION [USERS, GENDERS]
CREATE TABLE user_orientation (
  id_users INT UNSIGNED NOT NULL,
  id_genders INT UNSIGNED NOT NULL,
  FOREIGN KEY (id_users) REFERENCES users(id),
  FOREIGN KEY (id_genders) REFERENCES genders(id)
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
  FOREIGN KEY (id_users) REFERENCES users(id),
  FOREIGN KEY (id_interests) REFERENCES interests(id)
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
  FOREIGN KEY (origin) REFERENCES users(id),
  FOREIGN KEY (target) REFERENCES users(id)
) ENGINE="InnoDB";

CREATE TABLE matches (
  id_users1 INT UNSIGNED NOT NULL,
  id_users2 INT UNSIGNED NOT NULL,
  FOREIGN KEY (id_users1) REFERENCES users(id),
  FOREIGN KEY (id_users2) REFERENCES users(id)
) ENGINE="InnoDB";

CREATE TABLE notifications (
  origin INT UNSIGNED NOT NULL,
  target INT UNSIGNED NOT NULL,
  type SET("like", "visit", "message", "match", "unmatch"),
  FOREIGN KEY (origin) REFERENCES users(id),
  FOREIGN KEY (target) REFERENCES users(id)
) ENGINE="InnoDB";

CREATE TABLE blacklist (
  origin INT UNSIGNED NOT NULL,
  target INT UNSIGNED NOT NULL,
  FOREIGN KEY (origin) REFERENCES users(id),
  FOREIGN KEY (target) REFERENCES users(id)
) ENGINE="InnoDB";

CREATE TABLE reports (
  origin INT UNSIGNED NOT NULL,
  target INT UNSIGNED NOT NULL,
  FOREIGN KEY (origin) REFERENCES users(id),
  FOREIGN KEY (target) REFERENCES users(id)
) ENGINE="InnoDB";

-- TRIGGERS

-- CREATE TRIGGER before_delete_users
-- BEFORE DELETE ON users
-- FOR EACH ROW
-- BEGIN
--   DELETE FROM user_orientation WHERE id_users = OLD.id;
--   DELETE FROM user_interest WHERE id_users = OLD.id;
--   DELETE FROM user_orientation WHERE id_users = OLD.id;
--   DELETE FROM user_orientation WHERE id_users = OLD.id;
-- END ;