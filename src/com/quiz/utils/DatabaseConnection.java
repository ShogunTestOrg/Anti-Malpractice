package com.quiz.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database Connection Utility
 * Manages database connections for the quiz system with automatic fallback
 */
public class DatabaseConnection {
    
    // Database configuration
    private static final String DRIVER = "org.postgresql.Driver";
    
    // Primary (Cloud) database configuration
    private static final String CLOUD_URL = System.getenv("DB_URL");
    private static final String CLOUD_USERNAME = System.getenv("DB_USERNAME");
    private static final String CLOUD_PASSWORD = System.getenv("DB_PASSWORD");
    
    // Fallback (Local) database configuration
    private static final String LOCAL_URL = "jdbc:postgresql://localhost:5433/quiz_system";
    private static final String LOCAL_USERNAME = "postgres";
    private static final String LOCAL_PASSWORD = "Revanth2005";
    
    // Track which database is being used
    private static boolean usingFallback = false;
    private static boolean fallbackAttempted = false;
    
    static {
        try {
            // Load PostgreSQL JDBC Driver
            Class.forName(DRIVER);
            System.out.println("[INFO] PostgreSQL JDBC Driver loaded successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("[ERROR] Failed to load PostgreSQL JDBC Driver: " + e.getMessage());
            throw new RuntimeException("Database driver not found", e);
        }
    }
    
    /**
     * Get a connection to the database with automatic fallback
     * @return Connection object
     * @throws SQLException if both primary and fallback connections fail
     */
    public static Connection getConnection() throws SQLException {
        // Try cloud database first if environment variables are set
        if (CLOUD_URL != null && CLOUD_USERNAME != null && CLOUD_PASSWORD != null && !usingFallback) {
            try {
                Connection conn = DriverManager.getConnection(CLOUD_URL, CLOUD_USERNAME, CLOUD_PASSWORD);
                System.out.println("[INFO] Database connection established (Cloud)");
                return conn;
            } catch (SQLException e) {
                System.err.println("[ERROR] Failed to establish cloud database connection: " + e.getMessage());
                
                // Only log fallback message once
                if (!fallbackAttempted) {
                    System.out.println("[WARN] Attempting to connect to local fallback database...");
                    fallbackAttempted = true;
                }
                
                // Try fallback to local database
                try {
                    Connection fallbackConn = DriverManager.getConnection(LOCAL_URL, LOCAL_USERNAME, LOCAL_PASSWORD);
                    System.out.println("[INFO] Database connection established (Local Fallback)");
                    usingFallback = true;
                    return fallbackConn;
                } catch (SQLException fallbackException) {
                    System.err.println("[ERROR] Failed to establish local fallback connection: " + fallbackException.getMessage());
                    throw new SQLException("Both cloud and local database connections failed. " +
                        "Cloud error: " + e.getMessage() + 
                        " | Local error: " + fallbackException.getMessage());
                }
            }
        }
        
        // Use local database directly if no environment variables set
        try {
            Connection conn = DriverManager.getConnection(LOCAL_URL, LOCAL_USERNAME, LOCAL_PASSWORD);
            System.out.println("[INFO] Database connection established (Local)");
            return conn;
        } catch (SQLException e) {
            System.err.println("[ERROR] Failed to establish database connection: " + e.getMessage());
            throw e;
        }
    }
    
    /**
     * Test database connection
     * @return true if connection is successful
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("[ERROR] Database connection test failed: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Close database connection safely
     * @param conn Connection to close
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
                System.out.println("[INFO] Database connection closed");
            } catch (SQLException e) {
                System.err.println("[ERROR] Error closing database connection: " + e.getMessage());
            }
        }
    }
    
    /**
     * Get database URL for configuration display
     * @return Database URL (without credentials)
     */
    public static String getDatabaseInfo() {
        if (usingFallback) {
            return "Database: quiz_system (Local Fallback - localhost:5433)";
        } else if (CLOUD_URL != null) {
            return "Database: " + CLOUD_URL.substring(CLOUD_URL.lastIndexOf('/') + 1) + " (Cloud)";
        } else {
            return "Database: quiz_system (Local)";
        }
    }
    
    /**
     * Check if using fallback database
     * @return true if using local fallback
     */
    public static boolean isUsingFallback() {
        return usingFallback;
    }
    
    /**
     * Reset fallback status (for testing purposes)
     */
    public static void resetFallbackStatus() {
        usingFallback = false;
        fallbackAttempted = false;
    }
}