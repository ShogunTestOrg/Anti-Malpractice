# Changelog

All notable changes to the Online Quiz Anti-Malpractice Detection System.

## [1.0.0] - 2025-10-26

### Added
- **Initial Release** of Anti-Malpractice Detection System
- Complete JSP/Servlet architecture
- PostgreSQL database integration with custom ENUM types
- Real-time violation detection and logging
- Auto-submit functionality at violation threshold

### Features

#### Authentication & Authorization
- Login system with session management
- User roles (student, admin)
- Session validation on all protected pages
- Logout functionality with session cleanup

#### Quiz System
- Question randomization
- 10 questions per quiz
- 30-minute time limit with countdown
- Answer tracking in session
- Score calculation
- Quiz status tracking (in_progress, completed, auto_submitted)

#### Anti-Malpractice Detection
- **Tab Switch Detection**
  - Monitors visibilitychange events
  - Intelligent grace period (waits for page load)
  - Form submission detection to prevent false positives
  - Single violation per tab switch (no duplicates)
- **Copy/Paste/Cut Prevention**
  - Blocks all clipboard operations
  - Shows warning modal on attempt
- **Right-Click Disable**
  - Prevents context menu access
  - Logs violation attempt
- **Screenshot Detection**
  - Detects Print Screen key
  - Blocks Ctrl+Shift+S shortcuts
- **Violation Cooldown**
  - 3-second debouncing per violation type
  - Prevents duplicate logging

#### Auto-Submit Feature
- Triggers at 5 violations
- Shows countdown modal (3 seconds)
- Disables form inputs
- Automatic quiz submission
- Marks quiz as 'auto_submitted' in database

#### User Interface
- Modern purple gradient design
- Responsive layout
- Custom styled modals (replaces browser alerts)
- Progress bar and question counter
- Real-time violation counter
- Timer with color-coded warnings
- Smooth animations and transitions

#### Admin Dashboard
- Real-time statistics from database
- Active quiz sessions monitoring
- Violation logs with severity indicators
- Recent activity tracking
- Dynamic data updates

#### Database
- PostgreSQL schema with custom ENUMs
- Three main tables: users, quizzes, violations
- ENUM types: user_role, quiz_status, severity_level
- Proper CAST implementation for ENUM inserts
- Timestamp tracking for all activities

### Technical Implementation

#### Backend (Java)
- **LoginServlet**: Authentication and session creation
- **QuizServlet**: Quiz logic, navigation, and submission
- **ViolationServlet**: REST endpoint for violation logging
- **AdminServlet**: Dashboard data aggregation
- **LogoutServlet**: Session termination
- **DatabaseConnection**: PostgreSQL connection pool
- **Logger**: Violation logging with ENUM casting
- **SessionValidator**: Security validation utility

#### Frontend (JavaScript)
- **QuizMonitor Class**: Main monitoring system
  - Constructor with configuration
  - Event listener setup
  - Violation logging with debouncing
  - Tab switch detection with grace period
  - Form submission monitoring
  - Auto-submit with countdown
  - Custom modal system
  - Timer implementation

#### Database Schema
```sql
CREATE TYPE user_role AS ENUM ('student', 'admin');
CREATE TYPE quiz_status AS ENUM ('in_progress', 'completed', 'auto_submitted');
CREATE TYPE severity_level AS ENUM ('INFO', 'WARNING', 'CRITICAL');

CREATE TABLE users (...);
CREATE TABLE quizzes (...);
CREATE TABLE violations (...);
```

### Fixed Issues

#### PostgreSQL ENUM Casting
- **Problem**: "column is of type X but expression is of type character varying"
- **Solution**: Added `CAST(? AS enum_type)` to all INSERT/UPDATE statements
- **Affected Files**: QuizServlet.java, Logger.java

#### Tab Switch False Positives
- **Problem**: Tab switches detected during page navigation
- **Solution**: 
  1. Added dynamic grace period based on window.load event
  2. Disabled monitoring during form submission
  3. Re-enabled after page fully loads
- **Result**: Zero false positives during normal navigation

#### Duplicate Tab Switch Violations
- **Problem**: Leaving AND returning to tab both logged violations
- **Solution**: Added `isTabHidden` state flag to track current tab visibility
- **Result**: Only one violation per actual tab switch

#### Form Navigation Issues
- **Problem**: Navigation parameter not sent during form submission
- **Solution**: Added hidden input dynamically on form submit
- **Affected Files**: quiz.jsp

#### Slow Network Handling
- **Problem**: Fixed grace period insufficient for slow connections
- **Solution**: Dynamic monitoring based on page load completion
- **Benefit**: Works on any network speed

### Configuration
- Violation threshold: 5
- Violation cooldown: 3 seconds
- Quiz duration: 30 minutes
- Auto-submit delay: 3 seconds
- Grace period: Dynamic (load + 1s)

### Dependencies
- JDK 17
- Apache Tomcat 9.0
- PostgreSQL 8.x
- postgresql-42.7.8.jar (JDBC driver)

### Security
- PreparedStatements (SQL injection prevention)
- Session validation on all requests
- Password hashing ready (BCrypt recommended)
- ENUM type safety
- XSS protection in JSP

### Deployment
- PowerShell deployment script (deploy.ps1)
- Automatic Tomcat restart
- Compiled classes in WEB-INF/classes
- PostgreSQL on port 5433

### Known Limitations
- Browser-based screenshot detection (limited)
- No video proctoring
- No AI behavior analysis
- Single quiz format (no quiz creation interface)
- Hardcoded test questions

### Future Roadmap
- [ ] AI-based behavior analysis
- [ ] Video proctoring with webcam
- [ ] Face recognition
- [ ] Mobile app support
- [ ] Quiz creation interface for admins
- [ ] Email notifications
- [ ] Advanced analytics
- [ ] Export reports (PDF/Excel)
- [ ] LMS integration
- [ ] Multi-language support

---

## Development Timeline

**Week 1**: Initial setup and database design
**Week 2**: Authentication and basic quiz functionality
**Week 3**: Anti-malpractice detection implementation
**Week 4**: UI enhancements and custom modals
**Week 5**: Bug fixes and optimization
**Week 6**: Testing and documentation

---

## Version History

- **v1.0.0** (2025-10-26): Initial stable release with all core features

---

## Contributors
- Primary Developer: [Student Name]
- Institution: [College Name]
- Course: Web Programming Lab (Semester 5)
- Supervisor: [Faculty Name]

---

## License
Academic Project - October 2025
