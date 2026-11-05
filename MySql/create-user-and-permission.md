CREATE USER 'sammy'@'localhost' IDENTIFIED BY 'password';
using specific database//GRANT PRIVILEGE ON database.table TO 'username'@'host';
GRANT ALL PRIVILEGES ON *.* TO 'sammy'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
