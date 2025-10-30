package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import com.quiz.utils.DatabaseConnection;

@WebServlet("/edit-quiz")
public class EditQuizServlet extends HttpServlet {
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
        
        // Get form parameters
        String quizIdParam = request.getParameter("quiz_id");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String timeLimitParam = request.getParameter("time_limit");
        
        // Validation
        if (quizIdParam == null || quizIdParam.trim().isEmpty()) {
            response.sendRedirect("available_quizzes.jsp?error=invalid_quiz_id");
            return;
        }
        
        if (title == null || title.trim().isEmpty()) {
            response.sendRedirect("edit_quiz.jsp?id=" + quizIdParam + "&error=Title is required");
            return;
        }
        
        if (timeLimitParam == null || timeLimitParam.trim().isEmpty()) {
            response.sendRedirect("edit_quiz.jsp?id=" + quizIdParam + "&error=Time limit is required");
            return;
        }
        
        int quizId = 0;
        int timeLimit = 0;
        
        try {
            quizId = Integer.parseInt(quizIdParam);
            timeLimit = Integer.parseInt(timeLimitParam);
            
            if (timeLimit < 1 || timeLimit > 180) {
                response.sendRedirect("edit_quiz.jsp?id=" + quizIdParam + "&error=Time limit must be between 1 and 180 minutes");
                return;
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("edit_quiz.jsp?id=" + quizIdParam + "&error=Invalid number format");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Update quiz in database
            String sql = "UPDATE quizzes_master SET title = ?, description = ?, time_limit = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, title.trim());
            pstmt.setString(2, description != null ? description.trim() : "");
            pstmt.setInt(3, timeLimit);
            pstmt.setInt(4, quizId);
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                response.sendRedirect("edit_quiz.jsp?id=" + quizId + "&success=Quiz updated successfully!");
            } else {
                response.sendRedirect("edit_quiz.jsp?id=" + quizId + "&error=Quiz not found or no changes made");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("edit_quiz.jsp?id=" + quizIdParam + "&error=Database error: " + e.getMessage());
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
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
