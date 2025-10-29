<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.io.*, java.sql.*, java.text.*" %>
<%@ page import="com.quiz.utils.DatabaseConnection" %>
<%
    // Check admin session
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    if (username == null || !"admin".equals(role)) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }
    
    String quizIdParam = request.getParameter("id");
    if (quizIdParam == null || quizIdParam.trim().isEmpty()) {
        response.sendRedirect("available_quizzes.jsp?error=invalid_quiz");
        return;
    }
    
    int quizId = 0;
    try {
        quizId = Integer.parseInt(quizIdParam);
    } catch (NumberFormatException e) {
        response.sendRedirect("available_quizzes.jsp?error=invalid_quiz");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Quiz - Admin Panel</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f6fa;
        }
        .header {
            background: #2c3e50;
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header h1 {
            font-size: 24px;
        }
        .back-btn {
            background: #3498db;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            margin-right: 10px;
        }
        .logout-btn {
            background: #e74c3c;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
        }
        .container {
            max-width: 1000px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .form-container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #2c3e50;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .form-group textarea {
            height: 80px;
            resize: vertical;
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .btn-submit {
            background: #27ae60;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        .btn-submit:hover {
            background: #229954;
        }
        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .success-message {
            background: #e8f5e9;
            color: #2e7d32;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .info-message {
            background: #e3f2fd;
            color: #1565c0;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>✏️ Edit Quiz</h1>
            <p style="font-size: 14px; margin-top: 5px;">Welcome, <%= username %></p>
        </div>
        <div>
            <a href="available_quizzes.jsp" class="back-btn">← Back to Quizzes</a>
            <a href="logout" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="form-container">
            <%
                String error = request.getParameter("error");
                String success = request.getParameter("success");
                if (error != null) {
            %>
            <div class="error-message">
                <%= error %>
            </div>
            <%
                }
                if (success != null) {
            %>
            <div class="success-message">
                <%= success %>
            </div>
            <%
                }
            %>
            
            <div class="info-message">
                <strong>Note:</strong> Quiz editing functionality is currently under development. 
                For now, you can view quiz details or delete and recreate quizzes.
            </div>
            
            <%
                // Load quiz details from database
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = DatabaseConnection.getConnection();
                    
                    String sql = "SELECT title, description, time_limit FROM quizzes_master WHERE id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, quizId);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        String title = rs.getString("title");
                        String description = rs.getString("description");
                        int timeLimit = rs.getInt("time_limit");
            %>
            
            <h2>Quiz Information</h2>
            <form action="edit-quiz" method="POST">
                <input type="hidden" name="quiz_id" value="<%= quizId %>">
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="title">Quiz Title *</label>
                        <input type="text" id="title" name="title" value="<%= title %>" required>
                    </div>
                    <div class="form-group">
                        <label for="time_limit">Duration (minutes) *</label>
                        <input type="number" id="time_limit" name="time_limit" value="<%= timeLimit %>" min="1" max="180" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" placeholder="Enter a brief description of the quiz..."><%= description != null ? description : "" %></textarea>
                </div>
                
                <button type="submit" class="btn-submit">Update Quiz</button>
            </form>
            
            <%
                    } else {
            %>
            <div class="error-message">
                Quiz not found.
            </div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
            %>
            <div class="error-message">
                Error loading quiz: <%= e.getMessage() %>
            </div>
            <%
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>
        </div>
    </div>
</body>
</html>
