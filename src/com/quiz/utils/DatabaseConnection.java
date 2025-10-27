package com.quiz.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database Connection Utility
 * Manages database connections for the quiz system
 */
public class DatabaseConnection {
    
    // Database configuration
    private static final String DRIVER = "org.postgresql.Driver";
    private static final String URL = "jdbc:postgresql://localhost:5432/quiz_system";
    private static final String USERNAME = "postgres";
    private static final String PASSWORD = "1234"; // Update with your PostgreSQL password
    
    // Connection pool settings (for production)
    private static final int MAX_POOL_SIZE = 10;
    
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
     * Get a connection to the database
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            System.out.println("[INFO] Database connection established");
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
        return "Database: " + URL.substring(URL.lastIndexOf('/') + 1);
    }
}