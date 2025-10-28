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
        String[] selectedQuestions = request.getParameterValues("selected_questions");
        
        // Validate input
        if (title == null || title.trim().isEmpty()) {
            response.sendRedirect("create_quiz.jsp?error=Quiz title is required");
            return;
        }
        
        if (timeLimitStr == null || timeLimitStr.trim().isEmpty()) {
            response.sendRedirect("create_quiz.jsp?error=Time limit is required");
            return;
        }
        
        if (selectedQuestions == null || selectedQuestions.length == 0) {
            response.sendRedirect("create_quiz.jsp?error=Please select at least one question");
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
            
            // Insert quiz into quizzes_master table
            String insertQuizSql = "INSERT INTO quizzes_master (title, description, time_limit, created_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
            pstmt = conn.prepareStatement(insertQuizSql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, title.trim());
            pstmt.setString(2, description != null ? description.trim() : "");
            pstmt.setInt(3, timeLimit);
            
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
            
            // Insert questions into quiz_questions table
            String insertQuestionSql = "INSERT INTO quiz_questions (quiz_id, question_id, question_text, option_a, option_b, option_c, option_d, correct_option) " +
                                     "SELECT ?, q.id, q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, " +
                                     "CASE q.correct_answer " +
                                     "WHEN 0 THEN 'A' " +
                                     "WHEN 1 THEN 'B' " +
                                     "WHEN 2 THEN 'C' " +
                                     "WHEN 3 THEN 'D' " +
                                     "ELSE 'A' END " +
                                     "FROM questions q WHERE q.id = ?";
            
            pstmt = conn.prepareStatement(insertQuestionSql);
            
            for (String questionIdStr : selectedQuestions) {
                try {
                    int questionId = Integer.parseInt(questionIdStr);
                    pstmt.setInt(1, quizId);
                    pstmt.setInt(2, questionId);
                    pstmt.addBatch();
                } catch (NumberFormatException e) {
                    Logger.logError("Invalid question ID: " + questionIdStr, e);
                }
            }
            
            int[] batchResults = pstmt.executeBatch();
            int successCount = 0;
            for (int result : batchResults) {
                if (result > 0) successCount++;
            }
            
            if (successCount == 0) {
                throw new SQLException("Failed to add any questions to the quiz");
            }
            
            conn.commit(); // Commit transaction
            
            Logger.logDebug("Quiz created successfully: " + title + " (ID: " + quizId + ") with " + successCount + " questions");
            
            response.sendRedirect("create_quiz.jsp?success=Quiz created successfully with " + successCount + " questions");
            
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