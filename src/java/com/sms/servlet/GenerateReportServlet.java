package com.sms.servlet;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/GenerateReportServlet")
public class GenerateReportServlet extends HttpServlet {

    private static final Font FONT_TITLE      = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD,   BaseColor.WHITE);
    private static final Font FONT_SUBTITLE   = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD,   BaseColor.WHITE);
    private static final Font FONT_HEADER     = new Font(Font.FontFamily.HELVETICA, 9,  Font.BOLD,   BaseColor.WHITE);
    private static final Font FONT_BODY       = new Font(Font.FontFamily.HELVETICA, 9,  Font.NORMAL, BaseColor.BLACK);
    private static final Font FONT_BODY_BOLD  = new Font(Font.FontFamily.HELVETICA, 9,  Font.BOLD,   BaseColor.BLACK);
    private static final Font FONT_SMALL      = new Font(Font.FontFamily.HELVETICA, 8,  Font.NORMAL, new BaseColor(100,100,100));
    private static final Font FONT_PRESENT    = new Font(Font.FontFamily.HELVETICA, 9,  Font.BOLD,   new BaseColor(27,94,32));
    private static final Font FONT_ABSENT     = new Font(Font.FontFamily.HELVETICA, 9,  Font.BOLD,   new BaseColor(198,40,40));

    private static final BaseColor COLOR_HEADER  = new BaseColor(26,35,126);
    private static final BaseColor COLOR_SUBHEAD = new BaseColor(21,101,192);
    private static final BaseColor COLOR_ROW_ALT = new BaseColor(240,244,255);
    private static final BaseColor COLOR_BORDER  = new BaseColor(200,210,230);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String reportType = request.getParameter("type");
        String deptId     = request.getParameter("dept");
        String sem        = request.getParameter("sem");
        String dateParam  = request.getParameter("date");
        String viewMode   = request.getParameter("view"); // "1" = Inline preview, "0" = Download attachment

        boolean isView = "1".equals(viewMode);
        response.setContentType("application/pdf");

        try {
            if ("students".equals(reportType)) {
                String filename = "Student_Report.pdf";
                response.setHeader("Content-Disposition", (isView ? "inline" : "attachment") + "; filename=" + filename);
                generateStudentReport(response, deptId);

            } else if ("attendance".equals(reportType)) {
                String today = (dateParam != null && !dateParam.isEmpty()) ? dateParam :
                    new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
                String filename = "Attendance_Report_" + today + ".pdf";
                response.setHeader("Content-Disposition", (isView ? "inline" : "attachment") + "; filename=" + filename);
                generateAttendanceReport(response, deptId, today);

            } else if ("marks".equals(reportType)) {
                String filename = "Result_Sheet_Sem" + sem + ".pdf";
                response.setHeader("Content-Disposition", (isView ? "inline" : "attachment") + "; filename=" + filename);
                generateMarksReport(response, deptId, sem);

            } else {
                response.sendRedirect("reports.jsp?error=Invalid+report+type");
            }
        } catch (Exception e) {
            response.sendRedirect("reports.jsp?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    private void generateStudentReport(HttpServletResponse response, String deptId) throws Exception {
        Document doc = new Document(PageSize.A4.rotate(), 30, 30, 40, 30);
        PdfWriter writer = PdfWriter.getInstance(doc, response.getOutputStream());
        writer.setPageEvent(new HeaderFooter("Student List Report"));
        doc.open();

        Connection conn = DBConnection.getConnection();
        String deptName = "All Departments";
        if (deptId != null && !deptId.isEmpty() && !"ALL".equals(deptId)) {
            PreparedStatement dps = conn.prepareStatement("SELECT dept_name FROM departments WHERE dept_id=?");
            dps.setInt(1, Integer.parseInt(deptId));
            ResultSet drs = dps.executeQuery();
            if (drs.next()) deptName = drs.getString("dept_name");
            drs.close(); dps.close();
        }

        addTitleSection(doc, "STUDENT LIST REPORT", deptName, "");

        String sql = "SELECT s.reg_number, s.full_name, s.email, s.phone, s.year_level, s.course_name, d.dept_code " +
                     "FROM students s JOIN departments d ON s.dept_id=d.dept_id WHERE 1=1";
        if (deptId != null && !deptId.isEmpty() && !"ALL".equals(deptId)) {
            sql += " AND s.dept_id = " + Integer.parseInt(deptId);
        }
        sql += " ORDER BY d.dept_code, s.year_level, s.full_name";

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);

        PdfPTable table = new PdfPTable(7);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{4f, 12f, 7f, 18f, 7f, 12f, 10f});
        table.setSpacingBefore(10f);

        String[] headers = {"#", "Reg Number", "Dept", "Full Name", "Year", "Course", "Phone"};
        for (String h : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(h, FONT_HEADER));
            cell.setBackgroundColor(COLOR_HEADER);
            cell.setPadding(6);
            cell.setHorizontalAlignment(Element.ALIGN_CENTER);
            cell.setBorderColor(COLOR_BORDER);
            table.addCell(cell);
        }

        int row = 0;
        while (rs.next()) {
            row++;
            BaseColor rowColor = (row % 2 == 0) ? COLOR_ROW_ALT : BaseColor.WHITE;
            addCell(table, String.valueOf(row), rowColor, FONT_SMALL, Element.ALIGN_CENTER);
            addCell(table, rs.getString("reg_number"), rowColor, FONT_BODY_BOLD, Element.ALIGN_LEFT);
            addCell(table, rs.getString("dept_code"), rowColor, FONT_BODY, Element.ALIGN_CENTER);
            addCell(table, rs.getString("full_name"), rowColor, FONT_BODY, Element.ALIGN_LEFT);
            addCell(table, rs.getString("year_level"), rowColor, FONT_SMALL, Element.ALIGN_CENTER);
            addCell(table, nvl(rs.getString("course_name")), rowColor, FONT_SMALL, Element.ALIGN_LEFT);
            addCell(table, nvl(rs.getString("phone")), rowColor, FONT_SMALL, Element.ALIGN_LEFT);
        }

        doc.add(table);
        addSummary(doc, "Total Students: " + row);
        
        rs.close(); stmt.close(); conn.close();
        doc.close();
    }

    private void generateAttendanceReport(HttpServletResponse response, String deptId, String today) throws Exception {
        Document doc = new Document(PageSize.A4.rotate(), 30, 30, 40, 30);
        PdfWriter writer = PdfWriter.getInstance(doc, response.getOutputStream());
        writer.setPageEvent(new HeaderFooter("Attendance Report"));
        doc.open();

        Connection conn = DBConnection.getConnection();
        String deptName = "All Departments";
        if (deptId != null && !deptId.isEmpty() && !"ALL".equals(deptId)) {
            PreparedStatement dps = conn.prepareStatement("SELECT dept_name FROM departments WHERE dept_id=?");
            dps.setInt(1, Integer.parseInt(deptId));
            ResultSet drs = dps.executeQuery();
            if (drs.next()) deptName = drs.getString("dept_name");
            drs.close(); dps.close();
        }

        addTitleSection(doc, "ATTENDANCE REPORT", deptName, "Date: " + today);

        String sql = "SELECT s.reg_number, s.full_name, s.year_level, d.dept_code, a.status " +
                     "FROM students s JOIN departments d ON s.dept_id=d.dept_id " +
                     "LEFT JOIN attendance a ON s.student_id=a.student_id AND a.att_date=? ";
        if (deptId != null && !deptId.isEmpty() && !"ALL".equals(deptId)) {
            sql += " WHERE s.dept_id = " + Integer.parseInt(deptId);
        }
        sql += " ORDER BY d.dept_code, s.year_level, s.full_name";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, today);
        ResultSet rs = ps.executeQuery();

        PdfPTable table = new PdfPTable(6);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{4f, 12f, 20f, 10f, 8f, 10f});
        table.setSpacingBefore(10f);

        String[] headers = {"#", "Reg Number", "Full Name", "Department", "Year", "Status"};
        for (String h : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(h, FONT_HEADER));
            cell.setBackgroundColor(COLOR_HEADER);
            cell.setPadding(6);
            cell.setHorizontalAlignment(Element.ALIGN_CENTER);
            cell.setBorderColor(COLOR_BORDER);
            table.addCell(cell);
        }

        int row = 0, present = 0, absent = 0;
        while (rs.next()) {
            row++;
            boolean isPresent = "Present".equalsIgnoreCase(rs.getString("status"));
            if (isPresent) present++; else absent++;
            
            BaseColor rowColor = (row % 2 == 0) ? COLOR_ROW_ALT : BaseColor.WHITE;
            addCell(table, String.valueOf(row), rowColor, FONT_SMALL, Element.ALIGN_CENTER);
            addCell(table, rs.getString("reg_number"), rowColor, FONT_BODY_BOLD, Element.ALIGN_LEFT);
            addCell(table, rs.getString("full_name"), rowColor, FONT_BODY, Element.ALIGN_LEFT);
            addCell(table, rs.getString("dept_code"), rowColor, FONT_BODY, Element.ALIGN_CENTER);
            addCell(table, rs.getString("year_level"), rowColor, FONT_SMALL, Element.ALIGN_CENTER);

            PdfPCell statusCell = new PdfPCell(new Phrase(isPresent ? "Present" : "Absent", isPresent ? FONT_PRESENT : FONT_ABSENT));
            statusCell.setBackgroundColor(isPresent ? new BaseColor(230, 244, 234) : new BaseColor(254, 242, 242));
            statusCell.setPadding(5);
            statusCell.setHorizontalAlignment(Element.ALIGN_CENTER);
            statusCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
            statusCell.setBorderColor(COLOR_BORDER);
            table.addCell(statusCell);
        }

        doc.add(table);
        int pct = row > 0 ? (present * 100 / row) : 0;
        addSummary(doc, "Total Stack: " + row + "   |   Present: " + present + "   |   Absent: " + absent + "   |   Rate: " + pct + "%");

        rs.close(); ps.close(); conn.close();
        doc.close();
    }

    private void generateMarksReport(HttpServletResponse response, String deptId, String sem) throws Exception {
        if (deptId == null || deptId.isEmpty() || sem == null || sem.isEmpty()) {
            response.sendRedirect("reports.jsp?error=Select+department+and+semester");
            return;
        }

        Document doc = new Document(PageSize.A4.rotate(), 20, 20, 40, 30);
        PdfWriter writer = PdfWriter.getInstance(doc, response.getOutputStream());
        writer.setPageEvent(new HeaderFooter("Result Sheet"));
        doc.open();

        Connection conn = DBConnection.getConnection();
        int examYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

        String deptName = "", deptCode = "";
        PreparedStatement dps = conn.prepareStatement("SELECT dept_name, dept_code FROM departments WHERE dept_id=?");
        dps.setInt(1, Integer.parseInt(deptId));
        ResultSet drs = dps.executeQuery();
        if (drs.next()) {
            deptName = drs.getString("dept_name");
            deptCode = drs.getString("dept_code");
        }
        drs.close(); dps.close();

        int semInt = Integer.parseInt(sem);
        int yearNum = (int) Math.ceil((double) semInt / 2);
        int semInYr = (semInt % 2 == 0) ? 2 : 1;
        String[] yNames = {"First Year", "Second Year", "Third Year", "Fourth Year"};
        String yearLabel = yNames[yearNum - 1];

        addTitleSection(doc, "EXAMINATION RESULT SHEET", deptName + " (" + deptCode + ")", yearLabel + " — Semester " + semInYr + " | Exam Year: " + examYear);

        PreparedStatement sps = conn.prepareStatement("SELECT subject_id, subject_name FROM subjects WHERE dept_id=? AND semester=? ORDER BY subject_name");
        sps.setInt(1, Integer.parseInt(deptId));
        sps.setInt(2, semInt);
        ResultSet srs = sps.executeQuery();

        java.util.ArrayList<String> subIds = new java.util.ArrayList<>();
        java.util.ArrayList<String> subNames = new java.util.ArrayList<>();
        while (srs.next()) {
            subIds.add(String.valueOf(srs.getInt("subject_id")));
            subNames.add(srs.getString("subject_name"));
        }
        srs.close(); sps.close();

        if (subIds.isEmpty()) {
            doc.add(new Paragraph("No subjects found registered under this semester configuration.", FONT_BODY));
            doc.close(); conn.close(); return;
        }

        int cols = 3 + subIds.size() + 1;
        PdfPTable table = new PdfPTable(cols);
        table.setWidthPercentage(100);
        table.setSpacingBefore(10f);

        float[] widths = new float[cols];
        widths[0] = 3f;   
        widths[1] = 16f;  
        widths[2] = 12f;  
        for (int i = 3; i < cols - 1; i++) widths[i] = 6f; 
        widths[cols - 1] = 6f; 
        table.setWidths(widths);

        addHeaderCell(table, "#");
        addHeaderCell(table, "NAME");
        addHeaderCell(table, "INDEX NO.");
        for (String sn : subNames) {
            String short_name = sn.length() > 20 ? sn.substring(0, 18) + "." : sn;
            addHeaderCell(table, short_name);
        }
        addHeaderCell(table, "SGPA");

        PreparedStatement stps = conn.prepareStatement("SELECT student_id, reg_number, full_name FROM students WHERE dept_id=? ORDER BY full_name");
        stps.setInt(1, Integer.parseInt(deptId));
        ResultSet strs = stps.executeQuery();

        int rowNum = 0;
        while (strs.next()) {
            rowNum++;
            int sid = strs.getInt("student_id");
            String regNum = strs.getString("reg_number");
            String fullName = strs.getString("full_name");
            BaseColor rowColor = (rowNum % 2 == 0) ? COLOR_ROW_ALT : BaseColor.WHITE;

            addCell(table, String.valueOf(rowNum), rowColor, FONT_SMALL, Element.ALIGN_CENTER);
            addCell(table, fullName, rowColor, FONT_BODY, Element.ALIGN_LEFT);
            addCell(table, regNum, rowColor, FONT_BODY_BOLD, Element.ALIGN_LEFT);

            double totalGPA = 0; int counted = 0;

            for (String subId : subIds) {
                PreparedStatement gps = conn.prepareStatement("SELECT grade, gpa_points FROM marks WHERE student_id=? AND subject_id=? AND exam_year=?");
                gps.setInt(1, sid);
                gps.setInt(2, Integer.parseInt(subId));
                gps.setInt(3, examYear);
                ResultSet grs = gps.executeQuery();

                String grade = "—";
                double pts = -1;
                if (grs.next()) {
                    grade = grs.getString("grade") != null ? grs.getString("grade") : "—";
                    pts = grs.getDouble("gpa_points");
                }
                grs.close(); gps.close();

                BaseColor gradeColor = rowColor;
                Font gradeFont = FONT_BODY;
                if ("A+".equals(grade) || "A".equals(grade) || "A-".equals(grade)) {
                    gradeColor = new BaseColor(232, 245, 233); gradeFont = FONT_PRESENT;
                } else if (grade.startsWith("B")) {
                    gradeColor = new BaseColor(232, 240, 254);
                } else if (grade.startsWith("C")) {
                    gradeColor = new BaseColor(255, 243, 224);
                } else if ("E".equals(grade) || "NE".equals(grade)) {
                    gradeColor = new BaseColor(254, 235, 235); gradeFont = FONT_ABSENT;
                }

                PdfPCell gc = new PdfPCell(new Phrase(grade, gradeFont));
                gc.setBackgroundColor(gradeColor);
                gc.setHorizontalAlignment(Element.ALIGN_CENTER);
                gc.setVerticalAlignment(Element.ALIGN_MIDDLE);
                gc.setPadding(5);
                gc.setBorderColor(COLOR_BORDER);
                table.addCell(gc);

                if (pts >= 0) { totalGPA += pts; counted++; }
            }

            double sgpa = counted > 0 ? totalGPA / counted : 0.0;
            String sgpaStr = counted > 0 ? String.format("%.2f", sgpa) : "—";
            BaseColor sgpaColor = sgpa >= 3.5 ? new BaseColor(232, 245, 233) : (sgpa >= 2.0 ? new BaseColor(232, 240, 254) : new BaseColor(254, 235, 235));
            Font sgpaFont = sgpa >= 3.5 ? FONT_PRESENT : (sgpa >= 2.0 ? FONT_BODY_BOLD : FONT_ABSENT);

            PdfPCell sc = new PdfPCell(new Phrase(sgpaStr, sgpaFont));
            sc.setBackgroundColor(sgpaColor);
            sc.setHorizontalAlignment(Element.ALIGN_CENTER);
            sc.setVerticalAlignment(Element.ALIGN_MIDDLE);
            sc.setPadding(5);
            sc.setBorderColor(COLOR_BORDER);
            table.addCell(sc);
        }

        doc.add(table);
        addLegend(doc);
        addSummary(doc, "Total Registered Profiles: " + rowNum);

        strs.close(); stps.close(); conn.close();
        doc.close();
    }

    private void addTitleSection(Document doc, String title, String subtitle, String info) throws Exception {
        PdfPTable titleTable = new PdfPTable(1);
        titleTable.setWidthPercentage(100);
        titleTable.setSpacingAfter(4f);

        PdfPCell instCell = new PdfPCell();
        instCell.setBackgroundColor(COLOR_HEADER);
        instCell.setPadding(14);
        instCell.setBorder(Rectangle.NO_BORDER);

        Paragraph inst = new Paragraph();
        inst.add(new Chunk("SRI LANKA INSTITUTE OF ADVANCED TECHNOLOGICAL EDUCATION\n", FONT_SUBTITLE));
        inst.add(new Chunk("Badulla Campus\n", FONT_SUBTITLE));
        inst.add(new Chunk(title + "\n", FONT_TITLE));
        if (!subtitle.isEmpty()) inst.add(new Chunk(subtitle + "\n", FONT_SUBTITLE));
        if (!info.isEmpty()) inst.add(new Chunk(info, FONT_SUBTITLE));
        inst.setAlignment(Element.ALIGN_CENTER);
        
        instCell.addElement(inst);
        titleTable.addCell(instCell);
        doc.add(titleTable);

        Paragraph dateLine = new Paragraph("Generated: " + new java.util.Date().toString(), FONT_SMALL);
        dateLine.setAlignment(Element.ALIGN_RIGHT);
        dateLine.setSpacingAfter(4f);
        doc.add(dateLine);
    }

    private void addHeaderCell(PdfPTable table, String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text, FONT_HEADER));
        cell.setBackgroundColor(COLOR_SUBHEAD);
        cell.setPadding(6);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setBorderColor(COLOR_BORDER);
        table.addCell(cell);
    }

    private void addCell(PdfPTable table, String text, BaseColor bg, Font font, int align) {
        PdfPCell cell = new PdfPCell(new Phrase(text != null ? text : "—", font));
        cell.setBackgroundColor(bg);
        cell.setPadding(5);
        cell.setHorizontalAlignment(align);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setBorderColor(COLOR_BORDER);
        table.addCell(cell);
    }

    private void addSummary(Document doc, String text) throws Exception {
        Paragraph p = new Paragraph(text, FONT_BODY_BOLD);
        p.setSpacingBefore(10f);
        p.setAlignment(Element.ALIGN_RIGHT);
        doc.add(p);
    }

    private void addLegend(Document doc) throws Exception {
        Paragraph p = new Paragraph("I(SE)=Incomplete/Sitting Exam   NE=Not Eligible   AB=Absent   DFR=Deferred   E=Fail", FONT_SMALL);
        p.setSpacingBefore(8f);
        doc.add(p);
    }

    private String nvl(String s) {
        return (s == null || s.trim().isEmpty()) ? "—" : s;
    }

    class HeaderFooter extends PdfPageEventHelper {
        private final String reportTitle;
        HeaderFooter(String title) { this.reportTitle = title; }

        @Override
        public void onEndPage(PdfWriter writer, Document document) {
            PdfContentByte cb = writer.getDirectContent();
            Rectangle pageSize = document.getPageSize();

            cb.setColorStroke(COLOR_HEADER);
            cb.setLineWidth(2f);
            cb.moveTo(document.leftMargin(), pageSize.getHeight() - 20);
            cb.lineTo(pageSize.getWidth() - document.rightMargin(), pageSize.getHeight() - 20);
            cb.stroke();

            cb.setColorStroke(new BaseColor(200, 210, 230));
            cb.setLineWidth(0.5f);
            cb.moveTo(document.leftMargin(), 22);
            cb.lineTo(pageSize.getWidth() - document.rightMargin(), 22);
            cb.stroke();

            ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
                new Phrase("SLIATE Badulla — " + reportTitle, FONT_SMALL), document.leftMargin(), 12, 0);

            ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                new Phrase("Page " + writer.getPageNumber(), FONT_SMALL), pageSize.getWidth() - document.rightMargin(), 12, 0);
        }
    }
}