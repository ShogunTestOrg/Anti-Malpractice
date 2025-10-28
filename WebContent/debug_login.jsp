<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Debug Login</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        .form-group { margin: 10px 0; }
        input { padding: 8px; margin: 5px; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; }
    </style>
</head>
<body>
    <h1>Debug Login Test</h1>
    <form action="debug-login" method="post">
        <div class="form-group">
            <label>Username:</label>
            <input type="text" name="username" value="student" required>
        </div>
        <div class="form-group">
            <label>Password:</label>
            <input type="password" name="password" value="1234" required>
        </div>
        <button type="submit">Test Login</button>
    </form>
    
    <p><a href="index.jsp">Back to Normal Login</a></p>
</body>
</html>
