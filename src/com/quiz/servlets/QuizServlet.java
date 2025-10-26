package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import com.quiz.models.Question;
import com.quiz.utils.SessionValidator;
import com.quiz.utils.DatabaseConnection;

public class QuizServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (!SessionValidator.isValidSession(session)) {
            response.sendRedirect("index.jsp?error=session");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("start".equals(action)) {
            startQuiz(request, response, session);
        } else {
            response.sendRedirect("quiz.jsp");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== DOPOST CALLED ===");
        
        HttpSession session = request.getSession(false);
        if (!SessionValidator.isValidSession(session)) {
            System.out.println("Invalid session, redirecting to login");
            response.sendRedirect("index.jsp?error=session");
            return;
        }
        
        String action = request.getParameter("action");
        String navigation = request.getParameter("navigation");
        
        System.out.println("Action parameter: " + action);
        System.out.println("Navigation parameter: " + navigation);
        
        // Debug: print all parameters
        System.out.println("All parameters:");
        java.util.Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            System.out.println("  " + paramName + " = " + request.getParameter(paramName));
        }
        
        if ("answer".equals(action)) {
            processAnswer(request, response, session);
        }
        
        if (navigation != null) {
            handleNavigation(request, response, session, navigation);
        } else {
            System.out.println("WARNING: navigation parameter is NULL!");
        }
        
        System.out.println("=== DOPOST COMPLETED ===");
    }
    
    private void startQuiz(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String username = (String) session.getAttribute("username");
        
        System.out.println("=== QUIZ START REQUESTED ===");
        System.out.println("Username: " + username);
        
        // Generate quiz ID
        String quizId = "QUIZ-" + System.currentTimeMillis();
        session.setAttribute("quizId", quizId);
        System.out.println("Generated Quiz ID: " + quizId);
        
        // Insert quiz record into database
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            System.out.println("Getting database connection...");
            conn = DatabaseConnection.getConnection();
            System.out.println("Connection obtained: " + (conn != null ? "SUCCESS" : "FAILED"));
            
            // First, get user_id from username
            String getUserIdSql = "SELECT id FROM users WHERE username = ?";
            pstmt = conn.prepareStatement(getUserIdSql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            
            int userId = 0;
            if (rs.next()) {
                userId = rs.getInt("id");
                System.out.println("Found user_id: " + userId);
            } else {
                System.err.println("ERROR: User not found in database: " + username);
            }
            rs.close();
            pstmt.close();
            
            if (userId > 0) {
                // Insert quiz record - cast status to enum type
                String sql = "INSERT INTO quizzes (quiz_id, user_id, start_time, status) VALUES (?, ?, ?, CAST(? AS quiz_status))";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, quizId);
                pstmt.setInt(2, userId);
                pstmt.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
                pstmt.setString(4, "in_progress");
                
                System.out.println("Executing quiz insert...");
                int rows = pstmt.executeUpdate();
                System.out.println("Quiz record inserted! Rows affected: " + rows);
            }
            
            System.out.println("[INFO] Quiz started: " + quizId + " for user: " + username);
        } catch (SQLException e) {
            System.err.println("!!! SQL ERROR in startQuiz !!!");
            System.err.println("[ERROR] Failed to insert quiz record: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        System.out.println("=== QUIZ START COMPLETED ===");
        
        // Generate questions (In production, fetch from database)
        List<Question> questions = generateQuestions();
        
        // Randomize questions
        Collections.shuffle(questions);
        
        System.out.println("=== RESETTING SESSION ATTRIBUTES ===");
        session.setAttribute("questions", questions);
        session.setAttribute("currentIndex", 0);
        session.setAttribute("answers", new HashMap<Integer, Integer>());
        session.setAttribute("violationCount", 0);
        session.setAttribute("startTime", System.currentTimeMillis());
        System.out.println("Violation count reset to: 0");
        System.out.println("=== SESSION ATTRIBUTES RESET COMPLETE ===");
        
        response.sendRedirect("quiz.jsp");
    }
    
    private void processAnswer(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        System.out.println("=== PROCESS ANSWER ===");
        String answerStr = request.getParameter("answer");
        Integer currentIndex = (Integer) session.getAttribute("currentIndex");
        
        System.out.println("Answer: " + answerStr);
        System.out.println("Current Index: " + currentIndex);
        
        if (answerStr != null && currentIndex != null) {
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> answers = (Map<Integer, Integer>) session.getAttribute("answers");
            
            if (answers == null) {
                answers = new HashMap<>();
                session.setAttribute("answers", answers);
                System.out.println("Created new answers map");
            }
            
            answers.put(currentIndex, Integer.parseInt(answerStr));
            System.out.println("Stored answer " + answerStr + " for question " + currentIndex);
        } else {
            System.out.println("No answer provided or currentIndex is null");
        }
        System.out.println("=== PROCESS ANSWER COMPLETED ===");
    }
    
    private void handleNavigation(HttpServletRequest request, HttpServletResponse response, 
                                   HttpSession session, String navigation)
            throws ServletException, IOException {
        
        System.out.println("=== HANDLE NAVIGATION ===");
        System.out.println("Navigation: " + navigation);
        
        Integer currentIndex = (Integer) session.getAttribute("currentIndex");
        @SuppressWarnings("unchecked")
        List<Question> questions = (List<Question>) session.getAttribute("questions");
        
        System.out.println("Current Index: " + currentIndex);
        System.out.println("Questions: " + (questions != null ? questions.size() : "NULL"));
        
        if (currentIndex == null || questions == null) {
            System.out.println("ERROR: currentIndex or questions is null, redirecting to start");
            response.sendRedirect("quiz?action=start");
            return;
        }
        
        switch (navigation) {
            case "next":
                System.out.println("Navigation: next");
                if (currentIndex < questions.size() - 1) {
                    session.setAttribute("currentIndex", currentIndex + 1);
                    System.out.println("Updated currentIndex to: " + (currentIndex + 1));
                } else {
                    System.out.println("Already at last question");
                }
                response.sendRedirect("quiz.jsp");
                break;
                
            case "previous":
                System.out.println("Navigation: previous");
                if (currentIndex > 0) {
                    session.setAttribute("currentIndex", currentIndex - 1);
                    System.out.println("Updated currentIndex to: " + (currentIndex - 1));
                }
                response.sendRedirect("quiz.jsp");
                break;
                
            case "submit":
                System.out.println("Navigation: submit");
                submitQuiz(request, response, session);
                break;
                
            default:
                System.out.println("Navigation: default case");
                response.sendRedirect("quiz.jsp");
        }
        System.out.println("=== HANDLE NAVIGATION COMPLETED ===");
    }
    
    private void submitQuiz(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String quizId = (String) session.getAttribute("quizId");
        String username = (String) session.getAttribute("username");
        String autoSubmit = request.getParameter("autoSubmit");
        
        @SuppressWarnings("unchecked")
        Map<Integer, Integer> answers = (Map<Integer, Integer>) session.getAttribute("answers");
        @SuppressWarnings("unchecked")
        List<Question> questions = (List<Question>) session.getAttribute("questions");
        
        // Calculate score
        int score = 0;
        if (answers != null && questions != null) {
            for (int i = 0; i < questions.size(); i++) {
                Integer answer = answers.get(i);
                if (answer != null && answer == questions.get(i).getCorrectAnswer()) {
                    score++;
                }
            }
        }
        
        // Update quiz record in database
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE quizzes SET status = CAST(? AS quiz_status), end_time = ?, score = ? WHERE quiz_id = ?";
            pstmt = conn.prepareStatement(sql);
            
            // Set status based on auto-submit flag
            String status = "true".equals(autoSubmit) ? "auto_submitted" : "completed";
            pstmt.setString(1, status);
            pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            pstmt.setInt(3, score);
            pstmt.setString(4, quizId);
            pstmt.executeUpdate();
            
            System.out.println("[INFO] Quiz " + status + ": " + quizId + " for user: " + username + " with score: " + score);
        } catch (SQLException e) {
            System.err.println("[ERROR] Failed to update quiz record: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        // Store results
        session.setAttribute("score", score);
        session.setAttribute("totalQuestions", questions != null ? questions.size() : 0);
        session.setAttribute("autoSubmitted", "true".equals(autoSubmit));
        
        // Clean up quiz session
        session.removeAttribute("questions");
        session.removeAttribute("currentIndex");
        session.removeAttribute("answers");
        
        response.sendRedirect("result.jsp");
    }
    
    private List<Question> generateQuestions() {
        List<Question> questions = new ArrayList<>();
        
        // Sample questions (In production, fetch from database)
        questions.add(new Question(
            1,
            "What is the capital of France?",
            Arrays.asList("London", "Berlin", "Paris", "Madrid"),
            2
        ));
        
        questions.add(new Question(
            2,
            "What is 2 + 2?",
            Arrays.asList("3", "4", "5", "6"),
            1
        ));
        
        questions.add(new Question(
            3,
            "Which planet is known as the Red Planet?",
            Arrays.asList("Venus", "Mars", "Jupiter", "Saturn"),
            1
        ));
        
        questions.add(new Question(
            4,
            "What is the largest ocean on Earth?",
            Arrays.asList("Atlantic", "Indian", "Arctic", "Pacific"),
            3
        ));
        
        questions.add(new Question(
            5,
            "Who wrote 'Romeo and Juliet'?",
            Arrays.asList("Charles Dickens", "William Shakespeare", "Jane Austen", "Mark Twain"),
            1
        ));
        
        questions.add(new Question(
            6,
            "What is the chemical symbol for water?",
            Arrays.asList("H2O", "CO2", "O2", "NaCl"),
            0
        ));
        
        questions.add(new Question(
            7,
            "How many continents are there?",
            Arrays.asList("5", "6", "7", "8"),
            2
        ));
        
        questions.add(new Question(
            8,
            "What is the smallest prime number?",
            Arrays.asList("0", "1", "2", "3"),
            2
        ));
        
        questions.add(new Question(
            9,
            "Which programming language is used for Android development?",
            Arrays.asList("Python", "Java", "C++", "Ruby"),
            1
        ));
        
        questions.add(new Question(
            10,
            "What year did World War II end?",
            Arrays.asList("1943", "1944", "1945", "1946"),
            2
        ));
        
        return questions;
    }
}
