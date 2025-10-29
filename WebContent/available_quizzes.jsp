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
    <title>Available Quizzes - Admin Panel</title>
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
            max-width: 1400px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .btn-create {
            background: #27ae60;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
        }
        .btn-create:hover {
            background: #229954;
        }
        .search-box {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            width: 300px;
        }
        .quiz-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
        }
        .quiz-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .quiz-card:hover {
            transform: translateY(-2px);
        }
        .quiz-title {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 10px;
        }
        .quiz-description {
            color: #7f8c8d;
            margin-bottom: 15px;
            font-size: 14px;
        }
        .quiz-meta {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 12px;
            color: #7f8c8d;
        }
        .quiz-actions {
            display: flex;
            gap: 10px;
        }
        .btn-action {
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 12px;
            text-align: center;
        }
        .btn-edit {
            background: #3498db;
            color: white;
        }
        .btn-edit:hover {
            background: #2980b9;
        }
        .btn-delete {
            background: #e74c3c;
            color: white;
        }
        .btn-delete:hover {
            background: #c0392b;
        }
        .btn-view {
            background: #f39c12;
            color: white;
        }
        .btn-view:hover {
            background: #e67e22;
        }
        .quiz-stats {
            display: flex;
            gap: 15px;
            margin-top: 10px;
            font-size: 12px;
        }
        .stat-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .no-quizzes {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        .modal-content {
            background-color: white;
            margin: 15% auto;
            padding: 20px;
            border-radius: 10px;
            width: 80%;
            max-width: 500px;
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .close {
            color: #aaa;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        .close:hover {
            color: #000;
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
            <a href="admin.jsp" class="back-btn">← Back to Dashboard</a>
            <a href="logout" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <%
            // Handle success/error messages
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            if (success != null) {
        %>
        <div style="background: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin-bottom: 20px; border: 1px solid #c3e6cb;">
            <%
                if ("quiz_deleted".equals(success)) {
                    out.println("✅ Quiz deleted successfully!");
                }
            %>
        </div>
        <%
            }
            if (error != null) {
        %>
        <div style="background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
            <%
                if ("invalid_quiz_id".equals(error)) {
                    out.println("❌ Invalid quiz ID provided.");
                } else if ("quiz_not_found".equals(error)) {
                    out.println("❌ Quiz not found.");
                } else if ("database_error".equals(error)) {
                    out.println("❌ Database error occurred while deleting quiz.");
                } else {
                    out.println("❌ Error: " + error);
                }
            %>
        </div>
        <%
            }
        %>
        
        <div class="action-bar">
            <a href="create_quiz.jsp" class="btn-create">+ Create New Quiz</a>
            <input type="text" class="search-box" placeholder="Search quizzes..." id="searchInput">
        </div>
        
        <div class="quiz-grid" id="quizGrid">
            <%
                // Load quizzes from database
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = DatabaseConnection.getConnection();
                    
                    String sql = "SELECT qm.id, qm.title, qm.description, qm.time_limit, qm.created_at, " +
                                "COUNT(qq.question_id) as question_count, " +
                                "COUNT(qa.id) as attempt_count " +
                                "FROM quizzes_master qm " +
                                "LEFT JOIN quiz_questions qq ON qm.id = qq.quiz_id " +
                                "LEFT JOIN quiz_attempts qa ON qm.id = qa.quiz_id " +
                                "GROUP BY qm.id, qm.title, qm.description, qm.time_limit, qm.created_at " +
                                "ORDER BY qm.created_at DESC";
                    
                    pstmt = conn.prepareStatement(sql);
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
                        
                        // Format creation date
                        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
                        String formattedDate = sdf.format(createdAt);
            %>
            <div class="quiz-card" data-title="<%= title.toLowerCase() %>">
                <div class="quiz-title"><%= title %></div>
                <div class="quiz-description"><%= description != null ? description : "No description" %></div>
                <div class="quiz-meta">
                    <span>⏱️ <%= timeLimit %> min</span>
                    <span>📅 <%= formattedDate %></span>
                </div>
                <div class="quiz-stats">
                    <div class="stat-item">
                        <span>❓</span>
                        <span><%= questionCount %> questions</span>
                    </div>
                    <div class="stat-item">
                        <span>👥</span>
                        <span><%= attemptCount %> attempts</span>
                    </div>
                </div>
                <div class="quiz-actions">
                    <a href="edit_quiz.jsp?id=<%= quizId %>" class="btn-action btn-edit">Edit</a>
                    <a href="quiz_details.jsp?id=<%= quizId %>" class="btn-action btn-view">View Details</a>
                    <a href="#" class="btn-action btn-delete" data-quiz-id="<%= quizId %>" data-quiz-title="<%= title %>" onclick="confirmDelete(this)">Delete</a>
                </div>
            </div>
            <%
                    }
                    
                    if (!hasQuizzes) {
            %>
            <div class="no-quizzes">
                <h3>No quizzes found</h3>
                <p>Create your first quiz to get started!</p>
                <a href="create_quiz.jsp" class="btn-create" style="margin-top: 15px; display: inline-block;">Create Quiz</a>
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
    
    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Confirm Delete</h3>
                <span class="close" onclick="closeModal()">×</span>
            </div>
            <p>Are you sure you want to delete the quiz "<span id="quizTitle"></span>"?</p>
            <p style="color: #e74c3c; font-size: 12px; margin-top: 10px;">This action cannot be undone.</p>
            <div style="margin-top: 20px; text-align: right;">
                <button onclick="closeModal()" style="margin-right: 10px; padding: 8px 16px; border: 1px solid #ddd; background: white; border-radius: 5px; cursor: pointer;">Cancel</button>
                <button onclick="deleteQuiz()" style="padding: 8px 16px; background: #e74c3c; color: white; border: none; border-radius: 5px; cursor: pointer;">Delete</button>
            </div>
        </div>
    </div>
    
    <script>
        let quizToDelete = null;
        
        // Search functionality
        document.getElementById('searchInput').addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const quizCards = document.querySelectorAll('.quiz-card');
            
            quizCards.forEach(card => {
                const title = card.getAttribute('data-title');
                if (title.includes(searchTerm)) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        });
        
        // Delete confirmation
        function confirmDelete(element) {
            quizToDelete = parseInt(element.getAttribute('data-quiz-id'));
            document.getElementById('quizTitle').textContent = element.getAttribute('data-quiz-title');
            document.getElementById('deleteModal').style.display = 'block';
        }
        
        function closeModal() {
            document.getElementById('deleteModal').style.display = 'none';
            quizToDelete = null;
        }
        
        function deleteQuiz() {
            if (quizToDelete) {
                // Create a form and submit it to delete the quiz
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'delete-quiz';
                
                const quizIdInput = document.createElement('input');
                quizIdInput.type = 'hidden';
                quizIdInput.name = 'quiz_id';
                quizIdInput.value = quizToDelete;
                
                form.appendChild(quizIdInput);
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('deleteModal');
            if (event.target == modal) {
                closeModal();
            }
        }
    </script>
</body>
</html>