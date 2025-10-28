package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class DebugLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<h1>Debug Login</h1>");
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        response.getWriter().println("<p>Username: " + username + "</p>");
        response.getWriter().println("<p>Password: " + password + "</p>");
        
        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/quiz_system", 
                "postgres", 
                "1234"
            );
            
            response.getWriter().println("<p>Database connection: SUCCESS</p>");
            
            String sql = "SELECT password, role FROM users WHERE username = ? AND is_active = true";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String dbPassword = rs.getString("password");
                String dbRole = rs.getString("role");
                
                response.getWriter().println("<p>Database password: " + dbPassword + "</p>");
                response.getWriter().println("<p>Database role: " + dbRole + "</p>");
                response.getWriter().println("<p>Password match: " + password.equals(dbPassword) + "</p>");
                
                if (password.equals(dbPassword)) {
                    response.getWriter().println("<p style='color: green;'>AUTHENTICATION SUCCESS</p>");
                    
                    // Create session
                    HttpSession session = request.getSession(true);
                    session.setAttribute("username", username);
                    session.setAttribute("role", dbRole);
                    session.setAttribute("loginTime", System.currentTimeMillis());
                    session.setMaxInactiveInterval(45 * 60);
                    
                    response.getWriter().println("<p>Session created successfully</p>");
                    response.getWriter().println("<p><a href='admin.jsp'>Go to Admin</a> | <a href='student_quizzes.jsp'>Go to Student Portal</a></p>");
                } else {
                    response.getWriter().println("<p style='color: red;'>AUTHENTICATION FAILED - Password mismatch</p>");
                }
            } else {
                response.getWriter().println("<p style='color: red;'>AUTHENTICATION FAILED - User not found or inactive</p>");
            }
            
            rs.close();
            pstmt.close();
            conn.close();
            
        } catch (Exception e) {
            response.getWriter().println("<p style='color: red;'>Database error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }
}
