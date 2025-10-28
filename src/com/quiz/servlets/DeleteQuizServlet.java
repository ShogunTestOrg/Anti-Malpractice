package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import com.quiz.utils.DatabaseConnection;

public class DeleteQuizServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin session
        String username = (String) request.getSession().getAttribute("username");
        String role = (String) request.getSession().getAttribute("role");
        if (username == null || !"admin".equals(role)) {
            response.sendRedirect("index.jsp?error=unauthorized");
            return;
        }
        
        String quizIdParam = request.getParameter("quiz_id");
        if (quizIdParam == null || quizIdParam.trim().isEmpty()) {
            response.sendRedirect("available_quizzes.jsp?error=invalid_quiz_id");
            return;
        }
        
        int quizId = 0;
        try {
            quizId = Integer.parseInt(quizIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("available_quizzes.jsp?error=invalid_quiz_id");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction
            
            // Delete quiz attempts first (foreign key constraint)
            String deleteAttemptsSql = "DELETE FROM quiz_attempts WHERE quiz_id = ?";
            pstmt = conn.prepareStatement(deleteAttemptsSql);
            pstmt.setInt(1, quizId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Delete quiz questions
            String deleteQuestionsSql = "DELETE FROM quiz_questions WHERE quiz_id = ?";
            pstmt = conn.prepareStatement(deleteQuestionsSql);
            pstmt.setInt(1, quizId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Delete quiz results
            String deleteResultsSql = "DELETE FROM quiz_results WHERE quiz_id = ?";
            pstmt = conn.prepareStatement(deleteResultsSql);
            pstmt.setInt(1, quizId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Finally delete the quiz
            String deleteQuizSql = "DELETE FROM quizzes_master WHERE id = ?";
            pstmt = conn.prepareStatement(deleteQuizSql);
            pstmt.setInt(1, quizId);
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                conn.commit(); // Commit transaction
                response.sendRedirect("available_quizzes.jsp?success=quiz_deleted");
            } else {
                conn.rollback(); // Rollback transaction
                response.sendRedirect("available_quizzes.jsp?error=quiz_not_found");
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback(); // Rollback on error
                }
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            e.printStackTrace();
            response.sendRedirect("available_quizzes.jsp?error=database_error");
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to available quizzes
        response.sendRedirect("available_quizzes.jsp");
    }
}
