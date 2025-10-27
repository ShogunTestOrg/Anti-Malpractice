package com.quiz.models;

import java.sql.Timestamp;

public class QuizResult {
    private int resultId;
    private int userId;
    private String username;
    private int score;
    private int totalQuestions;
    private Timestamp submittedAt;

    public QuizResult(int resultId, int userId, String username, int score, int totalQuestions, Timestamp submittedAt) {
        this.resultId = resultId;
        this.userId = userId;
        this.username = username;
        this.score = score;
        this.totalQuestions = totalQuestions;
        this.submittedAt = submittedAt;
    }

    // Getters
    public int getResultId() {
        return resultId;
    }

    public int getUserId() {
        return userId;
    }

    public String getUsername() {
        return username;
    }

    public int getScore() {
        return score;
    }

    public int getTotalQuestions() {
        return totalQuestions;
    }

    public Timestamp getSubmittedAt() {
        return submittedAt;
    }
}
