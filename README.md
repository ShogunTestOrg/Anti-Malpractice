# Online Quiz Anti-Malpractice Detection System

## Overview
A comprehensive web application built with JSP and Servlets to monitor and prevent malpractice during online quizzes. Features real-time violation detection, automatic quiz submission, PostgreSQL database integration, support for both Multiple Choice and Numerical answer questions, and a modern dark theme interface.

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

### Question Types
- **Multiple Choice Questions (MCQ)** - Traditional 4-option questions with radio button selection
- **Numerical Answer Questions** - Direct numerical input with answer tolerance support
- **Mixed Quizzes** - Combine both MCQ and numerical questions in a single quiz
- **Answer Tolerance** - Configure acceptable answer ranges for numerical questions (e.g., π ± 0.01)

### User Interface
- **Modern Dark Theme** - Black background with white buttons for better readability
- **Responsive Layout** - Mobile-friendly design
- **Conditional Rendering** - Shows appropriate input type (radio buttons or number input) based on question type
- **Progress Tracking** - Visual progress bar and question counter
- **Timer Display** - Countdown timer with warnings at 5 and 1 minute
- **Violation Counter** - Real-time display of current violations
- **Admin Dashboard** - Dark-themed admin panel with real-time statistics

### Database Integration
- **PostgreSQL Database** with custom ENUM types
- **Question Type Support** - ENUM('multiple_choice', 'numerical')
- **Numerical Answer Storage** - NUMERIC fields for precise decimal handling
- **Answer Tolerance** - Configurable tolerance for numerical validation
- **Persistent Violation Logging** - All violations stored with timestamp and severity
- **Quiz Result Tracking** - Complete quiz history with scores and status
- **Real-time Statistics** - Dynamic admin dashboard with live data

## Tech Stack
- **Backend**: Java Servlets, JSP
- **Database**: PostgreSQL (Aiven Cloud Hosted) with JDBC Driver (postgresql-42.7.8.jar)
- **Server**: Apache Tomcat 9.0
- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Security**: PreparedStatements, Session validation, ENUM type casting

## Project Structure
```
Anti-Malpractice/
├── WebContent/
│   ├── index.jsp              (Login page)
│   ├── quiz.jsp               (Quiz interface with monitoring & question type support)
│   ├── result.jsp             (Quiz results page)
│   ├── admin.jsp              (Admin dashboard)
│   ├── add_question.jsp       (Add new questions - MCQ or Numerical)
│   ├── available_quizzes.jsp  (View all quizzes)
│   ├── create_quiz.jsp        (Create new quiz)
│   ├── edit_quiz.jsp          (Edit existing quiz)
│   ├── quiz_details.jsp       (View quiz details)
│   ├── student_quizzes.jsp    (Student quiz list)
│   ├── error.jsp              (Error page)
│   ├── css/
│   │   ├── style.css          (Main styling)
│   │   └── dark-theme-overrides.css (Dark theme)
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
│       │   ├── QuizServlet.java       (Quiz logic, navigation & answer validation)
│       │   ├── StartQuizServlet.java  (Quiz initialization & question loading)
│       │   ├── AddQuestionServlet.java (Add MCQ/Numerical questions)
│       │   ├── ViolationServlet.java  (Violation logging endpoint)
│       │   ├── AdminServlet.java      (Admin dashboard)
│       │   └── LogoutServlet.java     (Session cleanup)
│       ├── models/
│       │   ├── Question.java          (Question model with numerical support)
│       │   ├── User.java              (User model)
│       │   └── QuizResult.java        (Quiz result model)
│       └── utils/
│           ├── Logger.java            (Violation logger with ENUM casting)
│           ├── DatabaseConnection.java (PostgreSQL connection)
│           └── SessionValidator.java   (Session security)
├── database/
│   ├── schema.sql             (PostgreSQL schema with ENUM types & numerical support)
│   ├── add_numerical_questions.sql (Sample numerical questions)
│   └── clear_database.sql     (Reset database)
└── setenv.bat.example         (Example database configuration)
```

## Database Schema

### Tables
- **users** - User accounts (id, username, password_hash, role, is_active, created_at)
- **quizzes_master** - Quiz templates (id, title, description, time_limit, created_at)
- **quiz_questions** - Questions with type support (question_id, quiz_id, question_text, question_type, option_a/b/c/d, correct_option, numerical_answer, answer_tolerance)
- **quiz_attempts** - Quiz sessions (id, quiz_id, student_id, start_time, end_time, status, score, percentage)
- **violations** - Violation logs (id, quiz_id, username, violation_type, description, severity, timestamp)

### Custom ENUM Types
- **user_role**: 'student', 'admin'
- **quiz_status**: 'in_progress', 'completed', 'auto_submitted'
- **severity_level**: 'INFO', 'WARNING', 'CRITICAL'
- **question_type**: 'multiple_choice', 'numerical'

## Setup Instructions

### Prerequisites
- JDK 17 or higher
- Apache Tomcat 9.0
- PostgreSQL database access (cloud or local)
- IDE (VS Code, Eclipse, or IntelliJ IDEA)

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd Anti-Malpractice
   ```

2. **Setup Database Configuration**
   - Copy `setenv.bat.example` to `setenv.bat`
   - Edit `setenv.bat` with your PostgreSQL credentials:
     ```bat
     set DB_URL=jdbc:postgresql://your-host:port/quiz_system?sslmode=require
     set DB_USERNAME=your_username
     set DB_PASSWORD=your_password
     ```
   - **IMPORTANT**: Never commit `setenv.bat` to Git (already in .gitignore)

3. **Setup PostgreSQL Database**
   - Run the schema file to create database structure:
     ```bash
     psql -U your_username -h your_host -p port -d quiz_system -f database/schema.sql
     ```
   - (Optional) Add sample numerical questions:
     ```bash
     psql -U your_username -h your_host -p port -d quiz_system -f database/add_numerical_questions.sql
     ```

4. **Compile Java Classes**
   Use the PowerShell compilation script or compile manually:
   ```powershell
   # Compile servlets
   javac -d "WebContent\WEB-INF\classes" -cp "WebContent\WEB-INF\lib\*;$env:CATALINA_HOME\lib\servlet-api.jar" src\com\quiz\servlets\*.java
   
   # Compile utilities
   javac -d "WebContent\WEB-INF\classes" -cp "WebContent\WEB-INF\lib\*;$env:CATALINA_HOME\lib\servlet-api.jar;WebContent\WEB-INF\classes" src\com\quiz\utils\*.java
   
   # Compile models
   javac -d "WebContent\WEB-INF\classes" -cp "WebContent\WEB-INF\lib\*;$env:CATALINA_HOME\lib\servlet-api.jar" src\com\quiz\models\*.java
   ```

5. **Deploy to Tomcat**
   - Ensure `setenv.bat` is in Tomcat's `bin` directory (or run it before starting Tomcat)
   - Copy the entire `Anti-Malpractice` folder to Tomcat's `webapps` directory
   - Restart Tomcat

6. **Access Application**
   - URL: `http://localhost:8080/Anti-Malpractice`
   - Default Student Login: student/1234
   - Default Admin Login: admin/admin123

## Configuration

### Anti-Malpractice Settings (monitor.js)
- **Violation Threshold**: 5 (auto-submit)
- **Violation Cooldown**: 3000ms (3 seconds)
- **Grace Period**: Dynamic (waits for page load + 1 second)
- **Auto-Submit Delay**: 3 seconds after threshold reached

### Quiz Settings (QuizServlet.java)
- **Quiz Duration**: 30 minutes (1800 seconds)
- **Number of Questions**: Configurable per quiz
- **Question Types**: Multiple Choice and/or Numerical
- **Question Shuffle**: Enabled
- **Answer Tolerance**: Default 0, configurable per question

### Database Connection
- Configured via environment variables in `setenv.bat`
- Uses PostgreSQL JDBC Driver
- SSL mode: require (for cloud databases)
- Connection pooling: Not implemented (use for production)

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
- Dark theme for better visibility

### 6. Question Type Support
- **Multiple Choice**: Radio button selection with 4 options
- **Numerical**: Number input field with decimal support
- **Answer Validation**: 
  - MCQ: Exact match with correct_option
  - Numerical: Range check with tolerance (answer ± tolerance)
- **Mixed Quizzes**: Seamless combination in single quiz session

### 7. Dark Theme UI
- Black (`#000000`) background for reduced eye strain
- White (`#ffffff`) buttons for high contrast
- Consistent across all pages (student and admin)
- Smooth hover effects and transitions
- Color-coded status indicators (green for pass, red for fail)

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
- [ ] Admin login works
- [ ] Quiz starts and loads questions
- [ ] MCQ questions display with radio buttons
- [ ] Numerical questions display with number input
- [ ] Tab switch detection (after page loads)
- [ ] Copy/paste prevention
- [ ] Right-click disabled
- [ ] Navigation (Next/Previous) works
- [ ] MCQ answer submission
- [ ] Numerical answer validation with tolerance
- [ ] Auto-submit at 5 violations
- [ ] Manual quiz submission
- [ ] Results page displays correctly with score
- [ ] Violations stored in database
- [ ] Admin dashboard shows live data
- [ ] Add question (MCQ) works
- [ ] Add question (Numerical) works
- [ ] Create quiz works
- [ ] View quiz details works
- [ ] No false violations during navigation
- [ ] Dark theme consistent across all pages

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
1. Verify PostgreSQL is accessible from your network
2. Check credentials in `setenv.bat`
3. Ensure database `quiz_system` exists
4. Test connection: `psql -U username -h host -p port -d quiz_system`
5. Verify SSL settings if using cloud database

### Numerical Question Issues
1. Ensure question_type ENUM includes 'numerical'
2. Check numerical_answer and answer_tolerance fields exist
3. Verify proper CAST usage in SQL: `CAST(? AS question_type)`
4. Check Question.java has isNumerical() and checkNumericalAnswer() methods

### Deployment Issues
1. Verify `setenv.bat` is executed before Tomcat starts
2. Check Tomcat logs in `CATALINA_HOME/logs/catalina.out`
3. Ensure WebContent folder structure is correct
4. Clear Tomcat work directory if needed: `CATALINA_HOME/work`
5. Verify environment variables: DB_URL, DB_USERNAME, DB_PASSWORD

## Contributing
This is an academic project. Feel free to fork and enhance!

## License
Academic Project - Free to use and modify for educational purposes

## Authors
- Student Project
- Course: Web Programming Lab (Semester 5)
- Date: October 2025

## Important Security Notes
- **Never commit** `setenv.bat` with real credentials
- Use `setenv.bat.example` as a template
- Store production credentials securely (environment variables, secrets manager)
- Implement proper password hashing (BCrypt recommended)
- Use HTTPS in production
- Implement rate limiting for login attempts

## Acknowledgments
- Apache Tomcat Documentation
- PostgreSQL Documentation
- MDN Web Docs for JavaScript APIs
- Stack Overflow community
