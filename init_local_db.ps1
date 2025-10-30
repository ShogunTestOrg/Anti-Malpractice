# ============================================
# Local PostgreSQL Database Initialization Script
# Database: quiz_system (localhost:5433)
# ============================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Local Database Initialization for Anti-Malpractice" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$PGHOST = "localhost"
$PGPORT = "5433"
$PGUSER = "postgres"
$PGPASSWORD = "Revanth2005"
$PGDATABASE = "quiz_system"
$SQL_FILE = "database\init_local_database.sql"

# Set environment variables for psql
$env:PGPASSWORD = $PGPASSWORD

Write-Host "Database Configuration:" -ForegroundColor Yellow
Write-Host "  Host: $PGHOST" -ForegroundColor White
Write-Host "  Port: $PGPORT" -ForegroundColor White
Write-Host "  User: $PGUSER" -ForegroundColor White
Write-Host "  Database: $PGDATABASE" -ForegroundColor White
Write-Host ""

# Check if psql is available
Write-Host "Checking PostgreSQL client..." -ForegroundColor Yellow
$psqlPath = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlPath) {
    Write-Host "❌ Error: psql command not found!" -ForegroundColor Red
    Write-Host "Please install PostgreSQL client or add it to PATH" -ForegroundColor Red
    Write-Host "Typical location: C:\Program Files\PostgreSQL\16\bin" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ PostgreSQL client found: $($psqlPath.Source)" -ForegroundColor Green
Write-Host ""

# Test connection to PostgreSQL server
Write-Host "Testing connection to PostgreSQL server..." -ForegroundColor Yellow
try {
    $testConnection = & psql -h $PGHOST -p $PGPORT -U $PGUSER -d postgres -c "SELECT version();" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully connected to PostgreSQL server" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to connect to PostgreSQL server" -ForegroundColor Red
        Write-Host "Error: $testConnection" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Connection test failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Check if database exists
Write-Host "Checking if database exists..." -ForegroundColor Yellow
$dbExists = & psql -h $PGHOST -p $PGPORT -U $PGUSER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$PGDATABASE';" 2>&1

if ($dbExists -eq "1") {
    Write-Host "⚠️  Database '$PGDATABASE' already exists" -ForegroundColor Yellow
    $response = Read-Host "Do you want to drop and recreate it? (yes/no)"
    
    if ($response -eq "yes") {
        Write-Host "Dropping existing database..." -ForegroundColor Yellow
        & psql -h $PGHOST -p $PGPORT -U $PGUSER -d postgres -c "DROP DATABASE IF EXISTS $PGDATABASE;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Existing database dropped" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to drop database" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Initialization cancelled by user" -ForegroundColor Red
        exit 0
    }
}
Write-Host ""

# Create database
Write-Host "Creating database '$PGDATABASE'..." -ForegroundColor Yellow
& psql -h $PGHOST -p $PGPORT -U $PGUSER -d postgres -c "CREATE DATABASE $PGDATABASE;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Database '$PGDATABASE' created successfully" -ForegroundColor Green
} else {
    Write-Host "⚠️  Database may already exist or creation failed" -ForegroundColor Yellow
}
Write-Host ""

# Execute initialization SQL script
Write-Host "Executing initialization script..." -ForegroundColor Yellow
Write-Host "  Script: $SQL_FILE" -ForegroundColor White

if (-not (Test-Path $SQL_FILE)) {
    Write-Host "❌ SQL file not found: $SQL_FILE" -ForegroundColor Red
    exit 1
}

# Execute the SQL script (skip database creation as it's already done)
$sqlContent = Get-Content $SQL_FILE -Raw
# Remove the CREATE DATABASE section as we already created it
$sqlContent = $sqlContent -replace "(?s)-- Drop existing database.*?CREATE DATABASE.*?CONNECTION LIMIT = -1;", ""
$sqlContent = $sqlContent -replace "\\c quiz_system", ""

# Save modified SQL to temp file
$tempSqlFile = "database\temp_init.sql"
$sqlContent | Out-File -FilePath $tempSqlFile -Encoding UTF8

& psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f $tempSqlFile 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Database initialization completed successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some errors occurred during initialization" -ForegroundColor Yellow
    Write-Host "Check the output above for details" -ForegroundColor Yellow
}

# Cleanup temp file
Remove-Item $tempSqlFile -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Database Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Query database info
& psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -c "
SELECT 'Users:' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Quizzes Master:', COUNT(*) FROM quizzes_master
UNION ALL
SELECT 'Quiz Questions:', COUNT(*) FROM quiz_questions
UNION ALL
SELECT 'Quiz Attempts:', COUNT(*) FROM quiz_attempts
UNION ALL
SELECT 'Violations:', COUNT(*) FROM violations;
" 2>&1

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Connection Details:" -ForegroundColor Yellow
Write-Host "  Database: $PGDATABASE" -ForegroundColor White
Write-Host "  Host: $PGHOST" -ForegroundColor White
Write-Host "  Port: $PGPORT" -ForegroundColor White
Write-Host "  User: $PGUSER" -ForegroundColor White
Write-Host "  Password: $PGPASSWORD" -ForegroundColor White
Write-Host ""
Write-Host "Default Credentials:" -ForegroundColor Yellow
Write-Host "  Admin: admin / admin123" -ForegroundColor White
Write-Host "  Student: student1 / student123" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. If using cloud DB, set environment variables in setenv.bat" -ForegroundColor White
Write-Host "  2. Otherwise, the app will use this local fallback database" -ForegroundColor White
Write-Host "  3. Compile and deploy to Tomcat" -ForegroundColor White
Write-Host "  4. Access: http://localhost:8080/Anti-Malpractice" -ForegroundColor White
Write-Host ""

# Clear password from environment
$env:PGPASSWORD = ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
