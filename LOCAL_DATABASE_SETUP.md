# Local PostgreSQL Database Setup

## Fallback Database Configuration

The application uses a fallback local PostgreSQL database when environment variables are not set:

- **Host:** localhost
- **Port:** 5433
- **Database:** quiz_system
- **Username:** postgres
- **Password:** Revanth2005

## Quick Setup Instructions

### Option 1: Automated Setup (Recommended)

Run the PowerShell script:
```powershell
.\init_local_db.ps1
```

This script will:
1. Check PostgreSQL client installation
2. Test connection to PostgreSQL server
3. Create the `quiz_system` database
4. Initialize all tables and sample data
5. Display database summary

### Option 2: Manual Setup

#### Step 1: Create Database
```bash
psql -h localhost -p 5433 -U postgres -c "CREATE DATABASE quiz_system;"
```

#### Step 2: Initialize Tables
```bash
psql -h localhost -p 5433 -U postgres -d quiz_system -f database\init_local_tables.sql
```

### Option 3: Using pgAdmin

1. Open pgAdmin
2. Connect to localhost:5433 with user `postgres`
3. Right-click on "Databases" → Create → Database
4. Name it `quiz_system`
5. Open Query Tool on the new database
6. Load and execute `database\init_local_tables.sql`

## Database Schema

### Tables Created:
1. **users** - Student and admin accounts
2. **quizzes_master** - Quiz templates
3. **quiz_questions** - Question bank (MCQ + Numerical)
4. **quiz_attempts** - Student quiz sessions
5. **violations** - Violation audit log

### Custom ENUM Types:
- `user_role` - student, admin
- `question_type_enum` - multiple_choice, numerical
- `difficulty_level` - easy, medium, hard
- `quiz_status` - in_progress, completed, auto_submitted, abandoned
- `violation_type_enum` - TAB_SWITCH, COPY_ATTEMPT, etc.
- `severity_level` - INFO, WARNING, CRITICAL

## Sample Data Included

### Default Users:
- **Admin:** admin / admin123
- **Students:**
  - student1 / student123
  - student2 / student123
  - john_doe / password123
  - jane_smith / password123

### Sample Quiz:
- 1 quiz: "Sample Math Quiz" (30 minutes)
- 3 MCQ questions
- 3 Numerical questions

## Switching Between Local and Cloud Database

### Use Local Database (Fallback):
Simply don't set environment variables. The application will automatically use:
```
localhost:5433/quiz_system
```

### Use Cloud Database (Aiven):
Set environment variables by running:
```powershell
.\setenv.bat
```

This sets:
- `DB_URL` - Cloud database URL
- `DB_USERNAME` - Cloud username
- `DB_PASSWORD` - Cloud password

## Verification

After setup, verify the database:

```bash
# Connect to database
psql -h localhost -p 5433 -U postgres -d quiz_system

# Check tables
\dt

# Count records
SELECT 'Users' as table_name, COUNT(*) FROM users
UNION ALL SELECT 'Quizzes', COUNT(*) FROM quizzes_master
UNION ALL SELECT 'Questions', COUNT(*) FROM quiz_questions;

# Exit
\q
```

## Troubleshooting

### Issue: Connection refused
**Solution:** Make sure PostgreSQL server is running on port 5433
```bash
# Check PostgreSQL service
Get-Service -Name postgresql*

# Start if stopped
Start-Service postgresql-x64-16
```

### Issue: Database already exists
**Solution:** Drop and recreate
```bash
psql -h localhost -p 5433 -U postgres -c "DROP DATABASE quiz_system;"
psql -h localhost -p 5433 -U postgres -c "CREATE DATABASE quiz_system;"
psql -h localhost -p 5433 -U postgres -d quiz_system -f database\init_local_tables.sql
```

### Issue: psql command not found
**Solution:** Add PostgreSQL bin to PATH
```
C:\Program Files\PostgreSQL\16\bin
```

### Issue: Password authentication failed
**Solution:** Update password in `DatabaseConnection.java` and this README

## Notes

- This is a **fallback configuration** for local development
- For production, always use cloud database with environment variables
- Never commit real passwords to Git
- Use password hashing (BCrypt) in production instead of plain text
- The fallback port 5433 avoids conflicts with default PostgreSQL port 5432

## Files

- `database/init_local_tables.sql` - Table creation and sample data
- `init_local_db.ps1` - Automated setup script
- `src/com/quiz/utils/DatabaseConnection.java` - Connection utility with fallback
