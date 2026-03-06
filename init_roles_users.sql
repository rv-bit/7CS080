DROP USER IF EXISTS 'admin_user'@'%';
DROP ROLE IF EXISTS 'admin';

DROP USER IF EXISTS 'dev_user'@'%';
DROP ROLE IF EXISTS 'developer';

-- create users with passwords
CREATE USER IF NOT EXISTS 'admin_user'@'%' IDENTIFIED BY 'AdminPass123!';
CREATE USER IF NOT EXISTS 'dev_user'@'%' IDENTIFIED BY 'DevPass123!';

-- create some roles
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'developer';

GRANT USAGE, SELECT, INSERT ON 7CS080.* TO 'admin';
GRANT ALL PRIVILEGES ON 7CS080.* TO 'developer';

FLUSH PRIVILEGES;

-- Assign roles to users
GRANT 'admin' TO 'admin_user'@'%';
GRANT 'developer' TO 'dev_user'@'%';

SET DEFAULT ROLE admin TO 'admin_user'@'%';
SET DEFAULT ROLE developer TO 'dev_user'@'%';