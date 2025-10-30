package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import com.quiz.utils.SessionValidator;
import com.quiz.utils.DatabaseConnection;
import com.quiz.utils.Logger;

public class CreateQuizServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("index.jsp?error=session");
            return;
        }
        
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        
        if (username == null || !"admin".equals(role)) {
            response.sendRedirect("index.jsp?error=unauthorized");
            return;
        }
        
        // Forward to create quiz page
        response.sendRedirect("create_quiz.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (!SessionValidator.isValidSession(session)) {
            response.sendRedirect("index.jsp?error=session");
            return;
        }
        
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        
        if (username == null || !"admin".equals(role)) {
            response.sendRedirect("index.jsp?error=unauthorized");
            return;
        }
        
        // Get form parameters
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String timeLimitStr = request.getParameter("time_limit");
        
        // Validate input
        if (title == null || title.trim().isEmpty()) {
            response.sendRedirect("create_quiz.jsp?error=Quiz title is required");
            return;
        }
        
        if (timeLimitStr == null || timeLimitStr.trim().isEmpty()) {
            response.sendRedirect("create_quiz.jsp?error=Time limit is required");
            return;
        }
        
        int timeLimit;
        try {
            timeLimit = Integer.parseInt(timeLimitStr);
            if (timeLimit < 1 || timeLimit > 180) {
                response.sendRedirect("create_quiz.jsp?error=Time limit must be between 1 and 180 minutes");
                return;
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("create_quiz.jsp?error=Invalid time limit format");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction
            
            // Get admin user ID
            String getUserIdSql = "SELECT id FROM users WHERE username = ? AND role = 'admin'";
            pstmt = conn.prepareStatement(getUserIdSql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            
            int adminId = 1; // Default to 1 if not found
            if (rs.next()) {
                adminId = rs.getInt("id");
            }
            rs.close();
            pstmt.close();
            
            // Insert quiz into quizzes_master table
            String insertQuizSql = "INSERT INTO quizzes_master (title, description, time_limit, created_by, created_at) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
            pstmt = conn.prepareStatement(insertQuizSql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, title.trim());
            pstmt.setString(2, description != null ? description.trim() : "");
            pstmt.setInt(3, timeLimit);
            pstmt.setInt(4, adminId);
            
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new SQLException("Failed to create quiz");
            }
            
            // Get the generated quiz ID
            rs = pstmt.getGeneratedKeys();
            int quizId = 0;
            if (rs.next()) {
                quizId = rs.getInt(1);
            } else {
                throw new SQLException("Failed to get quiz ID");
            }
            rs.close();
            pstmt.close();
            
            conn.commit(); // Commit transaction
            
            Logger.logDebug("Quiz created successfully: " + title + " (ID: " + quizId + ")");
            
            // Redirect to add questions page for this quiz
            response.sendRedirect("add_question.jsp?quiz_id=" + quizId + "&success=Quiz created! Now add questions to it.");
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback(); // Rollback transaction on error
                }
            } catch (SQLException rollbackEx) {
                Logger.logError("Error during rollback", rollbackEx);
            }
            
            Logger.logError("Error creating quiz", e);
            response.sendRedirect("create_quiz.jsp?error=Database error: " + e.getMessage());
            
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException rollbackEx) {
                Logger.logError("Error during rollback", rollbackEx);
            }
            
            Logger.logError("Unexpected error creating quiz", e);
            response.sendRedirect("create_quiz.jsp?error=Unexpected error occurred");
            
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                }
            } catch (SQLException e) {
                Logger.logError("Error closing database resources", e);
            }
        }
    }
}