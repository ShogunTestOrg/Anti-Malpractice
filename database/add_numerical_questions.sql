-- Migration script to add numerical question support
-- Run this on existing database to add new features

-- Step 1: Create new question_type ENUM if it doesn't exist
DO $$ BEGIN
    CREATE TYPE question_type AS ENUM ('multiple_choice', 'numerical');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Step 2: Add new columns to questions table
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS question_type question_type DEFAULT 'multiple_choice',
ADD COLUMN IF NOT EXISTS numerical_answer DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS answer_tolerance DECIMAL(10,2) DEFAULT 0;

-- Step 3: Make multiple choice columns nullable (for numerical questions)
ALTER TABLE questions 
ALTER COLUMN option_a DROP NOT NULL,
ALTER COLUMN option_b DROP NOT NULL,
ALTER COLUMN option_c DROP NOT NULL,
ALTER COLUMN option_d DROP NOT NULL,
ALTER COLUMN correct_answer DROP NOT NULL;

-- Step 4: Add column to quiz_answers table
ALTER TABLE quiz_answers
ADD COLUMN IF NOT EXISTS numerical_answer DECIMAL(10,2);

-- Step 5: Add columns to quiz_questions table
ALTER TABLE quiz_questions
ADD COLUMN IF NOT EXISTS question_type VARCHAR(20) DEFAULT 'multiple_choice',
ADD COLUMN IF NOT EXISTS numerical_answer DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS answer_tolerance DECIMAL(10,2) DEFAULT 0;

-- Step 6: Insert sample numerical questions
INSERT INTO questions (question_text, question_type, numerical_answer, answer_tolerance, category, difficulty) VALUES
('What is the value of π (pi) to 2 decimal places?', 'numerical', 3.14, 0.01, 'Mathematics', 'easy'),
('Calculate: 15 × 8 = ?', 'numerical', 120, 0, 'Mathematics', 'easy'),
('What is the square root of 144?', 'numerical', 12, 0, 'Mathematics', 'easy'),
('If a = 5 and b = 3, what is a² + b²?', 'numerical', 34, 0, 'Mathematics', 'medium'),
('What is 25% of 200?', 'numerical', 50, 0, 'Mathematics', 'easy'),
('Solve: 3x + 7 = 22. What is x?', 'numerical', 5, 0, 'Mathematics', 'medium'),
('What is the speed of light in vacuum (in meters per second)? Answer in scientific notation as 3.0E8', 'numerical', 300000000, 1000000, 'Science', 'hard'),
('How many degrees in a right angle?', 'numerical', 90, 0, 'Mathematics', 'easy'),
('If you invest $1000 at 5% annual interest, how much interest will you earn in one year?', 'numerical', 50, 0, 'Mathematics', 'medium'),
('What is the boiling point of water at sea level (in Celsius)?', 'numerical', 100, 0, 'Science', 'easy')
ON CONFLICT DO NOTHING;

COMMIT;
