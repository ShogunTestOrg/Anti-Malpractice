# Anti-Malpractice Online Quiz System

## 🎓 Project Overview
A comprehensive web-based quiz system with advanced anti-malpractice detection built using JSP and Servlets.

## ✨ Key Features

### Anti-Malpractice Detection
- ✅ Tab Switch Detection & Logging
- ✅ Copy/Paste Prevention
- ✅ Right-Click Disable
- ✅ Screenshot Detection
- ✅ Fullscreen Exit Monitoring
- ✅ Multiple Tab Detection
- ✅ Inactivity Tracking
- ✅ DevTools Prevention
- ✅ Auto-Submit on Violation Threshold

### Additional Features
- Real-time Timer with Auto-Submit
- Question Randomization
- Secure Session Management
- Admin Dashboard with Analytics
- Violation Logging & Reporting
- Device Fingerprinting
- Grade Calculation
- Responsive Design

## 🛠️ Technology Stack

**Backend:**
- Java Servlets
- JSP (JavaServer Pages)
- JDBC (MySQL)

**Frontend:**
- HTML5
- CSS3
- JavaScript (ES6+)

**Server:**
- Apache Tomcat 9.x

**Database:**
- MySQL 8.x

## 📁 Project Structure

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
│   ├── index.jsp (Login)
│   ├── quiz.jsp (Quiz Interface)
│   ├── admin.jsp (Admin Dashboard)
│   ├── result.jsp (Results)
│   └── error.jsp (Error Page)
├── src/
│   └── com/quiz/
│       ├── servlets/
│       │   ├── LoginServlet.java
│       │   ├── QuizServlet.java
│       │   ├── ViolationServlet.java
│       │   ├── AdminServlet.java
│       │   └── LogoutServlet.java
│       ├── models/
│       │   ├── User.java
│       │   ├── Question.java
│       │   └── Violation.java
│       └── utils/
│           ├── Logger.java
│           ├── DatabaseConnection.java
│           ├── SessionValidator.java
│           └── DeviceDetectionHelper.java
├── database/
│   └── schema.sql
├── README.md
└── SETUP.md
```

## 🚀 Quick Start

### Prerequisites
- JDK 8+
- Apache Tomcat 9.x
- MySQL Server 8.x
- Eclipse/IntelliJ IDEA

### Installation

1. **Clone the project**
   ```bash
   cd "d:\College\Semester 5\Lab\Web Programming\Project\Anti-Malpractice"
   ```

2. **Setup Database**
   ```bash
   mysql -u root -p < database/schema.sql
   ```

3. **Configure Database**
   Edit `src/com/quiz/utils/DatabaseConnection.java`:
   ```java
   private static final String PASSWORD = "your_mysql_password";
   ```

4. **Add MySQL Driver**
   - Download MySQL Connector/J
   - Place in `WebContent/WEB-INF/lib/`

5. **Deploy to Tomcat**
   - Import project in IDE
   - Add Tomcat server
   - Run on server

6. **Access Application**
   ```
   http://localhost:8080/Anti-Malpractice
   ```

## 👤 Demo Credentials

### Student Account
- Username: `student`
- Password: `1234`

### Admin Account
- Username: `admin`
- Password: `admin123`

## 🎯 How It Works

### For Students
1. Login with credentials
2. Quiz starts automatically with monitoring
3. Answer questions within time limit
4. System monitors for malpractice
5. Auto-submit on time expiry or violation threshold
6. View results with violation report

### For Admins
1. Login to admin dashboard
2. View real-time violations
3. Monitor active quiz sessions
4. Generate reports
5. Analyze violation patterns

## 📊 Violation Types

| Type | Severity | Description |
|------|----------|-------------|
| TAB_SWITCH | CRITICAL | Student switched browser tabs |
| MULTIPLE_TABS | CRITICAL | Quiz opened in multiple tabs |
| FULLSCREEN_EXIT | CRITICAL | Exited fullscreen mode |
| DEVTOOLS_OPEN | CRITICAL | Developer tools detected |
| COPY_ATTEMPT | WARNING | Attempted to copy content |
| PASTE_ATTEMPT | WARNING | Attempted to paste content |
| SCREENSHOT_ATTEMPT | WARNING | Screenshot attempt detected |
| INACTIVITY | INFO | Inactive for extended period |

## 🔒 Security Features

- Password validation (use BCrypt in production)
- SQL injection prevention (PreparedStatements)
- XSS protection
- Secure session management
- CSRF token support (add in production)
- Input sanitization
- Secure cookies (HTTP-only)

## 📈 Future Enhancements

- [ ] Webcam-based face detection
- [ ] AI-based behavior analysis
- [ ] Email notifications for violations
- [ ] Detailed analytics dashboard
- [ ] Question bank management
- [ ] PDF report generation
- [ ] Mobile app support
- [ ] Integration with LMS
- [ ] Blockchain-based tamper-proof logs
- [ ] Video recording of quiz session

## 🐛 Troubleshooting

**Issue:** Servlets not found
- Check `web.xml` servlet mappings
- Verify package names match

**Issue:** Database connection failed
- Ensure MySQL is running
- Check credentials in DatabaseConnection.java
- Verify database exists

**Issue:** Violations not logging
- Check file permissions for WEB-INF
- Verify Logger class configuration

**Issue:** JavaScript not working
- Clear browser cache
- Check browser console for errors
- Ensure monitor.js is loaded

## 📝 Configuration

### Quiz Settings
Edit `QuizServlet.java`:
```java
int quizDuration = 30; // minutes
int violationThreshold = 5; // max violations
```

### Session Timeout
Edit `web.xml`:
```xml
<session-timeout>45</session-timeout>
```

## 🤝 Contributing

This is an academic project. Feel free to fork and enhance!

## 📄 License

Academic Project - Free to use and modify

## 👨‍💻 Author

**Your Name**
- College: [Your College Name]
- Course: Web Programming Lab (Semester 5)
- Date: October 2025

## 📧 Support

For issues or questions:
- Check SETUP.md for detailed setup
- Review Tomcat logs
- Check browser console
- Contact: [your-email@example.com]

## 🙏 Acknowledgments

- Instructors and TAs
- JSP/Servlet Documentation
- Apache Tomcat Team
- MySQL Documentation

---

**⚠️ Note:** This is a demonstration project. For production use:
- Implement proper password hashing (BCrypt)
- Add CSRF protection
- Enable HTTPS
- Use connection pooling
- Add comprehensive error handling
- Implement proper logging
- Add unit tests
- Use environment variables for configuration
