<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Quiz System</title>
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
        .error-container {
            background: #1a1a1a;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.5);
            text-align: center;
            max-width: 500px;
            border: 2px solid #e74c3c;
        }
        .error-icon {
            font-size: 72px;
            margin-bottom: 20px;
        }
        h1 {
            color: #e74c3c;
            margin-bottom: 15px;
        }
        p {
            color: #e0e0e0;
            margin-bottom: 25px;
            line-height: 1.6;
        }
        .btn-home {
            background: #ffffff;
            color: #000;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: background 0.3s;
        }
        .btn-home:hover {
            background: #e0e0e0;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">❌</div>
        <h1>Oops! Something went wrong</h1>
        <p>
            <%= request.getAttribute("javax.servlet.error.status_code") != null 
                ? "Error " + request.getAttribute("javax.servlet.error.status_code") 
                : "An unexpected error occurred" %>
        </p>
        <p>
            <%= request.getAttribute("javax.servlet.error.message") != null 
                ? request.getAttribute("javax.servlet.error.message") 
                : "Please try again or contact support if the problem persists." %>
        </p>
        <a href="index.jsp" class="btn-home">Go to Home</a>
    </div>
</body>
</html>
