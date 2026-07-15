package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AddStudentServlet")
public class AddStudentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String fullName   = request.getParameter("full_name");
        String email      = request.getParameter("email");
        String phone      = request.getParameter("phone");
        String deptId     = request.getParameter("dept_id");
        String yearLevel  = request.getParameter("year_level");
        String courseName = request.getParameter("course_name");

        try {
            Connection conn = DBConnection.getConnection();

           // Get dept code
PreparedStatement dps = conn.prepareStatement(
    "SELECT dept_code FROM departments WHERE dept_id=?");
dps.setInt(1, Integer.parseInt(deptId));
ResultSet drs = dps.executeQuery();
String deptCode = "XX";
if(drs.next()) deptCode = drs.getString("dept_code");

// Get next index for this dept AND year level
// First Year starts 001, Second Year starts 001 separately
PreparedStatement cps = conn.prepareStatement(
    "SELECT COUNT(*) FROM students " +
    "WHERE dept_id=? AND year_level=?");
cps.setInt(1, Integer.parseInt(deptId));
cps.setString(2, yearLevel);
ResultSet crs = cps.executeQuery();
int nextNum = 1;
if(crs.next()) nextNum = crs.getInt(1) + 1;

// Academic year
java.util.Calendar cal = java.util.Calendar.getInstance();
int year = cal.get(java.util.Calendar.YEAR);
String acadYear = String.valueOf(year-1).substring(2) +
                  String.valueOf(year).substring(2);

// Year code: F=First Year, S=Second Year, T=Third, Q=Fourth
String yearCode = "F";
if("Second Year".equals(yearLevel))      yearCode = "S";
else if("Third Year".equals(yearLevel))  yearCode = "T";
else if("Fourth Year".equals(yearLevel)) yearCode = "Q";

// Format: BAD/IT/2526/F/001
String regNumber = String.format(
    "BAD/%s/%s/%s/%03d",
    deptCode, acadYear, yearCode, nextNum);

            // Check if reg number exists (safety check)
            PreparedStatement chk = conn.prepareStatement(
                "SELECT student_id FROM students WHERE reg_number=?");
            chk.setString(1, regNumber);
            ResultSet chkRs = chk.executeQuery();
            if(chkRs.next()){
                // Try next number
                nextNum++;
                regNumber = String.format(
                    "BAD/%s/%s/F/%03d", deptCode, acadYear, nextNum);
            }

            // Insert student
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO students " +
                "(reg_number,full_name,email,phone," +
                "dept_id,year_level,course_name) " +
                "VALUES(?,?,?,?,?,?,?)");
            ps.setString(1, regNumber);
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setInt(5, Integer.parseInt(deptId));
            ps.setString(6, yearLevel);
            ps.setString(7, courseName);
            ps.executeUpdate();
            conn.close();

            response.sendRedirect("students.jsp?success=added");

        } catch(Exception e){
            request.setAttribute("errorMsg",
                "Error: " + e.getMessage());
            request.getRequestDispatcher("addStudent.jsp")
                   .forward(request, response);
        }
    }
}