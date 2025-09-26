CREATE USER 'repl'@'%' IDENTIFIED BY 'replpass';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
CREATE USER 'orc_client_user'@'%' identified by 'orc_client_password';
grant all privileges on *.* to 'orc_client_user'@'%';
FLUSH PRIVILEGES;

