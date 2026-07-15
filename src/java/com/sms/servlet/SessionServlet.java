package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CreateSessionServlet")
public class SessionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String deptId  = request.getParameter("dept_id");
        String minutes = request.getParameter("minutes");
        String user    = (String) request.getSession().getAttribute("loggedUser");

        try {
            Connection conn = DBConnection.getConnection();

            // Generate unique 8-character session code
            String code = generateCode();

            // Make sure code is unique
            PreparedStatement check = conn.prepareStatement(
                "SELECT session_id FROM attendance_sessions WHERE session_code=?");
            check.setString(1, code);
            while(check.executeQuery().next()){
                code = generateCode();
                check.setString(1, code);
            }

            // Today's date
            String today = new java.text.SimpleDateFormat("yyyy-MM-dd")
                               .format(new java.util.Date());

            // Expiry time
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.add(java.util.Calendar.MINUTE, Integer.parseInt(minutes));
            java.sql.Timestamp expires = new java.sql.Timestamp(cal.getTimeInMillis());

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO attendance_sessions " +
                "(session_code, dept_id, session_date, created_by, expires_at, is_active) " +
                "VALUES (?,?,?,?,?,1)"
            );
            ps.setString(1, code);
            ps.setInt(2, Integer.parseInt(deptId));
            ps.setString(3, today);
            ps.setString(4, user);
            ps.setTimestamp(5, expires);
            ps.executeUpdate();

            conn.close();

            response.sendRedirect("qrScan.jsp?session=" + code +
                                  "&dept=" + deptId +
                                  "&mins=" + minutes);

        } catch(Exception e){
            response.sendRedirect("qrScan.jsp?error=" +
                java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    private String generateCode(){
        String chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        StringBuilder sb = new StringBuilder();
        java.util.Random rand = new java.util.Random();
        for(int i = 0; i < 8; i++){
            sb.append(chars.charAt(rand.nextInt(chars.length())));
        }
        return sb.toString();
    }
}