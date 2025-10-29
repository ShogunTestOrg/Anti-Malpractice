# Quick Setup Guide for New Developers

## 🚀 Getting Started

After cloning this repository, follow these steps:

### 1. Configure Database Credentials

```powershell
# Copy the example file
Copy-Item setenv.bat.example setenv.bat

# Edit setenv.bat with your actual database credentials
notepad setenv.bat
```

### 2. Deploy the Application (Single Command!)

The `deploy.ps1` script does everything for you:
- ✅ Loads database credentials from setenv.bat
- ✅ Compiles all Java source files
- ✅ Stops Tomcat
- ✅ Deploys the application
- ✅ Starts Tomcat
- ✅ Opens the browser

```powershell
.\deploy.ps1
```

That's it! The script handles everything automatically.

### 3. Access the Application

The browser will open automatically, or you can manually go to:
```
http://localhost:8080/Anti-Malpractice/
```

## 📋 Default Credentials

**Admin Account:**
- Username: `admin`
- Password: `admin123`

**Student Account:**
- Username: `student`
- Password: `1234`

## ⚠️ Security Reminder

- Never commit `setenv.bat` to Git
- Keep your database credentials private
- See `SECURITY.md` for detailed security guidelines
