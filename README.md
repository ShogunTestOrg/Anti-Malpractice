# Online Quiz Anti-Malpractice Detection System

## Overview
A comprehensive web application built with JSP and Servlets to monitor and prevent malpractice during online quizzes. Features real-time violation detection, automatic quiz submission, and PostgreSQL database integration for persistent tracking.

## Features

### Core Anti-Malpractice Measures
1. **Tab Switch Detection** - Monitors and logs when students switch tabs with intelligent grace period
2. **Copy-Paste Prevention** - Blocks all copy/paste/cut operations
3. **Right-Click Disable** - Prevents context menu access
4. **Screenshot Detection** - Detects Print Screen and screenshot shortcuts
5. **Auto-Submit on Violations** - Automatically submits quiz after reaching violation threshold (5 violations)
6. **Custom In-Page Modals** - Professional styled dialogs instead of browser alerts
7. **Violation Cooldown** - 3-second debouncing to prevent duplicate violations
8. **Form Submission Monitoring** - Disables monitoring during page navigation to prevent false positives

### Database Integration
- **PostgreSQL Database** with custom ENUM types
- **Persistent Violation Logging** - All violations stored with timestamp and severity
- **Quiz Result Tracking** - Complete quiz history with scores and status
- **Real-time Statistics** - Dynamic admin dashboard with live data

### User Interface
- **Modern Gradient Design** - Purple gradient theme with smooth animations
- **Responsive Layout** - Mobile-friendly design
- **Progress Tracking** - Visual progress bar and question counter
- **Timer Display** - Countdown timer with warnings at 5 and 1 minute
- **Violation Counter** - Real-time display of current violations

## Tech Stack
- **Backend**: Java Servlets, JSP
- **Database**: PostgreSQL 8.x with JDBC Driver (postgresql-42.7.8.jar)
- **Server**: Apache Tomcat 9.0
- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Security**: PreparedStatements, Session validation, ENUM type casting

## Project Structure
```
Anti-Malpractice/
├── WebContent/
│   ├── index.jsp              (Login page)
│   ├── quiz.jsp               (Quiz interface with monitoring)
│   ├── result.jsp             (Quiz results page)
│   ├── admin.jsp              (Admin dashboard)
│   ├── css/
│   │   └── style.css          (Styling)
│   ├── js/
│   │   └── monitor.js         (Client-side monitoring - QuizMonitor class)
│   └── WEB-INF/
│       ├── web.xml            (Servlet configuration)
│       ├── classes/           (Compiled Java classes)
│       └── lib/
│           └── postgresql-42.7.8.jar
├── src/
│   └── com/quiz/
│       ├── servlets/
│       │   ├── LoginServlet.java      (Authentication)
│       │   ├── QuizServlet.java       (Quiz logic & navigation)
│       │   ├── ViolationServlet.java  (Violation logging endpoint)
│       │   ├── AdminServlet.java      (Admin dashboard)
│       │   └── LogoutServlet.java     (Session cleanup)
│       ├── models/
│       │   ├── Question.java          (Question model)
│       │   └── User.java              (User model - optional)
│       └── utils/
│           ├── Logger.java            (Violation logger with ENUM casting)
│           ├── DatabaseConnection.java (PostgreSQL connection)
│           └── SessionValidator.java   (Session security)
├── database/
│   └── schema.sql             (PostgreSQL schema with ENUM types)
└── deploy.ps1                 (PowerShell deployment script)
```

## Database Schema

### Tables
- **users** - User accounts (id, username, password_hash, role)
- **quizzes** - Quiz sessions (quiz_id, user_id, start_time, end_time, status, score)
- **violations** - Violation logs (id, quiz_id, username, violation_type, description, severity, timestamp)

### Custom ENUM Types
- **user_role**: 'student', 'admin'
- **quiz_status**: 'in_progress', 'completed', 'auto_submitted'
- **severity_level**: 'INFO', 'WARNING', 'CRITICAL'

## Setup Instructions

### Prerequisites
- JDK 17 or higher
- Apache Tomcat 9.0
- PostgreSQL 8.x or higher (running on port 5433)
- IDE (VS Code, Eclipse, or IntelliJ IDEA)

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd Anti-Malpractice
   ```

2. **Setup PostgreSQL Database**
   ```bash
   psql -U postgres -p 5433 -f database/schema.sql
   ```
   - Default credentials: postgres/Revanth2005
   - Database name: quiz_system

3. **Configure Database Connection**
   - Update `src/com/quiz/utils/DatabaseConnection.java` with your credentials
   - Default: localhost:5433, database: quiz_system

4. **Compile Java Classes**
   ```powershell
   javac -d "WebContent\WEB-INF\classes" -cp "WebContent\WEB-INF\lib\*;$TOMCAT_HOME\lib\servlet-api.jar" src\com\quiz\servlets\*.java
   javac -d "WebContent\WEB-INF\classes" -cp "WebContent\WEB-INF\lib\*;$TOMCAT_HOME\lib\servlet-api.jar;WebContent\WEB-INF\classes" src\com\quiz\utils\*.java
   javac -d "WebContent\WEB-INF\classes" -cp "WebContent\WEB-INF\lib\*;$TOMCAT_HOME\lib\servlet-api.jar" src\com\quiz\models\*.java
   ```

5. **Deploy to Tomcat**
   ```powershell
   .\deploy.ps1
   ```
   Or manually copy the `WebContent` folder to Tomcat's `webapps` directory

6. **Access Application**
   - URL: `http://localhost:8080/Anti-Malpractice`
   - Student Login: student/1234
   - Admin Login: admin/admin123

## Configuration

### Anti-Malpractice Settings (monitor.js)
- **Violation Threshold**: 5 (auto-submit)
- **Violation Cooldown**: 3000ms (3 seconds)
- **Grace Period**: Dynamic (waits for page load + 1 second)
- **Auto-Submit Delay**: 3 seconds after threshold reached

### Quiz Settings (QuizServlet.java)
- **Quiz Duration**: 30 minutes (1800 seconds)
- **Number of Questions**: 10 (randomized)
- **Question Shuffle**: Enabled

### Database Connection (DatabaseConnection.java)
- **Host**: localhost
- **Port**: 5433
- **Database**: quiz_system
- **User**: postgres
- **Password**: Revanth2005

## Key Features Explained

### 1. Tab Switch Detection
- Monitors `visibilitychange` event
- Grace period prevents false positives during page load
- Disables monitoring during form submission
- Tracks state with `isTabHidden` flag
- Logs to database with CRITICAL severity

### 2. Violation Auto-Submit
- Triggers at 5 violations
- Shows custom modal with countdown
- Disables form inputs to prevent further interaction
- Submits with `autoSubmit=true` flag
- Quiz marked as 'auto_submitted' in database

### 3. Custom Modals
- Replaces browser alerts/confirms
- Three types: confirm, warning, alert
- Color-coded buttons (green/red/gray)
- Smooth slideDown animation
- Backdrop overlay with click-to-close

### 4. PostgreSQL ENUM Casting
- Uses `CAST(? AS enum_type)` for INSERT/UPDATE
- Required for quiz_status, user_role, severity_level
- Prevents "column is of type X but expression is of type character varying" errors

### 5. Admin Dashboard
- Real-time statistics from database
- Active quiz sessions with JOIN queries
- Violation monitoring with severity indicators
- Recent violations with username lookup

## Security Features
- **SQL Injection Prevention**: PreparedStatements throughout
- **Session Validation**: SessionValidator checks on every request
- **XSS Protection**: Input sanitization in JSP
- **Password Storage**: Hashed with BCrypt (recommended)
- **ENUM Type Safety**: PostgreSQL ENUM prevents invalid values

## Known Issues & Solutions

### Issue: Tab Switch on Navigation
**Solution**: Implemented form submission detection that disables monitoring during page transitions

### Issue: PostgreSQL ENUM Type Errors
**Solution**: Added explicit CAST for all ENUM columns in SQL statements

### Issue: Slow Network Loading
**Solution**: Dynamic monitoring activation based on `window.load` event instead of fixed grace period

## Testing Checklist

- [ ] Student login works
- [ ] Quiz starts and loads questions
- [ ] Tab switch detection (after page loads)
- [ ] Copy/paste prevention
- [ ] Right-click disabled
- [ ] Navigation (Next/Previous) works
- [ ] Auto-submit at 5 violations
- [ ] Manual quiz submission
- [ ] Results page displays correctly
- [ ] Violations stored in database
- [ ] Admin dashboard shows live data
- [ ] No false violations during navigation

## Future Enhancements
- [ ] AI-based behavior analysis
- [ ] Video proctoring with webcam
- [ ] Mobile app support
- [ ] Integration with LMS platforms (Moodle, Canvas)
- [ ] Email notifications for violations
- [ ] Blockchain-based tamper-proof logs
- [ ] Face recognition for identity verification
- [ ] Advanced analytics dashboard
- [ ] Export reports to PDF/Excel

## Troubleshooting

### Database Connection Issues
1. Verify PostgreSQL is running on port 5433
2. Check credentials in DatabaseConnection.java
3. Ensure database `quiz_system` exists
4. Test connection: `psql -U postgres -p 5433 -d quiz_system`

### Compilation Errors
1. Ensure servlet-api.jar is in Tomcat's lib directory
2. Don't include servlet-api.jar in WEB-INF/lib (causes conflicts)
3. Check Java version compatibility (JDK 17)

### Deployment Issues
1. Verify Tomcat is running
2. Check logs in `TOMCAT_HOME/logs/catalina.out`
3. Ensure WebContent folder structure is correct
4. Clear Tomcat work directory if needed

## Contributing
This is an academic project. Feel free to fork and enhance!

## License
Academic Project - Free to use and modify for educational purposes

## Authors
- Student Project
- Course: Web Programming Lab (Semester 5)
- Date: October 26, 2025

## Acknowledgments
- Apache Tomcat Documentation
- PostgreSQL Documentation
- MDN Web Docs for JavaScript APIs
- Stack Overflow community
