package com.sms.servlet;

import com.sms.util.DBConnection;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/AttendanceSchedulerServlet")
public class AttendanceSchedulerServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {
        // Start background thread when app starts
        Thread scheduler = new Thread(new Runnable(){
            public void run(){
                while(true){
                    try{
                        java.util.Calendar now =
                            java.util.Calendar.getInstance();
                        int hour   = now.get(java.util.Calendar.HOUR_OF_DAY);
                        int minute = now.get(java.util.Calendar.MINUTE);

                        // Run at 9:20 AM every day
                        if(hour == 9 && minute == 20){
                            markAbsentStudents();
                            // Sleep 1 hour to avoid running twice
                            Thread.sleep(3600000);
                        } else {
                            // Check every minute
                            Thread.sleep(60000);
                        }
                    } catch(Exception e){
                        e.printStackTrace();
                    }
                }
            }
        });
        scheduler.setDaemon(true);
        scheduler.start();
        System.out.println("Attendance Scheduler Started!");
    }

    private void markAbsentStudents(){
        try{
            Connection conn = DBConnection.getConnection();
            String today = new java.text.SimpleDateFormat("yyyy-MM-dd")
                               .format(new java.util.Date());

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO attendance " +
                "(student_id, dept_id, att_date, att_time, status) " +
                "SELECT s.student_id, s.dept_id, ?, '09:15:00', 'Absent' " +
                "FROM students s " +
                "WHERE s.student_id NOT IN (" +
                "   SELECT student_id FROM attendance " +
                "   WHERE att_date=?" +
                ")");
            ps.setString(1, today);
            ps.setString(2, today);
            int count = ps.executeUpdate();
            conn.close();
            System.out.println("Auto marked " + count +
                               " students as Absent for " + today);
        } catch(Exception e){
            System.out.println("Scheduler error: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse res)
            throws IOException {
        res.setContentType("text/plain");
        res.getWriter().print("Scheduler running");
    }
}