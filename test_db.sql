-- Test database connection and data
\c quiz_system;

-- Check if users table exists and has data
SELECT COUNT(*) as user_count FROM users;

-- Check specific user data
SELECT username, password, role, is_active FROM users WHERE username IN ('student', 'admin');

-- Check if the student user exists and is active
SELECT username, password, role, is_active FROM users WHERE username = 'student' AND is_active = true;
