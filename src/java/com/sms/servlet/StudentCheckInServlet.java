package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/checkin")
public class StudentCheckInServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String sessionCode = request.getParameter("s");
        String studentId   = request.getParameter("id");

        if(sessionCode == null || studentId == null){
            response.sendRedirect("studentCheckin.jsp?error=invalid");
            return;
        }

        try {
            Connection conn = DBConnection.getConnection();

            // Validate session - check it exists, is active, not expired
            PreparedStatement sps = conn.prepareStatement(
                "SELECT * FROM attendance_sessions " +
                "WHERE session_code=? AND is_active=1 AND expires_at > NOW()"
            );
            sps.setString(1, sessionCode);
            ResultSet srs = sps.executeQuery();

            if(!srs.next()){
                response.sendRedirect("studentCheckin.jsp?error=expired&s=" + sessionCode);
                conn.close();
                return;
            }

            int    deptId  = srs.getInt("dept_id");
            String sesDate = srs.getString("session_date");

            // Get student info
            PreparedStatement stps = conn.prepareStatement(
                "SELECT s.student_id, s.full_name, s.reg_number, s.dept_id, d.dept_code " +
                "FROM students s " +
                "JOIN departments d ON s.dept_id=d.dept_id " +
                "WHERE s.student_id=?"
            );
            stps.setInt(1, Integer.parseInt(studentId));
            ResultSet strs = stps.executeQuery();

            if(!strs.next()){
                response.sendRedirect("studentCheckin.jsp?error=student&s=" + sessionCode);
                conn.close();
                return;
            }

            String fullName  = strs.getString("full_name");
            String regNumber = strs.getString("reg_number");
            int    stuDeptId = strs.getInt("dept_id");
            String deptCode  = strs.getString("dept_code");

            // Check student belongs to this session's department
            if(stuDeptId != deptId){
                response.sendRedirect("studentCheckin.jsp?error=dept&name=" +
                    java.net.URLEncoder.encode(fullName,"UTF-8") +
                    "&s=" + sessionCode);
                conn.close();
                return;
            }

            // Check already marked today
            PreparedStatement checkAtt = conn.prepareStatement(
                "SELECT att_id FROM attendance " +
                "WHERE student_id=? AND att_date=?"
            );
            checkAtt.setInt(1, Integer.parseInt(studentId));
            checkAtt.setString(2, sesDate);
            ResultSet checkRs = checkAtt.executeQuery();

            if(checkRs.next()){
                response.sendRedirect("studentCheckin.jsp?status=already" +
                    "&name=" + java.net.URLEncoder.encode(fullName,"UTF-8") +
                    "&reg="  + java.net.URLEncoder.encode(regNumber,"UTF-8") +
                    "&dept=" + deptCode +
                    "&s="    + sessionCode);
                conn.close();
                return;
            }

            // Mark attendance
            String currentTime = new java.text.SimpleDateFormat("HH:mm:ss")
                                     .format(new java.util.Date());

            PreparedStatement ins = conn.prepareStatement(
                "INSERT INTO attendance " +
                "(student_id, dept_id, att_date, att_time, status) " +
                "VALUES (?,?,?,?,'Present')"
            );
            ins.setInt(1, Integer.parseInt(studentId));
            ins.setInt(2, deptId);
            ins.setString(3, sesDate);
            ins.setString(4, currentTime);
            ins.executeUpdate();

            conn.close();

            // Redirect to success page
            response.sendRedirect("studentCheckin.jsp?status=success" +
                "&name="  + java.net.URLEncoder.encode(fullName,"UTF-8") +
                "&reg="   + java.net.URLEncoder.encode(regNumber,"UTF-8") +
                "&dept="  + deptCode +
                "&time="  + currentTime +
                "&s="     + sessionCode);

        } catch(Exception e){
            response.sendRedirect("studentCheckin.jsp?error=system&msg=" +
                java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));
        }
    }
}