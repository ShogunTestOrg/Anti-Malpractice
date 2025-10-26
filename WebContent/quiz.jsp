<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.quiz.models.*" %>
<%
    // Check session
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("index.jsp?error=session");
        return;
    }
    
    // Get quiz data from session
    @SuppressWarnings("unchecked")
    List<Question> questions = (List<Question>) session.getAttribute("questions");
    Integer currentIndex = (Integer) session.getAttribute("currentIndex");
    String quizId = (String) session.getAttribute("quizId");
    Integer violationCount = (Integer) session.getAttribute("violationCount");
    Long startTime = (Long) session.getAttribute("startTime");
    
    if (questions == null || currentIndex == null) {
        response.sendRedirect("quiz?action=start");
        return;
    }
    
    if (violationCount == null) violationCount = 0;
    if (startTime == null) startTime = System.currentTimeMillis();
    
    Question currentQuestion = questions.get(currentIndex);
    int totalQuestions = questions.size();
    
    // Quiz duration in minutes
    int quizDuration = 30;
    long elapsedTime = (System.currentTimeMillis() - startTime) / 1000; // in seconds
    long remainingTime = (quizDuration * 60) - elapsedTime;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz - Question <%= currentIndex + 1 %></title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .quiz-container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        .quiz-header {
            background: #667eea;
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
        }
        .quiz-info {
            display: flex;
            gap: 30px;
            flex-wrap: wrap;
        }
        .info-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .timer {
            font-size: 24px;
            font-weight: bold;
            padding: 10px 20px;
            background: rgba(255,255,255,0.2);
            border-radius: 5px;
        }
        .violation-badge {
            background: #e74c3c;
            padding: 5px 15px;
            border-radius: 20px;
            font-weight: bold;
        }
        .quiz-progress {
            background: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
        }
        .progress-bar {
            height: 10px;
            background: #e9ecef;
            border-radius: 5px;
            overflow: hidden;
            margin-top: 10px;
        }
        .progress-fill {
            height: 100%;
            background: #667eea;
            transition: width 0.3s;
        }
        .question-container {
            padding: 40px;
        }
        .question-number {
            color: #667eea;
            font-weight: bold;
            margin-bottom: 15px;
        }
        .question-text {
            font-size: 20px;
            color: #333;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .options {
            list-style: none;
        }
        .option-item {
            margin-bottom: 15px;
        }
        .option-label {
            display: flex;
            align-items: center;
            padding: 15px;
            border: 2px solid #dee2e6;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .option-label:hover {
            border-color: #667eea;
            background: #f8f9ff;
        }
        .option-label input[type="radio"] {
            margin-right: 15px;
            width: 20px;
            height: 20px;
            cursor: pointer;
        }
        .navigation-buttons {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
        }
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-previous {
            background: #6c757d;
            color: white;
        }
        .btn-previous:hover {
            background: #5a6268;
        }
        .btn-next {
            background: #667eea;
            color: white;
        }
        .btn-next:hover {
            background: #5568d3;
        }
        .btn-submit {
            background: #28a745;
            color: white;
        }
        .btn-submit:hover {
            background: #218838;
        }
        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .warning-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.8);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }
        .warning-box {
            background: white;
            padding: 40px;
            border-radius: 10px;
            text-align: center;
            max-width: 500px;
        }
        .warning-box h2 {
            color: #e74c3c;
            margin-bottom: 20px;
        }
        .warning-box p {
            margin-bottom: 20px;
            font-size: 16px;
        }
        .btn-understood {
            background: #e74c3c;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
        }
        
        /* Custom Confirmation Dialog */
        .custom-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.8);
            z-index: 10000;
            justify-content: center;
            align-items: center;
        }
        .modal-content {
            background: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            max-width: 450px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            animation: slideDown 0.3s ease-out;
        }
        @keyframes slideDown {
            from {
                transform: translateY(-50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
        .modal-content h3 {
            color: #2c3e50;
            margin-bottom: 15px;
            font-size: 24px;
        }
        .modal-content p {
            color: #7f8c8d;
            margin-bottom: 25px;
            font-size: 16px;
            line-height: 1.5;
        }
        .modal-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
        }
        .btn-modal {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-modal-confirm {
            background: #28a745;
            color: white;
        }
        .btn-modal-confirm:hover {
            background: #218838;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(40,167,69,0.3);
        }
        .btn-modal-cancel {
            background: #6c757d;
            color: white;
        }
        .btn-modal-cancel:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(108,117,125,0.3);
        }
        .btn-modal-warning {
            background: #dc3545;
            color: white;
        }
        .btn-modal-warning:hover {
            background: #c82333;
        }
    </style>
</head>
<body>
    <div class="quiz-container">
        <div class="quiz-header">
            <div class="quiz-info">
                <div class="info-item">
                    <span>👤 <%= username %></span>
                </div>
                <div class="info-item">
                    <span>📝 Quiz ID: <%= quizId %></span>
                </div>
                <div class="info-item violation-badge">
                    ⚠️ Violations: <span id="violationCount"><%= violationCount %></span>/5
                </div>
            </div>
            <div class="timer" id="timer">
                <%= String.format("%02d:%02d", remainingTime / 60, remainingTime % 60) %>
            </div>
        </div>
        
        <div class="quiz-progress">
            <div>Question <%= currentIndex + 1 %> of <%= totalQuestions %></div>
            <div class="progress-bar">
                <div class="progress-fill" style="width: <%= ((currentIndex + 1) * 100.0 / totalQuestions) %>%"></div>
            </div>
        </div>
        
        <form action="quiz" method="post" id="quizForm">
            <input type="hidden" name="action" value="answer">
            <input type="hidden" name="questionId" value="<%= currentQuestion.getId() %>">
            
            <div class="question-container">
                <div class="question-number">Question <%= currentIndex + 1 %></div>
                <div class="question-text"><%= currentQuestion.getQuestionText() %></div>
                
                <ul class="options">
                    <% 
                        List<String> options = currentQuestion.getOptions();
                        for (int i = 0; i < options.size(); i++) {
                            String optionLabel = (char)('A' + i) + "";
                    %>
                    <li class="option-item">
                        <label class="option-label">
                            <input type="radio" name="answer" value="<%= i %>" required>
                            <span><strong><%= optionLabel %>.</strong> <%= options.get(i) %></span>
                        </label>
                    </li>
                    <% } %>
                </ul>
                
                <div class="navigation-buttons">
                    <% if (currentIndex > 0) { %>
                        <button type="submit" name="navigation" value="previous" class="btn btn-previous">
                            ← Previous
                        </button>
                    <% } else { %>
                        <div></div>
                    <% } %>
                    
                    <% if (currentIndex < totalQuestions - 1) { %>
                        <button type="submit" name="navigation" value="next" class="btn btn-next">
                            Next →
                        </button>
                    <% } else { %>
                        <button type="submit" name="navigation" value="submit" class="btn btn-submit">
                            Submit Quiz
                        </button>
                    <% } %>
                </div>
            </div>
        </form>
    </div>
    
    <div class="warning-overlay" id="warningOverlay">
        <div class="warning-box">
            <h2>⚠️ WARNING!</h2>
            <p id="warningMessage">Malpractice detected!</p>
            <p>This incident has been logged. Repeated violations will result in automatic submission.</p>
            <button class="btn-understood" onclick="closeWarning()">I Understand</button>
        </div>
    </div>
    
    <!-- Custom Confirmation Modal -->
    <div class="custom-modal" id="customModal">
        <div class="modal-content">
            <h3 id="modalTitle">Confirm Action</h3>
            <p id="modalMessage">Are you sure?</p>
            <div class="modal-buttons" id="modalButtons">
                <button class="btn-modal btn-modal-cancel" onclick="closeModal()">Cancel</button>
                <button class="btn-modal btn-modal-confirm" onclick="confirmModal()">Confirm</button>
            </div>
        </div>
    </div>
    
    <script src="js/monitor.js"></script>
    <script>
        let modalCallback = null;
        
        // Show custom modal
        function showModal(title, message, onConfirm, type = 'confirm') {
            const modal = document.getElementById('customModal');
            const modalTitle = document.getElementById('modalTitle');
            const modalMessage = document.getElementById('modalMessage');
            const modalButtons = document.getElementById('modalButtons');
            
            modalTitle.textContent = title;
            modalMessage.textContent = message;
            modalCallback = onConfirm;
            
            if (type === 'alert') {
                modalButtons.innerHTML = '<button class="btn-modal btn-modal-confirm" onclick="closeModal()">OK</button>';
            } else if (type === 'warning') {
                modalButtons.innerHTML = `
                    <button class="btn-modal btn-modal-cancel" onclick="closeModal()">Cancel</button>
                    <button class="btn-modal btn-modal-warning" onclick="confirmModal()">Continue</button>
                `;
            } else {
                modalButtons.innerHTML = `
                    <button class="btn-modal btn-modal-cancel" onclick="closeModal()">Cancel</button>
                    <button class="btn-modal btn-modal-confirm" onclick="confirmModal()">Confirm</button>
                `;
            }
            
            modal.style.display = 'flex';
        }
        
        function closeModal() {
            document.getElementById('customModal').style.display = 'none';
            modalCallback = null;
        }
        
        function confirmModal() {
            if (modalCallback) {
                modalCallback();
            }
            closeModal();
        }
        
        // Initialize monitoring
        const quizMonitor = new QuizMonitor({
            username: '<%= username %>',
            quizId: '<%= quizId %>',
            violationThreshold: 5,
            timeRemaining: <%= remainingTime %>
        });
        
        function closeWarning() {
            document.getElementById('warningOverlay').style.display = 'none';
        }
        
        // Override form submission with confirmation
        const quizForm = document.getElementById('quizForm');
        
        quizForm.onsubmit = function(e) {
            e.preventDefault();
            
            // Get the button that was clicked
            const clickedButton = e.submitter;
            const navigationValue = clickedButton ? clickedButton.value : null;
            
            console.log('Form submitted, navigation value:', navigationValue);
            
            // Check if it's a submit button (final submission)
            if (navigationValue === 'submit') {
                showModal(
                    '📝 Submit Quiz?',
                    'Are you sure you want to submit your quiz? You cannot change your answers after submission.',
                    function() {
                        // Add navigation parameter before submitting
                        const navInput = document.createElement('input');
                        navInput.type = 'hidden';
                        navInput.name = 'navigation';
                        navInput.value = navigationValue;
                        quizForm.appendChild(navInput);
                        quizForm.submit();
                    },
                    'warning'
                );
            } else {
                // For next/previous, add navigation parameter and submit directly
                const navInput = document.createElement('input');
                navInput.type = 'hidden';
                navInput.name = 'navigation';
                navInput.value = navigationValue;
                quizForm.appendChild(navInput);
                quizForm.submit();
            }
            
            return false;
        };
        
        // Prevent form resubmission
        if (window.history.replaceState) {
            window.history.replaceState(null, null, window.location.href);
        }
    </script>
</body>
</html>
