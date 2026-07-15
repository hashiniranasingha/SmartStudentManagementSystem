package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DeleteStudentServlet")
public class DeleteStudentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId = request.getParameter("id");

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM students WHERE student_id=?");
            ps.setInt(1, Integer.parseInt(studentId));
            ps.executeUpdate();
            conn.close();
            response.sendRedirect("students.jsp?success=deleted");

        } catch(Exception e){
            response.sendRedirect("students.jsp?error=" + e.getMessage());
        }
    }
}