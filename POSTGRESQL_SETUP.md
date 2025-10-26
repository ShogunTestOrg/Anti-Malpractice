# PostgreSQL Setup Guide for Anti-Malpractice Quiz System

## Installing PostgreSQL

### Windows
1. Download PostgreSQL from https://www.postgresql.org/download/windows/
2. Run the installer
3. Set password for postgres user (remember this!)
4. Default port: 5432
5. Install pgAdmin 4 (included in installer)

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### macOS
```bash
brew install postgresql
brew services start postgresql
```

## Creating the Database

### Method 1: Using psql Command Line

```bash
# Login as postgres user
psql -U postgres

# Create database
CREATE DATABASE quiz_system;

# Connect to database
\c quiz_system

# Run the schema file
\i 'd:/College/Semester 5/Lab/Web Programming/Project/Anti-Malpractice/database/schema.sql'

# Verify tables
\dt

# Exit
\q
```

### Method 2: Using pgAdmin 4

1. Open pgAdmin 4
2. Right-click "Databases" → Create → Database
3. Name: `quiz_system`
4. Save
5. Click on quiz_system database
6. Tools → Query Tool
7. Open File → Select schema.sql
8. Click Execute (F5)

## Configure Database Connection

Edit: `src/com/quiz/utils/DatabaseConnection.java`

```java
private static final String URL = "jdbc:postgresql://localhost:5432/quiz_system";
private static final String USERNAME = "postgres";
private static final String PASSWORD = "your_postgres_password";
```

## Download PostgreSQL JDBC Driver

1. Go to https://jdbc.postgresql.org/download/
2. Download latest PostgreSQL JDBC Driver (e.g., postgresql-42.7.0.jar)
3. Copy to: `WebContent/WEB-INF/lib/postgresql-42.7.0.jar`

## Testing Connection

```bash
# Test PostgreSQL is running
psql -U postgres -c "SELECT version();"

# Test connection to quiz_system
psql -U postgres -d quiz_system -c "SELECT COUNT(*) FROM users;"
```

## Common PostgreSQL Commands

```sql
-- List all databases
\l

-- Connect to database
\c quiz_system

-- List all tables
\dt

-- Describe table
\d users

-- View data
SELECT * FROM users;

-- Check enum types
\dT+

-- View all views
\dv
```

## PostgreSQL vs MySQL Differences

| Feature | MySQL | PostgreSQL |
|---------|-------|------------|
| Driver | mysql-connector-java | postgresql |
| Port | 3306 | 5432 |
| Auto Increment | AUTO_INCREMENT | SERIAL |
| Enum | ENUM('val1', 'val2') | CREATE TYPE ... AS ENUM |
| Views | CREATE VIEW | CREATE OR REPLACE VIEW |
| URL Format | jdbc:mysql://... | jdbc:postgresql://... |

## Troubleshooting

### "Password authentication failed"
```bash
# Reset postgres password
sudo -u postgres psql
ALTER USER postgres PASSWORD 'newpassword';
```

### "Connection refused"
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start PostgreSQL
sudo systemctl start postgresql
```

### "Driver not found"
- Ensure postgresql-*.jar is in WEB-INF/lib/
- Clean and rebuild project
- Restart Tomcat

### "Database does not exist"
```bash
# Create database
psql -U postgres -c "CREATE DATABASE quiz_system;"
```

## Security Configuration (pg_hba.conf)

For development, ensure local connections are allowed:

```conf
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5

# IPv6 local connections:
host    all             all             ::1/128                 md5
```

Location:
- Windows: `C:\Program Files\PostgreSQL\15\data\pg_hba.conf`
- Linux: `/etc/postgresql/15/main/pg_hba.conf`

After changes: `sudo systemctl restart postgresql`

## Backup and Restore

### Backup
```bash
pg_dump -U postgres quiz_system > backup.sql
```

### Restore
```bash
psql -U postgres quiz_system < backup.sql
```

## Next Steps

1. ✅ Install PostgreSQL
2. ✅ Create quiz_system database
3. ✅ Run schema.sql
4. ✅ Download PostgreSQL JDBC driver
5. ✅ Update DatabaseConnection.java
6. ✅ Test connection
7. ✅ Deploy to Tomcat

## Advantages of PostgreSQL

- ✅ Better concurrency control
- ✅ Advanced data types
- ✅ Better standards compliance
- ✅ More robust transactions
- ✅ Better for complex queries
- ✅ Open source with no corporate control
- ✅ Better JSON support
- ✅ More reliable for production

Your quiz system is now configured for PostgreSQL! 🐘
