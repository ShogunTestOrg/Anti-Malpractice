-- Fix quiz_questions table structure
\c quiz_system;

-- Drop the existing table and recreate with correct structure
DROP TABLE IF EXISTS quiz_questions CASCADE;

CREATE TABLE quiz_questions (
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

-- Re-insert sample data with correct structure
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
(4, 20, 'Who painted the Mona Lisa?', 'Michelangelo', 'Leonardo da Vinci', 'Raphael', 'Donatello', 'B');

-- Verify the fix
SELECT 'Quiz Questions Table Fixed Successfully!' as status;
SELECT COUNT(*) as total_quiz_questions FROM quiz_questions;
