# Set your Tomcat path
$TOMCAT_HOME = "C:\Program Files\Apache Software Foundation\Tomcat 9.0"  # Replace with actual path
& "$TOMCAT_HOME\bin\shutdown.bat"

# Remove and recreate the deployment
Remove-Item -Path "$TOMCAT_HOME\webapps\Anti-Malpractice" -Recurse -Force -ErrorAction SilentlyContinue

# Wait a moment for Tomcat to detect removal
Start-Sleep -Seconds 2

# Redeploy fresh copy
New-Item -ItemType Directory -Path "$TOMCAT_HOME\webapps\Anti-Malpractice" -Force
Copy-Item -Path "WebContent\*" -Destination "$TOMCAT_HOME\webapps\Anti-Malpractice" -Recurse -Force

& "$TOMCAT_HOME\bin\startup.bat"
# Wait for Tomcat to deploy
# Start-Sleep -Seconds 3


# Open browser with cache clear
& Start-Process "http://localhost:8080/Anti-Malpractice"