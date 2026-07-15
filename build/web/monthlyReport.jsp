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

    String filterDept  = request.getParameter("dept");
    String filterMonth = request.getParameter("month");
    String filterYear  = request.getParameter("year");

    if(filterDept  == null) filterDept  = "ALL";
    if(filterMonth == null) filterMonth = String.valueOf(
        java.util.Calendar.getInstance().get(java.util.Calendar.MONTH)+1);
    if(filterYear  == null) filterYear  = String.valueOf(
        java.util.Calendar.getInstance().get(java.util.Calendar.YEAR));

    ArrayList<HashMap<String,String>> deptList =
        new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> reportData =
        new ArrayList<HashMap<String,String>>();
    int totalWorkDays = 0;
    String dbError = "";
    String monthName = "";

    // Month names
    String[] months = {"","January","February","March","April",
        "May","June","July","August","September",
        "October","November","December"};
    try{
        monthName = months[Integer.parseInt(filterMonth)];
    }catch(Exception me){ monthName = ""; }

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

        // Total working days in selected month/year
        String wdSql =
            "SELECT COUNT(DISTINCT att_date) as days " +
            "FROM attendance WHERE " +
            "MONTH(att_date)=? AND YEAR(att_date)=?";
        PreparedStatement wdPs = conn.prepareStatement(wdSql);
        wdPs.setInt(1, Integer.parseInt(filterMonth));
        wdPs.setInt(2, Integer.parseInt(filterYear));
        ResultSet wdRs = wdPs.executeQuery();
        if(wdRs.next()) totalWorkDays = wdRs.getInt("days");

        String filterYear2 = request.getParameter("yearlevel");
if(filterYear2 == null) filterYear2 = "ALL";

        // Monthly report data
        String sql =
            "SELECT s.student_id, s.full_name, s.reg_number, " +
            "s.year_level, d.dept_code, d.dept_name, " +
            "COUNT(CASE WHEN a.status='Present' THEN 1 END) as present_days, " +
            "COUNT(CASE WHEN a.status='Late' THEN 1 END) as late_days, " +
            "COUNT(CASE WHEN a.status='Absent' OR a.att_id IS NULL " +
            "THEN 1 END) as absent_days " +
            "FROM students s " +
            "JOIN departments d ON s.dept_id=d.dept_id " +
            "LEFT JOIN attendance a ON s.student_id=a.student_id " +
            "AND MONTH(a.att_date)=? AND YEAR(a.att_date)=? " +
            "WHERE 1=1 ";
            
            if(!"ALL".equals(filterYear2))
    sql += " AND s.year_level='" + filterYear2 + "'";
    
        if(!"ALL".equals(filterDept))
            sql += " AND d.dept_id=" + filterDept;
        sql += " GROUP BY s.student_id,s.full_name,s.reg_number," +
               "s.year_level,d.dept_code,d.dept_name " +
               " ORDER BY d.dept_code, s.reg_number";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(filterMonth));
        ps.setInt(2, Integer.parseInt(filterYear));
        ResultSet rs = ps.executeQuery();

        while(rs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            int present = rs.getInt("present_days");
            int late    = rs.getInt("late_days");
            int pct     = totalWorkDays>0 ?
                ((present+late)*100/totalWorkDays) : 0;

            row.put("student_id",  String.valueOf(rs.getInt("student_id")));
            row.put("full_name",   rs.getString("full_name"));
            row.put("reg_number",  rs.getString("reg_number"));
            row.put("year_level",  rs.getString("year_level"));
            row.put("dept_code",   rs.getString("dept_code"));
            row.put("dept_name",   rs.getString("dept_name"));
            row.put("present",     String.valueOf(present));
            row.put("late",        String.valueOf(late));
            row.put("absent",      String.valueOf(totalWorkDays-present-late));
            row.put("pct",         String.valueOf(pct));
            row.put("status",      pct>=75?"Good":pct>=50?"Warning":"Low");
            reportData.add(row);
        }
        conn.close();
    }catch(Exception e){ dbError = e.getMessage(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Monthly Attendance Report</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#f0f2f5;display:flex;min-height:100vh;}
        .sidebar{width:240px;min-height:100vh;background:linear-gradient(180deg,#1a237e,#0d47a1);display:flex;flex-direction:column;position:fixed;left:0;top:0;}
        .sidebar-logo{padding:24px 20px;border-bottom:1px solid rgba(255,255,255,0.1);}
        .sidebar-logo h2{color:white;font-size:15px;font-weight:700;}
        .sidebar-logo p{color:rgba(255,255,255,0.6);font-size:11px;}
        .nav-label{color:rgba(255,255,255,0.4);font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:1px;padding:0 8px;margin-bottom:6px;margin-top:16px;}
        .nav-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:rgba(255,255,255,0.75);font-size:13px;font-weight:500;text-decoration:none;margin-bottom:2px;transition:all 0.15s;}
        .nav-item:hover,.nav-item.active{background:rgba(255,255,255,0.15);color:white;}
        .nav-section{padding:12px;}
        .sidebar-user{margin-top:auto;padding:16px 20px;border-top:1px solid rgba(255,255,255,0.1);color:rgba(255,255,255,0.8);font-size:12px;}
        .sidebar-user strong{display:block;color:white;font-size:13px;}
        .main{margin-left:240px;padding:28px;flex:1;}
        .page-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:4px;}
        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}

        .filter-card{background:white;border-radius:12px;padding:16px 20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);margin-bottom:20px;display:flex;gap:14px;align-items:flex-end;flex-wrap:wrap;}
        .fg{display:flex;flex-direction:column;gap:5px;}
        .fg label{font-size:12px;font-weight:500;color:#374151;}
        .fg select{padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;min-width:150px;}
        .fg select:focus{border-color:#1a237e;}
        .btn-filter{background:#1a237e;color:white;border:none;border-radius:8px;padding:10px 20px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
        .btn-print{background:#1b5e20;color:white;border:none;border-radius:8px;padding:10px 20px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}

        /* Summary cards */
        .summary-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:20px;}
        .sum-card{background:white;border-radius:12px;padding:16px;box-shadow:0 1px 4px rgba(0,0,0,0.06);text-align:center;}
        .sum-card .val{font-size:24px;font-weight:800;margin-bottom:4px;}
        .sum-card .lbl{font-size:12px;color:#6b7280;}

        /* Table */
        .table-card{background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.06);overflow:hidden;}
        .table-header{padding:16px 20px;border-bottom:1px solid #f3f4f6;display:flex;justify-content:space-between;align-items:center;}
        .table-header span{font-size:14px;font-weight:600;color:#1a1a2e;}
        table{width:100%;border-collapse:collapse;}
        thead th{background:#f8f9fa;padding:11px 14px;text-align:left;font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;}
        tbody tr{border-bottom:1px solid #f3f4f6;}
        tbody tr:hover{background:#f8f9ff;}
        tbody td{padding:11px 14px;font-size:13px;color:#1a1a2e;}

        .badge{display:inline-block;padding:3px 8px;border-radius:10px;font-size:11px;font-weight:600;}
        .badge-IT{background:#e8f0fe;color:#1a237e;}
        .badge-ENG{background:#e6f4ea;color:#1b5e20;}
        .badge-THM{background:#fff3e0;color:#e65100;}
        .badge-MGT{background:#fce4ec;color:#880e4f;}
        .badge-ACC{background:#f3e8fd;color:#4a148c;}

        .pct-bar{width:80px;height:8px;background:#f3f4f6;border-radius:4px;display:inline-block;vertical-align:middle;margin-right:6px;}
        .pct-fill{height:100%;border-radius:4px;}
        .status-good{color:#1b5e20;font-weight:600;font-size:12px;}
        .status-warn{color:#f57c00;font-weight:600;font-size:12px;}
        .status-low{color:#dc2626;font-weight:600;font-size:12px;}

        @media print{
            .sidebar,.filter-card,.page-header .btn-print{display:none!important;}
            .main{margin-left:0;padding:8px;}
        }
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
        <a href="dashboard.jsp"      class="nav-item">&#9632; Dashboard</a>
        <a href="students.jsp"       class="nav-item">&#128101; Students</a>
        <a href="attendance.jsp"     class="nav-item">&#9989; Attendance</a>
        <a href="monthlyReport.jsp"  class="nav-item active">&#128197; Monthly Report</a>
        <a href="qrCode.jsp"         class="nav-item">&#9638; QR Codes</a>
        <a href="qrScan.jsp"         class="nav-item">&#128247; QR Scanner</a>
        <a href="marks.jsp"          class="nav-item">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"       class="nav-item">&#128218; Subjects</a>
        <a href="lms.jsp"            class="nav-item">&#128196; LMS</a>
        <a href="reports.jsp"        class="nav-item">&#128202; Reports</a>
        <a href="emailNotify.jsp" class="nav-item">&#128231; Email Alerts</a>
        <a href="notices.jsp" class="nav-item">&#128276; Notice Board</a>
        <a href="chatbot.jsp" class="nav-item">&#129302; Assistant</a>
        <a href="manageUsers.jsp"    class="nav-item">&#128272; Manage Users</a>
        <div class="nav-label">Account</div>
        <a href="LogoutServlet"      class="nav-item">&#128682; Logout</a>
    </div>
    <div class="sidebar-user">
        <strong><%= session.getAttribute("loggedUser") %></strong>
        <%= session.getAttribute("userRole") %>
    </div>
</div>

<div class="main">
    <div class="page-header">
        <div>
            <h1>&#128197; Monthly Attendance Report</h1>
            <p><%= monthName %> <%= filterYear %></p>
        </div>
        <button class="btn-print" onclick="window.print()">
            &#128424; Print / Download
        </button>
    </div>

    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <!-- Filter -->
    <div class="filter-card">
        <form method="get" action="monthlyReport.jsp"
              style="display:flex;gap:14px;align-items:flex-end;flex-wrap:wrap;width:100%;">
            <div class="fg">
                <label>Month</label>
                <select name="month">
                    <% for(int m=1; m<=12; m++){ %>
                    <option value="<%= m %>"
                        <%= String.valueOf(m).equals(filterMonth)?"selected":"" %>>
                        <%= months[m] %>
                    </option>
                    <% } %>
                </select>
            </div>
            <div class="fg">
                <label>Year</label>
                <select name="year">
                    <% for(int y=2024; y<=2027; y++){ %>
                    <option value="<%= y %>"
                        <%= String.valueOf(y).equals(filterYear)?"selected":"" %>>
                        <%= y %>
                    </option>
                    <% } %>
                </select>
            </div>
            <div class="fg">
                <label>Department</label>
                <select name="dept">
                    <option value="ALL"
                        <%= "ALL".equals(filterDept)?"selected":"" %>>
                        All Departments
                    </option>
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
    <select name="yearlevel">
        <option value="ALL">All Years</option>
        <option value="First Year"
            <%= "First Year".equals(request.getParameter("yearlevel"))
                ?"selected":"" %>>First Year</option>
        <option value="Second Year"
            <%= "Second Year".equals(request.getParameter("yearlevel"))
                ?"selected":"" %>>Second Year</option>
        <option value="Third Year"
            <%= "Third Year".equals(request.getParameter("yearlevel"))
                ?"selected":"" %>>Third Year</option>
        <option value="Fourth Year"
            <%= "Fourth Year".equals(request.getParameter("yearlevel"))
                ?"selected":"" %>>Fourth Year</option>
    </select>
</div>
    
            <button type="submit" class="btn-filter">
                &#128202; Generate Report
            </button>
        </form>
    </div>

    <%
    // Calculate summary stats
    int totalStudents = reportData.size();
    int goodCount=0, warnCount=0, lowCount=0;
    for(HashMap<String,String> r : reportData){
        String st = r.get("status");
        if("Good".equals(st)) goodCount++;
        else if("Warning".equals(st)) warnCount++;
        else lowCount++;
    }
    %>

    <!-- Summary -->
    <div class="summary-grid">
        <div class="sum-card">
            <div class="val" style="color:#1a237e;"><%= totalStudents %></div>
            <div class="lbl">Total Students</div>
        </div>
        <div class="sum-card">
            <div class="val" style="color:#1b5e20;"><%= goodCount %></div>
            <div class="lbl">Good (75%+)</div>
        </div>
        <div class="sum-card">
            <div class="val" style="color:#f57c00;"><%= warnCount %></div>
            <div class="lbl">Warning (50-74%)</div>
        </div>
        <div class="sum-card">
            <div class="val" style="color:#dc2626;"><%= lowCount %></div>
            <div class="lbl">Low (&lt;50%)</div>
        </div>
    </div>

    <!-- Report Table -->
    <div class="table-card">
        <div class="table-header">
            <span>
                Monthly Report — <%= monthName %> <%= filterYear %>
                (Working days: <%= totalWorkDays %>)
            </span>
            <small style="font-size:12px;color:#6b7280;">
                <%= totalStudents %> students
            </small>
        </div>
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Reg Number</th>
                    <th>Full Name</th>
                    <th>Dept</th>
                    <th>Year</th>
                    <th>Present</th>
                    <th>Late</th>
                    <th>Absent</th>
                    <th>Attendance %</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
            <% if(reportData.isEmpty()){ %>
            <tr>
                <td colspan="10" style="text-align:center;padding:32px;color:#9ca3af;">
                    No attendance data for <%= monthName %> <%= filterYear %>
                </td>
            </tr>
            <% } else {
                for(int i=0; i<reportData.size(); i++){
                    HashMap<String,String> r = reportData.get(i);
                    int pct = Integer.parseInt(r.get("pct"));
                    String barColor = pct>=75?"#1b5e20":pct>=50?"#f57c00":"#dc2626";
                    String dc = r.get("dept_code");
            %>
            <tr>
                <td style="color:#9ca3af;"><%= (i+1) %></td>
                <td style="font-weight:600;color:#1a237e;">
                    <%= r.get("reg_number") %>
                </td>
                <td><strong><%= r.get("full_name") %></strong></td>
                <td>
                    <span class="badge badge-<%= dc %>"><%= dc %></span>
                </td>
                <td style="font-size:12px;color:#6b7280;">
                    <%= r.get("year_level") %>
                </td>
                <td style="color:#1b5e20;font-weight:600;">
                    <%= r.get("present") %>
                </td>
                <td style="color:#f57c00;font-weight:600;">
                    <%= r.get("late") %>
                </td>
                <td style="color:#dc2626;font-weight:600;">
                    <%= r.get("absent") %>
                </td>
                <td>
                    <div class="pct-bar">
                        <div class="pct-fill"
                             style="width:<%= pct %>%;
                             background:<%= barColor %>;">
                        </div>
                    </div>
                    <strong style="color:<%= barColor %>;">
                        <%= pct %>%
                    </strong>
                </td>
                <td>
                    <span class="status-<%= r.get("status").toLowerCase() %>">
                        <%
                        String st = r.get("status");
                        if("Good".equals(st)){%>&#10003; Good
                        <%}else if("Warning".equals(st)){%>&#9888; Warning
                        <%}else{%>&#10060; Low<%}%>
                    </span>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</div>
            
            
</body>
</html>