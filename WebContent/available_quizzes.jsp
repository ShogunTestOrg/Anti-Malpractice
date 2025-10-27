<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.quiz.utils.DatabaseConnection, com.quiz.utils.SessionValidator" %>
<%
    if (!SessionValidator.isValidSession(session)) {
        response.sendRedirect("index.jsp?error=session");
        return;
    }

    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("index.jsp?error=session");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Available Quizzes</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Available Quizzes</h1>
            <p class="welcome-msg">Welcome, <%= username %>! Choose a quiz to begin.</p>
            <a href="logout" class="btn btn-secondary">Logout</a>
        </div>

        <div class="quiz-grid">
            <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                try {
                    conn = DatabaseConnection.getConnection();
                    String sql = "SELECT m.id, m.title, m.description, m.time_limit, m.created_at, " +
                                 "COUNT(q.question_id) AS qcount, " +
                                 "COUNT(DISTINCT r.username) AS attempt_count, " +
                                 "COALESCE(AVG(r.score), 0) AS avg_score " +
                                 "FROM quizzes_master m " +
                                 "LEFT JOIN quiz_questions q ON m.id = q.quiz_id " +
                                 "LEFT JOIN quiz_results r ON m.id = r.quiz_id " +
                                 "GROUP BY m.id, m.title, m.description, m.time_limit, m.created_at " +
                                 "ORDER BY m.created_at DESC";
                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();
                    while (rs.next()) {
                        int id = rs.getInt("id");
                        String title = rs.getString("title");
                        String desc = rs.getString("description");
                        int timeLimit = rs.getInt("time_limit");
                        int qcount = rs.getInt("qcount");
                        int attempts = rs.getInt("attempt_count");
                        double avgScore = rs.getDouble("avg_score");
            %>
                        <div class="quiz-card">
                            <div class="quiz-title"><%= title %></div>
                            <div class="quiz-desc"><%= desc %></div>
                            <div class="quiz-meta">
                                <span>⏱️ <%= timeLimit %> min</span>
                                <span>📝 <%= qcount %> questions</span>
                                <% if (attempts > 0) { %>
                                    <span>📊 Avg: <%= String.format("%.1f", avgScore) %>%</span>
                                <% } %>
                            </div>
                            <a href="quiz?action=start&quizId=<%= id %>" class="start-quiz-btn">Start Quiz →</a>
                        </div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<div class='alert alert-danger'>Error loading quizzes: " + e.getMessage() + "</div>");
                } finally {
                    try { if (rs != null) rs.close(); if (pstmt != null) pstmt.close(); if (conn != null) conn.close(); } catch (SQLException ignored) {}
                }
            %>
        </div>
    </div>
</body>
</html>
