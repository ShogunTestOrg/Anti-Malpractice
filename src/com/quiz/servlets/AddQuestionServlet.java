package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import com.quiz.utils.DatabaseConnection;
import com.quiz.utils.SessionValidator;
import com.quiz.utils.Logger;

public class AddQuestionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
        
        // Forward to add question page
        response.sendRedirect("add_question.jsp");
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
        String questionText = request.getParameter("question_text");
        String optionA = request.getParameter("option_a");
        String optionB = request.getParameter("option_b");
        String optionC = request.getParameter("option_c");
        String optionD = request.getParameter("option_d");
        String correctAnswerStr = request.getParameter("correct_answer");
        String category = request.getParameter("category");
        
        // Validate input
        if (questionText == null || questionText.trim().isEmpty()) {
            response.sendRedirect("add_question.jsp?error=Question text is required");
            return;
        }
        
        if (optionA == null || optionA.trim().isEmpty() ||
            optionB == null || optionB.trim().isEmpty() ||
            optionC == null || optionC.trim().isEmpty() ||
            optionD == null || optionD.trim().isEmpty()) {
            response.sendRedirect("add_question.jsp?error=All options are required");
            return;
        }
        
        if (correctAnswerStr == null || correctAnswerStr.trim().isEmpty()) {
            response.sendRedirect("add_question.jsp?error=Please select the correct answer");
            return;
        }
        
        if (category == null || category.trim().isEmpty()) {
            response.sendRedirect("add_question.jsp?error=Category is required");
            return;
        }
        
        int correctAnswer;
        try {
            correctAnswer = Integer.parseInt(correctAnswerStr);
            if (correctAnswer < 0 || correctAnswer > 3) {
                response.sendRedirect("add_question.jsp?error=Invalid correct answer selection");
                return;
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("add_question.jsp?error=Invalid correct answer format");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Insert question into questions table
            String insertQuestionSql = "INSERT INTO questions (question_text, option_a, option_b, option_c, option_d, correct_answer, category) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertQuestionSql);
            pstmt.setString(1, questionText.trim());
            pstmt.setString(2, optionA.trim());
            pstmt.setString(3, optionB.trim());
            pstmt.setString(4, optionC.trim());
            pstmt.setString(5, optionD.trim());
            pstmt.setInt(6, correctAnswer);
            pstmt.setString(7, category.trim());
            
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new SQLException("Failed to add question");
            }
            
            Logger.logDebug("Question added successfully: " + questionText.substring(0, Math.min(50, questionText.length())) + "...");
            
            response.sendRedirect("add_question.jsp?success=Question added successfully");
            
        } catch (SQLException e) {
            Logger.logError("Error adding question", e);
            response.sendRedirect("add_question.jsp?error=Database error: " + e.getMessage());
            
        } catch (Exception e) {
            Logger.logError("Unexpected error adding question", e);
            response.sendRedirect("add_question.jsp?error=Unexpected error occurred");
            
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                Logger.logError("Error closing database resources", e);
            }
        }
    }
}
