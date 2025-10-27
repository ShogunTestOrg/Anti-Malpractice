package com.quiz.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import com.quiz.utils.DatabaseConnection;

@WebServlet(name = "CreateQuizServlet", urlPatterns = {"/create-quiz"})
public class CreateQuizServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("index.jsp?error=unauthorized");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String title = request.getParameter("title").trim();
        String description = request.getParameter("description").trim();
        String timeLimitStr = request.getParameter("timeLimit");
        int timeLimit = 30;
        try { timeLimit = Integer.parseInt(timeLimitStr); } catch (Exception ignored) {}

        String qCountStr = request.getParameter("questionCount");
        int questionCount = 0;
        try { questionCount = Integer.parseInt(qCountStr); } catch (Exception ignored) {}

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

         String insertQuizSql = "INSERT INTO quizzes_master (title, description, time_limit) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(insertQuizSql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, title);
            pstmt.setString(2, description);
            pstmt.setInt(3, timeLimit);
            pstmt.executeUpdate();

            rs = pstmt.getGeneratedKeys();
            int quizId = -1;
            if (rs.next()) quizId = rs.getInt(1);
            rs.close();
            pstmt.close();

            if (quizId > 0) {
                String insertQuestionSql = "INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option) VALUES (?, ?, ?, ?, ?, ?, ?)";
                pstmt = conn.prepareStatement(insertQuestionSql);

                for (int i = 0; i < questionCount; i++) {
                    String prefix = "q" + i + "_";
                    String qText = request.getParameter(prefix + "text");
                    String a = request.getParameter(prefix + "a");
                    String b = request.getParameter(prefix + "b");
                    String c = request.getParameter(prefix + "c");
                    String d = request.getParameter(prefix + "d");
                    String correct = request.getParameter(prefix + "correct");

                    if (qText == null || qText.trim().isEmpty()) continue;

                    pstmt.setInt(1, quizId);
                    pstmt.setString(2, qText.trim());
                    pstmt.setString(3, a == null ? "" : a.trim());
                    pstmt.setString(4, b == null ? "" : b.trim());
                    pstmt.setString(5, c == null ? "" : c.trim());
                    pstmt.setString(6, d == null ? "" : d.trim());
                    pstmt.setString(7, correct == null ? "A" : correct.trim().toUpperCase());
                    pstmt.addBatch();
                }

                pstmt.executeBatch();
                pstmt.close();
            }

            conn.commit();
            response.sendRedirect("admin.jsp?msg=quiz_created");
        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException ignored) {}
            e.printStackTrace();
            response.sendRedirect("admin.jsp?error=quiz_create_failed");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
        }
    }
}
