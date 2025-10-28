<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.io.*, java.sql.*, java.text.*" %>
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
    <title>Admin Dashboard - Quiz Monitoring</title>
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
            max-width: 1400px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .stat-icon {
            font-size: 48px;
            width: 70px;
            height: 70px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
        }
        .stat-icon.blue { background: #e3f2fd; }
        .stat-icon.red { background: #ffebee; }
        .stat-icon.green { background: #e8f5e9; }
        .stat-icon.orange { background: #fff3e0; }
        .stat-info h3 {
            font-size: 32px;
            color: #2c3e50;
            margin-bottom: 5px;
        }
        .stat-info p {
            color: #7f8c8d;
            font-size: 14px;
        }
        .section {
            background: white;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .section h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #ecf0f1;
        }
        .filter-bar {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        .filter-bar input,
        .filter-bar select {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .btn-refresh {
            background: #3498db;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ecf0f1;
        }
        th {
            background: #f8f9fa;
            color: #2c3e50;
            font-weight: 600;
        }
        tr:hover {
            background: #f8f9fa;
        }
        .violation-type {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
        }
        .violation-type.critical {
            background: #ffebee;
            color: #c62828;
        }
        .violation-type.warning {
            background: #fff3e0;
            color: #ef6c00;
        }
        .violation-type.info {
            background: #e3f2fd;
            color: #1565c0;
        }
        .active-quiz {
            background: #e8f5e9;
            color: #2e7d32;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
        }
        .chart-container {
            margin-top: 20px;
            height: 300px;
        }
        .no-data {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>🎓 Admin Dashboard</h1>
            <p style="font-size: 14px; margin-top: 5px;">Welcome, <%= username %></p>
        </div>
        <div>
            <button class="btn-refresh" onclick="location.reload()">🔄 Refresh</button>
            <a href="logout" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div style="margin-bottom:16px;">
            <a href="create_quiz.jsp" class="btn-refresh">＋ Create New Quiz</a>
            <a href="add_question.jsp" class="btn-refresh" style="margin-left:8px;">❓ Add Question</a>
            <a href="available_quizzes.jsp" class="btn-refresh" style="margin-left:8px;">📚 View Quizzes</a>
        </div>
        <!-- Statistics Cards -->
        <%
            // Calculate statistics from database
            int activeStudents = 0;
            int totalViolations = 0;
            int completedQuizzes = 0;
            int activeQuizzes = 0;
            
            Connection statsConn = null;
            Statement statsStmt = null;
            ResultSet statsRs = null;
            
            try {
                Class.forName("org.postgresql.Driver");
                statsConn = DriverManager.getConnection(
                    "jdbc:postgresql://localhost:5432/quiz_system", 
                    "postgres", 
                    "1234"
                );
                statsStmt = statsConn.createStatement();
                
                // Count active students (students who have logged in)
                statsRs = statsStmt.executeQuery("SELECT COUNT(DISTINCT id) FROM users WHERE role = 'student' AND is_active = true");
                if (statsRs.next()) activeStudents = statsRs.getInt(1);
                statsRs.close();
                
                // Count total violations
                statsRs = statsStmt.executeQuery("SELECT COUNT(*) FROM violations");
                if (statsRs.next()) totalViolations = statsRs.getInt(1);
                statsRs.close();
                
                // Count completed quizzes
                statsRs = statsStmt.executeQuery("SELECT COUNT(*) FROM quizzes WHERE status = 'completed'");
                if (statsRs.next()) completedQuizzes = statsRs.getInt(1);
                statsRs.close();
                
                // Count active quizzes
                statsRs = statsStmt.executeQuery("SELECT COUNT(*) FROM quizzes WHERE status = 'in_progress'");
                if (statsRs.next()) activeQuizzes = statsRs.getInt(1);
                
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (statsRs != null) statsRs.close();
                    if (statsStmt != null) statsStmt.close();
                    if (statsConn != null) statsConn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        %>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue">👥</div>
                <div class="stat-info">
                    <h3><%= activeStudents %></h3>
                    <p>Active Students</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red">⚠️</div>
                <div class="stat-info">
                    <h3><%= totalViolations %></h3>
                    <p>Total Violations</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">✅</div>
                <div class="stat-info">
                    <h3><%= completedQuizzes %></h3>
                    <p>Completed Quizzes</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange">📝</div>
                <div class="stat-info">
                    <h3><%= activeQuizzes %></h3>
                    <p>Active Quizzes</p>
                </div>
            </div>
        </div>
        
        <!-- Recent Violations -->
        <div class="section">
            <h2>Recent Violations</h2>
            <div class="filter-bar">
                <input type="text" placeholder="Search by username..." id="searchUser">
                <select id="filterType">
                    <option value="">All Types</option>
                    <option value="TAB_SWITCH">Tab Switch</option>
                    <option value="COPY_ATTEMPT">Copy Attempt</option>
                    <option value="FULLSCREEN_EXIT">Fullscreen Exit</option>
                    <option value="MULTIPLE_TABS">Multiple Tabs</option>
                </select>
                <input type="date" id="filterDate">
            </div>
            
            <table>
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Student</th>
                        <th>Quiz ID</th>
                        <th>Violation Type</th>
                        <th>Description</th>
                        <th>Severity</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        // Read violations from database
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        
                        try {
                            Class.forName("org.postgresql.Driver");
                            conn = DriverManager.getConnection(
                                "jdbc:postgresql://localhost:5432/quiz_system", 
                                "postgres", 
                                "1234"
                            );
                            
                            String sql = "SELECT timestamp, username, quiz_id, violation_type, description, severity " +
                                        "FROM violations ORDER BY timestamp DESC LIMIT 20";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            
                            boolean hasData = false;
                            while (rs.next()) {
                                hasData = true;
                                String timestamp = rs.getTimestamp("timestamp").toString();
                                String user = rs.getString("username");
                                String qid = rs.getString("quiz_id");
                                String vtype = rs.getString("violation_type");
                                String desc = rs.getString("description");
                                String severity = rs.getString("severity");
                    %>
                    <tr>
                        <td><%= timestamp %></td>
                        <td><%= user %></td>
                        <td><%= qid %></td>
                        <td><span class="violation-type <%= severity.toLowerCase() %>"><%= vtype %></span></td>
                        <td><%= desc %></td>
                        <td>
                            <span class="violation-type <%= severity.toLowerCase() %>"><%= severity %></span>
                        </td>
                    </tr>
                    <%
                            }
                            
                            if (!hasData) {
                    %>
                    <tr><td colspan="6" class="no-data">No violations recorded yet.</td></tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6' class='no-data'>Error loading violations: " + e.getMessage() + "</td></tr>");
                            e.printStackTrace();
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
                </tbody>
            </table>
        </div>
        
        <!-- Active Quiz Sessions -->
        <div class="section">
            <h2>Active Quiz Sessions</h2>
            <table>
                <thead>
                    <tr>
                        <th>Student</th>
                        <th>Quiz ID</th>
                        <th>Start Time</th>
                        <th>Progress</th>
                        <th>Violations</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        // Query active quiz sessions from database
                        Connection conn2 = null;
                        PreparedStatement pstmt2 = null;
                        ResultSet rs2 = null;
                        
                        try {
                            Class.forName("org.postgresql.Driver");
                            conn2 = DriverManager.getConnection(
                                "jdbc:postgresql://localhost:5432/quiz_system", 
                                "postgres", 
                                "1234"
                            );
                            
                            String sql2 = "SELECT q.quiz_id, u.username, q.start_time, q.status, " +
                                         "(SELECT COUNT(*) FROM violations v WHERE v.quiz_id = q.quiz_id) as violation_count " +
                                         "FROM quizzes q " +
                                         "JOIN users u ON q.user_id = u.id " +
                                         "WHERE q.status = 'in_progress' " +
                                         "ORDER BY q.start_time DESC";
                            pstmt2 = conn2.prepareStatement(sql2);
                            rs2 = pstmt2.executeQuery();
                            
                            boolean hasActiveSessions = false;
                            while (rs2.next()) {
                                hasActiveSessions = true;
                                String qid = rs2.getString("quiz_id");
                                String user = rs2.getString("username");
                                Timestamp startTime = rs2.getTimestamp("start_time");
                                String status = rs2.getString("status");
                                int violations = rs2.getInt("violation_count");
                                
                                // Format start time
                                SimpleDateFormat sdf = new SimpleDateFormat("hh:mm a");
                                String formattedTime = sdf.format(startTime);
                    %>
                    <tr>
                        <td><%= user %></td>
                        <td><%= qid %></td>
                        <td><%= formattedTime %></td>
                        <td>-</td>
                        <td><%= violations %></td>
                        <td><span class="active-quiz">In Progress</span></td>
                    </tr>
                    <%
                            }
                            
                            if (!hasActiveSessions) {
                    %>
                    <tr><td colspan="6" class="no-data">No active quiz sessions at the moment.</td></tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6' class='no-data'>Error loading sessions: " + e.getMessage() + "</td></tr>");
                            e.printStackTrace();
                        } finally {
                            try {
                                if (rs2 != null) rs2.close();
                                if (pstmt2 != null) pstmt2.close();
                                if (conn2 != null) conn2.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                    %>
                </tbody>
            </table>
        </div>
        
        <!-- Violation Statistics -->
        <div class="section">
            <h2>Violation Statistics</h2>
            <div class="chart-container">
                <p class="no-data">Chart visualization will be displayed here.<br>
                Implement using Chart.js or similar library for production.</p>
            </div>
        </div>
    </div>
    
    <script>
        // Auto-refresh every 30 seconds
        setTimeout(() => location.reload(), 30000);
        
        // Filter functionality
        document.getElementById('searchUser').addEventListener('input', filterTable);
        document.getElementById('filterType').addEventListener('change', filterTable);
        document.getElementById('filterDate').addEventListener('change', filterTable);
        
        function filterTable() {
            const searchText = document.getElementById('searchUser').value.toLowerCase();
            const filterType = document.getElementById('filterType').value;
            const filterDate = document.getElementById('filterDate').value;
            
            const rows = document.querySelectorAll('tbody tr');
            rows.forEach(row => {
                const cells = row.cells;
                if (cells.length < 5) return;
                
                const username = cells[1].textContent.toLowerCase();
                const type = cells[3].textContent;
                const timestamp = cells[0].textContent;
                
                let show = true;
                
                if (searchText && !username.includes(searchText)) show = false;
                if (filterType && !type.includes(filterType)) show = false;
                if (filterDate && !timestamp.includes(filterDate)) show = false;
                
                row.style.display = show ? '' : 'none';
            });
        }
    </script>
</body>
</html>
