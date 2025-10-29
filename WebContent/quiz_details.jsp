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
    <title>Quiz Details - Admin Panel</title>
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
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .quiz-info {
            background: #1a1a1a;
            border: 1px solid #333333;
            border-radius: 10px;
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(255,255,255,0.05);
        }
        .quiz-title {
            font-size: 28px;
            color: #ffffff;
            margin-bottom: 10px;
        }
        .quiz-meta {
            display: flex;
            gap: 30px;
            margin-bottom: 20px;
            font-size: 14px;
            color: #b0b0b0;
        }
        .meta-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .quiz-description {
            color: #e0e0e0;
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .section {
            background: #1a1a1a;
            border: 1px solid #333333;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(255,255,255,0.05);
        }
        .section h3 {
            color: #ffffff;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #333333;
        }
        .question-item {
            background: #0a0a0a;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            border-left: 4px solid #4CAF50;
        }
        .question-text {
            font-weight: 600;
            color: #ffffff;
            margin-bottom: 15px;
        }
        .options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        .option {
            padding: 8px 12px;
            background: #1a1a1a;
            border-radius: 5px;
            border: 1px solid #444444;
            font-size: 14px;
            color: #e0e0e0;
        }
        .correct-option {
            background: #1a3d1a;
            border-color: #4CAF50;
            color: #4CAF50;
            font-weight: 600;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .stat-card {
            background: #0a0a0a;
            border: 1px solid #333333;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        .stat-number {
            font-size: 24px;
            font-weight: 600;
            color: #ffffff;
        }
        .stat-label {
            color: #b0b0b0;
            font-size: 14px;
            margin-top: 5px;
        }
        .attempts-table {
            width: 100%;
            border-collapse: collapse;
        }
        .attempts-table th,
        .attempts-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #333333;
            color: #e0e0e0;
        }
        .attempts-table th {
            background: #0a0a0a;
            color: #ffffff;
            font-weight: 600;
        }
        .attempts-table tr:hover {
            background: #2a2a2a;
        }
        .no-data {
            text-align: center;
            padding: 40px;
            color: #b0b0b0;
        }
        .btn-action {
            padding: 8px 16px;
            border: 2px solid #ffffff;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 12px;
            margin-right: 10px;
            transition: all 0.3s;
        }
        .btn-edit {
            background: #ffffff;
            color: #000000 !important;
        }
        .btn-delete {
            background: #f44336;
            color: white !important;
            border-color: #f44336;
        }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>📊 Quiz Details</h1>
            <p style="font-size: 14px; margin-top: 5px;">Welcome, <%= username %></p>
        </div>
        <div>
            <a href="available_quizzes.jsp" class="back-btn">← Back to Quizzes</a>
            <a href="logout" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <%
            // Load quiz details from database
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            String quizTitle = "";
            String quizDescription = "";
            int timeLimit = 0;
            Timestamp createdAt = null;
            int questionCount = 0;
            int attemptCount = 0;
            
            try {
                conn = DatabaseConnection.getConnection();
                
                // Get quiz basic info
                String quizInfoSql = "SELECT title, description, time_limit, created_at FROM quizzes_master WHERE id = ?";
                pstmt = conn.prepareStatement(quizInfoSql);
                pstmt.setInt(1, quizId);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    quizTitle = rs.getString("title");
                    quizDescription = rs.getString("description");
                    timeLimit = rs.getInt("time_limit");
                    createdAt = rs.getTimestamp("created_at");
                } else {
                    response.sendRedirect("available_quizzes.jsp?error=quiz_not_found");
                    return;
                }
                rs.close();
                pstmt.close();
                
                // Get question count
                String questionCountSql = "SELECT COUNT(*) FROM quiz_questions WHERE quiz_id = ?";
                pstmt = conn.prepareStatement(questionCountSql);
                pstmt.setInt(1, quizId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    questionCount = rs.getInt(1);
                }
                rs.close();
                pstmt.close();
                
                // Get attempt count
                String attemptCountSql = "SELECT COUNT(*) FROM quiz_attempts WHERE quiz_id = ?";
                pstmt = conn.prepareStatement(attemptCountSql);
                pstmt.setInt(1, quizId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    attemptCount = rs.getInt(1);
                }
                rs.close();
                pstmt.close();
                
        %>
        
        <div class="quiz-info">
            <div class="quiz-title"><%= quizTitle %></div>
            <div class="quiz-meta">
                <div class="meta-item">
                    <span>⏱️</span>
                    <span><%= timeLimit %> minutes</span>
                </div>
                <div class="meta-item">
                    <span>❓</span>
                    <span><%= questionCount %> questions</span>
                </div>
                <div class="meta-item">
                    <span>👥</span>
                    <span><%= attemptCount %> attempts</span>
                </div>
                <div class="meta-item">
                    <span>📅</span>
                    <span><%= new SimpleDateFormat("MMM dd, yyyy").format(createdAt) %></span>
                </div>
            </div>
            <div class="quiz-description">
                <%= quizDescription != null ? quizDescription : "No description available" %>
            </div>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number"><%= questionCount %></div>
                <div class="stat-label">Total Questions</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= attemptCount %></div>
                <div class="stat-label">Total Attempts</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= timeLimit %></div>
                <div class="stat-label">Time Limit (min)</div>
            </div>
        </div>
        
        <div class="section">
            <h3>Quiz Questions</h3>
            <%
                if (questionCount > 0) {
                    String questionsSql = "SELECT question_text, option_a, option_b, option_c, option_d, correct_option " +
                                        "FROM quiz_questions WHERE quiz_id = ? ORDER BY question_id ASC";
                    pstmt = conn.prepareStatement(questionsSql);
                    pstmt.setInt(1, quizId);
                    rs = pstmt.executeQuery();
                    
                    int questionNum = 1;
                    while (rs.next()) {
                        String questionText = rs.getString("question_text");
                        String optionA = rs.getString("option_a");
                        String optionB = rs.getString("option_b");
                        String optionC = rs.getString("option_c");
                        String optionD = rs.getString("option_d");
                        String correctOption = rs.getString("correct_option");
            %>
            <div class="question-item">
                <div class="question-text">Q<%= questionNum %>. <%= questionText %></div>
                <div class="options">
                    <div class="option <%= "A".equals(correctOption) ? "correct-option" : "" %>">
                        A. <%= optionA %>
                    </div>
                    <div class="option <%= "B".equals(correctOption) ? "correct-option" : "" %>">
                        B. <%= optionB %>
                    </div>
                    <div class="option <%= "C".equals(correctOption) ? "correct-option" : "" %>">
                        C. <%= optionC %>
                    </div>
                    <div class="option <%= "D".equals(correctOption) ? "correct-option" : "" %>">
                        D. <%= optionD %>
                    </div>
                </div>
            </div>
            <%
                        questionNum++;
                    }
                } else {
            %>
            <div class="no-data">No questions found for this quiz.</div>
            <%
                }
            %>
        </div>
        
        <div class="section">
            <h3>Recent Attempts</h3>
            <%
                String attemptsSql = "SELECT u.username, qa.score, qa.percentage, qa.start_time, qa.end_time, qa.status " +
                                   "FROM quiz_attempts qa " +
                                   "JOIN users u ON qa.student_id = u.id " +
                                   "WHERE qa.quiz_id = ? " +
                                   "ORDER BY qa.start_time DESC LIMIT 10";
                pstmt = conn.prepareStatement(attemptsSql);
                pstmt.setInt(1, quizId);
                rs = pstmt.executeQuery();
                
                boolean hasAttempts = false;
            %>
            <table class="attempts-table">
                <thead>
                    <tr>
                        <th>Student</th>
                        <th>Score</th>
                        <th>Percentage</th>
                        <th>Start Time</th>
                        <th>End Time</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        while (rs.next()) {
                            hasAttempts = true;
                            String studentUsername = rs.getString("username");
                            int score = rs.getInt("score");
                            double percentage = rs.getDouble("percentage");
                            Timestamp startTime = rs.getTimestamp("start_time");
                            Timestamp endTime = rs.getTimestamp("end_time");
                            String status = rs.getString("status");
                            
                            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, HH:mm");
                    %>
                    <tr>
                        <td><%= studentUsername %></td>
                        <td><%= score %>/<%= questionCount %></td>
                        <td><%= String.format("%.1f", percentage) %>%</td>
                        <td><%= sdf.format(startTime) %></td>
                        <td><%= endTime != null ? sdf.format(endTime) : "-" %></td>
                        <td><%= status %></td>
                    </tr>
                    <%
                        }
                        
                        if (!hasAttempts) {
                    %>
                    <tr>
                        <td colspan="6" class="no-data">No attempts recorded yet.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
        
        <%
            } catch (Exception e) {
                e.printStackTrace();
        %>
        <div class="section">
            <h3>Error</h3>
            <div class="no-data">Error loading quiz details: <%= e.getMessage() %></div>
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
</body>
</html>
