<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Online Quiz System</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a1a 0%, #000000 100%);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0;
        }
        .login-container {
            background: #1a1a1a;
            border: 1px solid #333333;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(255,255,255,0.1);
            width: 400px;
        }
        h2 {
            text-align: center;
            color: #ffffff;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #e0e0e0;
            font-weight: 500;
        }
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #444444;
            border-radius: 5px;
            font-size: 14px;
            box-sizing: border-box;
            background: #0a0a0a;
            color: #e0e0e0;
        }
        input[type="text"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: #ffffff;
            box-shadow: 0 0 0 2px rgba(255,255,255,0.1);
        }
        .btn-login {
            width: 100%;
            padding: 12px;
            background: #ffffff;
            color: #000000;
            border: 2px solid #ffffff;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-login:hover {
            background: #f0f0f0;
            box-shadow: 0 4px 12px rgba(255,255,255,0.3);
        }
        .error-message {
            color: #ff6b6b;
            text-align: center;
            margin-top: 15px;
            font-size: 14px;
            background: #330000;
            padding: 10px;
            border-radius: 5px;
        }
        .info-box {
            background: #0d47a1;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            border-left: 4px solid #1976d2;
        }
        .info-box h4 {
            margin: 0 0 10px 0;
            color: #64b5f6;
        }
        .info-box p {
            margin: 5px 0;
            font-size: 12px;
            color: #bbdefb;
        }
        .demo-box {
            background: #e65100;
            padding: 15px;
            border-radius: 5px;
            margin-top: 10px;
            border-left: 4px solid #ff9800;
        }
        .demo-box h4 {
            margin: 0 0 10px 0;
            color: #ffcc80;
        }
        .demo-box p {
            margin: 5px 0;
            font-size: 12px;
            color: #ffe0b2;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>🎓 Online Quiz System</h2>
        <form action="login" method="post">
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required autocomplete="off">
            </div>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit" class="btn-login">Login</button>
        </form>
        
        <% 
            String error = request.getParameter("error");
            if (error != null) { 
        %>
            <div class="error-message">
                <%
                    if ("invalid".equals(error)) {
                        out.println("Invalid username or password!");
                    } else if ("unauthorized".equals(error)) {
                        out.println("Access denied. Please login with appropriate credentials.");
                    } else if ("session".equals(error)) {
                        out.println("Session expired. Please login again.");
                    } else {
                        out.println("Please login to continue.");
                    }
                %>
            </div>
        <% } %>
        
        <div class="info-box">
            <h4>⚠️ Important Notice</h4>
            <p>• Do not switch tabs during the quiz</p>
            <p>• Copy-paste is disabled</p>
            <p>• Your activity is being monitored</p>
            <p>• Violations will be logged and reported</p>
        </div>
        
        <div class="demo-box">
            <h4>Demo Credentials</h4>
            <p><strong>Student:</strong> student / 1234</p>
            <p><strong>Admin:</strong> admin / admin123</p>
        </div>
    </div>
</body>
</html>
