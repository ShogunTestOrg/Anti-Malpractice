-- ============================================
-- Local PostgreSQL Database Initialization
-- Database: quiz_system (localhost:5433)
-- User: postgres / Revanth2005
-- ============================================

-- Drop existing database if exists (optional - uncomment if needed)
-- DROP DATABASE IF EXISTS quiz_system;

-- Create database
CREATE DATABASE quiz_system
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Connect to the database
\c quiz_system

-- ============================================
-- DROP EXISTING TABLES (Clean slate)
-- ============================================

DROP TABLE IF EXISTS violations CASCADE;
DROP TABLE IF EXISTS quiz_attempts CASCADE;
DROP TABLE IF EXISTS quiz_questions CASCADE;
DROP TABLE IF EXISTS quizzes_master CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================
-- DROP EXISTING TYPES
-- ============================================

DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS question_type_enum CASCADE;
DROP TYPE IF EXISTS difficulty_level CASCADE;
DROP TYPE IF EXISTS quiz_status CASCADE;
DROP TYPE IF EXISTS violation_type_enum CASCADE;
DROP TYPE IF EXISTS severity_level CASCADE;

-- ============================================
-- CREATE CUSTOM ENUM TYPES
-- ============================================

-- User roles
CREATE TYPE user_role AS ENUM ('student', 'admin');

-- Question types
CREATE TYPE question_type_enum AS ENUM ('multiple_choice', 'numerical');

-- Difficulty levels
CREATE TYPE difficulty_level AS ENUM ('easy', 'medium', 'hard');

-- Quiz status
CREATE TYPE quiz_status AS ENUM ('in_progress', 'completed', 'auto_submitted', 'abandoned');

-- Violation types
CREATE TYPE violation_type_enum AS ENUM (
    'TAB_SWITCH',
    'COPY_ATTEMPT',
    'PASTE_ATTEMPT',
    'SCREENSHOT_ATTEMPT',
    'CONTEXT_MENU',
    'KEYBOARD_SHORTCUT',
    'MULTIPLE_TABS',
    'SUSPICIOUS_BEHAVIOR'
);

-- Severity levels
CREATE TYPE severity_level AS ENUM ('INFO', 'WARNING', 'CRITICAL');

-- ============================================
-- CREATE TABLES
-- ============================================

-- Users table (students and admins)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'student',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Quiz master templates
CREATE TABLE quizzes_master (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    time_limit INTEGER NOT NULL, -- in minutes
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    is_active BOOLEAN DEFAULT true
);

-- Quiz questions (MCQ and Numerical)
CREATE TABLE quiz_questions (
    question_id SERIAL PRIMARY KEY,
    quiz_id INTEGER REFERENCES quizzes_master(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type question_type_enum DEFAULT 'multiple_choice',
    -- MCQ Fields
    option_a VARCHAR(500),
    option_b VARCHAR(500),
    option_c VARCHAR(500),
    option_d VARCHAR(500),
    correct_option CHAR(1), -- A, B, C, or D
    -- Numerical Fields
    numerical_answer NUMERIC(10,2),
    answer_tolerance NUMERIC(10,2) DEFAULT 0,
    -- Metadata
    category VARCHAR(100),
    difficulty difficulty_level,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Quiz attempts (student quiz sessions)
CREATE TABLE quiz_attempts (
    id SERIAL PRIMARY KEY,
    quiz_id INTEGER REFERENCES quizzes_master(id),
    student_id INTEGER REFERENCES users(id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    status quiz_status DEFAULT 'in_progress',
    score INTEGER,
    percentage NUMERIC(5,2),
    total_questions INTEGER,
    time_taken INTEGER, -- in seconds
    auto_submitted BOOLEAN DEFAULT false,
    violation_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Violations log
CREATE TABLE violations (
    id SERIAL PRIMARY KEY,
    quiz_id INTEGER,
    username VARCHAR(50) NOT NULL,
    violation_type violation_type_enum NOT NULL,
    description TEXT,
    severity severity_level DEFAULT 'WARNING',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    device_info TEXT,
    ip_address INET
);

-- ============================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_quiz_questions_quiz_id ON quiz_questions(quiz_id);
CREATE INDEX idx_quiz_attempts_student_id ON quiz_attempts(student_id);
CREATE INDEX idx_quiz_attempts_quiz_id ON quiz_attempts(quiz_id);
CREATE INDEX idx_quiz_attempts_status ON quiz_attempts(status);
CREATE INDEX idx_violations_username ON violations(username);
CREATE INDEX idx_violations_quiz_id ON violations(quiz_id);
CREATE INDEX idx_violations_timestamp ON violations(timestamp);

-- ============================================
-- INSERT SAMPLE DATA
-- ============================================

-- Insert admin user (password: admin123 - use hashing in production)
INSERT INTO users (username, password_hash, role) VALUES
('admin', 'admin123', 'admin');

-- Insert sample students
INSERT INTO users (username, password_hash, role) VALUES
('student1', 'student123', 'student'),
('student2', 'student123', 'student'),
('john_doe', 'password123', 'student'),
('jane_smith', 'password123', 'student');

-- Insert sample quiz
INSERT INTO quizzes_master (title, description, time_limit, created_by) VALUES
('Sample Math Quiz', 'Basic mathematics quiz with MCQ and numerical questions', 30, 1);

-- Insert MCQ questions
INSERT INTO quiz_questions (quiz_id, question_text, question_type, option_a, option_b, option_c, option_d, correct_option, difficulty) VALUES
(1, 'What is 2 + 2?', 'multiple_choice', '3', '4', '5', '6', 'B', 'easy'),
(1, 'What is the capital of France?', 'multiple_choice', 'London', 'Berlin', 'Paris', 'Madrid', 'C', 'easy'),
(1, 'What is 10 * 5?', 'multiple_choice', '50', '40', '60', '45', 'A', 'medium');

-- Insert numerical questions
INSERT INTO quiz_questions (quiz_id, question_text, question_type, numerical_answer, answer_tolerance, difficulty) VALUES
(1, 'What is the square root of 144?', 'numerical', 12.00, 0.01, 'easy'),
(1, 'Calculate: 25 * 4', 'numerical', 100.00, 0.01, 'easy'),
(1, 'What is 3.14159 rounded to 2 decimal places?', 'numerical', 3.14, 0.01, 'medium');

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Count records
SELECT 'Users:' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Quizzes Master:', COUNT(*) FROM quizzes_master
UNION ALL
SELECT 'Quiz Questions:', COUNT(*) FROM quiz_questions
UNION ALL
SELECT 'Quiz Attempts:', COUNT(*) FROM quiz_attempts
UNION ALL
SELECT 'Violations:', COUNT(*) FROM violations;

-- Show sample data
SELECT 'Sample Users:' as info;
SELECT id, username, role FROM users;

SELECT 'Sample Quiz:' as info;
SELECT id, title, time_limit FROM quizzes_master;

SELECT 'Sample Questions:' as info;
SELECT question_id, question_type, LEFT(question_text, 50) as question_preview FROM quiz_questions;

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

GRANT ALL PRIVILEGES ON DATABASE quiz_system TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- ============================================
-- COMPLETION MESSAGE
-- ============================================

SELECT '✅ Local database initialization complete!' as status;
SELECT 'Database: quiz_system' as info
UNION ALL
SELECT 'Host: localhost:5433'
UNION ALL
SELECT 'User: postgres'
UNION ALL
SELECT 'Password: Revanth2005'
UNION ALL
SELECT 'Tables created: 5'
UNION ALL
SELECT 'Sample users: 5 (1 admin, 4 students)'
UNION ALL
SELECT 'Sample quiz: 1 with 6 questions (3 MCQ + 3 Numerical)';
