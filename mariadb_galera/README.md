# MariaDB Galera Cluster Setup

This directory contains a **fully automated** Docker Compose setup for a MariaDB Galera cluster with 3 nodes and a ProxySQL load balancer. Everything is pre-configured and ready to use!

## 🚀 **Fully Automated Setup**

- **3 MariaDB Galera nodes** with synchronous replication
- **ProxySQL** for load balancing and connection pooling
- **Automatic configuration** - no manual steps required
- **Persistent volumes** for data storage
- **Custom network** for internal communication

## 📁 **Files Included**

- `docker-compose.yml` - Main orchestration file
- `.env` - Environment variables configuration
- `proxysql.cnf` - ProxySQL configuration
- `init-proxysql.sql` - ProxySQL server/user setup
- `startup-proxysql.sh` - Automated initialization script
- `change-version.sh` - Script to change MariaDB version
- `init-scripts/01-init.sql` - Database initialization
- `README.md` - This documentation

## 🎯 **Quick Start (Zero Manual Configuration)**

1. **Navigate to the directory:**
   ```bash
   cd mariadb_galera
   ```

2. **Start the complete environment:**
   ```bash
   sudo docker compose up -d
   ```

3. **Wait for initialization (about 60 seconds):**
   ```bash
   # Check if all containers are running
   sudo docker compose ps
   ```

4. **Connect to the cluster:**
   ```bash
   # Connect via ProxySQL (recommended - load balanced)
   mysql -h localhost -P 6033 -u root -prootpassword
   
   # Or connect directly to a specific node
   mysql -h localhost -P 3306 -u root -prootpassword  # Node 1
   mysql -h localhost -P 3307 -u root -prootpassword  # Node 2
   mysql -h localhost -P 3308 -u root -prootpassword  # Node 3
   ```

## 🏗️ **Architecture**

### MariaDB Galera Nodes
- **galera-node1**: Primary node (port 3306) - Bootstraps the cluster
- **galera-node2**: Secondary node (port 3307) - Joins automatically
- **galera-node3**: Secondary node (port 3308) - Joins automatically

### ProxySQL Load Balancer
- **galera-proxy**: Load balancer (ports 6033, 6032)
- **Automatic configuration** of servers and users
- **Load balancing** across all Galera nodes

## ⚙️ **Configuration**

### 🔧 **Environment Variables (.env file)**

All configuration is managed through the `.env` file. You can customize:

- `MARIADB_VERSION`: MariaDB version (11.4, 11.3, 11.2, 11.1, 11.0, 10.11, 10.10, 10.9, 10.8, 10.7, 10.6, 10.5, 10.4, 10.3, 10.2, 10.1)
- `MYSQL_ROOT_PASSWORD`: Root password for all nodes
- `MYSQL_DATABASE`: Default database to create
- `MYSQL_USER`: Default user to create
- `MYSQL_PASSWORD`: Password for the default user
- `GALERA_CLUSTER_NAME`: Name of the Galera cluster
- `GALERA_SST_METHOD`: State Snapshot Transfer method (rsync, mariabackup)
- `INNODB_BUFFER_POOL_SIZE`: InnoDB buffer pool size
- `MAX_CONNECTIONS`: Maximum number of connections
- `NETWORK_SUBNET`: Docker network subnet

### 🚀 **Change MariaDB Version**

**Easy way:**
```bash
# Change to MariaDB 11.4 (latest)
./change-version.sh 11.4

# Change to MariaDB 10.10
./change-version.sh 10.10

# Apply changes
docker compose down -v
docker compose up -d
```

**Manual way:**
```bash
# Edit .env file
nano .env

# Change MARIADB_VERSION=11.4
# Then restart
docker compose down -v
docker compose up -d
```

### ⚠️ **MariaDB Version Compatibility**

- **MariaDB 10.x**: Uses `mysql` client command
- **MariaDB 11.x**: Uses `mariadb` client command  
- **Galera Support**: Both versions use Galera 4, fully compatible with our setup
- **Upgrade Path**: You can upgrade from MariaDB 10.x to 11.x directly
- **Configuration**: All existing configurations work with both versions
- **Client Detection**: The setup automatically detects the version and uses the correct client
- **Testing**: Always test version changes in a non-production environment first

### Galera Configuration
The cluster is configured with:
- **Cluster name**: `galera-cluster`
- **SST method**: `rsync`
- **Binary log format**: `ROW`
- **Storage engine**: `InnoDB`
- **Auto-increment lock mode**: `2`

### Ports
- **3306**: galera-node1 (primary)
- **3307**: galera-node2
- **3308**: galera-node3
- **6033**: ProxySQL (MySQL interface)
- **6032**: ProxySQL (admin interface)

## 🔧 **Management Commands**

### Start the cluster
```bash
sudo docker compose up -d
```

### Stop the cluster
```bash
sudo docker compose down
```

### Restart the cluster
```bash
sudo docker compose restart
```

### Restart a specific node
```bash
sudo docker compose restart galera-node1
```

### View logs
```bash
# All services
sudo docker compose logs

# Specific service
sudo docker compose logs galera-node1
sudo docker compose logs galera-proxy
```

### Complete reset (fresh start)
```bash
# Stop and remove everything including data
sudo docker compose down -v

# Start fresh
sudo docker compose up -d
```

### Scale the cluster
```bash
# Add more nodes (not recommended for production)
sudo docker compose up -d --scale galera-node1=1 --scale galera-node2=1 --scale galera-node3=1
```

## ✨ **Automated Features**

- **Automatic Bootstrap**: Node1 automatically bootstraps the cluster
- **Auto-Join**: Other nodes automatically join the existing cluster
- **ProxySQL Auto-Config**: Automatically configures servers and users
- **Health Checks**: Waits for all services to be ready before starting
- **Load Balancing**: Automatically distributes connections across nodes
- **Data Replication**: All data automatically replicates across the cluster

## 📊 **Monitoring**

### Check cluster status
```bash
# Show cluster information
sudo docker exec galera-node1 mysql -u root -prootpassword -e "SHOW STATUS LIKE 'wsrep%';"

# Show cluster size (should be 3)
sudo docker exec galera-node1 mysql -u root -prootpassword -e "SHOW STATUS LIKE 'wsrep_cluster_size';"

# Show cluster state
sudo docker exec galera-node1 mysql -u root -prootpassword -e "SHOW STATUS LIKE 'wsrep_local_state_comment';"
```

### Check ProxySQL status
```bash
# Connect to ProxySQL admin
mysql -h localhost -P 6032 -u admin -padmin

# Show configured servers
SELECT * FROM mysql_servers;

# Show connection stats
SELECT * FROM stats_mysql_connection_pool;

# Show load balancing stats
SELECT * FROM stats_mysql_commands_counters;
```

### Test load balancing
```bash
# Run multiple connections to see load balancing
for i in {1..5}; do
  mysql -h localhost -P 6033 -u root -prootpassword --protocol=TCP -e "SELECT @@hostname, @@port;"
  sleep 1
done
```

## 🔧 **Troubleshooting**

### Common Issues

1. **Cluster won't start:**
   ```bash
   # Check container status
   sudo docker compose ps
   
   # Check logs for errors
   sudo docker compose logs galera-node1
   sudo docker compose logs galera-proxy
   ```

2. **Cluster size is 0:**
   ```bash
   # Check if Galera is enabled
   sudo docker exec galera-node1 mysql -u root -prootpassword -e "SHOW STATUS LIKE 'wsrep_on';"
   
   # Should show: wsrep_on = ON
   ```

3. **ProxySQL not connecting:**
   ```bash
   # Check if ProxySQL is configured
   sudo docker exec galera-proxy mysql -h 127.0.0.1 -P 6032 -u admin -padmin -e "SELECT * FROM mysql_servers;"
   ```

4. **Data inconsistency:**
   - Check if all nodes are in the cluster
   - Verify network connectivity between containers
   - Check disk space

### Recovery

1. **Complete reset (recommended):**
   ```bash
   # Stop and remove everything including data
   sudo docker compose down -v
   
   # Start fresh (everything will be auto-configured)
   sudo docker compose up -d
   ```

2. **Restart specific service:**
   ```bash
   # Restart ProxySQL
   sudo docker compose restart galera-proxy
   
   # Restart a specific node
   sudo docker compose restart galera-node1
   ```

3. **Check cluster health:**
   ```bash
   # Verify all nodes are connected
   sudo docker exec galera-node1 mysql -u root -prootpassword -e "SHOW STATUS LIKE 'wsrep_cluster_size';"
   
   # Should show: wsrep_cluster_size = 3
   ```

## Security Notes

- Change default passwords in production
- Use proper SSL/TLS certificates
- Configure firewall rules
- Regular backups
- Monitor cluster health

## Backup and Restore

### Backup
```bash
# Backup from any node
docker exec galera-node1 mysqldump -u root -prootpassword --all-databases > backup.sql
```

### Restore
```bash
# Restore to any node
docker exec -i galera-node1 mysql -u root -prootpassword < backup.sql
```

## 🚀 **Production Ready Features**

- **High Availability**: 3-node cluster with automatic failover
- **Load Balancing**: ProxySQL distributes connections efficiently
- **Data Synchronization**: Real-time replication across all nodes
- **Easy Management**: Simple Docker Compose commands
- **Persistent Storage**: Data survives container restarts
- **Health Monitoring**: Built-in health checks and status monitoring

## ⚡ **Performance Tuning**

For production environments, consider:
- Increasing `innodb-buffer-pool-size` in docker-compose.yml
- Adjusting `max-connections` based on load
- Configuring `wsrep-sst-method` to `mariabackup` for better performance
- Setting up monitoring and alerting
- Implementing proper backup strategies

## 🎉 **Success!**

Your Galera cluster with ProxySQL is now fully automated and production-ready! 

**Next time you need to start the environment:**
```bash
cd mariadb_galera
sudo docker compose up -d
```

**That's it! No manual configuration needed!** 🚀
