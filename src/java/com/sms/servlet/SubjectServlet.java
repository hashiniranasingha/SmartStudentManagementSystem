package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SubjectServlet")
public class SubjectServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action      = request.getParameter("action");
        String subjectId   = request.getParameter("subject_id");
        String deptId      = request.getParameter("dept_id");
        String semester    = request.getParameter("semester");
        String subjectName = request.getParameter("subject_name");
        String creditHours = request.getParameter("credit_hours");

        try {
            Connection conn = DBConnection.getConnection();

            if("add".equals(action)){
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO subjects (dept_id, semester, subject_name, credit_hours) " +
                    "VALUES (?,?,?,?)"
                );
                ps.setInt(1, Integer.parseInt(deptId));
                ps.setInt(2, Integer.parseInt(semester));
                ps.setString(3, subjectName.trim());
                ps.setInt(4, Integer.parseInt(creditHours));
                ps.executeUpdate();
                response.sendRedirect("subjects.jsp?success=added&dept=" + deptId);

            } else if("edit".equals(action)){
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE subjects SET dept_id=?, semester=?, " +
                    "subject_name=?, credit_hours=? WHERE subject_id=?"
                );
                ps.setInt(1, Integer.parseInt(deptId));
                ps.setInt(2, Integer.parseInt(semester));
                ps.setString(3, subjectName.trim());
                ps.setInt(4, Integer.parseInt(creditHours));
                ps.setInt(5, Integer.parseInt(subjectId));
                ps.executeUpdate();
                response.sendRedirect("subjects.jsp?success=updated&dept=" + deptId);

            } else if("delete".equals(action)){
                PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM subjects WHERE subject_id=?"
                );
                ps.setInt(1, Integer.parseInt(subjectId));
                ps.executeUpdate();
                response.sendRedirect("subjects.jsp?success=deleted");
            }

            conn.close();

        } catch(Exception e){
            response.sendRedirect("subjects.jsp?error=" +
                java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));
        }
    }
}