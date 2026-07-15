package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EditStudentServlet")
public class EditStudentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId  = request.getParameter("student_id");
        String regNumber  = request.getParameter("reg_number");
        String fullName   = request.getParameter("full_name");
        String email      = request.getParameter("email");
        String phone      = request.getParameter("phone");
        String deptId     = request.getParameter("dept_id");
        String yearLevel  = request.getParameter("year_level");
        String courseName = request.getParameter("course_name");

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE students SET reg_number=?, full_name=?, email=?, phone=?, " +
                "dept_id=?, year_level=?, course_name=? WHERE student_id=?");
            ps.setString(1, regNumber);
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setInt(5, Integer.parseInt(deptId));
            ps.setString(6, yearLevel);
            ps.setString(7, courseName);
            ps.setInt(8, Integer.parseInt(studentId));
            ps.executeUpdate();
            conn.close();
            response.sendRedirect("students.jsp?success=updated");

        } catch(Exception e){
            response.sendRedirect("students.jsp?error=" + e.getMessage());
        }
    }
}