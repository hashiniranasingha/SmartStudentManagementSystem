<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%
    if(session.getAttribute("loggedUser") == null){
        response.sendRedirect("login.jsp");
        return;
    }

    // Load ALL students with their QR status - all Java at top
    ArrayList<HashMap<String,String>> studentList = new ArrayList<HashMap<String,String>>();
    String dbError = "";

    // Filter
    String filterDept = request.getParameter("dept");
    if(filterDept == null) filterDept = "ALL";

    try{
        Connection conn = DBConnection.getConnection();

        String sql = "SELECT s.student_id, s.reg_number, s.full_name, s.qr_code_path, " +
                     "s.year_level, s.course_name, d.dept_code " +
                     "FROM students s " +
                     "JOIN departments d ON s.dept_id = d.dept_id " +
                     "WHERE 1=1 ";

        if(!"ALL".equals(filterDept)){
            sql += " AND d.dept_code = '" + filterDept + "'";
        }
        sql += " ORDER BY d.dept_code, s.year_level, s.full_name";

        ResultSet rs = conn.createStatement().executeQuery(sql);

        while(rs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("student_id",   String.valueOf(rs.getInt("student_id")));
            row.put("reg_number",   rs.getString("reg_number")   != null ? rs.getString("reg_number")   : "");
            row.put("full_name",    rs.getString("full_name")    != null ? rs.getString("full_name")    : "");
            row.put("year_level",   rs.getString("year_level")   != null ? rs.getString("year_level")   : "");
            row.put("dept_code",    rs.getString("dept_code")    != null ? rs.getString("dept_code")    : "");
            row.put("course_name",  rs.getString("course_name")  != null ? rs.getString("course_name")  : "");
            row.put("qr_code_path", rs.getString("qr_code_path") != null ? rs.getString("qr_code_path") : "");
            studentList.add(row);
        }

        rs.close();
        conn.close();

    } catch(Exception e){
        dbError = e.getMessage();
    }

    // Single student view (after QR generated)
    String viewId        = request.getParameter("id");
    String viewRegNum    = "";
    String viewName      = "";
    String viewDept      = "";
    String viewYear      = "";
    String viewQRPath    = "";
    String viewCourse    = "";

    if(viewId != null && !viewId.isEmpty()){
        try{
            Connection conn2 = DBConnection.getConnection();
            PreparedStatement ps2 = conn2.prepareStatement(
                "SELECT s.*, d.dept_code FROM students s " +
                "JOIN departments d ON s.dept_id=d.dept_id " +
                "WHERE s.student_id=?");
            ps2.setInt(1, Integer.parseInt(viewId));
            ResultSet rs2 = ps2.executeQuery();
            if(rs2.next()){
                viewRegNum = rs2.getString("reg_number")   != null ? rs2.getString("reg_number")   : "";
                viewName   = rs2.getString("full_name")    != null ? rs2.getString("full_name")    : "";
                viewDept   = rs2.getString("dept_code")    != null ? rs2.getString("dept_code")    : "";
                viewYear   = rs2.getString("year_level")   != null ? rs2.getString("year_level")   : "";
                viewQRPath = rs2.getString("qr_code_path") != null ? rs2.getString("qr_code_path") : "";
                viewCourse = rs2.getString("course_name")  != null ? rs2.getString("course_name")  : "";
            }
            rs2.close();
            conn2.close();
        } catch(Exception e2){
            dbError = e2.getMessage();
        }
    }

    String successMsg = request.getParameter("msg");
    String isSuccess  = request.getParameter("success");
    if(successMsg == null) successMsg = "";
    if(isSuccess  == null) isSuccess  = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SMS – QR Codes</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; display:flex; min-height:100vh; }

        .sidebar {
            width:240px; min-height:100vh;
            background:linear-gradient(180deg,#1a237e 0%,#0d47a1 100%);
            display:flex; flex-direction:column;
            position:fixed; left:0; top:0;
            box-shadow:4px 0 20px rgba(0,0,0,0.15);
        }
        .sidebar-logo { padding:24px 20px; border-bottom:1px solid rgba(255,255,255,0.1); }
        .sidebar-logo h2 { color:white; font-size:15px; font-weight:700; }
        .sidebar-logo p  { color:rgba(255,255,255,0.6); font-size:11px; margin-top:2px; }
        .nav-label {
            color:rgba(255,255,255,0.4); font-size:10px; font-weight:600;
            text-transform:uppercase; letter-spacing:1px;
            padding:0 8px; margin-bottom:6px; margin-top:16px;
        }
        .nav-item {
            display:flex; align-items:center; gap:10px;
            padding:10px 12px; border-radius:8px;
            color:rgba(255,255,255,0.75); font-size:13px; font-weight:500;
            text-decoration:none; margin-bottom:2px; transition:all 0.15s;
        }
        .nav-item:hover,.nav-item.active{ background:rgba(255,255,255,0.15); color:white; }
        .nav-section { padding:12px; }
        .sidebar-user {
            margin-top:auto; padding:16px 20px;
            border-top:1px solid rgba(255,255,255,0.1);
            color:rgba(255,255,255,0.8); font-size:12px;
        }
        .sidebar-user strong { display:block; color:white; font-size:13px; }

        .main { margin-left:240px; padding:28px; flex:1; }

        .page-header { margin-bottom:24px; }
        .page-header h1 { font-size:22px; font-weight:700; color:#1a1a2e; }
        .page-header p  { font-size:13px; color:#6b7280; margin-top:4px; }

        .alert-success {
            background:#e6f4ea; color:#1b5e20; border:1px solid #a8d5b5;
            border-radius:8px; padding:11px 16px; margin-bottom:20px; font-size:13px;
        }
        .alert-error {
            background:#fef2f2; color:#dc2626; border:1px solid #fecaca;
            border-radius:8px; padding:11px 16px; margin-bottom:20px; font-size:13px;
        }

        /* QR Preview Card */
        .qr-preview-card {
            background:white; border-radius:16px; padding:28px;
            box-shadow:0 4px 20px rgba(0,0,0,0.08);
            display:flex; gap:32px; align-items:flex-start;
            margin-bottom:28px; border:2px solid #e8f0fe;
        }
        .qr-image-box {
            text-align:center; flex-shrink:0;
        }
        .qr-image-box img {
            width:200px; height:200px;
            border:3px solid #e8f0fe; border-radius:12px; display:block;
        }
        .qr-image-box .no-qr {
            width:200px; height:200px;
            background:#f8f9fa; border:2px dashed #d1d5db; border-radius:12px;
            display:flex; align-items:center; justify-content:center;
            font-size:13px; color:#9ca3af; flex-direction:column; gap:8px;
        }
        .qr-info h2 { font-size:20px; font-weight:700; color:#1a1a2e; margin-bottom:12px; }
        .qr-info-row { display:flex; gap:8px; margin-bottom:8px; align-items:center; }
        .qr-info-row .lbl { font-size:12px; color:#9ca3af; font-weight:500; width:110px; }
        .qr-info-row .val { font-size:13px; color:#1a1a2e; font-weight:500; }
        .badge {
            display:inline-block; padding:3px 10px;
            border-radius:20px; font-size:11px; font-weight:600;
        }
        .badge-IT  { background:#e8f0fe; color:#1a237e; }
        .badge-ENG { background:#e6f4ea; color:#1b5e20; }
        .badge-THM { background:#fff3e0; color:#e65100; }
        .badge-MGT { background:#fce4ec; color:#880e4f; }
        .badge-ACC { background:#f3e8fd; color:#4a148c; }

        .qr-btn-row { display:flex; gap:10px; margin-top:20px; }
        .btn-print {
            background:linear-gradient(135deg,#1a237e,#1565c0);
            color:white; border:none; border-radius:8px;
            padding:10px 20px; font-size:13px; font-weight:600;
            cursor:pointer; font-family:'Inter',sans-serif;
        }
        .btn-regen {
            background:#f3f4f6; color:#374151; border:1px solid #e5e7eb;
            border-radius:8px; padding:10px 20px; font-size:13px; font-weight:500;
            cursor:pointer; text-decoration:none; font-family:'Inter',sans-serif;
        }

        /* Filter bar */
        .filter-bar {
            background:white; border-radius:12px; padding:14px 20px;
            box-shadow:0 1px 4px rgba(0,0,0,0.06); margin-bottom:20px;
            display:flex; gap:12px; align-items:center; flex-wrap:wrap;
        }
        .filter-bar label { font-size:13px; font-weight:500; color:#374151; }
        .filter-bar select {
            padding:8px 12px; border:1.5px solid #e5e7eb; border-radius:8px;
            font-size:13px; font-family:'Inter',sans-serif; outline:none;
        }
        .filter-bar select:focus { border-color:#1a237e; }
        .btn-filter {
            background:#1a237e; color:white; border:none; border-radius:8px;
            padding:8px 16px; font-size:13px; font-weight:600;
            cursor:pointer; font-family:'Inter',sans-serif;
        }
        .btn-reset {
            background:#f3f4f6; color:#374151; border:1px solid #e5e7eb;
            border-radius:8px; padding:8px 16px; font-size:13px;
            cursor:pointer; text-decoration:none;
        }

        /* Students QR table */
        .table-card {
            background:white; border-radius:12px;
            box-shadow:0 1px 4px rgba(0,0,0,0.06); overflow:hidden;
        }
        .table-header {
            padding:16px 20px; border-bottom:1px solid #f3f4f6;
            display:flex; justify-content:space-between; align-items:center;
        }
        .table-header span { font-size:13px; font-weight:600; color:#1a1a2e; }
        table { width:100%; border-collapse:collapse; }
        thead th {
            background:#f8f9fa; padding:11px 16px;
            text-align:left; font-size:12px; font-weight:600;
            color:#6b7280; text-transform:uppercase; letter-spacing:0.5px;
        }
        tbody tr { border-bottom:1px solid #f3f4f6; }
        tbody tr:hover { background:#f8f9ff; }
        tbody td { padding:12px 16px; font-size:13px; color:#1a1a2e; }

        .qr-thumb {
            width:48px; height:48px; border-radius:6px;
            border:1px solid #e5e7eb;
        }
        .no-qr-thumb {
            width:48px; height:48px; border-radius:6px;
            background:#f3f4f6; border:1px dashed #d1d5db;
            display:inline-flex; align-items:center; justify-content:center;
            font-size:10px; color:#9ca3af; text-align:center;
        }
        .status-generated {
            display:inline-block; background:#e6f4ea; color:#1b5e20;
            padding:3px 10px; border-radius:20px; font-size:11px; font-weight:600;
        }
        .status-pending {
            display:inline-block; background:#fff3e0; color:#e65100;
            padding:3px 10px; border-radius:20px; font-size:11px; font-weight:600;
        }
        .btn-generate {
            background:linear-gradient(135deg,#1a237e,#1565c0);
            color:white; border:none; border-radius:6px;
            padding:6px 14px; font-size:12px; font-weight:600;
            cursor:pointer; text-decoration:none; display:inline-block;
        }
        .btn-view {
            background:#e8f0fe; color:#1a237e; border:none; border-radius:6px;
            padding:6px 14px; font-size:12px; font-weight:600;
            cursor:pointer; text-decoration:none; display:inline-block;
            margin-left:4px;
        }
        .btn-generate:hover { opacity:0.9; }
        .btn-view:hover { background:#c7d9ff; }

        /* Print styles */
        @media print {
            .sidebar, .main > *:not(.print-area) { display:none !important; }
            .print-area { display:block !important; }
            body { background:white; }
            .print-card {
                text-align:center; padding:40px;
                border:2px solid #1a237e; border-radius:16px;
                max-width:350px; margin:40px auto;
            }
            .print-card img { width:220px; height:220px; }
            .print-card h2 { font-size:18px; margin:16px 0 6px; }
            .print-card p  { font-size:13px; color:#555; }
        }
        .print-area { display:none; }
    </style>
</head>
<body>

<!-- SIDEBAR -->
<div class="sidebar">
    <div class="sidebar-logo">
        <h2>&#128218; SMS System</h2>
        <p>SLIATE – Badulla ATI</p>
    </div>
    <div class="nav-section">
        <div class="nav-label">Main</div>
        <a href="dashboard.jsp"  class="nav-item">&#9632; Dashboard</a>
        <a href="students.jsp"   class="nav-item">&#128101; Students</a>
        <a href="attendance.jsp" class="nav-item">&#9989; Attendance</a>
        <a href="monthlyReport.jsp" class="nav-item">
    &#128197; Monthly Report
</a>
        <a href="qrCode.jsp"     class="nav-item active">&#9638; QR Codes</a>
        <a href="qrScan.jsp"     class="nav-item">&#128247; QR Scanner</a>
        <a href="marks.jsp"      class="nav-item">&#128196; Marks &amp; GPA</a>
        <a href="reports.jsp"    class="nav-item">&#128202; Reports</a>
        <a href="lms.jsp" class="nav-item">&#128196; LMS Materials</a>
     <a href="emailNotify.jsp" class="nav-item">&#128231; Email Alerts</a>
        <a href="notices.jsp" class="nav-item">&#128276; Notice Board</a>
        <div class="nav-label">Account</div>
        <a href="chatbot.jsp" class="nav-item">&#129302; Assistant</a>
        <a href="LogoutServlet"  class="nav-item">&#128682; Logout</a>
    </div>
    <div class="sidebar-user">
        <strong><%= session.getAttribute("loggedUser") %></strong>
        <%= session.getAttribute("userRole") %>
    </div>
</div>

<!-- MAIN -->
<div class="main">

    <div class="page-header">
        <h1>&#9638; QR Code Management</h1>
        <p>Generate and print QR codes for student attendance</p>
    </div>

    <!-- Alert messages -->
    <% if("true".equals(isSuccess) && !successMsg.isEmpty()){ %>
        <div class="alert-success">&#10003; <%= successMsg %></div>
    <% } else if("false".equals(isSuccess) && !successMsg.isEmpty()){ %>
        <div class="alert-error">&#9888; <%= successMsg %></div>
    <% } %>

    <% if(!dbError.isEmpty()){ %>
        <div class="alert-error">&#9888; Error: <%= dbError %></div>
    <% } %>

    <!-- QR Preview Section (shown after generating) -->
    <% if(viewId != null && !viewId.isEmpty() && !viewQRPath.isEmpty()){ %>
    <div class="qr-preview-card">
        <div class="qr-image-box">
            <img src="<%= viewQRPath %>?t=<%= System.currentTimeMillis() %>"
                 alt="QR Code for <%= viewName %>">
            <p style="font-size:11px; color:#9ca3af; margin-top:8px;">Scan to mark attendance</p>
        </div>
        <div class="qr-info">
            <h2><%= viewName %></h2>
            <div class="qr-info-row">
                <span class="lbl">Reg Number</span>
                <span class="val" style="color:#1a237e; font-weight:700;"><%= viewRegNum %></span>
            </div>
            <div class="qr-info-row">
                <span class="lbl">Department</span>
                <span class="badge badge-<%= viewDept %>"><%= viewDept %></span>
            </div>
            <div class="qr-info-row">
                <span class="lbl">Year</span>
                <span class="val"><%= viewYear %></span>
            </div>
            <div class="qr-info-row">
                <span class="lbl">Course</span>
                <span class="val"><%= viewCourse %></span>
            </div>
            <div class="qr-btn-row">
                <button class="btn-print" onclick="printQR()">&#128424; Print QR Card</button>
                <a href="GenerateQRServlet?id=<%= viewId %>" class="btn-regen">&#8635; Regenerate</a>
            </div>
        </div>
    </div>

    <!-- Hidden print area -->
    <div class="print-area" id="printArea">
        <div class="print-card">
            <img src="<%= viewQRPath %>" alt="QR Code">
            <h2><%= viewName %></h2>
            <p><strong><%= viewRegNum %></strong></p>
            <p><%= viewDept %> | <%= viewYear %></p>
            <p style="margin-top:8px; font-size:11px; color:#888;">SLIATE Badulla – SMS System</p>
        </div>
    </div>
    <% } %>

    <!-- Filter -->
    <div class="filter-bar">
        <form method="get" action="qrCode.jsp"
              style="display:flex; gap:12px; align-items:center; width:100%;">
            <label>Department:</label>
            <select name="dept">
                <option value="ALL" <%= "ALL".equals(filterDept) ? "selected":"" %>>All Departments</option>
                <option value="IT"  <%= "IT".equals(filterDept)  ? "selected":"" %>>IT</option>
                <option value="ENG" <%= "ENG".equals(filterDept) ? "selected":"" %>>English</option>
                <option value="THM" <%= "THM".equals(filterDept) ? "selected":"" %>>THM</option>
                <option value="MGT" <%= "MGT".equals(filterDept) ? "selected":"" %>>Management</option>
                <option value="ACC" <%= "ACC".equals(filterDept) ? "selected":"" %>>Accountancy</option>
            </select>
            <button type="submit" class="btn-filter">Filter</button>
            <a href="qrCode.jsp" class="btn-reset">Reset</a>
        </form>
    </div>

    <!-- Students Table -->
    <div class="table-card">
        <div class="table-header">
            <span>All Students — QR Status</span>
            <small><%= studentList.size() %> student(s)</small>
        </div>
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>QR Code</th>
                    <th>Reg Number</th>
                    <th>Full Name</th>
                    <th>Dept</th>
                    <th>Year</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% if(studentList.isEmpty()){ %>
                <tr>
                    <td colspan="8" style="text-align:center; padding:40px; color:#9ca3af;">
                        No students found. Add students first.
                    </td>
                </tr>
            <% } else {
                for(int i = 0; i < studentList.size(); i++){
                    HashMap<String,String> s = studentList.get(i);
                    String qrPath = s.get("qr_code_path");
                    boolean hasQR = qrPath != null && !qrPath.isEmpty();
                    String dc = s.get("dept_code");
            %>
            <tr>
                <td style="color:#9ca3af;"><%= (i+1) %></td>
                <td>
                    <% if(hasQR){ %>
                        <img src="<%= qrPath %>?t=<%= System.currentTimeMillis() %>"
                             class="qr-thumb" alt="QR">
                    <% } else { %>
                        <div class="no-qr-thumb">No QR</div>
                    <% } %>
                </td>
                <td style="font-weight:600; color:#1a237e;"><%= s.get("reg_number") %></td>
                <td><strong><%= s.get("full_name") %></strong></td>
                <td><span class="badge badge-<%= dc %>"><%= dc %></span></td>
                <td style="font-size:12px; color:#6b7280;"><%= s.get("year_level") %></td>
                <td>
                    <% if(hasQR){ %>
                        <span class="status-generated">&#10003; Generated</span>
                    <% } else { %>
                        <span class="status-pending">&#9888; Pending</span>
                    <% } %>
                </td>
                <td>
                    <a href="GenerateQRServlet?id=<%= s.get("student_id") %>"
                       class="btn-generate">&#9638; Generate</a>
                    <% if(hasQR){ %>
                    <a href="qrCode.jsp?id=<%= s.get("student_id") %>"
                       class="btn-view">&#128065; View</a>
                    <% } %>
                </td>
            </tr>
            <%  }
               } %>
            </tbody>
        </table>
    </div>

</div>

<script>
function printQR(){
    var printContents = document.getElementById('printArea').innerHTML;
    var original = document.body.innerHTML;
    document.body.innerHTML = printContents;
    window.print();
    document.body.innerHTML = original;
    window.location.reload();
}
</script>



</body>
</html>