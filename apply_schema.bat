@echo off
echo Applying database schema...
psql -U postgres -d quiz_system -f database/schema.sql
echo Schema applied successfully!
pause
