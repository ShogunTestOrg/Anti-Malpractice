# 🚀 Deployment Guide - Anti-Malpractice Quiz System

## Quick Start for Beginners

### Step 1: Install Prerequisites

#### Java Development Kit (JDK)
1. Download JDK 8 or higher from Oracle/OpenJDK
2. Install and set JAVA_HOME environment variable
3. Verify: `java -version`

#### Apache Tomcat
1. Download Tomcat 9.x from https://tomcat.apache.org/
2. Extract to C:\tomcat (Windows) or /opt/tomcat (Linux)
3. Verify: Run startup.bat (Windows) or startup.sh (Linux)

#### MySQL Server
1. Download MySQL 8.x from https://dev.mysql.com/downloads/
2. Install with root password
3. Verify: `mysql --version`

#### IDE (Eclipse)
1. Download Eclipse IDE for Enterprise Java Developers
2. Install and launch
3. Install Tomcat plugin if not included

---

## Step 2: Setup Database

### Create Database
```bash
# Start MySQL
mysql -u root -p

# Create database
CREATE DATABASE quiz_system;
USE quiz_system;

# Import schema
source d:/College/Semester 5/Lab/Web Programming/Project/Anti-Malpractice/database/schema.sql

# Verify tables created
SHOW TABLES;

# Exit MySQL
exit;
```

### Alternative: Using MySQL Workbench
1. Open MySQL Workbench
2. Connect to local MySQL server
3. File → Run SQL Script
4. Select `schema.sql`
5. Execute

---

## Step 3: Configure Project

### Update Database Password
Edit: `src/com/quiz/utils/DatabaseConnection.java`

```java
private static final String PASSWORD = "YOUR_MYSQL_PASSWORD";
```

### Add MySQL JDBC Driver

**Option 1: Manual**
1. Download MySQL Connector/J from:
   https://dev.mysql.com/downloads/connector/j/
2. Extract `mysql-connector-java-8.0.x.jar`
3. Copy to: `WebContent/WEB-INF/lib/`

**Option 2: Maven (if using Maven)**
Add to `pom.xml`:
```xml
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
</dependency>
```

---

## Step 4: Import Project to Eclipse

### Method 1: Import Existing Project
1. Eclipse → File → Import
2. General → Existing Projects into Workspace
3. Select project folder
4. Finish

### Method 2: Create New Dynamic Web Project
1. File → New → Dynamic Web Project
2. Project name: Anti-Malpractice
3. Target runtime: Apache Tomcat 9.0
4. Dynamic web module version: 4.0
5. Finish
6. Copy all files from downloaded project

---

## Step 5: Configure Tomcat in Eclipse

### Add Tomcat Server
1. Window → Preferences → Server → Runtime Environments
2. Add → Apache Tomcat v9.0
3. Browse to Tomcat installation directory
4. Finish

### Configure Project Facets
1. Right-click project → Properties
2. Project Facets
3. Enable:
   - Java: 1.8 or higher
   - Dynamic Web Module: 4.0
   - JavaScript: 1.0

### Set Build Path
1. Right-click project → Build Path → Configure Build Path
2. Add External JARs: servlet-api.jar (from Tomcat lib)
3. Add MySQL JDBC driver if not in WEB-INF/lib

---

## Step 6: Deploy and Run

### Deploy to Tomcat
1. Right-click project → Run As → Run on Server
2. Select Tomcat 9.0
3. Click Finish
4. Wait for deployment

### Verify Deployment
1. Check Console for errors
2. Look for "Server startup in [xxxx] ms"
3. No red error messages

### Access Application
Open browser and navigate to:
```
http://localhost:8080/Anti-Malpractice
```

---

## Step 7: Testing

### Test Login
1. Login as Student:
   - Username: `student`
   - Password: `1234`

2. Login as Admin:
   - Username: `admin`
   - Password: `admin123`

### Test Quiz Features
1. Start quiz
2. Answer questions
3. Try tab switching (should log violation)
4. Try copy-paste (should be blocked)
5. Submit quiz
6. Check results

### Test Admin Panel
1. Login as admin
2. View violations log
3. Check statistics

---

## Troubleshooting

### Issue: "HTTP Status 404 – Not Found"
**Solution:**
- Check project context: Right-click project → Properties → Web Project Settings
- Context root should be: `/Anti-Malpractice`
- Clean and rebuild: Project → Clean
- Restart Tomcat

### Issue: "The import javax.servlet cannot be resolved"
**Solution:**
- Add servlet-api.jar to build path
- Right-click project → Build Path → Add External JARs
- Select `servlet-api.jar` from Tomcat's lib folder

### Issue: "ClassNotFoundException: com.mysql.cj.jdbc.Driver"
**Solution:**
- Ensure MySQL JDBC driver is in `WEB-INF/lib/`
- Clean and rebuild project
- Restart Tomcat

### Issue: "Communications link failure"
**Solution:**
- Verify MySQL is running: `mysql -u root -p`
- Check database name and credentials in DatabaseConnection.java
- Check MySQL port (default: 3306)

### Issue: Violations not logging
**Solution:**
- Check file permissions for WEB-INF folder
- Verify Logger class is working
- Check Tomcat console for errors

### Issue: JavaScript not working
**Solution:**
- Clear browser cache (Ctrl+Shift+Delete)
- Check browser console for errors (F12)
- Verify `monitor.js` is loaded (Network tab)

---

## Production Deployment

### Security Checklist
- [ ] Change default passwords
- [ ] Implement BCrypt password hashing
- [ ] Enable HTTPS/SSL
- [ ] Add CSRF protection
- [ ] Validate all inputs
- [ ] Use prepared statements
- [ ] Configure secure cookies
- [ ] Disable directory listing
- [ ] Remove debug code

### Performance Optimization
- [ ] Enable connection pooling
- [ ] Implement caching
- [ ] Compress static resources
- [ ] Enable Tomcat compression
- [ ] Optimize database queries
- [ ] Add indexes to database tables

### Monitoring
- [ ] Setup application logs
- [ ] Configure error monitoring
- [ ] Setup database backup
- [ ] Monitor server resources
- [ ] Setup alerting system

---

## Docker Deployment (Optional)

### Create Dockerfile
```dockerfile
FROM tomcat:9.0-jdk11
COPY Anti-Malpractice.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]
```

### Build and Run
```bash
docker build -t quiz-system .
docker run -p 8080:8080 quiz-system
```

---

## Database Backup

### Manual Backup
```bash
mysqldump -u root -p quiz_system > backup.sql
```

### Restore from Backup
```bash
mysql -u root -p quiz_system < backup.sql
```

### Automated Backup (Linux)
Create cron job:
```bash
crontab -e

# Add line:
0 2 * * * mysqldump -u root -pYOUR_PASSWORD quiz_system > /backups/quiz_$(date +\%Y\%m\%d).sql
```

---

## Common Commands

### Tomcat
```bash
# Start
./startup.sh   (Linux)
startup.bat    (Windows)

# Stop
./shutdown.sh  (Linux)
shutdown.bat   (Windows)

# Check logs
tail -f logs/catalina.out
```

### MySQL
```bash
# Start
sudo service mysql start

# Stop
sudo service mysql stop

# Restart
sudo service mysql restart

# Check status
sudo service mysql status
```

---

## Support & Resources

### Documentation
- JSP/Servlet: https://jakarta.ee/specifications/servlet/
- Tomcat: https://tomcat.apache.org/tomcat-9.0-doc/
- MySQL: https://dev.mysql.com/doc/

### Community
- Stack Overflow
- Apache Tomcat User List
- MySQL Forums

### Files to Check
- `logs/catalina.out` - Tomcat logs
- Browser Console (F12) - JavaScript errors
- MySQL error log - Database errors

---

## Next Steps

After successful deployment:
1. ✅ Test all features thoroughly
2. ✅ Document any custom configurations
3. ✅ Create user accounts
4. ✅ Setup monitoring
5. ✅ Create backup strategy
6. ✅ Train admin users
7. ✅ Prepare user documentation

---

## Credits

Project: Anti-Malpractice Online Quiz System
Tech Stack: JSP, Servlets, MySQL, JavaScript
Server: Apache Tomcat 9.x
Date: October 2025

For questions: Check README.md and SETUP.md

**Good luck with your deployment! 🎉**
