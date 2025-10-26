package com.quiz.models;

import java.util.Date;

public class Violation {
    private int id;
    private String username;
    private String quizId;
    private String violationType;
    private String description;
    private Date timestamp;
    private String severity;
    
    public Violation() {
    }
    
    public Violation(String username, String quizId, String violationType, String description) {
        this.username = username;
        this.quizId = quizId;
        this.violationType = violationType;
        this.description = description;
        this.timestamp = new Date();
        this.severity = determineSeverity(violationType);
    }
    
    private String determineSeverity(String violationType) {
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
    
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getQuizId() {
        return quizId;
    }
    
    public void setQuizId(String quizId) {
        this.quizId = quizId;
    }
    
    public String getViolationType() {
        return violationType;
    }
    
    public void setViolationType(String violationType) {
        this.violationType = violationType;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Date getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(Date timestamp) {
        this.timestamp = timestamp;
    }
    
    public String getSeverity() {
        return severity;
    }
    
    public void setSeverity(String severity) {
        this.severity = severity;
    }
    
    @Override
    public String toString() {
        return "Violation{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", quizId='" + quizId + '\'' +
                ", violationType='" + violationType + '\'' +
                ", description='" + description + '\'' +
                ", timestamp=" + timestamp +
                ", severity='" + severity + '\'' +
                '}';
    }
}
