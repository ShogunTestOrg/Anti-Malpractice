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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create New Quiz - Admin Panel</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #000000;
            color: #e0e0e0;
        }
        .header {
            background: #1a1a1a;
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #333333;
        }
        .header h1 {
            font-size: 24px;
        }
        .back-btn {
            background: #ffffff;
            color: #000000 !important;
            padding: 10px 20px;
            border: 2px solid #ffffff;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            margin-right: 10px;
            transition: all 0.3s;
        }
        .back-btn:hover {
            background: #f0f0f0;
            box-shadow: 0 4px 12px rgba(255,255,255,0.3);
        }
        .logout-btn {
            background: #f44336;
            color: white;
            padding: 10px 20px;
            border: 2px solid #f44336;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s;
        }
        .logout-btn:hover {
            background: #e53935;
            box-shadow: 0 4px 12px rgba(244, 67, 54, 0.3);
        }
        .container {
            max-width: 1000px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .form-container {
            background: #1a1a1a;
            border: 1px solid #333333;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(255,255,255,0.05);
        }
        .form-container h2 {
            color: #ffffff;
            margin-bottom: 20px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #ffffff;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #444444;
            border-radius: 5px;
            font-size: 14px;
            background: #0a0a0a;
            color: #e0e0e0;
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
        .questions-section {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #333333;
        }
        .questions-section h3 {
            color: #ffffff;
            margin-bottom: 15px;
        }
        .questions-section p {
            color: #b0b0b0;
        }
        .question-list {
            max-height: 300px;
            overflow-y: auto;
            border: 1px solid #444444;
            border-radius: 5px;
            padding: 10px;
            background: #0a0a0a;
        }
        .question-item {
            display: flex;
            align-items: center;
            padding: 10px;
            border-bottom: 1px solid #333333;
        }
        .question-item:last-child {
            border-bottom: none;
        }
        .question-item input[type="checkbox"] {
            margin-right: 10px;
            transform: scale(1.2);
        }
        .question-text {
            flex: 1;
            font-size: 14px;
            color: #e0e0e0;
        }
        .question-category {
            font-size: 12px;
            color: #b0b0b0;
            margin-left: 10px;
        }
        .btn-submit {
            background: #ffffff;
            color: #000000 !important;
            padding: 15px 30px;
            border: 2px solid #ffffff;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
            transition: all 0.3s;
        }
        .btn-submit:hover {
            background: #f0f0f0;
            box-shadow: 0 4px 12px rgba(255,255,255,0.3);
        }
        .error-message {
            background: #3d1a1a;
            color: #ff6b6b;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #f44336;
        }
        .success-message {
            background: #1a3d1a;
            color: #4CAF50;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #4CAF50;
        }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>📝 Create New Quiz</h1>
            <p style="font-size: 14px; margin-top: 5px;">Welcome, <%= username %></p>
        </div>
        <div>
            <a href="admin.jsp" class="back-btn">← Back to Dashboard</a>
            <a href="logout" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="form-container">
            <h2>Quiz Information</h2>
            
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
            
            <form action="create-quiz" method="POST">
                <div class="form-row">
                    <div class="form-group">
                        <label for="title">Quiz Title *</label>
                        <input type="text" id="title" name="title" required>
                    </div>
                    <div class="form-group">
                        <label for="time_limit">Duration (minutes) *</label>
                        <input type="number" id="time_limit" name="time_limit" min="1" max="180" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" placeholder="Enter a brief description of the quiz..."></textarea>
                </div>
                
                <div class="questions-section">
                    <h3>Select Questions</h3>
                    <p style="color: #7f8c8d; margin-bottom: 15px;">Choose questions from the existing question bank:</p>
                    
                    <div class="question-list">
                        <%
                            // Load questions from database
                            Connection conn = null;
                            PreparedStatement pstmt = null;
                            ResultSet rs = null;
                            
                            try {
                                conn = DatabaseConnection.getConnection();
                                
                                String sql = "SELECT id, question_text, category FROM questions ORDER BY category, id";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                boolean hasQuestions = false;
                                while (rs.next()) {
                                    hasQuestions = true;
                                    int questionId = rs.getInt("id");
                                    String questionText = rs.getString("question_text");
                                    String category = rs.getString("category");
                        %>
                        <div class="question-item">
                            <input type="checkbox" id="question_<%= questionId %>" name="selected_questions" value="<%= questionId %>">
                            <label for="question_<%= questionId %>" class="question-text">
                                <%= questionText %>
                                <span class="question-category">[<%= category != null ? category : "General" %>]</span>
                            </label>
                        </div>
                        <%
                                }
                                
                                if (!hasQuestions) {
                        %>
                        <div style="text-align: center; padding: 20px; color: #b0b0b0;">
                            No questions available. Please add questions to the question bank first.
                        </div>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                        <div style="text-align: center; padding: 20px; color: #ff6b6b;">
                            Error loading questions: <%= e.getMessage() %>
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
                
                <button type="submit" class="btn-submit">Create Quiz</button>
            </form>
        </div>
    </div>
    
    <script>
        // Form validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const selectedQuestions = document.querySelectorAll('input[name="selected_questions"]:checked');
            if (selectedQuestions.length === 0) {
                e.preventDefault();
                alert('Please select at least one question for the quiz.');
                return false;
            }
            
            const title = document.getElementById('title').value.trim();
            const timeLimit = document.getElementById('time_limit').value;
            
            if (!title) {
                e.preventDefault();
                alert('Please enter a quiz title.');
                return false;
            }
            
            if (!timeLimit || timeLimit < 1) {
                e.preventDefault();
                alert('Please enter a valid time limit (minimum 1 minute).');
                return false;
            }
        });
        
        // Select all questions checkbox
        function toggleAllQuestions() {
            const checkboxes = document.querySelectorAll('input[name="selected_questions"]');
            const selectAll = document.getElementById('selectAll');
            checkboxes.forEach(checkbox => {
                checkbox.checked = selectAll.checked;
            });
        }
    </script>
</body>
</html>