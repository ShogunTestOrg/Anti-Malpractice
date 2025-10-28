<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Online Quiz System</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0;
        }
        .login-container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            width: 400px;
        }
        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: 500;
        }
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            box-sizing: border-box;
        }
        input[type="text"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: #667eea;
        }
        .btn-login {
            width: 100%;
            padding: 12px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.3s;
        }
        .btn-login:hover {
            background: #5568d3;
        }
        .error-message {
            color: #e74c3c;
            text-align: center;
            margin-top: 15px;
            font-size: 14px;
        }
        .info-box {
            background: #f0f8ff;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            border-left: 4px solid #667eea;
        }
        .info-box h4 {
            margin: 0 0 10px 0;
            color: #667eea;
        }
        .info-box p {
            margin: 5px 0;
            font-size: 12px;
            color: #666;
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
        
        <div class="info-box" style="margin-top: 10px; background: #fff3cd; border-left-color: #ffc107;">
            <h4>Demo Credentials</h4>
            <p><strong>Student:</strong> student / 1234</p>
            <p><strong>Admin:</strong> admin / admin123</p>
        </div>
    </div>
</body>
</html>
