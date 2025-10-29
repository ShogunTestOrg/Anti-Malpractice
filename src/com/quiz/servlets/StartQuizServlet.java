package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import com.quiz.models.Question;
import com.quiz.utils.DatabaseConnection;
import com.quiz.utils.SessionValidator;

@WebServlet(name = "StartQuizServlet", urlPatterns = {"/start-quiz"})
public class StartQuizServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!SessionValidator.isValidSession(session)) {
            response.sendRedirect("index.jsp?error=session");
            return;
        }

        String username = (String) session.getAttribute("username");
        if (username == null) {
            response.sendRedirect("index.jsp?error=session");
            return;
        }

        String quizIdParam = request.getParameter("quizId");
        Integer quizTemplateId = null;
        try { quizTemplateId = Integer.parseInt(quizIdParam); } catch (Exception e) { quizTemplateId = null; }

        // generate instance id
        String quizInstanceId = "QUIZ-" + System.currentTimeMillis();
        session.setAttribute("quizId", quizInstanceId);

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            // get user id
            String getUserSql = "SELECT id FROM users WHERE username = ?";
            pstmt = conn.prepareStatement(getUserSql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            int userId = 0;
            if (rs.next()) userId = rs.getInt("id");
            rs.close(); pstmt.close();

            if (userId == 0) {
                response.sendRedirect("available_quizzes.jsp?error=no_user");
                return;
            }

            // insert quiz instance
            String insertSql = "INSERT INTO quizzes (quiz_id, user_id, start_time, status) VALUES (?, ?, ?, CAST(? AS quiz_status))";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, quizInstanceId);
            pstmt.setInt(2, userId);
            pstmt.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            pstmt.setString(4, "in_progress");
            pstmt.executeUpdate();
            pstmt.close();

            // load questions from template if available
            List<Question> questions = new ArrayList<>();
            if (quizTemplateId != null) {
                // fetch quiz title for display
                try (PreparedStatement tstmt = conn.prepareStatement("SELECT title FROM quizzes_master WHERE id = ?")) {
                    tstmt.setInt(1, quizTemplateId);
                    try (ResultSet trs = tstmt.executeQuery()) {
                        if (trs.next()) {
                            session.setAttribute("quizTitle", trs.getString("title"));
                        }
                    }
                } catch (Exception e) {
                    // ignore title fetch errors
                }
                String qSql = "SELECT question_text, option_a, option_b, option_c, option_d, correct_option, question_type, numerical_answer, answer_tolerance FROM quiz_questions WHERE quiz_id = ? ORDER BY question_id ASC";
                pstmt = conn.prepareStatement(qSql);
                pstmt.setInt(1, quizTemplateId);
                rs = pstmt.executeQuery();
                int idx = 0;
                while (rs.next()) {
                    String text = rs.getString("question_text");
                    String questionType = rs.getString("question_type");
                    
                    if ("numerical".equalsIgnoreCase(questionType)) {
                        // Create numerical question
                        double numericalAnswer = rs.getDouble("numerical_answer");
                        double tolerance = rs.getDouble("answer_tolerance");
                        Question q = new Question(idx + 1, text, new ArrayList<>(), 0);
                        q.setQuestionType("numerical");
                        q.setNumericalAnswer(numericalAnswer);
                        q.setAnswerTolerance(tolerance);
                        questions.add(q);
                    } else {
                        // Create multiple choice question
                        List<String> opts = new ArrayList<>();
                        opts.add(rs.getString("option_a"));
                        opts.add(rs.getString("option_b"));
                        opts.add(rs.getString("option_c"));
                        opts.add(rs.getString("option_d"));
                        String correct = rs.getString("correct_option");
                        int correctIdx = 0;
                        if ("B".equalsIgnoreCase(correct)) correctIdx = 1;
                        else if ("C".equalsIgnoreCase(correct)) correctIdx = 2;
                        else if ("D".equalsIgnoreCase(correct)) correctIdx = 3;
                        Question q = new Question(idx + 1, text, opts, correctIdx);
                        q.setQuestionType("multiple_choice");
                        questions.add(q);
                    }
                    idx++;
                }
                rs.close(); pstmt.close();
            }

            if (questions.isEmpty()) {
                // fallback to the shared default question pool
                session.removeAttribute("quizTemplateId");
                session.setAttribute("questions", com.quiz.servlets.QuizServlet.getDefaultQuestions());
                session.removeAttribute("quizTitle");
            } else {
                session.setAttribute("quizTemplateId", quizTemplateId);
                session.setAttribute("questions", questions);
            }

            session.setAttribute("currentIndex", 0);
            session.setAttribute("answers", new HashMap<Integer, Integer>());
            session.setAttribute("numericalAnswers", new HashMap<Integer, Double>());
            session.setAttribute("violationCount", 0);
            session.setAttribute("startTime", System.currentTimeMillis());

            response.sendRedirect("quiz.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("available_quizzes.jsp?error=start_failed");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}
