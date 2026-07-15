package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LMSServlet")
@MultipartConfig(
    maxFileSize    = 10485760,
    maxRequestSize = 15728640
)
public class LMSServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String user   = (String) request.getSession()
                            .getAttribute("loggedUser");

        if("add".equals(action)){
            try{
                String title      = request.getParameter("title");
                String desc       = request.getParameter("description");
                String type       = request.getParameter("material_type");
                String deptId     = request.getParameter("dept_id");
                String subjectId  = request.getParameter("subject_id");
                String semester   = request.getParameter("semester");
                String uploadType = request.getParameter("upload_type");
                if(uploadType == null) uploadType = "link";

                String linkUrl  = "";
                String filePath = "";

                if("file".equals(uploadType)){
                    Part filePart = request.getPart("pdf_file");
                    if(filePart != null && filePart.getSize() > 0){
                        String origName = getSubmittedFileName(filePart);
                        String fileName = System.currentTimeMillis()
                            + "_" + origName.replaceAll(
                                "[^a-zA-Z0-9._-]", "_");
                        String uploadDir = getServletContext()
                            .getRealPath("/") + "uploads";
                        new File(uploadDir).mkdirs();
                        String fullPath = uploadDir +
                            File.separator + fileName;

                        InputStream is = filePart.getInputStream();
                        FileOutputStream fos =
                            new FileOutputStream(fullPath);
                        byte[] buffer = new byte[4096];
                        int len;
                        while((len = is.read(buffer)) != -1){
                            fos.write(buffer, 0, len);
                        }
                        fos.close();
                        is.close();

                        filePath = "uploads/" + fileName;
                        linkUrl  = filePath;
                    }
                } else {
                    linkUrl = request.getParameter("link_url");
                    if(linkUrl == null) linkUrl = "";
                }

                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO lms_materials " +
                    "(title, description, material_type, link_url, " +
                    "dept_id, subject_id, semester, uploaded_by) " +
                    "VALUES(?,?,?,?,?,?,?,?)");
                ps.setString(1, title);
                ps.setString(2, desc != null ? desc : "");
                ps.setString(3, type);
                ps.setString(4, linkUrl);

                if(deptId != null && !deptId.isEmpty()
                   && !"0".equals(deptId))
                    ps.setInt(5, Integer.parseInt(deptId));
                else
                    ps.setNull(5, Types.INTEGER);

                if(subjectId != null && !subjectId.isEmpty()
                   && !"0".equals(subjectId))
                    ps.setInt(6, Integer.parseInt(subjectId));
                else
                    ps.setNull(6, Types.INTEGER);

                if(semester != null && !semester.isEmpty()
                   && !"0".equals(semester))
                    ps.setInt(7, Integer.parseInt(semester));
                else
                    ps.setNull(7, Types.INTEGER);

                ps.setString(8, user);
                ps.executeUpdate();
                conn.close();

                response.sendRedirect("lms.jsp?success=added");

            } catch(Exception e){
                e.printStackTrace();
                response.sendRedirect("lms.jsp?error=" +
                    java.net.URLEncoder.encode(
                        e.getMessage() != null ?
                        e.getMessage() : "Unknown error",
                        "UTF-8"));
            }

        } else if("delete".equals(action)){
            String mid = request.getParameter("material_id");
            try{
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM lms_materials WHERE material_id=?");
                ps.setInt(1, Integer.parseInt(mid));
                ps.executeUpdate();
                conn.close();
                response.sendRedirect("lms.jsp?success=deleted");
            } catch(Exception e){
                response.sendRedirect("lms.jsp?error=" +
                    java.net.URLEncoder.encode(
                        e.getMessage(), "UTF-8"));
            }
        }
    }

    private String getSubmittedFileName(Part part){
        String header = part.getHeader("content-disposition");
        if(header == null) return "file.pdf";
        for(String token : header.split(";")){
            if(token.trim().startsWith("filename")){
                return token.substring(
                    token.indexOf('=') + 1)
                    .trim().replace("\"", "");
            }
        }
        return "file.pdf";
    }
}