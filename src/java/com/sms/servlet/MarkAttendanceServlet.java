package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/MarkAttendanceServlet")
public class MarkAttendanceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // Try multiple ways to get qrData
            String qrData = request.getParameter("qrData");

            // If null try reading raw body
            if(qrData == null || qrData.trim().isEmpty()) {
                java.io.BufferedReader reader = request.getReader();
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
                String body = sb.toString();
                if (body != null && body.contains("qrData=")) {
                    int start = body.indexOf("qrData=") + 7;
                    int end   = body.indexOf("&", start);
                    if (end == -1) end = body.length();
                    qrData = java.net.URLDecoder.decode(
                        body.substring(start, end), "UTF-8");
                }
            }

            if (qrData == null || qrData.trim().isEmpty()) {
                out.print("{\"status\":\"error\"," +
                          "\"message\":\"No QR data received\"}");
                return;
            }

            qrData = qrData.trim();

            if (!qrData.startsWith("SMS|")) {
                out.print("{\"status\":\"error\"," +
                          "\"message\":\"Invalid QR code\"}");
                return;
            }

            String[] parts = qrData.split("\\|", -1);
            if (parts.length < 5) {
                out.print("{\"status\":\"error\"," +
                          "\"message\":\"QR data incomplete\"}");
                return;
            }

            int    studentId = Integer.parseInt(parts[1].trim());
            String regNumber = parts[2].trim();
            String fullName  = parts[3].trim();
            String deptCode  = parts[4].trim();

            Connection conn = DBConnection.getConnection();

            String today = new java.text.SimpleDateFormat("yyyy-MM-dd")
                               .format(new java.util.Date());
            String now   = new java.text.SimpleDateFormat("HH:mm:ss")
                               .format(new java.util.Date());

            // Check already marked
            PreparedStatement chk = conn.prepareStatement(
                "SELECT att_id FROM attendance " +
                "WHERE student_id=? AND att_date=?");
            chk.setInt(1, studentId);
            chk.setString(2, today);
            ResultSet chkRs = chk.executeQuery();

            if (chkRs.next()) {
                conn.close();
                out.print("{\"status\":\"already\"," +
                          "\"name\":\"" + esc(fullName)  + "\"," +
                          "\"reg\":\""  + esc(regNumber) + "\"," +
                          "\"dept\":\"" + esc(deptCode)  + "\"}");
                return;
            }

            // Get dept_id
            int deptId = 0;
            PreparedStatement dp = conn.prepareStatement(
                "SELECT dept_id FROM departments WHERE dept_code=?");
            dp.setString(1, deptCode);
            ResultSet drs = dp.executeQuery();
            if (drs.next()) deptId = drs.getInt("dept_id");

            if (deptId == 0) {
                PreparedStatement sp = conn.prepareStatement(
                    "SELECT dept_id FROM students WHERE student_id=?");
                sp.setInt(1, studentId);
                ResultSet srs = sp.executeQuery();
                if (srs.next()) deptId = srs.getInt("dept_id");
            }

            // Determine status based on time
            // 9:00-9:15 = Present, after 9:15 = Late, else Absent
            String status = "Present";
            try {
                java.text.SimpleDateFormat sdf =
                    new java.text.SimpleDateFormat("HH:mm:ss");
                java.util.Date scanTime = sdf.parse(now);
                java.util.Date startTime= sdf.parse("09:00:00");
                java.util.Date endTime  = sdf.parse("09:15:00");
                if (scanTime.after(endTime)) {
                    status = "Late";
                }
            } catch(Exception te) {
                status = "Present";
            }

            PreparedStatement ins = conn.prepareStatement(
                "INSERT INTO attendance " +
                "(student_id, dept_id, att_date, att_time, status) " +
                "VALUES (?,?,?,?,?)");
            ins.setInt(1, studentId);
            ins.setInt(2, deptId);
            ins.setString(3, today);
            ins.setString(4, now);
            ins.setString(5, status);
            ins.executeUpdate();
            conn.close();

            out.print("{\"status\":\"success\"," +
                      "\"name\":\""   + esc(fullName)  + "\"," +
                      "\"reg\":\""    + esc(regNumber) + "\"," +
                      "\"dept\":\""   + esc(deptCode)  + "\"," +
                      "\"attStatus\":\"" + status      + "\"," +
                      "\"time\":\""   + now            + "\"}");

        } catch (Exception e) {
            out.print("{\"status\":\"error\"," +
                      "\"message\":\"" + esc(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain");
        response.getWriter().print(
            "MarkAttendanceServlet OK");
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}