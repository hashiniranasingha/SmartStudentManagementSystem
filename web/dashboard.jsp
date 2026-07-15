<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.sms.util.RoleCheck" %>
<%
    if(!RoleCheck.isLoggedIn(session)){
        response.sendRedirect("login.jsp"); return;
    }
    // Block students from admin pages
    if(RoleCheck.isStudent(session)){
        response.sendRedirect("studentDashboard.jsp"); return;
    }
%>
<%
    if(session.getAttribute("loggedUser") == null){
        response.sendRedirect("login.jsp");
        return;
    }
    
    

    // ── Summary counts ──────────────────────────────
    int totalStudents=0, totalIT=0, totalENG=0,
        totalTHM=0, totalMGT=0, totalACC=0;

    // ── Today's attendance ──────────────────────────
    String today = new java.text.SimpleDateFormat("yyyy-MM-dd")
                       .format(new java.util.Date());
    int todayPresent=0, todayAbsent=0;

    // ── Per-dept attendance for chart ───────────────
    // Each entry: deptCode, deptName, present, total, pct
    ArrayList<HashMap<String,String>> deptAtt =
        new ArrayList<HashMap<String,String>>();

    // ── Recent attendance log (last 8) ──────────────
    ArrayList<HashMap<String,String>> recentLog =
        new ArrayList<HashMap<String,String>>();

    // ── Weekly attendance (last 7 days) ─────────────
    ArrayList<HashMap<String,String>> weeklyAtt =
        new ArrayList<HashMap<String,String>>();

    String dbError = "";

    try{
        Connection conn = DBConnection.getConnection();

        // Total students per dept
        ResultSet rs = conn.createStatement().executeQuery(
            "SELECT COUNT(*) FROM students");
        if(rs.next()) totalStudents = rs.getInt(1);

        PreparedStatement dps = conn.prepareStatement(
            "SELECT COUNT(*) FROM students s " +
            "JOIN departments d ON s.dept_id=d.dept_id WHERE d.dept_code=?");

        dps.setString(1,"IT");  rs=dps.executeQuery(); if(rs.next()) totalIT  =rs.getInt(1);
        dps.setString(1,"ENG"); rs=dps.executeQuery(); if(rs.next()) totalENG =rs.getInt(1);
        dps.setString(1,"THM"); rs=dps.executeQuery(); if(rs.next()) totalTHM =rs.getInt(1);
        dps.setString(1,"MGT"); rs=dps.executeQuery(); if(rs.next()) totalMGT =rs.getInt(1);
        dps.setString(1,"ACC"); rs=dps.executeQuery(); if(rs.next()) totalACC =rs.getInt(1);

        // Today's overall attendance
        PreparedStatement todayPs = conn.prepareStatement(
            "SELECT " +
            "SUM(CASE WHEN status='Present' THEN 1 ELSE 0 END) as present, " +
            "COUNT(*) as total " +
            "FROM attendance WHERE att_date=?");
        todayPs.setString(1, today);
        ResultSet todayRs = todayPs.executeQuery();
        if(todayRs.next()){
            todayPresent = todayRs.getInt("present");
            todayAbsent  = todayRs.getInt("total") - todayPresent;
        }

        // Per-dept attendance for chart
        ResultSet deptRs = conn.createStatement().executeQuery(
            "SELECT d.dept_code, d.dept_name, " +
            "COUNT(s.student_id) as total_students, " +
            "COALESCE(SUM(CASE WHEN a.status='Present' AND a.att_date='" + today + "' " +
            "THEN 1 ELSE 0 END),0) as present_today " +
            "FROM departments d " +
            "LEFT JOIN students s ON s.dept_id=d.dept_id " +
            "LEFT JOIN attendance a ON a.student_id=s.student_id " +
            "GROUP BY d.dept_id, d.dept_code, d.dept_name " +
            "ORDER BY d.dept_name");
        while(deptRs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            int tot = deptRs.getInt("total_students");
            int pre = deptRs.getInt("present_today");
            int pct = tot > 0 ? (pre * 100 / tot) : 0;
            row.put("dept_code",  deptRs.getString("dept_code"));
            row.put("dept_name",  deptRs.getString("dept_name"));
            row.put("total",      String.valueOf(tot));
            row.put("present",    String.valueOf(pre));
            row.put("pct",        String.valueOf(pct));
            deptAtt.add(row);
        }

        // Recent attendance log
        ResultSet logRs = conn.createStatement().executeQuery(
            "SELECT s.full_name, s.reg_number, d.dept_code, " +
            "a.att_date, a.att_time, a.status " +
            "FROM attendance a " +
            "JOIN students s ON a.student_id=s.student_id " +
            "JOIN departments d ON s.dept_id=d.dept_id " +
            "ORDER BY a.att_date DESC, a.att_time DESC LIMIT 8");
        while(logRs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("name",      logRs.getString("full_name"));
            row.put("reg",       logRs.getString("reg_number"));
            row.put("dept_code", logRs.getString("dept_code"));
            row.put("date",      logRs.getString("att_date"));
            row.put("time",      logRs.getString("att_time") != null ? logRs.getString("att_time") : "—");
            row.put("status",    logRs.getString("status"));
            recentLog.add(row);
        }

        // Weekly attendance last 7 days
        for(int d=6; d>=0; d--){
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.add(java.util.Calendar.DAY_OF_YEAR, -d);
            String dayDate  = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
            String dayLabel = new java.text.SimpleDateFormat("EEE").format(cal.getTime());

            PreparedStatement wps = conn.prepareStatement(
                "SELECT COUNT(*) as present FROM attendance " +
                "WHERE att_date=? AND status='Present'");
            wps.setString(1, dayDate);
            ResultSet wrs = wps.executeQuery();
            int dayPresent = 0;
            if(wrs.next()) dayPresent = wrs.getInt("present");

            HashMap<String,String> row = new HashMap<String,String>();
            row.put("date",    dayDate);
            row.put("label",   dayLabel);
            row.put("present", String.valueOf(dayPresent));
            weeklyAtt.add(row);
        }

        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }

    int todayTotal = todayPresent + todayAbsent;
    int todayPct   = todayTotal > 0 ? (todayPresent * 100 / todayTotal) : 0;

    // Find max for weekly chart scaling
    int weekMax = 1;
    for(HashMap<String,String> w : weeklyAtt){
        int v = Integer.parseInt(w.get("present"));
        if(v > weekMax) weekMax = v;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SMS – Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#f0f2f5;display:flex;min-height:100vh;}

        /* Sidebar */
        .sidebar{width:240px;min-height:100vh;background:linear-gradient(180deg,#1a237e 0%,#0d47a1 100%);display:flex;flex-direction:column;position:fixed;left:0;top:0;box-shadow:4px 0 20px rgba(0,0,0,0.15);}
        .sidebar-logo{padding:24px 20px;border-bottom:1px solid rgba(255,255,255,0.1);}
        .sidebar-logo h2{color:white;font-size:15px;font-weight:700;}
        .sidebar-logo p{color:rgba(255,255,255,0.6);font-size:11px;margin-top:2px;}
        .nav-label{color:rgba(255,255,255,0.4);font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:1px;padding:0 8px;margin-bottom:6px;margin-top:16px;}
        .nav-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:rgba(255,255,255,0.75);font-size:13px;font-weight:500;text-decoration:none;margin-bottom:2px;transition:all 0.15s;}
        .nav-item:hover,.nav-item.active{background:rgba(255,255,255,0.15);color:white;}
        .nav-section{padding:12px;overflow-y:auto;max-height:calc(100vh - 120px);}.nav-section::-webkit-scrollbar{width:4px;}.nav-section::-webkit-scrollbar-thumb{background:rgba(255,255,255,0.2);border-radius:4px;}
        .nav-sub{padding-left:28px !important;font-size:12px !important;}
        .dept-dot{width:8px;height:8px;border-radius:50%;display:inline-block;flex-shrink:0;}
        .sidebar-user{margin-top:auto;padding:16px 20px;border-top:1px solid rgba(255,255,255,0.1);color:rgba(255,255,255,0.8);font-size:12px;}
        .sidebar-user strong{display:block;color:white;font-size:13px;}

        .main{margin-left:240px;padding:28px;flex:1;}

        /* Header */
        .page-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:24px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:3px;}
        .date-badge{background:white;border-radius:10px;padding:10px 16px;font-size:13px;font-weight:600;color:#1a237e;box-shadow:0 1px 4px rgba(0,0,0,0.06);}

        /* Stat cards */
        .stat-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px;}
        .stat-card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
        .stat-card .icon{font-size:24px;margin-bottom:10px;}
        .stat-card .val{font-size:28px;font-weight:800;color:#1a1a2e;}
        .stat-card .lbl{font-size:12px;color:#6b7280;margin-top:4px;}
        .stat-card .sub{font-size:11px;color:#9ca3af;margin-top:3px;}

        /* Today attendance banner */
        .today-banner{
            background:linear-gradient(135deg,#1a237e,#1565c0);
            border-radius:14px;padding:22px 28px;margin-bottom:24px;
            display:flex;align-items:center;gap:24px;flex-wrap:wrap;
        }
        .today-banner h3{font-size:15px;font-weight:700;color:white;margin-bottom:4px;}
        .today-banner p{font-size:12px;color:rgba(255,255,255,0.7);}
        .today-pct{font-size:42px;font-weight:800;color:white;flex-shrink:0;}
        .today-bar-wrap{flex:1;min-width:200px;}
        .today-bar-bg{background:rgba(255,255,255,0.2);border-radius:20px;height:12px;overflow:hidden;margin:10px 0;}
        .today-bar-fill{height:100%;border-radius:20px;background:white;transition:width 0.8s ease;}
        .today-stats{display:flex;gap:20px;}
        .today-stat{text-align:center;}
        .today-stat .n{font-size:22px;font-weight:800;color:white;}
        .today-stat .l{font-size:11px;color:rgba(255,255,255,0.7);}

        /* Two column layout */
        .two-col{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:24px;}
        .three-col{display:grid;grid-template-columns:1fr 1fr 1fr;gap:20px;margin-bottom:24px;}

        /* Cards */
        .card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
        .card-title{font-size:14px;font-weight:700;color:#1a1a2e;margin-bottom:16px;display:flex;justify-content:space-between;align-items:center;}
        .card-title a{font-size:12px;color:#1a237e;font-weight:500;text-decoration:none;}
        .card-title a:hover{text-decoration:underline;}

        /* Dept attendance bars */
        .dept-bar-item{margin-bottom:14px;}
        .dept-bar-item:last-child{margin-bottom:0;}
        .dept-bar-top{display:flex;justify-content:space-between;align-items:center;margin-bottom:4px;}
        .dept-bar-name{font-size:13px;font-weight:500;color:#1a1a2e;display:flex;align-items:center;gap:8px;}
        .dept-bar-pct{font-size:13px;font-weight:700;}
        .dept-bar-sub{font-size:11px;color:#9ca3af;}
        .bar-bg{background:#f3f4f6;border-radius:20px;height:10px;overflow:hidden;}
        .bar-fill{height:100%;border-radius:20px;transition:width 0.8s ease;}

        /* Weekly chart */
        .weekly-chart{display:flex;align-items:flex-end;gap:8px;height:120px;padding:0 4px;}
        .week-bar-wrap{flex:1;display:flex;flex-direction:column;align-items:center;gap:4px;}
        .week-bar-container{flex:1;display:flex;align-items:flex-end;width:100%;}
        .week-bar{
            width:100%;border-radius:6px 6px 0 0;
            background:linear-gradient(180deg,#1565c0,#1a237e);
            transition:height 0.8s ease;min-height:4px;
        }
        .week-bar.today{background:linear-gradient(180deg,#4fc3f7,#1565c0);}
        .week-label{font-size:11px;color:#6b7280;font-weight:500;}
        .week-val{font-size:10px;color:#9ca3af;}

        /* Recent log */
        .log-item{display:flex;align-items:center;gap:12px;padding:9px 0;border-bottom:1px solid #f3f4f6;}
        .log-item:last-child{border-bottom:none;}
        .log-avatar{width:34px;height:34px;border-radius:50%;background:#e8f0fe;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:#1a237e;flex-shrink:0;}
        .log-info{flex:1;}
        .log-info strong{font-size:13px;color:#1a1a2e;display:block;}
        .log-info span{font-size:11px;color:#9ca3af;}
        .log-right{text-align:right;}
        .log-time{font-size:11px;color:#9ca3af;display:block;}
        .att-pill{font-size:11px;padding:2px 8px;border-radius:10px;font-weight:600;}
        .att-p{background:#e6f4ea;color:#1b5e20;}
        .att-a{background:#fef2f2;color:#dc2626;}

        /* Dept quick cards */
        .dept-quick{display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:24px;}
        .dept-q-card{background:white;border-radius:10px;padding:14px 10px;text-align:center;box-shadow:0 1px 4px rgba(0,0,0,0.06);text-decoration:none;transition:transform 0.15s,box-shadow 0.15s;}
        .dept-q-card:hover{transform:translateY(-2px);box-shadow:0 4px 12px rgba(0,0,0,0.1);}
        .dept-q-code{font-size:12px;font-weight:700;padding:3px 10px;border-radius:12px;display:inline-block;margin-bottom:6px;}
        .dept-q-count{font-size:20px;font-weight:800;margin-bottom:2px;}
        .dept-q-label{font-size:10px;color:#9ca3af;}
        .dept-q-pct{font-size:11px;font-weight:600;margin-top:4px;}

        .badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;}
        .badge-IT{background:#e8f0fe;color:#1a237e;}
        .badge-ENG{background:#e6f4ea;color:#1b5e20;}
        .badge-THM{background:#fff3e0;color:#e65100;}
        .badge-MGT{background:#fce4ec;color:#880e4f;}
        .badge-ACC{background:#f3e8fd;color:#4a148c;}

        /* Quick actions */
        .quick-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;}
        .quick-card{background:white;border-radius:10px;padding:18px;box-shadow:0 1px 4px rgba(0,0,0,0.06);text-decoration:none;transition:transform 0.15s;}
        .quick-card:hover{transform:translateY(-2px);}
        .quick-card h4{font-size:13px;font-weight:600;color:#1a1a2e;margin-bottom:3px;}
        .quick-card p{font-size:12px;color:#6b7280;}
        .quick-card .q-icon{font-size:22px;margin-bottom:10px;}
        
        /* Enhanced card hover */
.stat-card{
    transition:transform 0.2s, box-shadow 0.2s;
    cursor:default;
}
.stat-card:hover{
    transform:translateY(-3px);
    box-shadow:0 8px 24px rgba(0,0,0,0.1);
}
/* Better table rows */
tbody tr{transition:background 0.15s;}
/* Smooth nav items */
.nav-item{transition:all 0.2s;}
/* Input focus glow */
input:focus, select:focus{
    box-shadow:0 0 0 3px rgba(26,35,126,0.12)!important;
}
/* Button press effect */
button:active{transform:scale(0.97);}
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
        <a href="dashboard.jsp"   class="nav-item active">&#9632; Dashboard</a>
        <a href="students.jsp"    class="nav-item">&#128101; Students</a>
        <a href="students.jsp?dept=IT"  class="nav-item nav-sub">
            <span class="dept-dot" style="background:#4fc3f7;"></span> IT
        </a>
        <a href="students.jsp?dept=ENG" class="nav-item nav-sub">
            <span class="dept-dot" style="background:#81c784;"></span> English
        </a>
        <a href="students.jsp?dept=THM" class="nav-item nav-sub">
            <span class="dept-dot" style="background:#ffb74d;"></span> THM
        </a>
        <a href="students.jsp?dept=MGT" class="nav-item nav-sub">
            <span class="dept-dot" style="background:#f48fb1;"></span> Management
        </a>
        <a href="students.jsp?dept=ACC" class="nav-item nav-sub">
            <span class="dept-dot" style="background:#ce93d8;"></span> Accountancy
        </a>
        <a href="attendance.jsp"  class="nav-item">&#9989; Attendance</a>
        <a href="monthlyReport.jsp" class="nav-item">
    &#128197; Monthly Report
</a>
        <a href="qrCode.jsp"      class="nav-item">&#9638; QR Codes</a>
        <a href="qrScan.jsp"      class="nav-item">&#128247; QR Scanner</a>
        <a href="marks.jsp"       class="nav-item">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"    class="nav-item">&#128218; Subjects</a>
        <a href="reports.jsp"     class="nav-item">&#128202; Reports</a>
        <a href="lms.jsp" class="nav-item">&#128196; LMS Materials</a>
        <a href="manageUsers.jsp" class="nav-item">&#128272; Manage Users</a>
        <a href="emailNotify.jsp" class="nav-item">&#128231; Email Alerts</a>
        <a href="notices.jsp" class="nav-item">&#128276; Notice Board</a>
        <div class="nav-label">Account</div>
        <a href="chatbot.jsp" class="nav-item">&#129302; Assistant</a>
        <a href="LogoutServlet"   class="nav-item">&#128682; Logout</a>
    </div>
    <div class="sidebar-user">
        <strong><%= session.getAttribute("loggedUser") %></strong>
        <%= session.getAttribute("userRole") %>
    </div>
</div>

<!-- MAIN -->
<div class="main">

    <!-- Header -->
    <div class="page-header">
        <div>
            <h1>&#128202; Dashboard</h1>
            <p>Welcome back, <strong><%= session.getAttribute("loggedUser") %></strong>!
               Here is today's overview.</p>
        </div>
        <div class="date-badge">
            &#128197; <%= new java.text.SimpleDateFormat("EEEE, dd MMMM yyyy")
                             .format(new java.util.Date()) %>
        </div>
    </div>

    <% if(dbError != null && !dbError.isEmpty()){ %>
    <div style="background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:18px;font-size:13px;">
        &#9888; <%= dbError %>
    </div>
    <% } %>

    <!-- Summary stats -->
    <div class="stat-grid">
        <div class="stat-card">
            <div class="icon">&#128104;&#8205;&#127979;</div>
            <div class="val"><%= totalStudents %></div>
            <div class="lbl">Total Students</div>
            <div class="sub">All departments</div>
        </div>
        <div class="stat-card">
            <div class="icon">&#127963;</div>
            <div class="val">5</div>
            <div class="lbl">Departments</div>
            <div class="sub">IT · ENG · THM · MGT · ACC</div>
        </div>
        <div class="stat-card">
            <div class="icon">&#9989;</div>
            <div class="val" style="color:#1b5e20;"><%= todayPresent %></div>
            <div class="lbl">Present Today</div>
            <div class="sub"><%= today %></div>
        </div>
        <div class="stat-card">
            <div class="icon">&#128202;</div>
            <div class="val" style="color:<%= todayPct>=75?"#1b5e20":todayPct>=50?"#f57c00":"#dc2626" %>;">
                <%= todayPct %>%
            </div>
            <div class="lbl">Today's Rate</div>
            <div class="sub"><%= todayPresent %>/<%= todayTotal %> students</div>
        </div>
    </div>

    <!-- Today attendance banner -->
    <div class="today-banner">
        <div>
            <h3>&#128197; Today's Attendance</h3>
            <p><%= today %></p>
        </div>
        <div class="today-pct"><%= todayPct %>%</div>
        <div class="today-bar-wrap">
            <div class="today-bar-bg">
                <div class="today-bar-fill" style="width:<%= todayPct %>%;"></div>
            </div>
            <div class="today-stats">
                <div class="today-stat">
                    <div class="n"><%= todayPresent %></div>
                    <div class="l">Present</div>
                </div>
                <div class="today-stat">
                    <div class="n"><%= todayAbsent %></div>
                    <div class="l">Absent</div>
                </div>
                <div class="today-stat">
                    <div class="n"><%= totalStudents %></div>
                    <div class="l">Total</div>
                </div>
            </div>
        </div>
        <a href="qrScan.jsp"
           style="background:white;color:#1a237e;border:none;border-radius:10px;
                  padding:12px 20px;font-size:13px;font-weight:700;cursor:pointer;
                  text-decoration:none;white-space:nowrap;">
            &#128247; Open Scanner
        </a>
    </div>

    <!-- Dept quick cards -->
    <div class="dept-quick">
        <%
        String[] dcs   = {"IT","ENG","THM","MGT","ACC"};
        int[]    dCnts = {totalIT,totalENG,totalTHM,totalMGT,totalACC};
        String[] dcColors = {"#1a237e","#1b5e20","#e65100","#880e4f","#4a148c"};
        String[] dcBgs    = {"#e8f0fe","#e6f4ea","#fff3e0","#fce4ec","#f3e8fd"};

        for(int di=0; di<dcs.length; di++){
            // Find attendance pct for this dept
            int dPct = 0;
            for(HashMap<String,String> da : deptAtt){
                if(dcs[di].equals(da.get("dept_code"))){
                    dPct = Integer.parseInt(da.get("pct")); break;
                }
            }
        %>
        <a href="students.jsp?dept=<%= dcs[di] %>" class="dept-q-card">
            <div class="dept-q-code"
                 style="background:<%= dcBgs[di] %>;color:<%= dcColors[di] %>;">
                <%= dcs[di] %>
            </div>
            <div class="dept-q-count" style="color:<%= dcColors[di] %>;">
                <%= dCnts[di] %>
            </div>
            <div class="dept-q-label">students</div>
            <div class="dept-q-pct"
                 style="color:<%= dPct>=75?"#1b5e20":dPct>=50?"#f57c00":"#9ca3af" %>;">
                <%= dPct > 0 ? dPct+"% today" : "no data" %>
            </div>
        </a>
        <% } %>
    </div>

    <!-- Charts row -->
    <div class="two-col">

        <!-- Dept attendance bar chart -->
        <div class="card">
            <div class="card-title">
                <span>&#128202; Attendance by Department — Today</span>
                <a href="attendance.jsp">View All</a>
            </div>
            <% for(HashMap<String,String> da : deptAtt){
                int pct = Integer.parseInt(da.get("pct"));
                String barColor = pct>=75?"#1b5e20": pct>=50?"#f57c00":"#dc2626";
                String dc = da.get("dept_code");
            %>
            <div class="dept-bar-item">
                <div class="dept-bar-top">
                    <div class="dept-bar-name">
                        <span class="badge badge-<%= dc %>"><%= dc %></span>
                        <span style="font-size:12px;color:#6b7280;">
                            <%= da.get("dept_name") %>
                        </span>
                    </div>
                    <div>
                        <span class="dept-bar-pct" style="color:<%= barColor %>;">
                            <%= pct %>%
                        </span>
                        <span class="dept-bar-sub">
                            &nbsp;<%= da.get("present") %>/<%= da.get("total") %>
                        </span>
                    </div>
                </div>
                <div class="bar-bg">
                    <div class="bar-fill"
                         style="width:<%= pct %>%;background:<%= barColor %>;">
                    </div>
                </div>
            </div>
            <% } %>
        </div>

        <!-- Weekly attendance chart -->
        <div class="card">
            <div class="card-title">
                <span>&#128197; Weekly Attendance — Last 7 Days</span>
                <a href="attendance.jsp">Details</a>
            </div>
            <div class="weekly-chart">
                <% for(int wi=0; wi<weeklyAtt.size(); wi++){
                    HashMap<String,String> w = weeklyAtt.get(wi);
                    int val   = Integer.parseInt(w.get("present"));
                    int hPct  = weekMax > 0 ? (val * 100 / weekMax) : 0;
                    boolean isToday = today.equals(w.get("date"));
                %>
                <div class="week-bar-wrap">
                    <div class="week-val"><%= val %></div>
                    <div class="week-bar-container">
                        <div class="week-bar <%= isToday?"today":"" %>"
                             style="height:<%= Math.max(hPct,4) %>%;">
                        </div>
                    </div>
                    <div class="week-label"
                         style="color:<%= isToday?"#1a237e":"#6b7280" %>;
                                font-weight:<%= isToday?"700":"400" %>;">
                        <%= w.get("label") %>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Recent log + Quick actions -->
    <div class="two-col">

        <!-- Recent attendance log -->
        <div class="card">
            <div class="card-title">
                <span>&#128203; Recent Attendance Log</span>
                <a href="attendance.jsp">View All</a>
            </div>
            <% if(recentLog.isEmpty()){ %>
            <div style="text-align:center;padding:24px;color:#9ca3af;font-size:13px;">
                No attendance records yet today
            </div>
            <% } else {
                for(HashMap<String,String> log : recentLog){
                    boolean isP = "Present".equals(log.get("status"));
                    String ini = "?";
                    String nm  = log.get("name");
                    if(nm!=null && nm.length()>0){
                        String[] pts = nm.split(" ");
                        ini = pts[0].substring(0,1).toUpperCase();
                        if(pts.length>1) ini += pts[pts.length-1].substring(0,1).toUpperCase();
                    }
            %>
            <div class="log-item">
                <div class="log-avatar"><%= ini %></div>
                <div class="log-info">
                    <strong><%= log.get("name") %></strong>
                    <span><%= log.get("reg") %> &nbsp;|&nbsp;
                        <span class="badge badge-<%= log.get("dept_code") %>">
                            <%= log.get("dept_code") %>
                        </span>
                    </span>
                </div>
                <div class="log-right">
                    <span class="log-time"><%= log.get("date") %> <%= log.get("time") %></span>
                    <span class="att-pill <%= isP?"att-p":"att-a" %>">
                        <%= log.get("status") %>
                    </span>
                </div>
            </div>
            <% } } %>
        </div>

        <!-- Quick actions -->
        <div class="card">
            <div class="card-title">
                <span>&#9889; Quick Actions</span>
            </div>
            <div class="quick-grid">
                <a href="addStudent.jsp" class="quick-card">
                    <div class="q-icon">&#10133;</div>
                    <h4>Add Student</h4>
                    <p>Register new student</p>
                </a>
                <a href="qrScan.jsp" class="quick-card">
                    <div class="q-icon">&#128247;</div>
                    <h4>QR Scanner</h4>
                    <p>Mark attendance</p>
                </a>
                <a href="qrCode.jsp" class="quick-card">
                    <div class="q-icon">&#9638;</div>
                    <h4>QR Codes</h4>
                    <p>Generate QR codes</p>
                </a>
                <a href="marks.jsp" class="quick-card">
                    <div class="q-icon">&#128196;</div>
                    <h4>Enter Marks</h4>
                    <p>Add student grades</p>
                </a>
                <a href="reports.jsp" class="quick-card">
                    <div class="q-icon">&#128202;</div>
                    <h4>Reports</h4>
                    <p>Download PDFs</p>
                </a>
                <a href="emailNotify.jsp" class="quick-card">
                    <div class="q-icon">&#128231;</div>
                    <h4>Email Alerts</h4>
                    <p>Low attendance</p>
                </a>
            </div>
        </div>
    </div>

</div>
 
</body>


</html>