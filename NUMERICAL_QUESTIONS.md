# Numerical Answer Questions Implementation Guide

## 📊 Overview

This document outlines the implementation of numerical answer-based questions in the Anti-Malpractice Quiz System.

## ✅ Completed Changes

### 1. Database Schema Updates

#### New ENUM Type
```sql
CREATE TYPE question_type AS ENUM ('multiple_choice', 'numerical');
```

#### Updated `questions` Table
Added fields:
- `question_type` - Type of question (multiple_choice or numerical)
- `numerical_answer` - Correct answer for numerical questions (DECIMAL)
- `answer_tolerance` - Acceptable margin of error (DECIMAL)

Made optional:
- `option_a`, `option_b`, `option_c`, `option_d` - Not needed for numerical
- `correct_answer` - Not needed for numerical

#### Updated `quiz_answers` Table
Added fields:
- `numerical_answer` - Student's numerical answer

#### Updated `quiz_questions` Table
Added fields:
- `question_type` - Type of question
- `numerical_answer` - Correct answer
- `answer_tolerance` - Acceptable margin

### 2. Question Model Enhancement

**File:** `src/com/quiz/models/Question.java`

Added properties:
- `questionType` - "multiple_choice" or "numerical"
- `numericalAnswer` - Correct numerical answer
- `answerTolerance` - Acceptable error margin

Added methods:
- `isNumerical()` - Check if question is numerical
- `isMultipleChoice()` - Check if question is multiple choice
- `checkNumericalAnswer(double answer)` - Validate answer within tolerance

### 3. Database Migration Script

**File:** `database/add_numerical_questions.sql`

Includes:
- ALTER statements to add new columns
- 10 sample numerical questions
- Safe migration (doesn't break existing data)

## 🚀 Next Steps (To Be Implemented)

### 1. Update AddQuestionServlet
**File:** `src/com/quiz/servlets/AddQuestionServlet.java`

Add handling for:
```java
String questionType = request.getParameter("question_type");
if ("numerical".equals(questionType)) {
    double numericalAnswer = Double.parseDouble(request.getParameter("numerical_answer"));
    double tolerance = Double.parseDouble(request.getParameter("answer_tolerance"));
    // Insert into database
}
```

### 2. Update add_question.jsp
**File:** `WebContent/add_question.jsp`

Add UI elements:
```html
<select id="questionType" name="question_type" onchange="toggleQuestionType()">
    <option value="multiple_choice">Multiple Choice</option>
    <option value="numerical">Numerical Answer</option>
</select>

<div id="multipleChoiceFields">
    <!-- Existing option A, B, C, D fields -->
</div>

<div id="numericalFields" style="display:none;">
    <input type="number" step="0.01" name="numerical_answer" placeholder="Correct Answer">
    <input type="number" step="0.01" name="answer_tolerance" placeholder="Tolerance (e.g., 0.1)">
</div>
```

JavaScript to toggle:
```javascript
function toggleQuestionType() {
    const type = document.getElementById('questionType').value;
    if (type === 'numerical') {
        document.getElementById('multipleChoiceFields').style.display = 'none';
        document.getElementById('numericalFields').style.display = 'block';
    } else {
        document.getElementById('multipleChoiceFields').style.display = 'block';
        document.getElementById('numericalFields').style.display = 'none';
    }
}
```

### 3. Update quiz.jsp
**File:** `WebContent/quiz.jsp`

Modify question display:
```jsp
<% if ("numerical".equals(questionType)) { %>
    <input type="number" 
           step="0.01" 
           name="answer_<%= questionId %>" 
           placeholder="Enter your answer" 
           required>
<% } else { %>
    <!-- Existing radio buttons for multiple choice -->
<% } %>
```

### 4. Update QuizServlet
**File:** `src/com/quiz/servlets/QuizServlet.java`

Add answer validation:
```java
if (question.isNumerical()) {
    String answerStr = request.getParameter("answer_" + questionId);
    double studentAnswer = Double.parseDouble(answerStr);
    isCorrect = question.checkNumericalAnswer(studentAnswer);
    
    // Save numerical answer
    pstmt.setNull(4, Types.INTEGER); // selected_answer is null
    pstmt.setDouble(5, studentAnswer); // numerical_answer
} else {
    // Existing multiple choice logic
}
```

### 5. Update CreateQuizServlet
**File:** `src/com/quiz/servlets/CreateQuizServlet.java`

Handle numerical questions when creating quiz templates:
```java
String questionType = rs.getString("question_type");
if ("numerical".equals(questionType)) {
    // Get numerical_answer and tolerance
    // Insert into quiz_questions with type
}
```

### 6. Update StartQuizServlet
**File:** `src/com/quiz/servlets/StartQuizServlet.java`

Load question type from database:
```java
question.setQuestionType(rs.getString("question_type"));
question.setNumericalAnswer(rs.getDouble("numerical_answer"));
question.setAnswerTolerance(rs.getDouble("answer_tolerance"));
```

## 📝 Sample Numerical Questions

Already added to migration script:

1. **Easy Math:**
   - What is π to 2 decimal places? (Answer: 3.14, Tolerance: ±0.01)
   - Calculate: 15 × 8 = ? (Answer: 120)
   - Square root of 144? (Answer: 12)

2. **Medium Math:**
   - If a=5, b=3, what is a² + b²? (Answer: 34)
   - 25% of 200? (Answer: 50)
   - Solve: 3x + 7 = 22. x = ? (Answer: 5)

3. **Science:**
   - Speed of light in m/s? (Answer: 300000000, Tolerance: ±1000000)
   - Boiling point of water? (Answer: 100°C)

## 🔍 Testing Checklist

- [ ] Run migration script on database
- [ ] Compile updated Question.java
- [ ] Test adding numerical questions via admin panel
- [ ] Test taking quiz with numerical questions
- [ ] Test answer validation with tolerance
- [ ] Test mixed quizzes (both types)
- [ ] Verify scoring calculation
- [ ] Test edge cases (very large/small numbers)

## 🎯 Benefits

1. **More Question Types:** Support for calculations, formulas, quantities
2. **Precise Answers:** Numbers instead of selecting from options
3. **Flexible Grading:** Tolerance allows for rounding differences
4. **Educational Value:** Better for math, science, engineering questions
5. **Anti-Cheating:** Harder to guess numerical answers

## 📊 Database Example

```sql
-- Multiple Choice Question
INSERT INTO questions (question_text, question_type, option_a, option_b, option_c, option_d, correct_answer)
VALUES ('What is 2+2?', 'multiple_choice', '3', '4', '5', '6', 1);

-- Numerical Question
INSERT INTO questions (question_text, question_type, numerical_answer, answer_tolerance)
VALUES ('What is π to 2 decimals?', 'numerical', 3.14, 0.01);
```

## 🚀 Deployment Steps

1. **Backup Database:**
   ```bash
   pg_dump -h host -U user -d quiz_system > backup.sql
   ```

2. **Run Migration:**
   ```bash
   psql -h host -U user -d quiz_system -f database/add_numerical_questions.sql
   ```

3. **Compile Java Code:**
   ```powershell
   .\deploy.ps1
   ```

4. **Test:**
   - Log in as admin
   - Add a numerical question
   - Create a quiz with mixed questions
   - Take quiz as student
   - Verify scoring

## 📚 Additional Resources

- PostgreSQL DECIMAL type: https://www.postgresql.org/docs/current/datatype-numeric.html
- HTML5 number input: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/number
- Java Double validation: https://docs.oracle.com/javase/8/docs/api/java/lang/Double.html

---

## ✅ DATABASE UPDATE COMPLETED

### Update Date: December 2024

### Verification Results:
```
✓ Connected to database
✓ question_type column exists
✓ Questions by type:
  - multiple_choice: 21
  - numerical: 10
✓ Total questions: 31
```

### Inserted Numerical Questions (IDs 22-31):
1. **ID 22**: What is the value of pi to 2 decimal places? (3.14 ±0.01)
2. **ID 23**: Calculate: 15 x 8 = ? (120 ±0)
3. **ID 24**: What is the square root of 144? (12 ±0)
4. **ID 25**: If a = 5 and b = 3, what is a^2 + b^2? (34 ±0)
5. **ID 26**: What is 25% of 200? (50 ±0)
6. **ID 27**: Solve: 3x + 7 = 22. What is x? (5 ±0)
7. **ID 28**: What is the speed of light in vacuum (x 10^8 m/s)? (3 ±0.1)
8. **ID 29**: How many degrees in a right angle? (90 ±0)
9. **ID 30**: If you invest $1000 at 5% annual interest, how much interest in dollars? (50 ±0)
10. **ID 31**: What is the boiling point of water at sea level (in Celsius)? (100 ±0)

### Scripts Created:
- `migrate_db.ps1` - Automated migration script
- `run_sql.ps1` - SQL file execution utility
- `insert_numerical.sql` - Direct insert script
- `TestNumericalQuestions.java` - Validation test
- `check_numerical.sql` - Verification queries
- `check_schema.sql` - Schema check queries

### Database Connection:
- Host: `pg-36ca7ba0-revanth-93fb.g.aivencloud.com:18574`
- Database: `quiz_system`
- Credentials: Stored in `setenv.bat` (gitignored)

---

**Status:** Database and Model Updates Complete ✅  
**Phase 1:** COMPLETE ✅  
**Phase 2:** Update Servlets and JSP Pages 🚧
