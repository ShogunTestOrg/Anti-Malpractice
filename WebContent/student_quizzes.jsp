<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.io.*, java.sql.*, java.text.*" %>
<%@ page import="com.quiz.utils.DatabaseConnection" %>
<%
    // Check student session
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    if (username == null || !"student".equals(role)) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Quizzes - Student Portal</title>
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
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .welcome-section {
            background: white;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .welcome-section h2 {
            color: #2c3e50;
            margin-bottom: 10px;
        }
        .welcome-section p {
            color: #7f8c8d;
        }
        .search-section {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .search-box {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .quiz-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
        }
        .quiz-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.2s, box-shadow 0.2s;
            position: relative;
        }
        .quiz-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }
        .quiz-title {
            font-size: 20px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 10px;
        }
        .quiz-description {
            color: #7f8c8d;
            margin-bottom: 15px;
            font-size: 14px;
            line-height: 1.4;
        }
        .quiz-meta {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            font-size: 13px;
            color: #7f8c8d;
        }
        .quiz-stats {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            font-size: 13px;
        }
        .stat-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .btn-start {
            background: #27ae60;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            display: inline-block;
            text-align: center;
            width: 100%;
            transition: background 0.2s;
        }
        .btn-start:hover {
            background: #229954;
        }
        .btn-start:disabled {
            background: #bdc3c7;
            cursor: not-allowed;
        }
        .attempted-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            background: #3498db;
            color: white;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
        }
        .no-quizzes {
            text-align: center;
            padding: 60px 20px;
            color: #7f8c8d;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .no-quizzes h3 {
            margin-bottom: 10px;
            color: #2c3e50;
        }
        .difficulty-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            margin-left: 10px;
        }
        .difficulty-easy {
            background: #d5f4e6;
            color: #27ae60;
        }
        .difficulty-medium {
            background: #fff3cd;
            color: #f39c12;
        }
        .difficulty-hard {
            background: #f8d7da;
            color: #e74c3c;
        }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>📚 Available Quizzes</h1>
            <p style="font-size: 14px; margin-top: 5px;">Welcome, <%= username %></p>
        </div>
        <div>
            <a href="logout" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="welcome-section">
            <h2>Welcome to the Quiz Portal!</h2>
            <p>Select a quiz below to begin. Remember to follow the rules and avoid any malpractice during the quiz.</p>
        </div>
        
        <div class="search-section">
            <input type="text" class="search-box" placeholder="Search quizzes by title or description..." id="searchInput">
        </div>
        
        <div class="quiz-grid" id="quizGrid">
            <%
                // Load quizzes from database
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = DatabaseConnection.getConnection();
                    
                    // Get user ID
                    String getUserIdSql = "SELECT id FROM users WHERE username = ?";
                    PreparedStatement userStmt = conn.prepareStatement(getUserIdSql);
                    userStmt.setString(1, username);
                    ResultSet userRs = userStmt.executeQuery();
                    int userId = 0;
                    if (userRs.next()) {
                        userId = userRs.getInt("id");
                    }
                    userRs.close();
                    userStmt.close();
                    
                    String sql = "SELECT qm.id, qm.title, qm.description, qm.time_limit, qm.created_at, " +
                                "COUNT(qq.question_id) as question_count, " +
                                "COUNT(qa.id) as attempt_count, " +
                                "MAX(qa.score) as best_score, " +
                                "MAX(qa.percentage) as best_percentage " +
                                "FROM quizzes_master qm " +
                                "INNER JOIN quiz_questions qq ON qm.id = qq.quiz_id " +
                                "LEFT JOIN quiz_attempts qa ON qm.id = qa.quiz_id AND qa.student_id = ? " +
                                "GROUP BY qm.id, qm.title, qm.description, qm.time_limit, qm.created_at " +
                                "HAVING COUNT(qq.question_id) > 0 " +
                                "ORDER BY qm.created_at DESC";
                    
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, userId);
                    rs = pstmt.executeQuery();
                    
                    boolean hasQuizzes = false;
                    while (rs.next()) {
                        hasQuizzes = true;
                        int quizId = rs.getInt("id");
                        String title = rs.getString("title");
                        String description = rs.getString("description");
                        int timeLimit = rs.getInt("time_limit");
                        Timestamp createdAt = rs.getTimestamp("created_at");
                        int questionCount = rs.getInt("question_count");
                        int attemptCount = rs.getInt("attempt_count");
                        int bestScore = rs.getInt("best_score");
                        double bestPercentage = rs.getDouble("best_percentage");
                        
                        // Format creation date
                        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
                        String formattedDate = sdf.format(createdAt);
                        
                        // Determine difficulty based on time limit and question count
                        String difficulty = "medium";
                        String difficultyClass = "difficulty-medium";
                        if (timeLimit <= 15 || questionCount <= 5) {
                            difficulty = "easy";
                            difficultyClass = "difficulty-easy";
                        } else if (timeLimit >= 45 || questionCount >= 15) {
                            difficulty = "hard";
                            difficultyClass = "difficulty-hard";
                        }
            %>
            <div class="quiz-card" data-title="<%= title.toLowerCase() %>" data-description="<%= (description != null ? description : "").toLowerCase() %>">
                <% if (attemptCount > 0) { %>
                <div class="attempted-badge">Attempted</div>
                <% } %>
                
                <div class="quiz-title">
                    <%= title %>
                    <span class="difficulty-badge <%= difficultyClass %>"><%= difficulty.toUpperCase() %></span>
                </div>
                <div class="quiz-description"><%= description != null ? description : "No description available" %></div>
                <div class="quiz-meta">
                    <span>⏱️ <%= timeLimit %> minutes</span>
                    <span>📅 <%= formattedDate %></span>
                </div>
                <div class="quiz-stats">
                    <div class="stat-item">
                        <span>❓</span>
                        <span><%= questionCount %> questions</span>
                    </div>
                    <% if (attemptCount > 0) { %>
                    <div class="stat-item">
                        <span>🏆</span>
                        <span>Best: <%= bestScore %>/<%= questionCount %> (<%= String.format("%.1f", bestPercentage) %>%)
                    </div>
                    <% } %>
                </div>
                <a href="quiz?action=start&quizId=<%= quizId %>" class="btn-start">
                    <% if (attemptCount > 0) { %>
                        Retake Quiz
                    <% } else { %>
                        Start Quiz
                    <% } %>
                </a>
            </div>
            <%
                    }
                    
                    if (!hasQuizzes) {
            %>
            <div class="no-quizzes">
                <h3>No quizzes available</h3>
                <p>There are currently no quizzes available. Please check back later.</p>
            </div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
            %>
            <div class="no-quizzes">
                <h3>Error loading quizzes</h3>
                <p><%= e.getMessage() %></p>
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
    
    <script>
        // Search functionality
        document.getElementById('searchInput').addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const quizCards = document.querySelectorAll('.quiz-card');
            
            quizCards.forEach(card => {
                const title = card.getAttribute('data-title');
                const description = card.getAttribute('data-description');
                
                if (title.includes(searchTerm) || description.includes(searchTerm)) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        });
        
        // Add click animation to quiz cards
        document.querySelectorAll('.quiz-card').forEach(card => {
            card.addEventListener('click', function(e) {
                if (e.target.classList.contains('btn-start')) {
                    this.style.transform = 'scale(0.98)';
                    setTimeout(() => {
                        this.style.transform = '';
                    }, 150);
                }
            });
        });
    </script>
</body>
</html>
