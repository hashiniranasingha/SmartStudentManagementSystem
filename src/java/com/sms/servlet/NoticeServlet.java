package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/NoticeServlet")
public class NoticeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String user   = (String)request.getSession()
                            .getAttribute("loggedUser");

        if("add".equals(action)){
            String title    = request.getParameter("title");
            String content  = request.getParameter("content");
            String deptId   = request.getParameter("dept_id");
            String priority = request.getParameter("priority");
            String expires  = request.getParameter("expires_at");

            try{
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO notices " +
                    "(title,content,dept_id,priority," +
                    "posted_by,expires_at) " +
                    "VALUES(?,?,?,?,?,?)");
                ps.setString(1, title);
                ps.setString(2, content);
                if(deptId!=null&&!deptId.isEmpty()&&!"0".equals(deptId))
                    ps.setInt(3, Integer.parseInt(deptId));
                else ps.setNull(3, Types.INTEGER);
                ps.setString(4, priority);
                ps.setString(5, user);
                if(expires!=null&&!expires.isEmpty())
                    ps.setString(6, expires);
                else ps.setNull(6, Types.VARCHAR);
                ps.executeUpdate();
                conn.close();
                response.sendRedirect("notices.jsp?success=added");
            } catch(Exception e){
                response.sendRedirect("notices.jsp?error=" +
                    java.net.URLEncoder.encode(
                        e.getMessage(),"UTF-8"));
            }

        } else if("delete".equals(action)){
            String nid = request.getParameter("notice_id");
            try{
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM notices WHERE notice_id=?");
                ps.setInt(1, Integer.parseInt(nid));
                ps.executeUpdate();
                conn.close();
                response.sendRedirect("notices.jsp?success=deleted");
            } catch(Exception e){
                response.sendRedirect("notices.jsp?error=" +
                    java.net.URLEncoder.encode(
                        e.getMessage(),"UTF-8"));
            }
        }
    }
}