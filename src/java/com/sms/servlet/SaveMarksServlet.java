package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SaveMarksServlet")
public class SaveMarksServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId  = request.getParameter("student_id");
        String semester   = request.getParameter("semester");
        String examYear   = request.getParameter("exam_year");
        String[] subjectIds = request.getParameterValues("subject_id");
        String[] grades     = request.getParameterValues("grade");

        try {
            Connection conn = DBConnection.getConnection();

            for(int i = 0; i < subjectIds.length; i++){
                String grade     = grades[i].trim();
                double gpaPoints = getGPAPoints(grade);

                PreparedStatement check = conn.prepareStatement(
                    "SELECT mark_id FROM marks " +
                    "WHERE student_id=? AND subject_id=? AND exam_year=?"
                );
                check.setInt(1, Integer.parseInt(studentId));
                check.setInt(2, Integer.parseInt(subjectIds[i]));
                check.setString(3, examYear);
                ResultSet rs = check.executeQuery();

                if(rs.next()){
                    PreparedStatement upd = conn.prepareStatement(
                        "UPDATE marks SET grade=?, gpa_points=? " +
                        "WHERE student_id=? AND subject_id=? AND exam_year=?"
                    );
                    upd.setString(1, grade);
                    upd.setDouble(2, gpaPoints);
                    upd.setInt(3, Integer.parseInt(studentId));
                    upd.setInt(4, Integer.parseInt(subjectIds[i]));
                    upd.setString(5, examYear);
                    upd.executeUpdate();
                } else {
                    PreparedStatement ins = conn.prepareStatement(
                        "INSERT INTO marks " +
                        "(student_id, subject_id, grade, gpa_points, exam_year, semester) " +
                        "VALUES (?,?,?,?,?,?)"
                    );
                    ins.setInt(1, Integer.parseInt(studentId));
                    ins.setInt(2, Integer.parseInt(subjectIds[i]));
                    ins.setString(3, grade);
                    ins.setDouble(4, gpaPoints);
                    ins.setString(5, examYear);
                    ins.setInt(6, Integer.parseInt(semester));
                    ins.executeUpdate();
                }
            }
            conn.close();
            response.sendRedirect("marks.jsp?success=saved&sid=" + studentId);

        } catch(Exception e){
            response.sendRedirect("marks.jsp?error=" +
                java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));
        }
    }

    public static double getGPAPoints(String grade){
        if(grade == null) return 0.0;
        grade = grade.trim();
        if("A+".equals(grade))   return 4.0;
        if("A".equals(grade))    return 4.0;
        if("A-".equals(grade))   return 3.7;
        if("B+".equals(grade))   return 3.3;
        if("B".equals(grade))    return 3.0;
        if("B-".equals(grade))   return 2.7;
        if("C+".equals(grade))   return 2.3;
        if("C".equals(grade))    return 2.0;
        if("C-".equals(grade))   return 1.7;
        if("E".equals(grade))    return 0.0;
        if("NE".equals(grade))   return 0.0;
        if("AB".equals(grade))   return 0.0;
        if("DFR".equals(grade))  return 0.0;
        // I(SE) = not counted in GPA
        return -1.0;
    }
}