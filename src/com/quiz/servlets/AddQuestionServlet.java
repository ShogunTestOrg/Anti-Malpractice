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
        String quizIdStr = request.getParameter("quiz_id");
        String questionText = request.getParameter("question_text");
        String questionType = request.getParameter("question_type");
        String optionA = request.getParameter("option_a");
        String optionB = request.getParameter("option_b");
        String optionC = request.getParameter("option_c");
        String optionD = request.getParameter("option_d");
        String correctAnswerStr = request.getParameter("correct_answer");
        String numericalAnswerStr = request.getParameter("numerical_answer");
        String answerToleranceStr = request.getParameter("answer_tolerance");
        String category = request.getParameter("category");
        String difficulty = request.getParameter("difficulty");
        
        // Validate quiz ID
        if (quizIdStr == null || quizIdStr.trim().isEmpty()) {
            response.sendRedirect("add_question.jsp?error=Quiz ID is required");
            return;
        }
        
        int quizId;
        try {
            quizId = Integer.parseInt(quizIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("add_question.jsp?error=Invalid quiz ID");
            return;
        }
        
        // Set defaults
        if (questionType == null || questionType.trim().isEmpty()) {
            questionType = "multiple_choice";
        }
        if (difficulty == null || difficulty.trim().isEmpty()) {
            difficulty = "medium";
        }
        
        // Validate input
        if (questionText == null || questionText.trim().isEmpty()) {
            response.sendRedirect("add_question.jsp?error=Question text is required");
            return;
        }
        
        if (category == null || category.trim().isEmpty()) {
            response.sendRedirect("add_question.jsp?error=Category is required");
            return;
        }
        
        // Validate based on question type
        if ("numerical".equals(questionType)) {
            // Validate numerical question
            if (numericalAnswerStr == null || numericalAnswerStr.trim().isEmpty()) {
                response.sendRedirect("add_question.jsp?error=Numerical answer is required");
                return;
            }
            
            try {
                Double.parseDouble(numericalAnswerStr);
            } catch (NumberFormatException e) {
                response.sendRedirect("add_question.jsp?error=Invalid numerical answer format");
                return;
            }
            
            if (answerToleranceStr != null && !answerToleranceStr.trim().isEmpty()) {
                try {
                    Double.parseDouble(answerToleranceStr);
                } catch (NumberFormatException e) {
                    response.sendRedirect("add_question.jsp?error=Invalid tolerance format");
                    return;
                }
            }
        } else {
            // Validate multiple choice question
            if (optionA == null || optionA.trim().isEmpty() ||
                optionB == null || optionB.trim().isEmpty() ||
                optionC == null || optionC.trim().isEmpty() ||
                optionD == null || optionD.trim().isEmpty()) {
                response.sendRedirect("add_question.jsp?error=All options are required for multiple choice");
                return;
            }
            
            if (correctAnswerStr == null || correctAnswerStr.trim().isEmpty()) {
                response.sendRedirect("add_question.jsp?error=Please select the correct answer");
                return;
            }
        }
        
        Integer correctAnswer = null;
        if ("multiple_choice".equals(questionType)) {
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
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Insert question based on type
            if ("numerical".equals(questionType)) {
                // Insert numerical question into quiz_questions
                String insertQuestionSql = "INSERT INTO quiz_questions (quiz_id, question_text, question_type, numerical_answer, answer_tolerance, difficulty) " +
                                         "VALUES (?, ?, CAST(? AS question_type_enum), ?, ?, CAST(? AS difficulty_level))";
                pstmt = conn.prepareStatement(insertQuestionSql);
                pstmt.setInt(1, quizId);
                pstmt.setString(2, questionText.trim());
                pstmt.setString(3, questionType);
                pstmt.setDouble(4, Double.parseDouble(numericalAnswerStr));
                
                if (answerToleranceStr != null && !answerToleranceStr.trim().isEmpty()) {
                    pstmt.setDouble(5, Double.parseDouble(answerToleranceStr));
                } else {
                    pstmt.setDouble(5, 0.01); // Default tolerance
                }
                
                pstmt.setString(6, difficulty);
            } else {
                // Insert multiple choice question into quiz_questions
                // Convert correctAnswer (0,1,2,3) to correct_option (A,B,C,D)
                String correctOption = "A";
                switch (correctAnswer) {
                    case 0: correctOption = "A"; break;
                    case 1: correctOption = "B"; break;
                    case 2: correctOption = "C"; break;
                    case 3: correctOption = "D"; break;
                }
                
                String insertQuestionSql = "INSERT INTO quiz_questions (quiz_id, question_text, question_type, option_a, option_b, option_c, option_d, correct_option, difficulty) " +
                                         "VALUES (?, ?, CAST(? AS question_type_enum), ?, ?, ?, ?, ?, CAST(? AS difficulty_level))";
                pstmt = conn.prepareStatement(insertQuestionSql);
                pstmt.setInt(1, quizId);
                pstmt.setString(2, questionText.trim());
                pstmt.setString(3, questionType);
                pstmt.setString(4, optionA.trim());
                pstmt.setString(5, optionB.trim());
                pstmt.setString(6, optionC.trim());
                pstmt.setString(7, optionD.trim());
                pstmt.setString(8, correctOption);
                pstmt.setString(9, difficulty);
            }
            
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new SQLException("Failed to add question");
            }
            
            Logger.logDebug("Question added successfully (" + questionType + "): " + questionText.substring(0, Math.min(50, questionText.length())) + "...");
            
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
