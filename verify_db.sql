-- Verify database setup
\c quiz_system;

-- Check if users table exists
SELECT table_name FROM information_schema.tables WHERE table_name = 'users';

-- Check users data
SELECT username, password, role, is_active FROM users;

-- Check if student user exists and is active
SELECT username, password, role, is_active FROM users WHERE username = 'student';

-- Check if admin user exists and is active  
SELECT username, password, role, is_active FROM users WHERE username = 'admin';
