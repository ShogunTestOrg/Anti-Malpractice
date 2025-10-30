package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import com.quiz.models.Question;
import com.quiz.utils.SessionValidator;
import com.quiz.utils.DatabaseConnection;
import com.quiz.utils.Logger;

public class QuizServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Session attribute constants
    private static final String ATTR_QUESTIONS = "questions";
    private static final String ATTR_CURRENT_INDEX = "currentIndex";
    private static final String ATTR_ANSWERS = "answers";
    private static final String ATTR_VIOLATION_COUNT = "violationCount";
    private static final String ATTR_START_TIME = "startTime";
    private static final String ATTR_QUIZ_ID = "quizId";
    private static final String ATTR_QUIZ_TEMPLATE_ID = "quizTemplateId";
    private static final String ATTR_QUIZ_TITLE = "quizTitle";
    private static final String ATTR_TIME_LIMIT = "timeLimit";
    private static final String ATTR_ERROR = "error";
    private static final String ATTR_SCORE = "score";
    private static final String ATTR_TOTAL_QUESTIONS = "totalQuestions";
    private static final String ATTR_AUTO_SUBMITTED = "autoSubmitted";
    
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
        
        Logger.logDebug("=== DOPOST CALLED ===");
        
        HttpSession session = request.getSession(false);
        if (!SessionValidator.isValidSession(session)) {
            Logger.logDebug("Invalid session, redirecting to login");
            response.sendRedirect("index.jsp?error=session");
            return;
        }
        
        String action = request.getParameter("action");
        String navigation = request.getParameter("navigation");
        
        Logger.logDebug("Action parameter: " + action);
        Logger.logDebug("Navigation parameter: " + navigation);
        
        // Debug: print all parameters
        Logger.logDebug("All parameters:");
        java.util.Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            Logger.logDebug("  " + paramName + " = " + request.getParameter(paramName));
        }
        
        try {
            if ("answer".equals(action)) {
                processAnswer(request, response, session);
            }
            
            if (navigation != null) {
                handleNavigation(request, response, session, navigation);
            } else {
                Logger.logDebug("WARNING: navigation parameter is NULL!");
            }
        } catch (Exception e) {
            Logger.logError("Error processing quiz request", e);
            response.sendRedirect("quiz.jsp?error=internal");
        }
        
        Logger.logDebug("=== DOPOST COMPLETED ===");
    }
    
    private void startQuiz(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String username = (String) session.getAttribute("username");
        
        Logger.logDebug("=== QUIZ START REQUESTED ===");
        Logger.logDebug("Username: " + username);
        
        // Determine if a quizId parameter (template) was provided
        String quizIdParam = request.getParameter("quizId");
        Integer quizTemplateId = null;
        if (quizIdParam != null && !quizIdParam.trim().isEmpty()) {
            try { 
                quizTemplateId = Integer.parseInt(quizIdParam); 
                session.setAttribute(ATTR_QUIZ_TEMPLATE_ID, quizTemplateId);
            } catch (Exception e) { 
                Logger.logError("Failed to parse quiz template ID", e);
                quizTemplateId = null; 
            }
        }

        String quizId = "QUIZ-" + System.currentTimeMillis();
        session.setAttribute(ATTR_QUIZ_ID, quizId);
        Logger.logDebug("Generated Quiz ID: " + quizId);
        Logger.logDebug("Quiz session started for user: " + username);
        
        System.out.println("=== QUIZ START COMPLETED ===");
        
    // Generate or load questions (In production, fetch from database)
    List<Question> questions = new ArrayList<>();

            if (quizTemplateId != null) {
            // Load quiz title and questions from template
            try (Connection qConn = DatabaseConnection.getConnection()) {
                // First get quiz title and time limit
                try (PreparedStatement titleStmt = qConn.prepareStatement("SELECT title, time_limit FROM quizzes_master WHERE id = ?")) {
                    titleStmt.setInt(1, quizTemplateId);
                    try (ResultSet titleRs = titleStmt.executeQuery()) {
                        if (titleRs.next()) {
                            session.setAttribute("quizTitle", titleRs.getString("title"));
                            session.setAttribute("timeLimit", titleRs.getInt("time_limit"));
                        }
                    }
                }

                // Then load questions
                try (PreparedStatement qPstmt = qConn.prepareStatement(
                    "SELECT question_id, question_text, option_a, option_b, option_c, option_d, correct_option, " +
                    "question_type, numerical_answer, answer_tolerance " +
                    "FROM quiz_questions WHERE quiz_id = ? ORDER BY question_id ASC")) {
                    qPstmt.setInt(1, quizTemplateId);
                    try (ResultSet qRs = qPstmt.executeQuery()) {
                        while (qRs.next()) {
                            String text = qRs.getString("question_text");
                            String questionType = qRs.getString("question_type");
                            int questionId = qRs.getInt("question_id");
                            
                            if ("numerical".equalsIgnoreCase(questionType)) {
                                // Create numerical question
                                double numericalAnswer = qRs.getDouble("numerical_answer");
                                double tolerance = qRs.getDouble("answer_tolerance");
                                Question q = new Question(questionId, text, new ArrayList<>(), 0);
                                q.setQuestionType("numerical");
                                q.setNumericalAnswer(numericalAnswer);
                                q.setAnswerTolerance(tolerance);
                                questions.add(q);
                                Logger.logDebug("Added numerical question: " + text);
                            } else {
                                // Create multiple choice question
                                List<String> opts = new ArrayList<>();
                                String optA = qRs.getString("option_a");
                                String optB = qRs.getString("option_b");
                                String optC = qRs.getString("option_c");
                                String optD = qRs.getString("option_d");
                                String correct = qRs.getString("correct_option");
                                
                                opts.add(optA != null ? optA.trim() : "");
                                opts.add(optB != null ? optB.trim() : "");
                                opts.add(optC != null ? optC.trim() : "");
                                opts.add(optD != null ? optD.trim() : "");
                                
                                int correctIdx = 0;
                                if (correct != null) {
                                    correct = correct.trim().toUpperCase();
                                    switch (correct) {
                                        case "B": correctIdx = 1; break;
                                        case "C": correctIdx = 2; break;
                                        case "D": correctIdx = 3; break;
                                        default: correctIdx = 0;
                                    }
                                }
                                Question q = new Question(questionId, text, opts, correctIdx);
                                q.setQuestionType("multiple_choice");
                                questions.add(q);
                                Logger.logDebug("Added multiple choice question: " + text);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("error", "Failed to load quiz: " + e.getMessage());
                response.sendRedirect("available_quizzes.jsp");
                return;
            }
            
            if (questions.isEmpty()) {
                session.setAttribute("error", "No questions found for this quiz.");
                response.sendRedirect("available_quizzes.jsp");
                return;
            }
        } else {
            // fallback to generated pool
            questions = generateQuestions();
        }
        
        // Randomize questions
        Collections.shuffle(questions);
        
        System.out.println("=== RESETTING SESSION ATTRIBUTES ===");
        session.setAttribute(ATTR_QUESTIONS, questions);
        session.setAttribute(ATTR_CURRENT_INDEX, 0);
        session.setAttribute(ATTR_ANSWERS, new HashMap<Integer, Integer>());
        session.setAttribute(ATTR_VIOLATION_COUNT, 0);
        session.setAttribute(ATTR_START_TIME, System.currentTimeMillis());
        Logger.logDebug("Session attributes initialized for quiz " + quizId);
        System.out.println("Violation count reset to: 0");
        System.out.println("=== SESSION ATTRIBUTES RESET COMPLETE ===");
        
        response.sendRedirect("quiz.jsp");
    }
    
    private void processAnswer(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        Logger.logDebug("=== PROCESS ANSWER ===");
        String answerStr = request.getParameter("answer");
        String numericalAnswerStr = request.getParameter("numerical_answer");
        Integer currentIndex = (Integer) session.getAttribute(ATTR_CURRENT_INDEX);
        
        Logger.logDebug("MC Answer: " + answerStr);
        Logger.logDebug("Numerical Answer: " + numericalAnswerStr);
        Logger.logDebug("Current Index: " + currentIndex);
        
        if (currentIndex != null) {
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> answers = (Map<Integer, Integer>) session.getAttribute(ATTR_ANSWERS);
            @SuppressWarnings("unchecked")
            Map<Integer, Double> numericalAnswers = (Map<Integer, Double>) session.getAttribute("numericalAnswers");
            
            if (answers == null) {
                answers = new HashMap<>();
                session.setAttribute(ATTR_ANSWERS, answers);
                Logger.logDebug("Created new answers map");
            }
            
            if (numericalAnswers == null) {
                numericalAnswers = new HashMap<>();
                session.setAttribute("numericalAnswers", numericalAnswers);
                Logger.logDebug("Created new numerical answers map");
            }
            
            // Handle numerical answer
            if (numericalAnswerStr != null && !numericalAnswerStr.trim().isEmpty()) {
                try {
                    double numericalAnswer = Double.parseDouble(numericalAnswerStr);
                    numericalAnswers.put(currentIndex, numericalAnswer);
                    Logger.logDebug("Stored numerical answer " + numericalAnswer + " for question " + currentIndex);
                } catch (NumberFormatException e) {
                    Logger.logError("Invalid numerical answer format: " + numericalAnswerStr, e);
                }
            }
            // Handle multiple choice answer
            else if (answerStr != null) {
                answers.put(currentIndex, Integer.parseInt(answerStr));
                Logger.logDebug("Stored MC answer " + answerStr + " for question " + currentIndex);
            } else {
                Logger.logDebug("No answer provided");
            }
        } else {
            Logger.logDebug("currentIndex is null");
        }
        Logger.logDebug("=== PROCESS ANSWER COMPLETED ===");
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
        Map<Integer, Double> numericalAnswers = (Map<Integer, Double>) session.getAttribute("numericalAnswers");
        @SuppressWarnings("unchecked")
        List<Question> questions = (List<Question>) session.getAttribute("questions");
        
        // Calculate score
        int score = 0;
        if (questions != null) {
            for (int i = 0; i < questions.size(); i++) {
                Question question = questions.get(i);
                
                if (question.isNumerical()) {
                    // Check numerical answer
                    if (numericalAnswers != null) {
                        Double studentAnswer = numericalAnswers.get(i);
                        if (studentAnswer != null && question.checkNumericalAnswer(studentAnswer)) {
                            score++;
                            Logger.logDebug("Question " + i + " (numerical) correct: " + studentAnswer);
                        } else {
                            Logger.logDebug("Question " + i + " (numerical) incorrect: " + studentAnswer + 
                                          " (expected: " + question.getNumericalAnswer() + " ±" + question.getAnswerTolerance() + ")");
                        }
                    }
                } else {
                    // Check multiple choice answer
                    if (answers != null) {
                        Integer answer = answers.get(i);
                        if (answer != null && answer == question.getCorrectAnswer()) {
                            score++;
                            Logger.logDebug("Question " + i + " (MC) correct: " + answer);
                        } else {
                            Logger.logDebug("Question " + i + " (MC) incorrect: " + answer + 
                                          " (expected: " + question.getCorrectAnswer() + ")");
                        }
                    }
                }
            }
        }
        
        // Insert quiz attempt record to database
        Object tmplObj = session.getAttribute("quizTemplateId");
        if (tmplObj != null) {
            try (Connection rConn = DatabaseConnection.getConnection()) {
                // Insert into quiz_attempts for tracking
                String insertAttemptSql = "INSERT INTO quiz_attempts (quiz_instance_id, student_id, quiz_id, score, percentage, " +
                                        "start_time, end_time, status, total_questions) " +
                                        "SELECT ?, u.id, ?, ?, ?, ?, CURRENT_TIMESTAMP, CAST(? AS quiz_status), ? " +
                                        "FROM users u WHERE u.username = ?";
                try (PreparedStatement ap = rConn.prepareStatement(insertAttemptSql)) {
                    double percentage = questions != null && questions.size() > 0 ? 
                                      (double) score / questions.size() * 100 : 0.0;
                    String status = "true".equals(autoSubmit) ? "auto_submitted" : "completed";
                    Long startTime = (Long) session.getAttribute(ATTR_START_TIME);
                    
                    ap.setString(1, quizId);  // quiz_instance_id like "QUIZ-1761797380480"
                    ap.setInt(2, (Integer) tmplObj);  // quiz_id (template reference)
                    ap.setInt(3, score);
                    ap.setDouble(4, percentage);
                    ap.setTimestamp(5, new Timestamp(startTime != null ? startTime : System.currentTimeMillis()));
                    ap.setString(6, status);
                    ap.setInt(7, questions != null ? questions.size() : 0);
                    ap.setString(8, username);
                    
                    int rows = ap.executeUpdate();
                    System.out.println("[INFO] Quiz " + status + ": " + quizId + " for user: " + username + " with score: " + score + "/" + questions.size());
                }
            } catch (SQLException e) {
                System.err.println("[ERROR] Failed to insert quiz attempt record: " + e.getMessage());
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

    // Provide default questions for reuse by other servlets
    public static List<Question> getDefaultQuestions() {
        QuizServlet tmp = new QuizServlet();
        return tmp.generateQuestions();
    }
}
