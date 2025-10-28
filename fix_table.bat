@echo off
echo Fixing quiz_questions table structure...
psql -U postgres -d quiz_system -c "DROP TABLE IF EXISTS quiz_questions CASCADE;"
psql -U postgres -d quiz_system -c "CREATE TABLE quiz_questions (id SERIAL PRIMARY KEY, quiz_id INT NOT NULL REFERENCES quizzes_master(id) ON DELETE CASCADE, question_id INT NOT NULL REFERENCES questions(id) ON DELETE CASCADE, question_text TEXT NOT NULL, option_a TEXT, option_b TEXT, option_c TEXT, option_d TEXT, correct_option CHAR(1) DEFAULT 'A', UNIQUE(quiz_id, question_id));"
echo Table structure fixed!
pause
