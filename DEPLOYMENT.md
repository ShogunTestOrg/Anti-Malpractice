# 🚀 Deployment Guide - Anti-Malpractice Quiz System# 🚀 Deployment Guide - Anti-Malpractice Quiz System



## 📦 One-Command Automated Deployment## Quick Start for Beginners



The `deploy.ps1` script provides a **complete automated deployment solution**:### Step 1: Install Prerequisites



### What It Does#### Java Development Kit (JDK)

1. Download JDK 8 or higher from Oracle/OpenJDK

```2. Install and set JAVA_HOME environment variable

deploy.ps13. Verify: `java -version`

├─ [1/6] Load database credentials from setenv.bat

├─ [2/6] Prepare build directories  #### Apache Tomcat

├─ [3/6] Compile all Java source files1. Download Tomcat 9.x from https://tomcat.apache.org/

├─ [4/6] Stop Tomcat server2. Extract to C:\tomcat (Windows) or /opt/tomcat (Linux)

├─ [5/6] Deploy application to Tomcat3. Verify: Run startup.bat (Windows) or startup.sh (Linux)

└─ [6/6] Start Tomcat server & open browser

```#### MySQL Server

1. Download MySQL 8.x from https://dev.mysql.com/downloads/

## 🎯 Quick Deployment2. Install with root password

3. Verify: `mysql --version`

```powershell

# First time setup#### IDE (Eclipse)

Copy-Item setenv.bat.example setenv.bat1. Download Eclipse IDE for Enterprise Java Developers

notepad setenv.bat  # Edit with your database credentials2. Install and launch

3. Install Tomcat plugin if not included

# Deploy (every time you make changes)

.\deploy.ps1---

```

## Step 2: Setup Database

That's it! Everything is automated.

### Create Database

## ✨ Script Features```bash

# Start MySQL

### ✅ Automatic Credential Loadingmysql -u root -p

- Reads database credentials from `setenv.bat`

- Sets environment variables for the current session# Create database

- Copies credentials to Tomcat's bin directoryCREATE DATABASE quiz_system;

USE quiz_system;

### ✅ Smart Compilation

- Automatically finds all Java source files (20 files)# Import schema

- Compiles with proper classpath (Servlet API + PostgreSQL driver)source d:/College/Semester 5/Lab/Web Programming/Project/Anti-Malpractice/database/schema.sql

- Shows compilation status with colored output

- Handles errors gracefully# Verify tables created

SHOW TABLES;

### ✅ Safe Deployment

- Stops Tomcat gracefully# Exit MySQL

- Removes old deployment completelyexit;

- Deploys fresh application files```

- Starts Tomcat with new configuration

### Alternative: Using MySQL Workbench

### ✅ User-Friendly Output1. Open MySQL Workbench

- Color-coded status messages (Green=Success, Yellow=Warning, Red=Error)2. Connect to local MySQL server

- Progress indicators [1/6, 2/6, etc.]3. File → Run SQL Script

- Deployment summary4. Select `schema.sql`

- Automatic browser launch5. Execute



## 📋 Prerequisites---



Before running `deploy.ps1`, ensure you have:## Step 3: Configure Project



1. **Java Development Kit (JDK)** - Version 8 or higher### Update Database Password

   ```powershellEdit: `src/com/quiz/utils/DatabaseConnection.java`

   java -version  # Should show version 1.8 or higher

   ``````java

private static final String PASSWORD = "YOUR_MYSQL_PASSWORD";

2. **Apache Tomcat** - Version 9.0 or higher```

   - Installed at: `C:\Program Files\Apache Software Foundation\Tomcat 9.0`

   - Or edit `$TOMCAT_HOME` variable in `deploy.ps1`### Add MySQL JDBC Driver



3. **PostgreSQL JDBC Driver** - Already included**Option 1: Manual**

   - Location: `WebContent/WEB-INF/lib/postgresql-42.7.8.jar`1. Download MySQL Connector/J from:

   https://dev.mysql.com/downloads/connector/j/

4. **Database Credentials** - Configured in `setenv.bat`2. Extract `mysql-connector-java-8.0.x.jar`

   ```batch3. Copy to: `WebContent/WEB-INF/lib/`

   set DB_URL=jdbc:postgresql://host:port/database?sslmode=require

   set DB_USERNAME=your_username**Option 2: Maven (if using Maven)**

   set DB_PASSWORD=your_passwordAdd to `pom.xml`:

   ``````xml

<dependency>

## 📤 Example Output    <groupId>mysql</groupId>

    <artifactId>mysql-connector-java</artifactId>

```    <version>8.0.33</version>

========================================</dependency>

Anti-Malpractice Deployment Script```

========================================

---

[1/6] Loading database credentials...

  ✓ Found setenv.bat, loading credentials...## Step 4: Import Project to Eclipse

  ✓ Set DB_URL

  ✓ Set DB_USERNAME### Method 1: Import Existing Project

  ✓ Set DB_PASSWORD1. Eclipse → File → Import

2. General → Existing Projects into Workspace

[2/6] Preparing build directories...3. Select project folder

  ✓ Classes directory exists4. Finish



[3/6] Compiling Java source files...### Method 2: Create New Dynamic Web Project

  Found 20 Java files to compile1. File → New → Dynamic Web Project

  ✓ Compilation successful!2. Project name: Anti-Malpractice

3. Target runtime: Apache Tomcat 9.0

[4/6] Stopping Tomcat server...4. Dynamic web module version: 4.0

  ✓ Tomcat shutdown initiated5. Finish

6. Copy all files from downloaded project

[5/6] Deploying application to Tomcat...

  ✓ Removed old deployment---

  ✓ Copied application files to Tomcat

  ✓ Copied setenv.bat to Tomcat bin directory## Step 5: Configure Tomcat in Eclipse



[6/6] Starting Tomcat server...### Add Tomcat Server

  ✓ Tomcat startup initiated1. Window → Preferences → Server → Runtime Environments

2. Add → Apache Tomcat v9.0

========================================3. Browse to Tomcat installation directory

Deployment Complete!4. Finish

========================================

### Configure Project Facets

Application URL: http://localhost:8080/Anti-Malpractice1. Right-click project → Properties

2. Project Facets

Deployment Summary:3. Enable:

  • Source files compiled: 20   - Java: 1.8 or higher

  • Deployment location: C:\Program Files\...\webapps\Anti-Malpractice   - Dynamic Web Module: 4.0

  • Environment variables: Loaded   - JavaScript: 1.0

```

### Set Build Path

## ⚙️ Configuration1. Right-click project → Build Path → Configure Build Path

2. Add External JARs: servlet-api.jar (from Tomcat lib)

### Default Paths (Configurable in deploy.ps1)3. Add MySQL JDBC driver if not in WEB-INF/lib



| Variable | Default Value | Description |---

|----------|---------------|-------------|

| `$TOMCAT_HOME` | `C:\Program Files\Apache Software Foundation\Tomcat 9.0` | Tomcat installation directory |## Step 6: Deploy and Run

| `$SRC_DIR` | `src` | Java source files location |

| `$CLASSES_DIR` | `WebContent\WEB-INF\classes` | Compiled classes output |### Deploy to Tomcat

| `$LIB_DIR` | `WebContent\WEB-INF\lib` | JAR libraries location |1. Right-click project → Run As → Run on Server

| `$APP_NAME` | `Anti-Malpractice` | Application context path |2. Select Tomcat 9.0

3. Click Finish

### Customizing Tomcat Path4. Wait for deployment



If your Tomcat is installed elsewhere, edit `deploy.ps1`:### Verify Deployment

1. Check Console for errors

```powershell2. Look for "Server startup in [xxxx] ms"

$TOMCAT_HOME = "D:\Apache\Tomcat"  # Your custom path3. No red error messages

```

### Access Application

## 🔧 TroubleshootingOpen browser and navigate to:

```

### ⚠️ "setenv.bat not found"http://localhost:8080/Anti-Malpractice

**Problem:** Script warns about missing setenv.bat  ```

**Solution:**

```powershell---

Copy-Item setenv.bat.example setenv.bat

notepad setenv.bat  # Configure your credentials## Step 7: Testing

```

### Test Login

### ❌ "Compilation failed"1. Login as Student:

**Problem:** Java compilation errors     - Username: `student`

**Solutions:**   - Password: `1234`

1. Check Java is installed:

   ```powershell2. Login as Admin:

   java -version   - Username: `admin`

   javac -version   - Password: `admin123`

   ```

2. Verify servlet-api.jar exists in Tomcat lib directory### Test Quiz Features

3. Check postgresql-42.7.8.jar exists in `WebContent/WEB-INF/lib/`1. Start quiz

2. Answer questions

### ❌ "Tomcat startup failed"3. Try tab switching (should log violation)

**Problem:** Tomcat won't start  4. Try copy-paste (should be blocked)

**Solutions:**5. Submit quiz

1. Check Tomcat path in `deploy.ps1` is correct6. Check results

2. Verify Tomcat is installed correctly

3. Check port 8080 is not already in use:### Test Admin Panel

   ```powershell1. Login as admin

   netstat -ano | findstr :80802. View violations log

   ```3. Check statistics

4. Check Tomcat logs:

   ```---

   C:\Program Files\...\Tomcat 9.0\logs\catalina.out

   ```## Troubleshooting



### ❌ "Database connection failed"### Issue: "HTTP Status 404 – Not Found"

**Problem:** Cannot connect to database  **Solution:**

**Solutions:**- Check project context: Right-click project → Properties → Web Project Settings

1. Verify database credentials in `setenv.bat`- Context root should be: `/Anti-Malpractice`

2. Check database server is running- Clean and rebuild: Project → Clean

3. Test connection:- Restart Tomcat

   ```powershell

   java -cp ".;WebContent\WEB-INF\lib\postgresql-42.7.8.jar" TestConnection### Issue: "The import javax.servlet cannot be resolved"

   ```**Solution:**

4. Check firewall settings- Add servlet-api.jar to build path

5. Verify SSL mode is correct for your database- Right-click project → Build Path → Add External JARs

- Select `servlet-api.jar` from Tomcat's lib folder

## 🛠️ Manual Steps (Advanced)

### Issue: "ClassNotFoundException: com.mysql.cj.jdbc.Driver"

If you need to perform steps individually:**Solution:**

- Ensure MySQL JDBC driver is in `WEB-INF/lib/`

### Compile Only- Clean and rebuild project

```powershell- Restart Tomcat

$TOMCAT_LIB = "C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib"

$CLASSPATH = "$TOMCAT_LIB\servlet-api.jar;WebContent\WEB-INF\lib\postgresql-42.7.8.jar"### Issue: "Communications link failure"

javac -d "WebContent\WEB-INF\classes" -cp $CLASSPATH -encoding UTF-8 (Get-ChildItem -Path "src" -Filter "*.java" -Recurse).FullName**Solution:**

```- Verify MySQL is running: `mysql -u root -p`

- Check database name and credentials in DatabaseConnection.java

### Deploy Only- Check MySQL port (default: 3306)

```powershell

Copy-Item -Path "WebContent\*" -Destination "C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\Anti-Malpractice" -Recurse -Force### Issue: Violations not logging

```**Solution:**

- Check file permissions for WEB-INF folder

### Restart Tomcat Only- Verify Logger class is working

```powershell- Check Tomcat console for errors

& "C:\Program Files\Apache Software Foundation\Tomcat 9.0\bin\shutdown.bat"

Start-Sleep -Seconds 3### Issue: JavaScript not working

& "C:\Program Files\Apache Software Foundation\Tomcat 9.0\bin\startup.bat"**Solution:**

```- Clear browser cache (Ctrl+Shift+Delete)

- Check browser console for errors (F12)

## 🔄 Development Workflow- Verify `monitor.js` is loaded (Network tab)



```powershell---

# 1. Make code changes

#    - Edit Java files in src/## Production Deployment

#    - Modify JSP files in WebContent/

#    - Update CSS/JS as needed### Security Checklist

- [ ] Change default passwords

# 2. Deploy with one command- [ ] Implement BCrypt password hashing

.\deploy.ps1- [ ] Enable HTTPS/SSL

- [ ] Add CSRF protection

# 3. Application automatically opens in browser- [ ] Validate all inputs

#    http://localhost:8080/Anti-Malpractice- [ ] Use prepared statements

- [ ] Configure secure cookies

# 4. Test your changes- [ ] Disable directory listing

- [ ] Remove debug code

# 5. Repeat!

```### Performance Optimization

- [ ] Enable connection pooling

## 🌐 Production Deployment- [ ] Implement caching

- [ ] Compress static resources

For production environments, follow these best practices:- [ ] Enable Tomcat compression

- [ ] Optimize database queries

### Security- [ ] Add indexes to database tables

- ✅ Use environment-specific `setenv.bat` files

- ✅ Store credentials in secure secret management### Monitoring

  - Azure Key Vault- [ ] Setup application logs

  - AWS Secrets Manager- [ ] Configure error monitoring

  - HashiCorp Vault- [ ] Setup database backup

- ✅ Enable SSL/TLS for database connections- [ ] Monitor server resources

- ✅ Use strong passwords- [ ] Setup alerting system

- ✅ Limit database user permissions

---

### CI/CD Pipeline

- ✅ Use automated deployment (GitHub Actions, Jenkins)## Docker Deployment (Optional)

- ✅ Run automated tests before deployment

- ✅ Deploy to staging environment first### Create Dockerfile

- ✅ Use blue-green or canary deployment strategies```dockerfile

FROM tomcat:9.0-jdk11

### MonitoringCOPY Anti-Malpractice.war /usr/local/tomcat/webapps/

- ✅ Enable Tomcat access logsEXPOSE 8080

- ✅ Monitor application performanceCMD ["catalina.sh", "run"]

- ✅ Set up error alerting```

- ✅ Use logging frameworks (Log4j, SLF4J)

### Build and Run

### Configuration```bash

- ✅ Use separate databases for dev/staging/productiondocker build -t quiz-system .

- ✅ Configure connection poolingdocker run -p 8080:8080 quiz-system

- ✅ Set appropriate timeouts```

- ✅ Enable compression for static resources

---

## 📚 See Also

## Database Backup

- **`SECURITY.md`** - Security best practices for credentials

- **`QUICKSTART.md`** - Quick start guide for new developers  ### Manual Backup

- **`README.md`** - Project overview and features```bash

- **`POSTGRESQL_SETUP.md`** - Database setup guidemysqldump -u root -p quiz_system > backup.sql

```

## 📞 Support

### Restore from Backup

If you encounter issues not covered here:```bash

1. Check Tomcat logs in `logs/` directorymysql -u root -p quiz_system < backup.sql

2. Review application logs in Tomcat console```

3. Verify all prerequisites are installed

4. Ensure database is accessible### Automated Backup (Linux)

5. Contact the development teamCreate cron job:

```bash

---crontab -e



**Happy Deploying! 🚀**# Add line:

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
