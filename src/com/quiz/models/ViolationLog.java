package com.quiz.models;

import java.sql.Timestamp;

public class ViolationLog {
    private int logId;
    private int userId;
    private String username;
    private String violationType;
    private Timestamp timestamp;
    private String severity;

    public ViolationLog(int logId, int userId, String username, String violationType, Timestamp timestamp, String severity) {
        this.logId = logId;
        this.userId = userId;
        this.username = username;
        this.violationType = violationType;
        this.timestamp = timestamp;
        this.severity = severity;
    }

    // Getters
    public int getLogId() {
        return logId;
    }

    public int getUserId() {
        return userId;
    }

    public String getUsername() {
        return username;
    }

    public String getViolationType() {
        return violationType;
    }

    public Timestamp getTimestamp() {
        return timestamp;
    }

    public String getSeverity() {
        return severity;
    }
}
