-- Database Schema for Online Quiz Anti-Malpractice System
-- PostgreSQL

-- Create ENUM types
CREATE TYPE user_role AS ENUM ('student', 'admin');
CREATE TYPE quiz_status AS ENUM ('in_progress', 'completed', 'auto_submitted');
CREATE TYPE difficulty_level AS ENUM ('easy', 'medium', 'hard');
CREATE TYPE severity_level AS ENUM ('INFO', 'WARNING', 'CRITICAL');

-- Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- Store hashed passwords in production
    email VARCHAR(100) UNIQUE NOT NULL,
    role user_role NOT NULL DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Questions Table
CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    question_text TEXT NOT NULL,
    option_a VARCHAR(255) NOT NULL,
    option_b VARCHAR(255) NOT NULL,
    option_c VARCHAR(255) NOT NULL,
    option_d VARCHAR(255) NOT NULL,
    correct_answer INT NOT NULL, -- 0=A, 1=B, 2=C, 3=D
    difficulty difficulty_level DEFAULT 'medium',
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Quizzes Table
CREATE TABLE quizzes (
    id SERIAL PRIMARY KEY,
    quiz_id VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    duration_minutes INT DEFAULT 30,
    total_questions INT,
    score INT,
    percentage DECIMAL(5,2),
    status quiz_status DEFAULT 'in_progress',
    violation_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Quiz Answers Table
CREATE TABLE quiz_answers (
    id SERIAL PRIMARY KEY,
    quiz_id VARCHAR(50) NOT NULL,
    question_id INT NOT NULL,
    selected_answer INT,
    is_correct BOOLEAN,
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- Violations Table
CREATE TABLE violations (
    id SERIAL PRIMARY KEY,
    quiz_id VARCHAR(50) NOT NULL,
    username VARCHAR(50) NOT NULL,
    violation_type VARCHAR(50) NOT NULL,
    description TEXT,
    severity severity_level DEFAULT 'WARNING',
    ip_address VARCHAR(45),
    user_agent TEXT,
    device_fingerprint VARCHAR(255),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for violations table
CREATE INDEX idx_violations_quiz_id ON violations(quiz_id);
CREATE INDEX idx_violations_username ON violations(username);
CREATE INDEX idx_violations_timestamp ON violations(timestamp);

-- Session Logs Table
CREATE TABLE session_logs (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    quiz_id VARCHAR(50),
    action VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes for session_logs table
CREATE INDEX idx_session_logs_user_id ON session_logs(user_id);
CREATE INDEX idx_session_logs_quiz_id ON session_logs(quiz_id);

-- Insert Sample Data

-- Insert admin and student users (password: plain text for demo, use bcrypt in production)
INSERT INTO users (username, password, email, role) VALUES
('admin', 'admin123', 'admin@quiz.com', 'admin'),
('student', '1234', 'student@quiz.com', 'student'),
('john_doe', 'pass123', 'john@quiz.com', 'student'),
('jane_smith', 'pass456', 'jane@quiz.com', 'student');

-- Insert sample questions
INSERT INTO questions (question_text, option_a, option_b, option_c, option_d, correct_answer, category) VALUES
('What is the capital of France?', 'London', 'Berlin', 'Paris', 'Madrid', 2, 'Geography'),
('What is 2 + 2?', '3', '4', '5', '6', 1, 'Mathematics'),
('Which planet is known as the Red Planet?', 'Venus', 'Mars', 'Jupiter', 'Saturn', 1, 'Science'),
('What is the largest ocean on Earth?', 'Atlantic', 'Indian', 'Arctic', 'Pacific', 3, 'Geography'),
('Who wrote Romeo and Juliet?', 'Charles Dickens', 'William Shakespeare', 'Jane Austen', 'Mark Twain', 1, 'Literature'),
('What is the chemical symbol for water?', 'H2O', 'CO2', 'O2', 'NaCl', 0, 'Chemistry'),
('How many continents are there?', '5', '6', '7', '8', 2, 'Geography'),
('What is the smallest prime number?', '0', '1', '2', '3', 2, 'Mathematics'),
('Which programming language is used for Android development?', 'Python', 'Java', 'C++', 'Ruby', 1, 'Technology'),
('What year did World War II end?', '1943', '1944', '1945', '1946', 2, 'History'),
('What is the chemical symbol for water?', 'H2O', 'CO2', 'O2', 'NaCl', 0, 'Chemistry'),
('How many bones are in the human body?', '206', '208', '210', '212', 0, 'Science'),
('What gas do plants absorb from the atmosphere?', 'Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen', 2, 'Science'),
('What is the speed of light?', '299,792,458 m/s', '300,000,000 m/s', '299,000,000 m/s', '300,792,458 m/s', 0, 'Science'),
('What is the hardest natural substance?', 'Gold', 'Iron', 'Diamond', 'Platinum', 2, 'Science'),
('In which year did World War II end?', '1943', '1944', '1945', '1946', 2, 'History'),
('Who was the first President of the United States?', 'Thomas Jefferson', 'John Adams', 'George Washington', 'Benjamin Franklin', 2, 'History'),
('Which empire was ruled by Julius Caesar?', 'Greek Empire', 'Roman Empire', 'Byzantine Empire', 'Ottoman Empire', 1, 'History'),
('In which year did the Berlin Wall fall?', '1987', '1988', '1989', '1990', 2, 'History'),
('Who painted the Mona Lisa?', 'Michelangelo', 'Leonardo da Vinci', 'Raphael', 'Donatello', 1, 'Art');

-- Create Views for Reports

-- Violation Summary View
CREATE OR REPLACE VIEW violation_summary AS
SELECT 
    username,
    COUNT(*) as total_violations,
    SUM(CASE WHEN severity = 'CRITICAL' THEN 1 ELSE 0 END) as critical_count,
    SUM(CASE WHEN severity = 'WARNING' THEN 1 ELSE 0 END) as warning_count,
    MAX(timestamp) as last_violation
FROM violations
GROUP BY username;

-- Quiz Statistics View
CREATE OR REPLACE VIEW quiz_statistics AS
SELECT 
    u.username,
    COUNT(q.id) as total_quizzes,
    AVG(q.percentage) as avg_score,
    SUM(q.violation_count) as total_violations,
    MAX(q.end_time) as last_quiz_date
FROM users u
LEFT JOIN quizzes q ON u.id = q.user_id
WHERE q.status = 'completed'
GROUP BY u.username, u.id;

-- Recent Activity View
CREATE OR REPLACE VIEW recent_activity AS
SELECT 
    v.timestamp,
    v.username,
    v.quiz_id,
    v.violation_type,
    v.description,
    v.severity
FROM violations v
ORDER BY v.timestamp DESC
LIMIT 100;

-- Additional tables for admin-created quizzes (templates)
CREATE TABLE IF NOT EXISTS quizzes_master (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    time_limit INT DEFAULT 30,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quiz_questions (
    id SERIAL PRIMARY KEY,
    quiz_id INT NOT NULL REFERENCES quizzes_master(id) ON DELETE CASCADE,
    question_id INT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    option_a TEXT,
    option_b TEXT,
    option_c TEXT,
    option_d TEXT,
    correct_option CHAR(1) DEFAULT 'A',
    UNIQUE(quiz_id, question_id)
);

CREATE TABLE IF NOT EXISTS quiz_results (
    result_id SERIAL PRIMARY KEY,
    quiz_id INT REFERENCES quizzes_master(id),
    username VARCHAR(100),
    score INT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Quiz Attempts Table for tracking student quiz attempts
CREATE TABLE IF NOT EXISTS quiz_attempts (
    id SERIAL PRIMARY KEY,
    student_id INT REFERENCES users(id) ON DELETE CASCADE,
    quiz_id INT REFERENCES quizzes_master(id) ON DELETE CASCADE,
    score INT DEFAULT 0,
    percentage DECIMAL(5,2) DEFAULT 0.00,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    status VARCHAR(20) DEFAULT 'in_progress',
    violation_count INT DEFAULT 0
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_student ON quiz_attempts(student_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_start_time ON quiz_attempts(start_time);

-- Insert sample quiz templates for testing
INSERT INTO quizzes_master (title, description, time_limit) VALUES
('General Knowledge Quiz', 'A comprehensive quiz covering various topics', 30),
('Mathematics Quiz', 'Basic mathematics questions', 20),
('Science Quiz', 'Science and technology questions', 25),
('History Quiz', 'World history questions', 35)
ON CONFLICT DO NOTHING;

-- Insert sample questions for the quiz templates
INSERT INTO quiz_questions (quiz_id, question_id, question_text, option_a, option_b, option_c, option_d, correct_option) VALUES
-- General Knowledge Quiz (quiz_id = 1)
(1, 1, 'What is the capital of France?', 'London', 'Berlin', 'Paris', 'Madrid', 'C'),
(1, 2, 'What is 2 + 2?', '3', '4', '5', '6', 'B'),
(1, 3, 'Which planet is known as the Red Planet?', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'B'),
(1, 4, 'What is the largest ocean on Earth?', 'Atlantic', 'Indian', 'Arctic', 'Pacific', 'D'),
(1, 5, 'Who wrote Romeo and Juliet?', 'Charles Dickens', 'William Shakespeare', 'Jane Austen', 'Mark Twain', 'B'),

-- Mathematics Quiz (quiz_id = 2)
(2, 6, 'What is 15 + 27?', '40', '42', '41', '43', 'B'),
(2, 7, 'What is 8 × 7?', '54', '56', '58', '60', 'B'),
(2, 8, 'What is the square root of 64?', '6', '7', '8', '9', 'C'),
(2, 9, 'What is 100 ÷ 4?', '20', '25', '30', '35', 'B'),
(2, 10, 'What is 3² + 4²?', '20', '24', '25', '30', 'C'),

-- Science Quiz (quiz_id = 3)
(3, 11, 'What is the chemical symbol for water?', 'H2O', 'CO2', 'O2', 'NaCl', 'A'),
(3, 12, 'How many bones are in the human body?', '206', '208', '210', '212', 'A'),
(3, 13, 'What gas do plants absorb from the atmosphere?', 'Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen', 'C'),
(3, 14, 'What is the speed of light?', '299,792,458 m/s', '300,000,000 m/s', '299,000,000 m/s', '300,792,458 m/s', 'A'),
(3, 15, 'What is the hardest natural substance?', 'Gold', 'Iron', 'Diamond', 'Platinum', 'C'),

-- History Quiz (quiz_id = 4)
(4, 16, 'In which year did World War II end?', '1943', '1944', '1945', '1946', 'C'),
(4, 17, 'Who was the first President of the United States?', 'Thomas Jefferson', 'John Adams', 'George Washington', 'Benjamin Franklin', 'C'),
(4, 18, 'Which empire was ruled by Julius Caesar?', 'Greek Empire', 'Roman Empire', 'Byzantine Empire', 'Ottoman Empire', 'B'),
(4, 19, 'In which year did the Berlin Wall fall?', '1987', '1988', '1989', '1990', 'C'),
(4, 20, 'Who painted the Mona Lisa?', 'Michelangelo', 'Leonardo da Vinci', 'Raphael', 'Donatello', 'B')
ON CONFLICT DO NOTHING;
