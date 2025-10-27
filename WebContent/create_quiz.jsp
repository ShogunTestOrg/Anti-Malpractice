<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.quiz.utils.SessionValidator" %>
<%
    if (!SessionValidator.isValidSession(session) || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create Quiz</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .container { max-width: 900px; margin: 24px auto; padding: 20px; background: #fff; border-radius: 6px; }
        .question-block { border: 1px solid #eee; padding: 12px; margin-bottom: 12px; border-radius: 6px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Create New Quiz</h1>
        <form id="quizForm" method="post" action="create-quiz">
            <div>
                <label>Title</label><br>
                <input type="text" name="title" id="title" required style="width:100%" />
            </div>
            <div>
                <label>Description</label><br>
                <textarea name="description" id="description" rows="3" style="width:100%"></textarea>
            </div>
            <div>
                <label>Time Limit (minutes)</label><br>
                <input type="number" name="timeLimit" id="timeLimit" value="30" required />
            </div>

            <hr />
            <h3>Questions</h3>
            <div id="questions"></div>
            <input type="hidden" id="questionCount" name="questionCount" value="0" />
            <button type="button" onclick="addQuestion()">Add Question</button>
            <button type="button" onclick="removeQuestion()">Remove Last</button>
            <hr />
            <button type="submit">Create Quiz</button>
        </form>
    </div>

    <script>
        let qIndex = 0;
        function addQuestion() {
            const container = document.getElementById('questions');
            const idx = qIndex++;
            const div = document.createElement('div');
            div.className = 'question-block';
            div.id = 'q' + idx;
            div.innerHTML = `
                <label>Question ${idx+1}</label><br>
                <textarea name="q${idx}_text" required style="width:100%" rows="2"></textarea>
                <div style="display:flex; gap:8px; margin-top:8px;">
                    <input placeholder="Option A" name="q${idx}_a" required style="flex:1" />
                    <input placeholder="Option B" name="q${idx}_b" required style="flex:1" />
                    <input placeholder="Option C" name="q${idx}_c" required style="flex:1" />
                    <input placeholder="Option D" name="q${idx}_d" required style="flex:1" />
                </div>
                <div style="margin-top:6px;">
                    <label>Correct Option:</label>
                    <select name="q${idx}_correct">
                        <option value="A">A</option>
                        <option value="B">B</option>
                        <option value="C">C</option>
                        <option value="D">D</option>
                    </select>
                </div>
            `;
            container.appendChild(div);
            document.getElementById('questionCount').value = qIndex;
        }

        function removeQuestion() {
            if (qIndex <= 0) return;
            qIndex--;
            const el = document.getElementById('q' + qIndex);
            if (el) el.remove();
            document.getElementById('questionCount').value = qIndex;
        }
    </script>
</body>
</html>
