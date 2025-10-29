<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("index.jsp?error=session");
        return;
    }
    
    Integer score = (Integer) session.getAttribute("score");
    Integer totalQuestions = (Integer) session.getAttribute("totalQuestions");
    Integer violationCount = (Integer) session.getAttribute("violationCount");
    Boolean autoSubmitted = (Boolean) session.getAttribute("autoSubmitted");
    
    if (score == null) score = 0;
    if (totalQuestions == null) totalQuestions = 0;
    if (violationCount == null) violationCount = 0;
    if (autoSubmitted == null) autoSubmitted = false;
    
    double percentage = totalQuestions > 0 ? (score * 100.0 / totalQuestions) : 0;
    String grade;
    
    if (percentage >= 90) grade = "A+";
    else if (percentage >= 80) grade = "A";
    else if (percentage >= 70) grade = "B";
    else if (percentage >= 60) grade = "C";
    else if (percentage >= 50) grade = "D";
    else grade = "F";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz Results</title>
    <link rel="stylesheet" href="css/dark-theme-overrides.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a1a 0%, #000000 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            color: #e0e0e0;
        }
        .result-container {
            background: #1a1a1a;
            border: 1px solid #333333;
            border-radius: 15px;
            padding: 40px;
            max-width: 600px;
            width: 100%;
            box-shadow: 0 10px 30px rgba(255,255,255,0.1);
            text-align: center;
        }
        .result-header {
            margin-bottom: 30px;
        }
        .result-header h1 {
            color: #ffffff;
            margin-bottom: 10px;
        }
        .result-header p {
            color: #b0b0b0;
            font-size: 16px;
        }
        .score-circle {
            width: 200px;
            height: 200px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ffffff 0%, #d0d0d0 100%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            margin: 30px auto;
            color: #000000;
        }
        .score-circle .percentage {
            font-size: 48px;
            font-weight: bold;
        }
        .score-circle .grade {
            font-size: 24px;
            margin-top: 10px;
        }
        .result-details {
            background: #2a2a2a;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            border: 1px solid #444;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #444;
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            color: #b0b0b0;
            font-weight: 500;
        }
        .detail-value {
            color: #ffffff;
            font-weight: 600;
        }
        .violation-warning {
            background: #3a3000;
            border: 1px solid #ffc107;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            color: #ffd700;
        }
        .violation-warning.critical {
            background: #3a0000;
            border-color: #dc3545;
            color: #ff6b6b;
        }
        .actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
            color: #000000 !important;
        }
        .btn-primary {
            background: #ffffff;
            color: #000000 !important;
        }
        .btn-primary:hover {
            background: #e0e0e0;
            color: #000000 !important;
        }
        .btn-secondary {
            background: #ffffff;
            color: #000000 !important;
        }
        .btn-secondary:hover {
            background: #e0e0e0;
            color: #000000 !important;
        }
        .message {
            margin-top: 20px;
            font-size: 18px;
            color: #e0e0e0;
        }
        .message.pass {
            color: #4CAF50;
        }
        .message.fail {
            color: #ff6b6b;
        }
    </style>
</head>
<body>
    <div class="result-container">
        <div class="result-header">
            <h1>🎉 Quiz Completed!</h1>
            <p>Hello, <%= username %></p>
        </div>
        
        <div class="score-circle">
            <div class="percentage"><%= String.format("%.0f", percentage) %>%</div>
            <div class="grade">Grade: <%= grade %></div>
        </div>
        
        <div class="result-details">
            <div class="detail-row">
                <span class="detail-label">Correct Answers:</span>
                <span class="detail-value"><%= score %> / <%= totalQuestions %></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Score:</span>
                <span class="detail-value"><%= String.format("%.2f", percentage) %>%</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Grade:</span>
                <span class="detail-value"><%= grade %></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Violations:</span>
                <span class="detail-value" style="color: <%= violationCount > 0 ? "#ff6b6b" : "#4CAF50" %>;">
                    <%= violationCount %>
                </span>
            </div>
        </div>
        
        <% if (autoSubmitted) { %>
            <div class="violation-warning critical">
                <strong>⚠️ AUTO-SUBMITTED:</strong> 
                Your quiz was automatically submitted because you reached the violation threshold (<%= violationCount %> violations).
                <br>Please follow quiz rules in future attempts.
            </div>
        <% } else if (violationCount > 0) { %>
            <div class="violation-warning <%= violationCount >= 3 ? "critical" : "" %>">
                <strong>⚠️ Warning:</strong> 
                <%= violationCount %> violation(s) were detected during your quiz.
            </div>
        <% } %>
        
        <p class="message <%= percentage >= 60 ? "pass" : "fail" %>">
            <% if (percentage >= 60) { %>
                🎊 Congratulations! You passed the quiz!
            <% } else { %>
                📚 Keep studying! You can do better next time.
            <% } %>
        </p>
        
        <div class="actions">
            <a href="student_quizzes.jsp" class="btn btn-primary">Take Another Quiz</a>
            <a href="logout" class="btn btn-secondary">Logout</a>
        </div>
    </div>
</body>
</html>
