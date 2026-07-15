package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SendEmailServlet")
public class SendEmailServlet extends HttpServlet {

    // =============================================
    // PUT YOUR GMAIL DETAILS HERE
    // =============================================
    private static final String FROM_EMAIL    = "hashinisuwanika@gmail.com";
    private static final String FROM_PASSWORD = "nexiugydaxhhihei";
    private static final String FROM_NAME     = "SLIATE Badulla SMS System";
    // =============================================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession ses = request.getSession();

        if("send".equals(action)){
            sendLowAttendanceEmails(request, response, ses);
        } else {
            response.sendRedirect("emailNotify.jsp");
        }
    }

    private void sendLowAttendanceEmails(HttpServletRequest request,
            HttpServletResponse response, HttpSession ses)
            throws IOException {

        String deptFilter  = request.getParameter("dept_id");
        String thresholdStr = request.getParameter("threshold");
        int threshold = 75;
        try{ threshold = Integer.parseInt(thresholdStr); } catch(Exception e){}

        int sentCount    = 0;
        int skippedCount = 0;
        int failedCount  = 0;
        StringBuilder log = new StringBuilder();

        try {
            Connection conn = DBConnection.getConnection();

            // Get all students with their attendance percentage
            String sql =
                "SELECT s.student_id, s.full_name, s.email, s.reg_number, " +
                "d.dept_name, d.dept_code, s.year_level, " +
                "COUNT(a.att_id) as present_days, " +
                "(SELECT COUNT(DISTINCT att_date) FROM attendance WHERE dept_id = d.dept_id) as total_days " +
                "FROM students s " +
                "JOIN departments d ON s.dept_id = d.dept_id " +
                "LEFT JOIN attendance a ON s.student_id = a.student_id AND a.status='Present' " +
                "WHERE 1=1 ";

            if(deptFilter != null && !deptFilter.isEmpty() && !"ALL".equals(deptFilter)){
                sql += " AND s.dept_id = " + deptFilter;
            }
            sql += " GROUP BY s.student_id, s.full_name, s.email, s.reg_number, " +
                   "d.dept_name, d.dept_code, s.year_level " +
                   " HAVING total_days > 0";

            ResultSet rs = conn.createStatement().executeQuery(sql);

            while(rs.next()){
                String email    = rs.getString("email");
                String name     = rs.getString("full_name");
                String regNo    = rs.getString("reg_number");
                String dept     = rs.getString("dept_name");
                String deptCode = rs.getString("dept_code");
                String year     = rs.getString("year_level");
                int present     = rs.getInt("present_days");
                int total       = rs.getInt("total_days");

                if(total == 0) continue;

                int percentage = (present * 100) / total;

                // Only send if below threshold
                if(percentage >= threshold){
                    skippedCount++;
                    continue;
                }

                // Skip if no email
                if(email == null || email.trim().isEmpty() ||
                   email.equals("-") || !email.contains("@")){
                    log.append("SKIPPED (no email): ").append(name).append("<br>");
                    skippedCount++;
                    continue;
                }

                // Send email
                boolean sent = sendEmail(
                    email.trim(), name, regNo, dept,
                    deptCode, year, present, total, percentage
                );

                if(sent){
                    sentCount++;
                    log.append("&#10003; SENT to: ").append(name)
                       .append(" (").append(email).append(") — ")
                       .append(percentage).append("%<br>");
                } else {
                    failedCount++;
                    log.append("&#10007; FAILED: ").append(name)
                       .append(" (").append(email).append(")<br>");
                }
            }
            conn.close();

        } catch(Exception e){
            log.append("Database error: ").append(e.getMessage()).append("<br>");
        }

        // Store results in session
        ses.setAttribute("emailSent",    sentCount);
        ses.setAttribute("emailSkipped", skippedCount);
        ses.setAttribute("emailFailed",  failedCount);
        ses.setAttribute("emailLog",     log.toString());
        ses.setAttribute("emailThreshold", threshold);

        response.sendRedirect("emailNotify.jsp?done=1");
    }

    private boolean sendEmail(String toEmail, String studentName,
            String regNo, String deptName, String deptCode,
            String yearLevel, int presentDays, int totalDays,
            int percentage){
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host",            "smtp.gmail.com");
            props.put("mail.smtp.port",            "587");
            props.put("mail.smtp.auth",            "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");

            Session mailSession = Session.getInstance(props, new Authenticator(){
                @Override
                protected PasswordAuthentication getPasswordAuthentication(){
                    return new PasswordAuthentication(FROM_EMAIL, FROM_PASSWORD);
                }
            });

            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO,
                InternetAddress.parse(toEmail));
            message.setSubject("Low Attendance Alert — " + deptCode +
                               " | SLIATE Badulla");
            message.setContent(buildEmailBody(
                studentName, regNo, deptName, deptCode,
                yearLevel, presentDays, totalDays, percentage
            ), "text/html; charset=utf-8");

            Transport.send(message);
            return true;

        } catch(Exception e){
            System.err.println("Email failed for " + toEmail + ": " + e.getMessage());
            return false;
        }
    }

    private String buildEmailBody(String name, String regNo,
            String dept, String deptCode, String year,
            int present, int total, int percentage){

        String color = percentage < 50 ? "#dc2626" :
                       percentage < 65 ? "#f57c00" : "#e65100";

        return "<!DOCTYPE html>" +
        "<html><head><meta charset='UTF-8'></head>" +
        "<body style='margin:0;padding:0;background:#f0f2f5;font-family:Arial,sans-serif;'>" +
        "<div style='max-width:560px;margin:32px auto;background:white;" +
             "border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.1);'>" +

        // Header
        "<div style='background:linear-gradient(135deg,#1a237e,#1565c0);" +
             "padding:28px 32px;text-align:center;'>" +
        "<h1 style='color:white;font-size:20px;margin:0 0 4px;'>" +
             "Sri Lanka Institute of Advanced Technological Education</h1>" +
        "<p style='color:rgba(255,255,255,0.8);font-size:13px;margin:0;'>Badulla ATI</p>" +
        "</div>" +

        // Alert banner
        "<div style='background:" + color + ";padding:14px 32px;text-align:center;'>" +
        "<p style='color:white;font-size:15px;font-weight:bold;margin:0;'>" +
             "&#9888; Attendance Alert — Action Required</p>" +
        "</div>" +

        // Body
        "<div style='padding:32px;'>" +
        "<p style='font-size:15px;color:#1a1a2e;margin:0 0 20px;'>" +
             "Dear <strong>" + name + "</strong>,</p>" +
        "<p style='font-size:14px;color:#374151;line-height:1.7;margin:0 0 24px;'>" +
             "We are writing to inform you that your attendance record has fallen " +
             "below the minimum required level. Please review your attendance " +
             "details below and take immediate action to improve your attendance.</p>" +

        // Attendance box
        "<div style='background:#fef2f2;border:2px solid #fecaca;" +
             "border-radius:12px;padding:20px;margin-bottom:24px;text-align:center;'>" +
        "<p style='font-size:13px;color:#6b7280;margin:0 0 8px;'>Your Current Attendance</p>" +
        "<p style='font-size:48px;font-weight:800;color:" + color + ";margin:0;'>" +
             percentage + "%</p>" +
        "<p style='font-size:13px;color:#6b7280;margin:4px 0 0;'>" +
             present + " days present out of " + total + " days</p>" +
        "</div>" +

        // Student details table
        "<table style='width:100%;border-collapse:collapse;margin-bottom:24px;'>" +
        "<tr style='background:#f8f9fa;'>" +
        "<td style='padding:10px 14px;font-size:12px;color:#6b7280;" +
             "font-weight:600;border:1px solid #e5e7eb;'>Registration Number</td>" +
        "<td style='padding:10px 14px;font-size:13px;color:#1a1a2e;" +
             "font-weight:600;border:1px solid #e5e7eb;'>" + regNo + "</td>" +
        "</tr>" +
        "<tr>" +
        "<td style='padding:10px 14px;font-size:12px;color:#6b7280;" +
             "font-weight:600;border:1px solid #e5e7eb;'>Department</td>" +
        "<td style='padding:10px 14px;font-size:13px;color:#1a1a2e;" +
             "border:1px solid #e5e7eb;'>" + dept + " (" + deptCode + ")</td>" +
        "</tr>" +
        "<tr style='background:#f8f9fa;'>" +
        "<td style='padding:10px 14px;font-size:12px;color:#6b7280;" +
             "font-weight:600;border:1px solid #e5e7eb;'>Year Level</td>" +
        "<td style='padding:10px 14px;font-size:13px;color:#1a1a2e;" +
             "border:1px solid #e5e7eb;'>" + year + "</td>" +
        "</tr>" +
        "<tr>" +
        "<td style='padding:10px 14px;font-size:12px;color:#6b7280;" +
             "font-weight:600;border:1px solid #e5e7eb;'>Required Attendance</td>" +
        "<td style='padding:10px 14px;font-size:13px;color:#1b5e20;" +
             "font-weight:700;border:1px solid #e5e7eb;'>Minimum 75%</td>" +
        "</tr>" +
        "</table>" +

        "<p style='font-size:13px;color:#374151;line-height:1.7;margin:0 0 16px;'>" +
             "Failure to maintain the required attendance may result in " +
             "<strong>not being eligible</strong> to sit for examinations. " +
             "Please contact your lecturer or the department office if you have any concerns.</p>" +

        "<div style='background:#e8f0fe;border-radius:8px;padding:14px 18px;'>" +
        "<p style='font-size:13px;color:#1a237e;margin:0;'>" +
             "&#128222; Please contact your Head of Department immediately " +
             "if you believe this is an error.</p>" +
        "</div>" +
        "</div>" +

        // Footer
        "<div style='background:#f8f9fa;padding:20px 32px;text-align:center;" +
             "border-top:1px solid #f0f0f0;'>" +
        "<p style='font-size:12px;color:#9ca3af;margin:0 0 4px;'>" +
             "This is an automated message from the SMS System</p>" +
        "<p style='font-size:12px;color:#9ca3af;margin:0;'>" +
             "SLIATE Badulla ATI — Department of " + dept + "</p>" +
        "</div>" +
        "</div></body></html>";
    }
}