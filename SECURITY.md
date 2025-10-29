# Database Security Setup

## ⚠️ IMPORTANT: Securing Database Credentials

This project uses environment variables to keep database credentials secure and out of version control.

## Setup Instructions

### Method 1: Using setenv.bat (Windows - Recommended for Tomcat)

1. Copy `setenv.bat.example` to `setenv.bat`:
   ```powershell
   Copy-Item setenv.bat.example setenv.bat
   ```

2. Edit `setenv.bat` with your actual database credentials:
   ```batch
   set DB_URL=jdbc:postgresql://your-host:port/database_name?sslmode=require
   set DB_USERNAME=your_username
   set DB_PASSWORD=your_password
   ```

3. Run the batch file before starting Tomcat:
   ```powershell
   .\setenv.bat
   ```

4. Or copy `setenv.bat` to your Tomcat `bin` directory (Tomcat will automatically load it)

### Method 2: System Environment Variables (Windows)

1. Open System Properties → Advanced → Environment Variables
2. Add the following User or System variables:
   - `DB_URL`: Your database JDBC URL
   - `DB_USERNAME`: Your database username
   - `DB_PASSWORD`: Your database password

### Method 3: Using .env file (Alternative)

1. Copy `.env.example` to `.env`:
   ```powershell
   Copy-Item .env.example .env
   ```

2. Edit `.env` with your actual credentials

3. Use a library like `dotenv-java` to load environment variables from `.env` file

## Environment Variables Required

| Variable | Description | Example |
|----------|-------------|---------|
| `DB_URL` | JDBC connection URL | `jdbc:postgresql://host:port/dbname?sslmode=require` |
| `DB_USERNAME` | Database username | `admin` |
| `DB_PASSWORD` | Database password | `your_secure_password` |

## Default Fallback Values

If environment variables are not set, the application falls back to local development defaults:
- URL: `jdbc:postgresql://localhost:5432/quiz_system`
- Username: `postgres`
- Password: `` (empty)

## Security Best Practices

✅ **DO:**
- Use environment variables for credentials
- Keep `setenv.bat` and `.env` files local (not in Git)
- Use `.gitignore` to exclude credential files
- Share `.example` files to show required configuration
- Use different credentials for development and production

❌ **DON'T:**
- Commit actual credentials to Git
- Share credential files via email/chat
- Use production credentials in development
- Hardcode credentials in source code

## Files Excluded from Git

These files are automatically ignored by `.gitignore`:
- `setenv.bat` (actual credentials)
- `.env` (actual credentials)
- `database.properties` (if used)

## Files Included in Git (Safe)

These template files are safe to commit:
- `setenv.bat.example` (example template)
- `.env.example` (example template)
- `SECURITY.md` (this file)

## For Team Members

When cloning this repository:
1. Copy the `.example` files to create your local configuration
2. Fill in your own database credentials
3. Never commit the actual credential files

## Production Deployment

For production:
- Use secure secret management (Azure Key Vault, AWS Secrets Manager, etc.)
- Use managed identity/IAM roles when possible
- Rotate credentials regularly
- Use SSL/TLS connections (sslmode=require)
- Limit database user permissions to minimum required
