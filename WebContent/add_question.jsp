<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.io.*, java.sql.*, java.text.*" %>
<%
    // Check admin session
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    if (username == null || !"admin".equals(role)) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Question - Admin Panel</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f6fa;
        }
        .header {
            background: #2c3e50;
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header h1 {
            font-size: 24px;
        }
        .back-btn {
            background: #3498db;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            margin-right: 10px;
        }
        .logout-btn {
            background: #e74c3c;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
        }
        .container {
            max-width: 1000px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .form-container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #2c3e50;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .form-group textarea {
            height: 100px;
            resize: vertical;
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .option-group {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .btn-submit {
            background: #27ae60;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        .btn-submit:hover {
            background: #229954;
        }
        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .success-message {
            background: #e8f5e9;
            color: #2e7d32;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .required {
            color: #e74c3c;
        }
        .question-preview {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
            border-left: 4px solid #3498db;
        }
        .preview-title {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 15px;
        }
        .preview-options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        .preview-option {
            padding: 8px 12px;
            background: white;
            border-radius: 5px;
            border: 1px solid #ddd;
            font-size: 14px;
        }
        .preview-option.correct {
            background: #d5f4e6;
            border-color: #27ae60;
            color: #27ae60;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>➕ Add New Question</h1>
            <p style="font-size: 14px; margin-top: 5px;">Welcome, <%= username %></p>
        </div>
        <div>
            <a href="admin.jsp" class="back-btn">← Back to Dashboard</a>
            <a href="logout" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="form-container">
            <%
                String error = request.getParameter("error");
                String success = request.getParameter("success");
                if (error != null) {
            %>
            <div class="error-message">
                ❌ <%= error %>
            </div>
            <%
                }
                if (success != null) {
            %>
            <div class="success-message">
                ✅ <%= success %>
            </div>
            <%
                }
            %>
            
            <h2>Question Details</h2>
            <form action="add-question" method="POST" id="questionForm">
                <div class="form-group">
                    <label for="question_text">Question Text <span class="required">*</span></label>
                    <textarea id="question_text" name="question_text" placeholder="Enter your question here..." required></textarea>
                </div>
                
                <div class="form-group">
                    <label for="category">Category <span class="required">*</span></label>
                    <select id="category" name="category" required>
                        <option value="">Select a category</option>
                        <option value="General Knowledge">General Knowledge</option>
                        <option value="Mathematics">Mathematics</option>
                        <option value="Science">Science</option>
                        <option value="History">History</option>
                        <option value="Geography">Geography</option>
                        <option value="Literature">Literature</option>
                        <option value="Technology">Technology</option>
                        <option value="Chemistry">Chemistry</option>
                        <option value="Physics">Physics</option>
                        <option value="Biology">Biology</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                
                <div class="option-group">
                    <div class="form-group">
                        <label for="option_a">Option A <span class="required">*</span></label>
                        <input type="text" id="option_a" name="option_a" placeholder="First option" required>
                    </div>
                    <div class="form-group">
                        <label for="option_b">Option B <span class="required">*</span></label>
                        <input type="text" id="option_b" name="option_b" placeholder="Second option" required>
                    </div>
                    <div class="form-group">
                        <label for="option_c">Option C <span class="required">*</span></label>
                        <input type="text" id="option_c" name="option_c" placeholder="Third option" required>
                    </div>
                    <div class="form-group">
                        <label for="option_d">Option D <span class="required">*</span></label>
                        <input type="text" id="option_d" name="option_d" placeholder="Fourth option" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="correct_answer">Correct Answer <span class="required">*</span></label>
                    <select id="correct_answer" name="correct_answer" required>
                        <option value="">Select correct answer</option>
                        <option value="0">Option A</option>
                        <option value="1">Option B</option>
                        <option value="2">Option C</option>
                        <option value="3">Option D</option>
                    </select>
                </div>
                
                <button type="submit" class="btn-submit">Add Question</button>
            </form>
            
            <div class="question-preview" id="preview" style="display: none;">
                <div class="preview-title">Question Preview:</div>
                <div id="previewText"></div>
                <div class="preview-options" id="previewOptions"></div>
            </div>
        </div>
    </div>
    
    <script>
        // Live preview functionality
        function updatePreview() {
            const questionText = document.getElementById('question_text').value;
            const optionA = document.getElementById('option_a').value;
            const optionB = document.getElementById('option_b').value;
            const optionC = document.getElementById('option_c').value;
            const optionD = document.getElementById('option_d').value;
            const correctAnswer = document.getElementById('correct_answer').value;
            
            if (questionText && optionA && optionB && optionC && optionD) {
                document.getElementById('previewText').textContent = questionText;
                
                const options = [optionA, optionB, optionC, optionD];
                const previewOptions = document.getElementById('previewOptions');
                previewOptions.innerHTML = '';
                
                options.forEach((option, index) => {
                    const optionDiv = document.createElement('div');
                    optionDiv.className = 'preview-option';
                    if (correctAnswer == index) {
                        optionDiv.classList.add('correct');
                    }
                    optionDiv.textContent = String.fromCharCode(65 + index) + '. ' + option;
                    previewOptions.appendChild(optionDiv);
                });
                
                document.getElementById('preview').style.display = 'block';
            } else {
                document.getElementById('preview').style.display = 'none';
            }
        }
        
        // Add event listeners for live preview
        document.getElementById('question_text').addEventListener('input', updatePreview);
        document.getElementById('option_a').addEventListener('input', updatePreview);
        document.getElementById('option_b').addEventListener('input', updatePreview);
        document.getElementById('option_c').addEventListener('input', updatePreview);
        document.getElementById('option_d').addEventListener('input', updatePreview);
        document.getElementById('correct_answer').addEventListener('change', updatePreview);
        
        // Form validation
        document.getElementById('questionForm').addEventListener('submit', function(e) {
            const questionText = document.getElementById('question_text').value.trim();
            const optionA = document.getElementById('option_a').value.trim();
            const optionB = document.getElementById('option_b').value.trim();
            const optionC = document.getElementById('option_c').value.trim();
            const optionD = document.getElementById('option_d').value.trim();
            const correctAnswer = document.getElementById('correct_answer').value;
            const category = document.getElementById('category').value;
            
            if (!questionText || !optionA || !optionB || !optionC || !optionD || !correctAnswer || !category) {
                e.preventDefault();
                alert('Please fill in all required fields.');
                return false;
            }
            
            // Check for duplicate options
            const options = [optionA, optionB, optionC, optionD];
            const uniqueOptions = [...new Set(options)];
            if (uniqueOptions.length !== options.length) {
                e.preventDefault();
                alert('All options must be unique.');
                return false;
            }
        });
    </script>
</body>
</html>
