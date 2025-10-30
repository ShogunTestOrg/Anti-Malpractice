package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import com.quiz.utils.DatabaseConnection;
import com.quiz.utils.Logger;

public class ViolationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("Unauthorized");
            return;
        }
        
        String username = (String) session.getAttribute("username");
        String quizId = (String) session.getAttribute("quizId");
        String reason = request.getParameter("reason");
        String type = request.getParameter("type");
        
        if (username == null || quizId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("Invalid session");
            return;
        }
        
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Unknown violation";
        }
        
        if (type == null || type.trim().isEmpty()) {
            type = "UNKNOWN";
        }
        
        // Increment violation count in session
        Integer violationCount = (Integer) session.getAttribute("violationCount");
        if (violationCount == null) {
            violationCount = 0;
        }
        violationCount++;
        session.setAttribute("violationCount", violationCount);
        
        // Update violation count in database
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "UPDATE quiz_attempts SET violation_count = ? WHERE quiz_instance_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, violationCount);
                pstmt.setString(2, quizId);
                pstmt.executeUpdate();
                Logger.logDebug("Updated violation count to " + violationCount + " for quiz " + quizId);
            }
        } catch (SQLException e) {
            Logger.logError("Failed to update violation count in database", e);
        }
        
        // Log the violation
        Logger.logViolation(username, quizId, type, reason);
        
        // Set response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().print(
            "{\"status\":\"success\",\"violationCount\":" + violationCount + "}"
        );
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
