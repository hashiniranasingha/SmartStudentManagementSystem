<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="com.sms.util.RoleCheck" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%
    if(!RoleCheck.isLoggedIn(session)){
        response.sendRedirect("login.jsp"); return;
    }

    String filterDept = request.getParameter("dept");
    String filterDate = request.getParameter("date");
    String filterYear = request.getParameter("year");
    if(filterDept == null) filterDept = "ALL";
    if(filterYear == null) filterYear = "ALL";
    if(filterDate == null || filterDate.isEmpty()){
        filterDate = new java.text.SimpleDateFormat("yyyy-MM-dd")
                         .format(new java.util.Date());
    }

    // Check current time for attendance window
    // 8:30 - 9:00 = Present, 9:00 - 9:30 = Late, after 9:30 = Absent
    java.util.Calendar now = java.util.Calendar.getInstance();
    int curHour = now.get(java.util.Calendar.HOUR_OF_DAY);
    int curMin  = now.get(java.util.Calendar.MINUTE);
    int curTotal = curHour * 60 + curMin;
    // 8:30 = 510, 9:00 = 540, 9:30 = 570
    boolean attendanceOpen   = curTotal >= 510 && curTotal <= 570;
    boolean attendanceClosed = curTotal > 570;

    ArrayList<HashMap<String,String>> attList =
        new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> deptList =
        new ArrayList<HashMap<String,String>>();
    int presentCount = 0, lateCount = 0,
        absentCount  = 0, notMarkedCount = 0;
    int totalStudents = 0;
    String dbError = "";

    try{
        Connection conn = DBConnection.getConnection();

        // Departments
        ResultSet drs = conn.createStatement().executeQuery(
            "SELECT * FROM departments ORDER BY dept_name");
        while(drs.next()){
            HashMap<String,String> d = new HashMap<String,String>();
            d.put("dept_id",   String.valueOf(drs.getInt("dept_id")));
            d.put("dept_code", drs.getString("dept_code"));
            d.put("dept_name", drs.getString("dept_name"));
            deptList.add(d);
        }

        // Count total students
        String cntSql =
            "SELECT COUNT(*) FROM students s " +
            "JOIN departments d ON s.dept_id=d.dept_id WHERE 1=1";
        if(!"ALL".equals(filterDept))
            cntSql += " AND d.dept_id=" + filterDept;
        if(!"ALL".equals(filterYear))
            cntSql += " AND s.year_level='" + filterYear + "'";
        ResultSet crs = conn.createStatement().executeQuery(cntSql);
        if(crs.next()) totalStudents = crs.getInt(1);

        // Attendance data
        String sql =
            "SELECT s.student_id, s.reg_number, s.full_name, " +
            "s.year_level, d.dept_code, " +
            "a.att_time, a.status, a.att_date " +
            "FROM students s " +
            "JOIN departments d ON s.dept_id=d.dept_id " +
            "LEFT JOIN attendance a ON s.student_id=a.student_id " +
            "AND a.att_date='" + filterDate + "' " +
            "WHERE 1=1 ";
        if(!"ALL".equals(filterDept))
            sql += " AND d.dept_id=" + filterDept;
        if(!"ALL".equals(filterYear))
            sql += " AND s.year_level='" + filterYear + "'";
        sql += " ORDER BY d.dept_code, s.year_level, s.full_name";

        ResultSet rs = conn.createStatement().executeQuery(sql);
        while(rs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("student_id", String.valueOf(rs.getInt("student_id")));
            row.put("reg_number", rs.getString("reg_number") != null ? rs.getString("reg_number") : "");
            row.put("full_name",  rs.getString("full_name")  != null ? rs.getString("full_name")  : "");
            row.put("year_level", rs.getString("year_level") != null ? rs.getString("year_level") : "");
            row.put("dept_code",  rs.getString("dept_code")  != null ? rs.getString("dept_code")  : "");
            row.put("att_time",   rs.getString("att_time")   != null ? rs.getString("att_time")   : "");

            String dbStatus = rs.getString("status");

            // Determine display status
            String displayStatus;
            if(dbStatus != null){
                displayStatus = dbStatus; // Present, Late, Absent
            } else {
                // No record — determine based on time
                if(attendanceClosed){
                    displayStatus = "Absent"; // After 9:30 = Absent
                } else {
                    displayStatus = "Not Marked"; // Still open
                }
            }
            row.put("status", displayStatus);

            if("Present".equals(displayStatus))    presentCount++;
            else if("Late".equals(displayStatus))  lateCount++;
            else if("Absent".equals(displayStatus))absentCount++;
            else                                   notMarkedCount++;

            attList.add(row);
        }
        rs.close();
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }

    int attendancePct = totalStudents > 0 ?
        ((presentCount + lateCount) * 100 / totalStudents) : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Attendance</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#f0f2f5;display:flex;min-height:100vh;}
        .sidebar{width:240px;min-height:100vh;background:linear-gradient(180deg,#1a237e 0%,#0d47a1 100%);display:flex;flex-direction:column;position:fixed;left:0;top:0;}
        .sidebar-logo{padding:24px 20px;border-bottom:1px solid rgba(255,255,255,0.1);}
        .sidebar-logo h2{color:white;font-size:15px;font-weight:700;}
        .sidebar-logo p{color:rgba(255,255,255,0.6);font-size:11px;}
        .nav-label{color:rgba(255,255,255,0.4);font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:1px;padding:0 8px;margin-bottom:6px;margin-top:16px;}
        .nav-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:rgba(255,255,255,0.75);font-size:13px;font-weight:500;text-decoration:none;margin-bottom:2px;transition:all 0.15s;}
        .nav-item:hover,.nav-item.active{background:rgba(255,255,255,0.15);color:white;}
        .nav-section{padding:12px;overflow-y:auto;max-height:calc(100vh - 100px);}
        .nav-section::-webkit-scrollbar{width:4px;}
        .nav-section::-webkit-scrollbar-thumb{background:rgba(255,255,255,0.2);border-radius:4px;}
        .sidebar-user{padding:16px 20px;border-top:1px solid rgba(255,255,255,0.1);color:rgba(255,255,255,0.8);font-size:12px;}
        .sidebar-user strong{display:block;color:white;font-size:13px;}
        .main{margin-left:240px;padding:28px;flex:1;}
        .page-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:4px;}
        .btn-scanner{background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:10px;padding:11px 20px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;}
        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}

        /* Time window banner */
        .time-banner{
            border-radius:10px;padding:12px 18px;margin-bottom:20px;
            display:flex;align-items:center;gap:12px;font-size:13px;font-weight:500;
        }
        .time-open{background:#e6f4ea;color:#1b5e20;border:1px solid #a8d5b5;}
        .time-late{background:#fff3e0;color:#e65100;border:1px solid #ffcc80;}
        .time-closed{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;}

        /* Summary */
        .summary-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin-bottom:20px;}
        .summary-card{background:white;border-radius:12px;padding:16px;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
        .summary-card .lbl{font-size:12px;color:#6b7280;margin-bottom:6px;}
        .summary-card .val{font-size:24px;font-weight:800;}
        .summary-card .sub{font-size:11px;color:#9ca3af;margin-top:3px;}

        /* Progress */
        .progress-wrap{background:white;border-radius:12px;padding:16px 20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);margin-bottom:20px;}
        .progress-top{display:flex;justify-content:space-between;font-size:13px;font-weight:500;color:#374151;margin-bottom:8px;}
        .progress-bg{background:#f3f4f6;border-radius:20px;height:12px;overflow:hidden;}
        .progress-fill{height:100%;border-radius:20px;background:linear-gradient(90deg,#1a237e,#1565c0);}

        /* Filter */
        .filter-bar{background:white;border-radius:12px;padding:14px 20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);margin-bottom:20px;display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap;}
        .fg{display:flex;flex-direction:column;gap:5px;}
        .fg label{font-size:12px;font-weight:500;color:#374151;}
        .fg select,.fg input{padding:8px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;}
        .btn-filter{background:#1a237e;color:white;border:none;border-radius:8px;padding:9px 18px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
        .btn-reset{background:#f3f4f6;color:#374151;border:1px solid #e5e7eb;border-radius:8px;padding:9px 14px;font-size:13px;text-decoration:none;}

        /* Table */
        .table-card{background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.06);overflow:hidden;}
        .table-header{padding:14px 20px;border-bottom:1px solid #f3f4f6;display:flex;justify-content:space-between;align-items:center;}
        .table-header span{font-size:13px;font-weight:600;color:#1a1a2e;}
        table{width:100%;border-collapse:collapse;}
        thead th{background:#f8f9fa;padding:10px 14px;text-align:left;font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;}
        tbody tr{border-bottom:1px solid #f3f4f6;transition:background 0.1s;}
        tbody tr:hover{background:#f8f9ff;}
        tbody td{padding:11px 14px;font-size:13px;color:#1a1a2e;}

        .badge{display:inline-block;padding:4px 10px;border-radius:20px;font-size:11px;font-weight:600;}
        .badge-IT{background:#e8f0fe;color:#1a237e;}
        .badge-ENG{background:#e6f4ea;color:#1b5e20;}
        .badge-THM{background:#fff3e0;color:#e65100;}
        .badge-MGT{background:#fce4ec;color:#880e4f;}
        .badge-ACC{background:#f3e8fd;color:#4a148c;}
        .badge-y1{background:#e8f5e9;color:#2e7d32;}
        .badge-y2{background:#fff8e1;color:#f57f17;}
    </style>
</head>
<body>
<div class="sidebar">
    <div class="sidebar-logo">
        <h2>&#128218; SMS System</h2>
        <p>SLIATE – Badulla ATI</p>
    </div>
    <div class="nav-section">
        <div class="nav-label">Main</div>
        <a href="dashboard.jsp"     class="nav-item">&#9632; Dashboard</a>
        <a href="students.jsp"      class="nav-item">&#128101; Students</a>
        <a href="attendance.jsp"    class="nav-item active">&#9989; Attendance</a>
        <a href="monthlyReport.jsp" class="nav-item">&#128197; Monthly Report</a>
        <a href="qrCode.jsp"        class="nav-item">&#9638; QR Codes</a>
        <a href="qrScan.jsp"        class="nav-item">&#128247; QR Scanner</a>
        <a href="marks.jsp"         class="nav-item">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"      class="nav-item">&#128218; Subjects</a>
        <a href="lms.jsp"           class="nav-item">&#128196; LMS</a>
        <a href="notices.jsp"       class="nav-item">&#128276; Notices</a>
        <a href="chatbot.jsp"       class="nav-item">&#129302; Assistant</a>
        <a href="reports.jsp"       class="nav-item">&#128202; Reports</a>
        <a href="emailNotify.jsp"   class="nav-item">&#128231; Email Alerts</a>
        <div class="nav-label">Account</div>
        <a href="LogoutServlet"     class="nav-item">&#128682; Logout</a>
    </div>
    <div class="sidebar-user">
        <strong><%= session.getAttribute("loggedUser") %></strong>
        <%= session.getAttribute("userRole") %>
    </div>
</div>

<div class="main">
    <div class="page-header">
        <div>
            <h1>&#9989; Attendance Records</h1>
            <p>Daily attendance — 8:30 AM to 9:30 AM window</p>
        </div>
        <a href="qrScan.jsp" class="btn-scanner">
            &#128247; Open QR Scanner
        </a>
    </div>

    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <!-- Attendance time window banner -->
    <%
    String bannerClass = "time-banner ";
    String bannerText  = "";
    if(attendanceOpen && curTotal < 540){
        bannerClass += "time-open";
        bannerText   = "&#128247; Attendance window is OPEN (8:30 - 9:00 AM) — Students scanning now marked Present";
    } else if(attendanceOpen && curTotal >= 540){
        bannerClass += "time-late";
        bannerText   = "&#9201; Late window (9:00 - 9:30 AM) — Students scanning now marked Late";
    } else if(attendanceClosed){
        bannerClass += "time-closed";
        bannerText   = "&#128721; Attendance window CLOSED (after 9:30 AM) — Unscanned students marked Absent";
    } else {
        bannerClass += "time-open";
        bannerText   = "&#128336; Attendance window opens at 8:30 AM";
    }
    %>
    <div class="<%= bannerClass %>">
        <%= bannerText %>
    </div>

    <!-- Summary -->
    <div class="summary-grid">
        <div class="summary-card">
            <div class="lbl">Total Students</div>
            <div class="val" style="color:#1a237e;">
                <%= totalStudents %>
            </div>
            <div class="sub">Selected filter</div>
        </div>
        <div class="summary-card">
            <div class="lbl">Present</div>
            <div class="val" style="color:#1b5e20;">
                <%= presentCount %>
            </div>
            <div class="sub">On time</div>
        </div>
        <div class="summary-card">
            <div class="lbl">Late</div>
            <div class="val" style="color:#f57c00;">
                <%= lateCount %>
            </div>
            <div class="sub">After 9:00 AM</div>
        </div>
        <div class="summary-card">
            <div class="lbl">Absent</div>
            <div class="val" style="color:#dc2626;">
                <%= absentCount %>
            </div>
            <div class="sub">Not scanned</div>
        </div>
        <div class="summary-card">
            <div class="lbl">Not Marked</div>
            <div class="val" style="color:#9ca3af;">
                <%= notMarkedCount %>
            </div>
            <div class="sub">Window still open</div>
        </div>
    </div>

    <!-- Progress bar -->
    <div class="progress-wrap">
        <div class="progress-top">
            <span>Attendance Rate — <%= filterDate %></span>
            <span>
                <%= presentCount+lateCount %> / <%= totalStudents %>
                present/late
                (<%= attendancePct %>%)
            </span>
        </div>
        <div class="progress-bg">
            <div class="progress-fill"
                 style="width:<%= attendancePct %>%;"></div>
        </div>
    </div>

    <!-- Filter -->
    <div class="filter-bar">
        <form method="get" action="attendance.jsp"
              style="display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap;width:100%;">
            <div class="fg">
                <label>Date</label>
                <input type="date" name="date" value="<%= filterDate %>">
            </div>
            <div class="fg">
                <label>Department</label>
                <select name="dept">
                    <option value="ALL">All Departments</option>
                    <% for(HashMap<String,String> d : deptList){ %>
                    <option value="<%= d.get("dept_id") %>"
                        <%= d.get("dept_id").equals(filterDept)?"selected":"" %>>
                        <%= d.get("dept_code") %> — <%= d.get("dept_name") %>
                    </option>
                    <% } %>
                </select>
            </div>
            <div class="fg">
                <label>Year Level</label>
                <select name="year">
                    <option value="ALL">All Years</option>
                    <option value="First Year"  <%= "First Year".equals(filterYear)?"selected":"" %>>First Year</option>
                    <option value="Second Year" <%= "Second Year".equals(filterYear)?"selected":"" %>>Second Year</option>
                    <option value="Third Year"  <%= "Third Year".equals(filterYear)?"selected":"" %>>Third Year</option>
                    <option value="Fourth Year" <%= "Fourth Year".equals(filterYear)?"selected":"" %>>Fourth Year</option>
                </select>
            </div>
            <button type="submit" class="btn-filter">Filter</button>
            <a href="attendance.jsp" class="btn-reset">Reset</a>
        </form>
    </div>

    <!-- Table -->
    <div class="table-card">
        <div class="table-header">
            <span>Attendance for <%= filterDate %></span>
            <small style="font-size:12px;color:#6b7280;">
                <%= attList.size() %> records
            </small>
        </div>
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Reg Number</th>
                    <th>Full Name</th>
                    <th>Department</th>
                    <th>Year</th>
                    <th>Status</th>
                    <th>Time Marked</th>
                </tr>
            </thead>
            <tbody>
            <% if(attList.isEmpty()){ %>
            <tr>
                <td colspan="7" style="text-align:center;padding:32px;color:#9ca3af;">
                    No records found
                </td>
            </tr>
            <% } else {
                for(int i=0; i<attList.size(); i++){
                    HashMap<String,String> a = attList.get(i);
                    String attStatus = a.get("status");
                    String bStyle = "", bText = "";
                    if("Present".equals(attStatus)){
                        bStyle="background:#e6f4ea;color:#1b5e20;";
                        bText="&#10003; Present";
                    } else if("Late".equals(attStatus)){
                        bStyle="background:#fff3e0;color:#e65100;";
                        bText="&#9201; Late";
                    } else if("Absent".equals(attStatus)){
                        bStyle="background:#fef2f2;color:#dc2626;";
                        bText="&#10007; Absent";
                    } else {
                        bStyle="background:#f3f4f6;color:#9ca3af;";
                        bText="&#8212; Not Marked";
                    }
                    String dc = a.get("dept_code");
                    String yr = a.get("year_level");
                    String yrBadge = "First Year".equals(yr) ? "badge-y1" : "badge-y2";
            %>
            <tr>
                <td style="color:#9ca3af;"><%= (i+1) %></td>
                <td style="font-weight:600;color:#1a237e;">
                    <%= a.get("reg_number") %>
                </td>
                <td><strong><%= a.get("full_name") %></strong></td>
                <td>
                    <span class="badge badge-<%= dc %>">
                        <%= dc %>
                    </span>
                </td>
                <td>
                    <span class="badge <%= yrBadge %>">
                        <%= yr %>
                    </span>
                </td>
                <td>
                    <span class="badge" style="<%= bStyle %>">
                        <%= bText %>
                    </span>
                </td>
                <td style="color:#6b7280;">
                    <%= "Present".equals(attStatus)||"Late".equals(attStatus) ?
                        a.get("att_time") : "—" %>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</div>


</body>
</html>