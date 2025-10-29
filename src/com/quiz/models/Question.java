package com.quiz.models;

import java.util.List;

public class Question {
    private int id;
    private String questionText;
    private String questionType; // "multiple_choice" or "numerical"
    private List<String> options;
    private int correctAnswer; // For multiple choice (0-3)
    private Double numericalAnswer; // For numerical questions
    private Double answerTolerance; // Acceptable margin of error
    private String category;
    private String difficulty;
    
    public Question() {
        this.questionType = "multiple_choice"; // Default
        this.answerTolerance = 0.0;
    }
    
    public Question(int id, String questionText, List<String> options, int correctAnswer) {
        this.id = id;
        this.questionText = questionText;
        this.questionType = "multiple_choice";
        this.options = options;
        this.correctAnswer = correctAnswer;
        this.answerTolerance = 0.0;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getQuestionText() {
        return questionText;
    }
    
    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }
    
    public String getQuestionType() {
        return questionType;
    }
    
    public void setQuestionType(String questionType) {
        this.questionType = questionType;
    }
    
    public List<String> getOptions() {
        return options;
    }
    
    public void setOptions(List<String> options) {
        this.options = options;
    }
    
    public int getCorrectAnswer() {
        return correctAnswer;
    }
    
    public void setCorrectAnswer(int correctAnswer) {
        this.correctAnswer = correctAnswer;
    }
    
    public Double getNumericalAnswer() {
        return numericalAnswer;
    }
    
    public void setNumericalAnswer(Double numericalAnswer) {
        this.numericalAnswer = numericalAnswer;
    }
    
    public Double getAnswerTolerance() {
        return answerTolerance;
    }
    
    public void setAnswerTolerance(Double answerTolerance) {
        this.answerTolerance = answerTolerance;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public String getDifficulty() {
        return difficulty;
    }
    
    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }
    
    public boolean isNumerical() {
        return "numerical".equalsIgnoreCase(questionType);
    }
    
    public boolean isMultipleChoice() {
        return "multiple_choice".equalsIgnoreCase(questionType);
    }
    
    /**
     * Check if a numerical answer is correct within tolerance
     */
    public boolean checkNumericalAnswer(double answer) {
        if (numericalAnswer == null) {
            return false;
        }
        double tolerance = (answerTolerance != null) ? answerTolerance : 0.0;
        return Math.abs(answer - numericalAnswer) <= tolerance;
    }
    
    @Override
    public String toString() {
        return "Question{" +
                "id=" + id +
                ", questionText='" + questionText + '\'' +
                ", questionType='" + questionType + '\'' +
                ", options=" + options +
                ", correctAnswer=" + correctAnswer +
                ", numericalAnswer=" + numericalAnswer +
                ", answerTolerance=" + answerTolerance +
                ", category='" + category + '\'' +
                ", difficulty='" + difficulty + '\'' +
                '}';
    }
}
