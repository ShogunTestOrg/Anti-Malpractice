package com.quiz.utils;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Logger {
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    public static void logViolation(String username, String quizId, String type, String reason) {
        System.out.println("=== Logger.logViolation CALLED ===");
        System.out.println("Username: " + username);
        System.out.println("QuizId: " + quizId);
        System.out.println("Type: " + type);
        System.out.println("Reason: " + reason);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            System.out.println("Attempting to get database connection...");
            conn = DatabaseConnection.getConnection();
            System.out.println("Database connection obtained: " + (conn != null ? "SUCCESS" : "FAILED"));
            
            String sql = "INSERT INTO violations (quiz_id, username, violation_type, description, severity, timestamp) " +
                        "VALUES (?, ?, ?, ?, CAST(? AS severity_level), ?)";
            
            System.out.println("Preparing SQL statement...");
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, quizId);
            pstmt.setString(2, username);
            pstmt.setString(3, type);
            pstmt.setString(4, reason);
            pstmt.setString(5, determineSeverity(type));
            pstmt.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
            
            System.out.println("Executing insert...");
            int rows = pstmt.executeUpdate();
            System.out.println("Insert completed! Rows affected: " + rows);
            
            // Also log to console for debugging
            String timestamp = LocalDateTime.now().format(formatter);
            System.out.println(String.format("[VIOLATION] %s | %s | %s | %s | %s", 
                timestamp, username, quizId, type, reason));
            
        } catch (SQLException e) {
            System.err.println("!!! SQL ERROR in logViolation !!!");
            System.err.println("Error logging violation to database: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("!!! GENERAL ERROR in logViolation !!!");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        System.out.println("=== Logger.logViolation COMPLETED ===");
    }
    
    private static String determineSeverity(String violationType) {
        if (violationType == null) return "INFO";
        
        switch (violationType.toUpperCase()) {
            case "TAB_SWITCH":
            case "MULTIPLE_TABS":
            case "FULLSCREEN_EXIT":
            case "DEVTOOLS_OPEN":
                return "CRITICAL";
                
            case "COPY_ATTEMPT":
            case "PASTE_ATTEMPT":
            case "CUT_ATTEMPT":
            case "SCREENSHOT_ATTEMPT":
                return "WARNING";
                
            default:
                return "INFO";
        }
    }
    
    public static void logInfo(String message) {
        String timestamp = LocalDateTime.now().format(formatter);
        System.out.println("[INFO] " + timestamp + " - " + message);
    }
    
    public static void logDebug(String message) {
        String timestamp = LocalDateTime.now().format(formatter);
        System.out.println("[DEBUG] " + timestamp + " - " + message);
    }
    
    public static void logError(String message, Exception e) {
        String timestamp = LocalDateTime.now().format(formatter);
        System.err.println("[ERROR] " + timestamp + " - " + message);
        if (e != null) {
            e.printStackTrace();
        }
    }
}
