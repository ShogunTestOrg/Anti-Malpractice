# Anti-Malpractice Online Quiz System - Setup Guide

## Prerequisites
- JDK 8 or higher
- Apache Tomcat 9.x
- MySQL Server 8.x
- IDE (Eclipse/IntelliJ IDEA)

## Installation Steps

### 1. Database Setup
```bash
# Start MySQL service
mysql -u root -p

# Create database and import schema
source database/schema.sql
```

### 2. Configure Database Connection
Create a file: `src/com/quiz/utils/DatabaseConnection.java`
```java
public class DatabaseConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/quiz_system";
    private static final String USER = "root";
    private static final String PASSWORD = "your_password";
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
```

### 3. Add MySQL JDBC Driver
Download MySQL Connector/J and place it in:
```
WebContent/WEB-INF/lib/mysql-connector-java-8.0.x.jar
```

### 4. Configure Tomcat
1. Open Eclipse/IntelliJ
2. Add Tomcat Server
3. Set project facets:
   - Dynamic Web Module: 4.0
   - Java: 1.8+

### 5. Deploy Project
1. Right-click project → Run As → Run on Server
2. Select Tomcat Server
3. Access: http://localhost:8080/Anti-Malpractice

## Default Credentials

### Student Account
- Username: `student`
- Password: `1234`

### Admin Account
- Username: `admin`
- Password: `admin123`

## Project Structure Verification

Ensure this structure:
```
Anti-Malpractice/
├── WebContent/
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── monitor.js
│   ├── WEB-INF/
│   │   ├── web.xml
│   │   └── lib/
│   ├── index.jsp
│   ├── quiz.jsp
│   ├── admin.jsp
│   └── result.jsp
├── src/
│   └── com/quiz/
│       ├── servlets/
│       ├── models/
│       ├── utils/
│       └── dao/
└── database/
    └── schema.sql
```

## Testing

### 1. Test Login
- Access http://localhost:8080/Anti-Malpractice
- Login with student credentials
- Should redirect to quiz

### 2. Test Quiz
- Answer questions
- Try tab switching (should log violation)
- Try copy-paste (should be blocked)
- Submit quiz

### 3. Test Admin Panel
- Login with admin credentials
- View violations log
- Check statistics

## Troubleshooting

### Issue: 404 Error
**Solution:** Check Tomcat deployment, verify context path

### Issue: Servlet not found
**Solution:** Check web.xml servlet mappings

### Issue: Database connection failed
**Solution:** Verify MySQL is running, check credentials

### Issue: Violations not logging
**Solution:** Check file permissions for WEB-INF directory

## Security Notes (Production)

1. **Use HTTPS** - Enable SSL/TLS
2. **Hash Passwords** - Use BCrypt
3. **Prepared Statements** - Prevent SQL injection
4. **CSRF Tokens** - Add to all forms
5. **Session Security** - Configure secure cookies
6. **Input Validation** - Validate all user input

## Performance Optimization

1. Enable connection pooling
2. Use caching for questions
3. Optimize database queries
4. Compress static resources
5. Enable Tomcat compression

## Monitoring

Check logs at:
- `WEB-INF/violations.log` - Violation logs
- `logs/catalina.out` - Tomcat logs

## Next Steps

1. Implement database DAO layer
2. Add email notifications
3. Integrate webcam monitoring
4. Add report generation
5. Implement AI-based detection

## Support

For issues, check:
- Console logs
- Browser developer tools
- Tomcat logs

## License
Academic Project - Free to use
