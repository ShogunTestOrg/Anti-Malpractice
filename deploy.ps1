##############################################################################
# Anti-Malpractice Quiz System - Complete Build & Deploy Script
# This script handles: Environment setup, Compilation, and Deployment
##############################################################################

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Anti-Malpractice Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$TOMCAT_HOME = "C:\Program Files\Apache Software Foundation\Tomcat 9.0"
$PROJECT_ROOT = $PSScriptRoot
$SRC_DIR = "$PROJECT_ROOT\src"
$CLASSES_DIR = "$PROJECT_ROOT\WebContent\WEB-INF\classes"
$LIB_DIR = "$PROJECT_ROOT\WebContent\WEB-INF\lib"
$TOMCAT_LIB = "$TOMCAT_HOME\lib"
$APP_NAME = "Anti-Malpractice"

##############################################################################
# Step 1: Load Environment Variables from setenv.bat
##############################################################################
Write-Host "[1/6] Loading database credentials..." -ForegroundColor Yellow

if (Test-Path "$PROJECT_ROOT\setenv.bat") {
    Write-Host "  ✓ Found setenv.bat, loading credentials..." -ForegroundColor Green
    
    # Parse setenv.bat and set environment variables
    Get-Content "$PROJECT_ROOT\setenv.bat" | ForEach-Object {
        if ($_ -match '^set\s+([^=]+)=(.+)$') {
            $varName = $matches[1].Trim()
            $varValue = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($varName, $varValue, "Process")
            Write-Host "  ✓ Set $varName" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  ⚠ WARNING: setenv.bat not found!" -ForegroundColor Yellow
    Write-Host "  Using default/fallback database configuration" -ForegroundColor Yellow
    Write-Host "  Copy setenv.bat.example to setenv.bat and configure it" -ForegroundColor Yellow
}
Write-Host ""

##############################################################################
# Step 2: Create Classes Directory
##############################################################################
Write-Host "[2/6] Preparing build directories..." -ForegroundColor Yellow

if (!(Test-Path $CLASSES_DIR)) {
    New-Item -ItemType Directory -Path $CLASSES_DIR -Force | Out-Null
    Write-Host "  ✓ Created classes directory" -ForegroundColor Green
} else {
    Write-Host "  ✓ Classes directory exists" -ForegroundColor Green
}
Write-Host ""

##############################################################################
# Step 3: Compile Java Source Files
##############################################################################
Write-Host "[3/6] Compiling Java source files..." -ForegroundColor Yellow

# Build classpath
$CLASSPATH = "$TOMCAT_LIB\servlet-api.jar;$LIB_DIR\postgresql-42.7.8.jar"

# Get all Java files
$javaFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.java" -Recurse

if ($javaFiles.Count -eq 0) {
    Write-Host "  ✗ ERROR: No Java files found in src directory!" -ForegroundColor Red
    exit 1
}

Write-Host "  Found $($javaFiles.Count) Java files to compile" -ForegroundColor Cyan

# Compile
$javaFilePaths = ($javaFiles.FullName | ForEach-Object { "`"$_`"" }) -join " "
$compileCommand = "javac -d `"$CLASSES_DIR`" -cp `"$CLASSPATH`" -encoding UTF-8 $javaFilePaths"

try {
    $output = cmd /c $compileCommand 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Compilation successful!" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Compilation failed!" -ForegroundColor Red
        if ($output) { Write-Host $output -ForegroundColor Red }
        exit 1
    }
} catch {
    Write-Host "  ✗ Compilation error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

##############################################################################
# Step 4: Stop Tomcat
##############################################################################
Write-Host "[4/6] Stopping Tomcat server..." -ForegroundColor Yellow

try {
    & "$TOMCAT_HOME\bin\shutdown.bat" 2>&1 | Out-Null
    Write-Host "  ✓ Tomcat shutdown initiated" -ForegroundColor Green
    Start-Sleep -Seconds 3
} catch {
    Write-Host "  ⚠ Tomcat may not be running" -ForegroundColor Yellow
}
Write-Host ""

##############################################################################
# Step 5: Deploy Application
##############################################################################
Write-Host "[5/6] Deploying application to Tomcat..." -ForegroundColor Yellow

# Remove old deployment
$deployPath = "$TOMCAT_HOME\webapps\$APP_NAME"
if (Test-Path $deployPath) {
    Remove-Item -Path $deployPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  ✓ Removed old deployment" -ForegroundColor Green
}

# Wait for cleanup
Start-Sleep -Seconds 2

# Deploy new version
New-Item -ItemType Directory -Path $deployPath -Force | Out-Null
Copy-Item -Path "WebContent\*" -Destination $deployPath -Recurse -Force
Write-Host "  ✓ Copied application files to Tomcat" -ForegroundColor Green

# Copy setenv.bat to Tomcat bin (optional, for automatic loading)
if (Test-Path "$PROJECT_ROOT\setenv.bat") {
    Copy-Item -Path "$PROJECT_ROOT\setenv.bat" -Destination "$TOMCAT_HOME\bin\setenv.bat" -Force
    Write-Host "  ✓ Copied setenv.bat to Tomcat bin directory" -ForegroundColor Green
}
Write-Host ""

##############################################################################
# Step 6: Start Tomcat
##############################################################################
Write-Host "[6/6] Starting Tomcat server..." -ForegroundColor Yellow

& "$TOMCAT_HOME\bin\startup.bat"
Write-Host "  ✓ Tomcat startup initiated" -ForegroundColor Green
Write-Host ""

##############################################################################
# Wait and Open Browser
##############################################################################
Write-Host "Waiting for application to deploy..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Application URL: http://localhost:8080/$APP_NAME" -ForegroundColor Cyan
Write-Host ""
Write-Host "Opening browser..." -ForegroundColor Cyan
Start-Process "http://localhost:8080/$APP_NAME"

Write-Host ""
Write-Host "Deployment Summary:" -ForegroundColor Yellow
Write-Host "  • Source files compiled: $($javaFiles.Count)" -ForegroundColor White
Write-Host "  • Deployment location: $deployPath" -ForegroundColor White
Write-Host "  • Environment variables: " -NoNewline -ForegroundColor White
if (Test-Path "$PROJECT_ROOT\setenv.bat") {
    Write-Host "Loaded" -ForegroundColor Green
} else {
    Write-Host "Using defaults" -ForegroundColor Yellow
}
Write-Host ""