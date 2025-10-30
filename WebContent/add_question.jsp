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
            background: #000000;
            color: #e0e0e0;
        }
        .header {
            background: #1a1a1a;
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #333333;
        }
        .header h1 {
            font-size: 24px;
        }
        .back-btn {
            background: #ffffff;
            color: #000000 !important;
            padding: 10px 20px;
            border: 2px solid #ffffff;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            margin-right: 10px;
            transition: all 0.3s;
        }
        .back-btn:hover {
            background: #f0f0f0;
            box-shadow: 0 4px 12px rgba(255,255,255,0.3);
        }
        .logout-btn {
            background: #f44336;
            color: white;
            padding: 10px 20px;
            border: 2px solid #f44336;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s;
        }
        .logout-btn:hover {
            background: #e53935;
            box-shadow: 0 4px 12px rgba(244, 67, 54, 0.3);
        }
        .container {
            max-width: 1000px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .form-container {
            background: #1a1a1a;
            border: 1px solid #333333;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(255,255,255,0.05);
        }
        .form-container h2 {
            color: #ffffff;
            margin-bottom: 20px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #ffffff;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #444444;
            border-radius: 5px;
            font-size: 14px;
            background: #0a0a0a;
            color: #e0e0e0;
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
            background: #ffffff;
            color: #000000 !important;
            padding: 15px 30px;
            border: 2px solid #ffffff;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
            transition: all 0.3s;
        }
        .btn-submit:hover {
            background: #f0f0f0;
            box-shadow: 0 4px 12px rgba(255,255,255,0.3);
        }
        .error-message {
            background: #3d1a1a;
            color: #ff6b6b;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #f44336;
        }
        .success-message {
            background: #1a3d1a;
            color: #4CAF50;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #4CAF50;
        }
        .required {
            color: #ff6b6b;
        }
        .question-preview {
            background: #0a0a0a;
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
            border-left: 4px solid #4CAF50;
        }
        .preview-title {
            font-weight: 600;
            color: #ffffff;
            margin-bottom: 15px;
        }
        .preview-options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        .preview-option {
            padding: 8px 12px;
            background: #1a1a1a;
            border-radius: 5px;
            border: 1px solid #444444;
            font-size: 14px;
            color: #e0e0e0;
        }
        .preview-option.correct {
            background: #1a3d1a;
            border-color: #4CAF50;
            color: #4CAF50;
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
                <!-- Quiz Selection -->
                <div class="form-group">
                    <label for="quiz_id">Select Quiz <span class="required">*</span></label>
                    <select id="quiz_id" name="quiz_id" required>
                        <option value="">-- Select a Quiz --</option>
                        <%
                            // Load available quizzes from database
                            Connection conn = null;
                            PreparedStatement pstmt = null;
                            ResultSet rs = null;
                            String selectedQuizId = request.getParameter("quiz_id");
                            
                            try {
                                conn = com.quiz.utils.DatabaseConnection.getConnection();
                                String sql = "SELECT id, title FROM quizzes_master ORDER BY created_at DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                while (rs.next()) {
                                    int qid = rs.getInt("id");
                                    String qtitle = rs.getString("title");
                                    boolean isSelected = selectedQuizId != null && selectedQuizId.equals(String.valueOf(qid));
                        %>
                        <option value="<%= qid %>" <%= isSelected ? "selected" : "" %>><%= qtitle %></option>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<option value=''>Error loading quizzes</option>");
                                e.printStackTrace();
                            } finally {
                                try {
                                    if (rs != null) rs.close();
                                    if (pstmt != null) pstmt.close();
                                    if (conn != null) conn.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }
                        %>
                    </select>
                    <small style="color: #888;">Select the quiz to add this question to, or <a href="create_quiz.jsp" style="color: #4CAF50;">create a new quiz</a></small>
                </div>
                
                <div class="form-group">
                    <label for="question_type">Question Type <span class="required">*</span></label>
                    <select id="question_type" name="question_type" onchange="toggleQuestionType()" required>
                        <option value="multiple_choice">Multiple Choice</option>
                        <option value="numerical">Numerical Answer</option>
                    </select>
                </div>
                
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
                
                <div class="form-group">
                    <label for="difficulty">Difficulty Level <span class="required">*</span></label>
                    <select id="difficulty" name="difficulty" required>
                        <option value="easy">Easy</option>
                        <option value="medium" selected>Medium</option>
                        <option value="hard">Hard</option>
                    </select>
                </div>
                
                <!-- Multiple Choice Fields -->
                <div id="multipleChoiceFields">
                    <h3 style="margin: 20px 0 10px 0; color: #ffffff;">Multiple Choice Options</h3>
                    <div class="option-group">
                        <div class="form-group">
                            <label for="option_a">Option A <span class="required">*</span></label>
                            <input type="text" id="option_a" name="option_a" placeholder="First option">
                        </div>
                        <div class="form-group">
                            <label for="option_b">Option B <span class="required">*</span></label>
                            <input type="text" id="option_b" name="option_b" placeholder="Second option">
                        </div>
                        <div class="form-group">
                            <label for="option_c">Option C <span class="required">*</span></label>
                            <input type="text" id="option_c" name="option_c" placeholder="Third option">
                        </div>
                        <div class="form-group">
                            <label for="option_d">Option D <span class="required">*</span></label>
                            <input type="text" id="option_d" name="option_d" placeholder="Fourth option">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="correct_answer">Correct Answer <span class="required">*</span></label>
                        <select id="correct_answer" name="correct_answer">
                            <option value="">Select correct answer</option>
                            <option value="0">Option A</option>
                            <option value="1">Option B</option>
                            <option value="2">Option C</option>
                            <option value="3">Option D</option>
                        </select>
                    </div>
                </div>
                
                <!-- Numerical Answer Fields -->
                <div id="numericalFields" style="display: none;">
                    <h3 style="margin: 20px 0 10px 0; color: #ffffff;">Numerical Answer</h3>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="numerical_answer">Correct Answer <span class="required">*</span></label>
                            <input type="number" step="0.01" id="numerical_answer" name="numerical_answer" placeholder="e.g., 3.14">
                            <small style="color: #b0b0b0;">Enter the exact numerical answer</small>
                        </div>
                        <div class="form-group">
                            <label for="answer_tolerance">Answer Tolerance (±)</label>
                            <input type="number" step="0.01" id="answer_tolerance" name="answer_tolerance" placeholder="e.g., 0.01" value="0">
                            <small style="color: #b0b0b0;">Acceptable margin of error (0 for exact match)</small>
                        </div>
                    </div>
                    <div class="info-box" style="background: #0d2847; padding: 15px; border-radius: 5px; margin: 10px 0; border: 1px solid #1976d2;">
                        <p style="color: #64b5f6; margin: 0;"><strong>💡 Tip:</strong> For answers like π (3.14), set tolerance to 0.01 to accept 3.13-3.15</p>
                    </div>
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
        // Toggle between multiple choice and numerical question fields
        function toggleQuestionType() {
            const questionType = document.getElementById('question_type').value;
            const multipleChoiceFields = document.getElementById('multipleChoiceFields');
            const numericalFields = document.getElementById('numericalFields');
            
            if (questionType === 'numerical') {
                multipleChoiceFields.style.display = 'none';
                numericalFields.style.display = 'block';
                
                // Remove required attribute from multiple choice fields
                document.getElementById('option_a').removeAttribute('required');
                document.getElementById('option_b').removeAttribute('required');
                document.getElementById('option_c').removeAttribute('required');
                document.getElementById('option_d').removeAttribute('required');
                document.getElementById('correct_answer').removeAttribute('required');
                
                // Add required attribute to numerical fields
                document.getElementById('numerical_answer').setAttribute('required', 'required');
            } else {
                multipleChoiceFields.style.display = 'block';
                numericalFields.style.display = 'none';
                
                // Add required attribute to multiple choice fields
                document.getElementById('option_a').setAttribute('required', 'required');
                document.getElementById('option_b').setAttribute('required', 'required');
                document.getElementById('option_c').setAttribute('required', 'required');
                document.getElementById('option_d').setAttribute('required', 'required');
                document.getElementById('correct_answer').setAttribute('required', 'required');
                
                // Remove required attribute from numerical fields
                document.getElementById('numerical_answer').removeAttribute('required');
            }
        }
        
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
            const questionType = document.getElementById('question_type').value;
            const questionText = document.getElementById('question_text').value.trim();
            const category = document.getElementById('category').value;
            
            if (!questionText || !category) {
                e.preventDefault();
                alert('Please fill in question text and category.');
                return false;
            }
            
            if (questionType === 'multiple_choice') {
                const optionA = document.getElementById('option_a').value.trim();
                const optionB = document.getElementById('option_b').value.trim();
                const optionC = document.getElementById('option_c').value.trim();
                const optionD = document.getElementById('option_d').value.trim();
                const correctAnswer = document.getElementById('correct_answer').value;
                
                if (!optionA || !optionB || !optionC || !optionD || !correctAnswer) {
                    e.preventDefault();
                    alert('Please fill in all multiple choice options and select correct answer.');
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
            } else if (questionType === 'numerical') {
                const numericalAnswer = document.getElementById('numerical_answer').value;
                
                if (!numericalAnswer) {
                    e.preventDefault();
                    alert('Please enter the numerical answer.');
                    return false;
                }
                
                if (isNaN(numericalAnswer)) {
                    e.preventDefault();
                    alert('Numerical answer must be a valid number.');
                    return false;
                }
            }
        });
    </script>
</body>
</html>
