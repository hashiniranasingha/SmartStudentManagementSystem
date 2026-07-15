package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SaveClassMarksServlet")
public class SaveClassMarksServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String semester   = request.getParameter("semester");
        String examYear   = request.getParameter("exam_year");
        String deptId     = request.getParameter("dept_id");
        String subjectId  = request.getParameter("subject_id");
        String[] studentIds = request.getParameterValues("student_id");
        String[] grades     = request.getParameterValues("grade");

        try {
            Connection conn = DBConnection.getConnection();

            for(int i = 0; i < studentIds.length; i++){
                String grade = grades[i].trim();
                if(grade.isEmpty()) continue;

                double gpaPoints = SaveMarksServlet.getGPAPoints(grade);

                PreparedStatement check = conn.prepareStatement(
                    "SELECT mark_id FROM marks " +
                    "WHERE student_id=? AND subject_id=? AND exam_year=?"
                );
                check.setInt(1, Integer.parseInt(studentIds[i]));
                check.setInt(2, Integer.parseInt(subjectId));
                check.setString(3, examYear);
                ResultSet rs = check.executeQuery();

                if(rs.next()){
                    PreparedStatement upd = conn.prepareStatement(
                        "UPDATE marks SET grade=?, gpa_points=? " +
                        "WHERE student_id=? AND subject_id=? AND exam_year=?"
                    );
                    upd.setString(1, grade);
                    upd.setDouble(2, gpaPoints);
                    upd.setInt(3, Integer.parseInt(studentIds[i]));
                    upd.setInt(4, Integer.parseInt(subjectId));
                    upd.setString(5, examYear);
                    upd.executeUpdate();
                } else {
                    PreparedStatement ins = conn.prepareStatement(
                        "INSERT INTO marks " +
                        "(student_id, subject_id, grade, gpa_points, exam_year, semester) " +
                        "VALUES (?,?,?,?,?,?)"
                    );
                    ins.setInt(1, Integer.parseInt(studentIds[i]));
                    ins.setInt(2, Integer.parseInt(subjectId));
                    ins.setString(3, grade);
                    ins.setDouble(4, gpaPoints);
                    ins.setString(5, examYear);
                    ins.setInt(6, Integer.parseInt(semester));
                    ins.executeUpdate();
                }
            }
            conn.close();
            response.sendRedirect("classMarks.jsp?success=saved&dept=" +
                deptId + "&sem=" + semester);

        } catch(Exception e){
            response.sendRedirect("classMarks.jsp?error=" +
                java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));
        }
    }
}