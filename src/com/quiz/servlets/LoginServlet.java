package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import com.quiz.utils.SessionValidator;

public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // Input validation
        if (username == null || password == null || 
            username.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect("index.jsp?error=invalid");
            return;
        }
        
        // Simple authentication (In production, use database with hashed passwords)
        boolean isValid = false;
        String role = null;
        
        if ("student".equals(username) && "1234".equals(password)) {
            isValid = true;
            role = "student";
        } else if ("admin".equals(username) && "admin123".equals(password)) {
            isValid = true;
            role = "admin";
        }
        
        if (isValid) {
            // Create session
            HttpSession session = request.getSession(true);
            session.setAttribute("username", username);
            session.setAttribute("role", role);
            session.setAttribute("loginTime", System.currentTimeMillis());
            session.setMaxInactiveInterval(45 * 60); // 45 minutes
            
            // Redirect based on role
            if ("admin".equals(role)) {
                response.sendRedirect("admin.jsp");
            } else {
                // Redirect students to available quizzes list
                response.sendRedirect("available_quizzes.jsp");
            }
        } else {
            response.sendRedirect("index.jsp?error=invalid");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to login page
        response.sendRedirect("index.jsp");
    }
}
