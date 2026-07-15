package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "SELECT u.*, d.dept_code, d.dept_name " +
                "FROM users u " +
                "LEFT JOIN departments d ON u.dept_id = d.dept_id " +
                "WHERE u.username=? AND u.password=?"
            );
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if(rs.next()){
                HttpSession session = request.getSession();
                String role      = rs.getString("role");
                String fullName  = rs.getString("full_name");
                int    userId    = rs.getInt("user_id");

                session.setAttribute("loggedUser",  fullName);
                session.setAttribute("username",    username);
                session.setAttribute("userRole",    role);
                session.setAttribute("userId",      userId);

                // Store dept info for lecturers
                if("lecturer".equals(role)){
                    session.setAttribute("userDeptId",   String.valueOf(rs.getInt("dept_id")));
                    session.setAttribute("userDeptCode", rs.getString("dept_code") != null ? rs.getString("dept_code") : "");
                    session.setAttribute("userDeptName", rs.getString("dept_name") != null ? rs.getString("dept_name") : "");
                    response.sendRedirect("dashboard.jsp");

                } else if("student".equals(role)){
                    session.setAttribute("studentId", String.valueOf(rs.getInt("student_id")));
                    response.sendRedirect("studentDashboard.jsp");

                } else {
                    // admin
                    response.sendRedirect("dashboard.jsp");
                }

            } else {
                request.setAttribute("errorMsg", "Invalid username or password!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
            conn.close();

        } catch(Exception e){
            request.setAttribute("errorMsg", "Error: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}