```mermaid
erDiagram
    users {
        int id PK
        varchar username UK
        varchar password_hash
        user_role role "ENUM('student', 'admin')"
        boolean is_active
        timestamp created_at
        timestamp last_login
    }

    quizzes_master {
        int id PK
        varchar title
        text description
        int time_limit "in minutes"
        timestamp created_at
        int created_by FK
        boolean is_active
    }

    quiz_questions {
        int question_id PK
        int quiz_id FK
        text question_text
        question_type_enum question_type "ENUM('multiple_choice', 'numerical')"
        varchar option_a
        varchar option_b
        varchar option_c
        varchar option_d
        char correct_option "A, B, C, or D"
        numeric numerical_answer
        numeric answer_tolerance
        varchar category
        difficulty_level difficulty "ENUM('easy', 'medium', 'hard')"
        timestamp created_at
    }

    quiz_attempts {
        int id PK
        int quiz_id FK
        int student_id FK
        timestamp start_time
        timestamp end_time
        quiz_status status "ENUM('in_progress', 'completed', 'auto_submitted', 'abandoned')"
        int score
        numeric percentage
        int total_questions
        int time_taken "in seconds"
        boolean auto_submitted
        int violation_count
        timestamp created_at
    }

    violations {
        int id PK
        int quiz_id FK
        varchar username
        violation_type_enum violation_type "ENUM('TAB_SWITCH', 'COPY_ATTEMPT', etc.)"
        text description
        severity_level severity "ENUM('INFO', 'WARNING', 'CRITICAL')"
        timestamp timestamp
        text device_info
        inet ip_address
    }

    users ||--o{ quizzes_master : "creates"
    users ||--o{ quiz_attempts : "takes"
    users ||--o{ violations : "commits"
    
    quizzes_master ||--o{ quiz_questions : "contains"
    quizzes_master ||--o{ quiz_attempts : "has_attempts"
    
    quiz_attempts ||--o{ violations : "logs"

```

## Database Schema Overview

### Key Relationships:
- **Users** create **Quizzes Master** (Admin role)
- **Users** take **Quiz Attempts** (Student role)
- **Quizzes Master** contains **Quiz Questions** (1-to-many)
- **Quizzes Master** has **Quiz Attempts** (1-to-many)
- **Quiz Attempts** logs **Violations** (1-to-many)
- **Users** commit **Violations** during quiz attempts

### Custom ENUM Types:
- `user_role`: student, admin
- `question_type_enum`: multiple_choice, numerical
- `difficulty_level`: easy, medium, hard
- `quiz_status`: in_progress, completed, auto_submitted, abandoned
- `violation_type_enum`: TAB_SWITCH, COPY_ATTEMPT, PASTE_ATTEMPT, SCREENSHOT_ATTEMPT, CONTEXT_MENU, KEYBOARD_SHORTCUT, MULTIPLE_TABS, SUSPICIOUS_BEHAVIOR
- `severity_level`: INFO, WARNING, CRITICAL