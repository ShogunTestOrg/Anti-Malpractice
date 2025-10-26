# Development Notes

## Implementation Checklist

### Phase 1: Basic Setup ✅
- [x] Project structure created
- [x] web.xml configuration
- [x] JSP pages (login, quiz, admin, result)
- [x] CSS styling
- [x] JavaScript monitoring

### Phase 2: Backend Logic ✅
- [x] LoginServlet
- [x] QuizServlet
- [x] ViolationServlet
- [x] AdminServlet
- [x] LogoutServlet

### Phase 3: Models & Utils ✅
- [x] User model
- [x] Question model
- [x] Violation model
- [x] Logger utility
- [x] SessionValidator utility
- [x] DeviceDetectionHelper utility
- [x] DatabaseConnection utility

### Phase 4: Database
- [x] SQL schema created
- [ ] DAO layer implementation (optional - using file-based logging for now)
- [ ] Connection pooling (optional - for production)

### Phase 5: Testing
- [ ] Unit tests
- [ ] Integration tests
- [ ] User acceptance testing

## Known Issues & Todos

### Critical
- [ ] Add MySQL JDBC driver to lib folder
- [ ] Configure database password
- [ ] Test all violation types
- [ ] Verify auto-submit functionality

### Important
- [ ] Implement password hashing (BCrypt)
- [ ] Add CSRF protection
- [ ] Implement DAO layer for database operations
- [ ] Add email notifications
- [ ] Improve error handling

### Nice to Have
- [ ] Add webcam monitoring
- [ ] Implement AI-based detection
- [ ] Add PDF report generation
- [ ] Create admin analytics dashboard
- [ ] Add question bank management UI
- [ ] Implement answer review feature
- [ ] Add timer pause feature (for special cases)
- [ ] Create mobile-responsive design

## Code Improvements Needed

### Security
```java
// TODO: Implement password hashing
String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

// TODO: Add CSRF tokens
String csrfToken = UUID.randomUUID().toString();
session.setAttribute("csrf_token", csrfToken);

// TODO: Validate and sanitize all inputs
String sanitizedUsername = StringEscapeUtils.escapeHtml4(username);
```

### Database
```java
// TODO: Implement connection pooling
// Use HikariCP or Apache Commons DBCP

// TODO: Create DAO classes
public interface QuizDAO {
    List<Question> getAllQuestions();
    void saveQuiz(Quiz quiz);
    List<Violation> getViolations(String username);
}
```

### Error Handling
```java
// TODO: Add try-catch blocks
try {
    // database operation
} catch (SQLException e) {
    Logger.logError("Database error", e);
    response.sendRedirect("error.jsp?msg=database_error");
}
```

## Testing Scenarios

### Student Flow
1. Login → Quiz Start → Answer Questions → Submit
2. Login → Tab Switch → Violation Logged
3. Login → Copy Attempt → Prevented & Logged
4. Login → Time Expiry → Auto Submit
5. Login → 5 Violations → Auto Submit

### Admin Flow
1. Login → View Dashboard
2. View Violations Log
3. Filter by student/date
4. View statistics

### Edge Cases
- Session timeout during quiz
- Multiple simultaneous logins
- Network disconnection
- Browser crash
- Tab closed accidentally

## Performance Considerations

### Current Implementation
- File-based violation logging (simple but not scalable)
- Session-based quiz state (works for small scale)
- No caching (all questions loaded per request)

### Production Recommendations
- Use database for all data
- Implement Redis for session management
- Add caching layer for questions
- Use CDN for static resources
- Enable gzip compression
- Optimize database queries with indexes

## Browser Compatibility

Tested on:
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Edge (latest)
- [ ] Safari (latest)

## Deployment Notes

### Development
- Tomcat 9.x local server
- File-based logging
- Debug mode enabled
- No HTTPS required

### Production
- Configure HTTPS
- Use environment variables for config
- Enable production logging
- Set up monitoring (e.g., New Relic)
- Configure backup strategy
- Set up CI/CD pipeline

## Documentation

- [x] README.md
- [x] SETUP.md
- [x] PROJECT_DETAILS.md
- [x] Code comments
- [ ] API documentation (if needed)
- [ ] User manual
- [ ] Admin manual

## References

- JSP/Servlet Spec: https://jakarta.ee/specifications/servlet/
- Tomcat Docs: https://tomcat.apache.org/tomcat-9.0-doc/
- MySQL Docs: https://dev.mysql.com/doc/
- JavaScript APIs: https://developer.mozilla.org/

## Contact for Help

- Instructor: [Name]
- TA: [Name]
- Project Group: [Members]

---

Last Updated: October 26, 2025
