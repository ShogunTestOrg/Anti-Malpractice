package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class TestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.getWriter().println("<h1>Database Test</h1>");
        
        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/quiz_system", 
                "postgres", 
                "1234"
            );
            
            response.getWriter().println("<p>Database connection: SUCCESS</p>");
            
            String sql = "SELECT username, password, role FROM users WHERE username = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "student");
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                response.getWriter().println("<p>Student user found:</p>");
                response.getWriter().println("<p>Username: " + rs.getString("username") + "</p>");
                response.getWriter().println("<p>Password: " + rs.getString("password") + "</p>");
                response.getWriter().println("<p>Role: " + rs.getString("role") + "</p>");
            } else {
                response.getWriter().println("<p>Student user NOT found</p>");
            }
            
            rs.close();
            pstmt.close();
            conn.close();
            
        } catch (Exception e) {
            response.getWriter().println("<p>Database error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }
}
