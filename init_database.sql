CREATE DATABASE IF NOT EXISTS 7CS080;
USE 7CS080

-- create some roles
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'developer';

-- Grant privileges to roles
GRANT SELECT ON 7CS080.* TO 'admin';
GRANT ALL PRIVILEGES ON 7CS080.* TO 'developer';

-- create users with passwords
CREATE USER IF NOT EXISTS 'admin_user'@'%' IDENTIFIED BY 'AdminPass123!';
CREATE USER IF NOT EXISTS 'dev_user'@'%' IDENTIFIED BY 'DevPass123!';

-- Assign roles to users
GRANT 'admin' TO 'admin_user'@'%';
GRANT 'developer' TO 'dev_user'@'%';

-- mysql -u dev_user -p