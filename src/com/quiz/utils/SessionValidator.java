package com.quiz.utils;

import javax.servlet.http.HttpSession;

public class SessionValidator {
    
    /**
     * Validates if a session is active and valid
     * @param session The HttpSession to validate
     * @return true if session is valid, false otherwise
     */
    public static boolean isValidSession(HttpSession session) {
        if (session == null) {
            return false;
        }
        
        String username = (String) session.getAttribute("username");
        if (username == null || username.trim().isEmpty()) {
            return false;
        }
        
        // Check if session has not exceeded timeout
        Long loginTime = (Long) session.getAttribute("loginTime");
        if (loginTime == null) {
            return false;
        }
        
        // Session is valid for 45 minutes (2700000 ms)
        long currentTime = System.currentTimeMillis();
        long sessionDuration = currentTime - loginTime;
        long maxSessionDuration = 45 * 60 * 1000; // 45 minutes
        
        if (sessionDuration > maxSessionDuration) {
            session.invalidate();
            return false;
        }
        
        return true;
    }
    
    /**
     * Validates if the session belongs to an admin
     * @param session The HttpSession to check
     * @return true if user is admin, false otherwise
     */
    public static boolean isAdmin(HttpSession session) {
        if (!isValidSession(session)) {
            return false;
        }
        
        String role = (String) session.getAttribute("role");
        return "admin".equals(role);
    }
    
    /**
     * Validates if the session belongs to a student
     * @param session The HttpSession to check
     * @return true if user is student, false otherwise
     */
    public static boolean isStudent(HttpSession session) {
        if (!isValidSession(session)) {
            return false;
        }
        
        String role = (String) session.getAttribute("role");
        return "student".equals(role);
    }
    
    /**
     * Gets the username from session
     * @param session The HttpSession
     * @return username or null if not found
     */
    public static String getUsername(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute("username");
    }
    
    /**
     * Gets the role from session
     * @param session The HttpSession
     * @return role or null if not found
     */
    public static String getRole(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute("role");
    }
}
