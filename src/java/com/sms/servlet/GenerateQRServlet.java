package com.sms.servlet;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.sms.util.DBConnection;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Path;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/GenerateQRServlet")
public class GenerateQRServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId = request.getParameter("id");
        String message   = "";
        boolean success  = false;

        try {
            Connection conn = DBConnection.getConnection();

            // Get student details
            PreparedStatement ps = conn.prepareStatement(
                "SELECT s.student_id, s.reg_number, s.full_name, d.dept_code, s.year_level " +
                "FROM students s " +
                "JOIN departments d ON s.dept_id = d.dept_id " +
                "WHERE s.student_id = ?"
            );
            ps.setInt(1, Integer.parseInt(studentId));
            ResultSet rs = ps.executeQuery();

            if(rs.next()){
                String regNumber = rs.getString("reg_number");
                String fullName  = rs.getString("full_name");
                String deptCode  = rs.getString("dept_code");
                String yearLevel = rs.getString("year_level");

                // QR code content - this is what gets scanned
                String qrContent = "SMS|" + studentId + "|" + regNumber + "|" + fullName + "|" + deptCode;

                // File name and save path
                String fileName   = "QR_" + studentId + "_" + regNumber.replaceAll("[^a-zA-Z0-9]", "_") + ".png";
                String savePath   = getServletContext().getRealPath("/") + "qrcodes/" + fileName;
                String dbSavePath = "qrcodes/" + fileName;

                // Generate QR code image
                QRCodeWriter qrWriter = new QRCodeWriter();
                BitMatrix bitMatrix   = qrWriter.encode(qrContent, BarcodeFormat.QR_CODE, 300, 300);
                Path path = FileSystems.getDefault().getPath(savePath);
                MatrixToImageWriter.writeToPath(bitMatrix, "PNG", path);

                // Save QR path to database
                PreparedStatement update = conn.prepareStatement(
                    "UPDATE students SET qr_code_path = ? WHERE student_id = ?"
                );
                update.setString(1, dbSavePath);
                update.setInt(2, Integer.parseInt(studentId));
                update.executeUpdate();

                success = true;
                message = "QR code generated successfully for " + fullName;
            } else {
                message = "Student not found!";
            }

            conn.close();

        } catch(WriterException e){
            message = "QR generation error: " + e.getMessage();
        } catch(Exception e){
            message = "Error: " + e.getMessage();
        }

        response.sendRedirect("qrCode.jsp?id=" + studentId +
                              "&success=" + success +
                              "&msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
    }
}