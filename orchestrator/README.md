This code is to setup the docker instance which will deploy
1) MySQL Master 5.7
2) MySQL replica 5.7
3) MySQL Replica 8.0
4) Orchestrator.

Replication binary logs and GTID will be enabled. Replication has to be configured manually after connecting each replica,




docker exec -it yunus-shaikh-mysql57-replica mysql -uroot -prootpass

CHANGE MASTER TO
  MASTER_HOST='yunus-shaikh-mysql57-primary',
  MASTER_USER='repl',
  MASTER_PASSWORD='replpass',
  MASTER_AUTO_POSITION=1;

START SLAVE;
SHOW SLAVE STATUS\G

docker exec -it yunus-shaikh-mysql80-replica mysql -uroot -prootpass

CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='yunus-shaikh-mysql57-primary',
  SOURCE_USER='repl',
  SOURCE_PASSWORD='replpass',
  SOURCE_AUTO_POSITION=1;

START REPLICA;
SHOW REPLICA STATUS\G


To remove
docker-compose down -v
