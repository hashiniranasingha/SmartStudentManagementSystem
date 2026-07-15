<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.LinkedHashMap" %>
<%
    if(session.getAttribute("loggedUser") == null){
        response.sendRedirect("login.jsp"); return;
    }

    String studentId = request.getParameter("id");
    if(studentId == null || studentId.isEmpty()){
        response.sendRedirect("students.jsp"); return;
    }

    // Student basic info
    String sName="", sReg="", sEmail="", sPhone="";
    String sDept="", sDeptCode="", sYear="", sCourse="";
    String sQR="";
    int    sDeptId=0;

    // Attendance stats
    int totalDays=0, presentDays=0, absentDays=0;
    int attPercent=0;

    // Marks grouped by semester
    LinkedHashMap<Integer, ArrayList<HashMap<String,String>>> semMarks =
        new LinkedHashMap<Integer, ArrayList<HashMap<String,String>>>();

    double totalGPA = 0; int gpaCount = 0;

    // Recent attendance (last 10)
    ArrayList<HashMap<String,String>> recentAtt =
        new ArrayList<HashMap<String,String>>();

    String dbError = "";
    int examYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

    try{
        Connection conn = DBConnection.getConnection();

        // Student info
        PreparedStatement ps = conn.prepareStatement(
            "SELECT s.*, d.dept_name, d.dept_code " +
            "FROM students s JOIN departments d ON s.dept_id=d.dept_id " +
            "WHERE s.student_id=?");
        ps.setInt(1, Integer.parseInt(studentId));
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            sName    = rs.getString("full_name")    != null ? rs.getString("full_name")    : "";
            sReg     = rs.getString("reg_number")   != null ? rs.getString("reg_number")   : "";
            sEmail   = rs.getString("email")        != null ? rs.getString("email")        : "-";
            sPhone   = rs.getString("phone")        != null ? rs.getString("phone")        : "-";
            sDept    = rs.getString("dept_name")    != null ? rs.getString("dept_name")    : "";
            sDeptCode= rs.getString("dept_code")    != null ? rs.getString("dept_code")    : "";
            sYear    = rs.getString("year_level")   != null ? rs.getString("year_level")   : "";
            sCourse  = rs.getString("course_name")  != null ? rs.getString("course_name")  : "-";
            sQR      = rs.getString("qr_code_path") != null ? rs.getString("qr_code_path") : "";
            sDeptId  = rs.getInt("dept_id");
        }

        // Attendance stats
        PreparedStatement attPs = conn.prepareStatement(
            "SELECT COUNT(*) as total, " +
            "SUM(CASE WHEN status='Present' THEN 1 ELSE 0 END) as present " +
            "FROM attendance WHERE student_id=?");
        attPs.setInt(1, Integer.parseInt(studentId));
        ResultSet attRs = attPs.executeQuery();
        if(attRs.next()){
            totalDays   = attRs.getInt("total");
            presentDays = attRs.getInt("present");
            absentDays  = totalDays - presentDays;
            attPercent  = totalDays > 0 ? (presentDays * 100 / totalDays) : 0;
        }

        // Recent attendance (last 10 records)
        PreparedStatement recPs = conn.prepareStatement(
            "SELECT att_date, att_time, status FROM attendance " +
            "WHERE student_id=? ORDER BY att_date DESC LIMIT 10");
        recPs.setInt(1, Integer.parseInt(studentId));
        ResultSet recRs = recPs.executeQuery();
        while(recRs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("date",   recRs.getString("att_date")  != null ? recRs.getString("att_date")  : "");
            row.put("time",   recRs.getString("att_time")  != null ? recRs.getString("att_time")  : "-");
            row.put("status", recRs.getString("status")    != null ? recRs.getString("status")    : "Absent");
            recentAtt.add(row);
        }

        // Marks grouped by semester
        PreparedStatement mps = conn.prepareStatement(
            "SELECT sub.subject_name, sub.semester, sub.credit_hours, " +
            "m.grade, m.gpa_points " +
            "FROM subjects sub " +
            "LEFT JOIN marks m ON sub.subject_id=m.subject_id " +
            "AND m.student_id=? AND m.exam_year=? " +
            "WHERE sub.dept_id=? " +
            "ORDER BY sub.semester, sub.subject_name");
        mps.setInt(1, Integer.parseInt(studentId));
        mps.setInt(2, examYear);
        mps.setInt(3, sDeptId);
        ResultSet mRs = mps.executeQuery();
        while(mRs.next()){
            int sem = mRs.getInt("semester");
            if(!semMarks.containsKey(sem)){
                semMarks.put(sem, new ArrayList<HashMap<String,String>>());
            }
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("subject_name", mRs.getString("subject_name"));
            row.put("semester",     String.valueOf(sem));
            row.put("credit_hours", String.valueOf(mRs.getInt("credit_hours")));
            row.put("grade",        mRs.getString("grade")      != null ? mRs.getString("grade")      : "—");
            row.put("gpa_points",   mRs.getString("gpa_points") != null ?
                    String.format("%.1f", mRs.getDouble("gpa_points")) : "—");
            semMarks.get(sem).add(row);

            if(mRs.getString("gpa_points") != null){
                double pts = mRs.getDouble("gpa_points");
                if(pts >= 0){ totalGPA += pts; gpaCount++; }
            }
        }
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }

    double avgGPA = gpaCount > 0 ? totalGPA / gpaCount : 0.0;
    String gpaGrade = avgGPA>=3.7?"A+": avgGPA>=3.3?"A": avgGPA>=3.0?"A-":
                      avgGPA>=2.7?"B+": avgGPA>=2.3?"B": avgGPA>=2.0?"B-":
                      avgGPA>=1.7?"C+": avgGPA>=1.3?"C": avgGPA>=1.0?"C-":"F";

    String[] yearNames = {"First Year","Second Year","Third Year","Fourth Year"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – <%= sName %></title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#f0f2f5;display:flex;min-height:100vh;}
        .sidebar{width:240px;min-height:100vh;background:linear-gradient(180deg,#1a237e 0%,#0d47a1 100%);display:flex;flex-direction:column;position:fixed;left:0;top:0;box-shadow:4px 0 20px rgba(0,0,0,0.15);}
        .sidebar-logo{padding:24px 20px;border-bottom:1px solid rgba(255,255,255,0.1);}
        .sidebar-logo h2{color:white;font-size:15px;font-weight:700;}
        .sidebar-logo p{color:rgba(255,255,255,0.6);font-size:11px;margin-top:2px;}
        .nav-label{color:rgba(255,255,255,0.4);font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:1px;padding:0 8px;margin-bottom:6px;margin-top:16px;}
        .nav-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:rgba(255,255,255,0.75);font-size:13px;font-weight:500;text-decoration:none;margin-bottom:2px;transition:all 0.15s;}
        .nav-item:hover{background:rgba(255,255,255,0.15);color:white;}
        .nav-section{padding:12px;}
        .sidebar-user{margin-top:auto;padding:16px 20px;border-top:1px solid rgba(255,255,255,0.1);color:rgba(255,255,255,0.8);font-size:12px;}
        .sidebar-user strong{display:block;color:white;font-size:13px;}

        .main{margin-left:240px;padding:28px;flex:1;}

        /* Back button */
        .back-btn{display:inline-flex;align-items:center;gap:6px;color:#1a237e;font-size:13px;font-weight:500;text-decoration:none;margin-bottom:20px;background:white;padding:8px 14px;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
        .back-btn:hover{background:#e8f0fe;}

        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:18px;font-size:13px;}

        /* Profile header */
        .profile-header{
            background:linear-gradient(135deg,#1a237e 0%,#1565c0 100%);
            border-radius:16px;padding:28px;margin-bottom:24px;
            display:flex;align-items:center;gap:24px;
            box-shadow:0 4px 20px rgba(26,35,126,0.3);
        }
        .profile-avatar{
            width:80px;height:80px;border-radius:20px;
            background:rgba(255,255,255,0.2);
            display:flex;align-items:center;justify-content:center;
            font-size:28px;font-weight:800;color:white;flex-shrink:0;
            border:3px solid rgba(255,255,255,0.3);
        }
        .profile-info{flex:1;}
        .profile-info h1{font-size:22px;font-weight:800;color:white;margin-bottom:4px;}
        .profile-info .reg{font-size:14px;color:rgba(255,255,255,0.8);margin-bottom:10px;}
        .profile-tags{display:flex;gap:8px;flex-wrap:wrap;}
        .profile-tag{
            background:rgba(255,255,255,0.15);color:white;
            padding:4px 12px;border-radius:20px;font-size:12px;font-weight:500;
            border:1px solid rgba(255,255,255,0.2);
        }
        .profile-actions{display:flex;flex-direction:column;gap:8px;flex-shrink:0;}
        .btn-edit-profile{
            background:white;color:#1a237e;border:none;border-radius:8px;
            padding:9px 18px;font-size:13px;font-weight:600;cursor:pointer;
            text-decoration:none;text-align:center;
        }
        .btn-qr-profile{
            background:rgba(255,255,255,0.15);color:white;
            border:1px solid rgba(255,255,255,0.3);border-radius:8px;
            padding:9px 18px;font-size:13px;font-weight:600;cursor:pointer;
            text-decoration:none;text-align:center;
        }

        /* Stats grid */
        .stats-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px;}
        .stat-card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);text-align:center;}
        .stat-card .icon{font-size:28px;margin-bottom:8px;}
        .stat-card .val{font-size:26px;font-weight:800;margin-bottom:4px;}
        .stat-card .lbl{font-size:12px;color:#6b7280;}

        /* Two column layout */
        .two-col{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px;}
        .three-col{display:grid;grid-template-columns:1fr 1fr 1fr;gap:20px;margin-bottom:20px;}

        /* Cards */
        .card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
        .card-title{font-size:14px;font-weight:700;color:#1a1a2e;margin-bottom:16px;display:flex;align-items:center;gap:8px;}

        /* Info rows */
        .info-row{display:flex;justify-content:space-between;align-items:center;padding:9px 0;border-bottom:1px solid #f3f4f6;}
        .info-row:last-child{border-bottom:none;}
        .info-row .key{font-size:12px;color:#9ca3af;font-weight:500;}
        .info-row .val{font-size:13px;color:#1a1a2e;font-weight:600;text-align:right;}

        /* Attendance bar */
        .att-bar-wrap{margin:16px 0;}
        .att-bar-labels{display:flex;justify-content:space-between;font-size:12px;color:#6b7280;margin-bottom:6px;}
        .att-bar-bg{background:#f3f4f6;border-radius:20px;height:14px;overflow:hidden;}
        .att-bar-fill{height:100%;border-radius:20px;transition:width 0.5s ease;}
        .att-segments{display:flex;gap:16px;margin-top:12px;}
        .att-seg{display:flex;align-items:center;gap:6px;font-size:12px;}
        .att-dot{width:10px;height:10px;border-radius:50%;}

        /* Recent attendance */
        .att-item{display:flex;align-items:center;gap:12px;padding:8px 0;border-bottom:1px solid #f3f4f6;}
        .att-item:last-child{border-bottom:none;}
        .att-status-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0;}
        .att-date{font-size:13px;font-weight:500;color:#1a1a2e;flex:1;}
        .att-time-text{font-size:12px;color:#9ca3af;}
        .att-badge{font-size:11px;padding:2px 8px;border-radius:10px;font-weight:600;}
        .badge-present{background:#e6f4ea;color:#1b5e20;}
        .badge-absent{background:#fef2f2;color:#dc2626;}

        /* Marks section */
        .sem-block{margin-bottom:16px;}
        .sem-title{
            font-size:12px;font-weight:700;color:#1a237e;
            background:#e8f0fe;padding:6px 14px;border-radius:6px;
            margin-bottom:8px;display:inline-block;
        }
        .marks-mini-table{width:100%;border-collapse:collapse;}
        .marks-mini-table th{font-size:10px;color:#9ca3af;font-weight:600;text-transform:uppercase;padding:4px 8px;text-align:left;background:#f8f9fa;}
        .marks-mini-table td{font-size:12px;padding:7px 8px;border-bottom:1px solid #f3f4f6;color:#1a1a2e;}
        .marks-mini-table tr:last-child td{border-bottom:none;}
        .grade-chip{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700;}
        .gA{background:#e6f4ea;color:#1b5e20;}
        .gB{background:#e8f0fe;color:#1565c0;}
        .gC{background:#fff3e0;color:#e65100;}
        .gE{background:#fef2f2;color:#dc2626;}
        .gN{background:#f3f4f6;color:#9ca3af;}

        /* GPA circle */
        .gpa-circle{
            width:100px;height:100px;border-radius:50%;
            display:flex;flex-direction:column;align-items:center;justify-content:center;
            margin:0 auto 16px;border:6px solid;
        }
        .gpa-circle .gpa-num{font-size:22px;font-weight:800;}
        .gpa-circle .gpa-lbl{font-size:10px;color:#9ca3af;margin-top:2px;}

        /* QR section */
        .qr-box{text-align:center;}
        .qr-box img{width:150px;height:150px;border-radius:10px;border:2px solid #e8f0fe;}
        .qr-box p{font-size:11px;color:#9ca3af;margin-top:8px;}
        .no-qr{width:150px;height:150px;border:2px dashed #d1d5db;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:12px;color:#9ca3af;margin:0 auto;flex-direction:column;gap:6px;}

        .badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;}
        .badge-IT{background:#e8f0fe;color:#1a237e;}
        .badge-ENG{background:#e6f4ea;color:#1b5e20;}
        .badge-THM{background:#fff3e0;color:#e65100;}
        .badge-MGT{background:#fce4ec;color:#880e4f;}
        .badge-ACC{background:#f3e8fd;color:#4a148c;}

        .empty-marks{text-align:center;padding:24px;color:#9ca3af;font-size:13px;}

        @media print{
            .sidebar,.back-btn,.profile-actions{display:none!important;}
            .main{margin-left:0;}
        }
    </style>
</head>
<body>

<!-- SIDEBAR -->
<div class="sidebar">
    <div class="sidebar-logo">
        <h2>&#128218; SMS System</h2>
        <p>SLIATE – Badulla Campus</p>
    </div>
    <div class="nav-section">
        <div class="nav-label">Main</div>
        <a href="dashboard.jsp"   class="nav-item">&#9632; Dashboard</a>
        <a href="students.jsp"    class="nav-item">&#128101; Students</a>
        <a href="attendance.jsp"  class="nav-item">&#9989; Attendance</a>
        <a href="monthlyReport.jsp" class="nav-item">
    &#128197; Monthly Report
</a>
        <a href="qrCode.jsp"      class="nav-item">&#9638; QR Codes</a>
        <a href="qrScan.jsp"      class="nav-item">&#128247; QR Scanner</a>
        <a href="marks.jsp"       class="nav-item">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"    class="nav-item">&#128218; Subjects</a>
        <a href="reports.jsp"     class="nav-item">&#128202; Reports</a>
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

    <a href="students.jsp?dept=<%= sDeptCode %>" class="back-btn">
        &#8592; Back to <%= sDeptCode %> Students
    </a>

    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <!-- Profile Header -->
    <%
    String initials = "S";
    if(sName.length() > 0){
        String[] parts = sName.split(" ");
        initials = parts[0].substring(0,1).toUpperCase();
        if(parts.length > 1)
            initials += parts[parts.length-1].substring(0,1).toUpperCase();
    }
    %>
    <div class="profile-header">
        <div class="profile-avatar"><%= initials %></div>
        <div class="profile-info">
            <h1><%= sName %></h1>
            <div class="reg"><%= sReg %></div>
            <div class="profile-tags">
                <span class="profile-tag">&#127979; <%= sDept %></span>
                <span class="profile-tag"><%= sYear %></span>
                <span class="profile-tag"><%= sCourse %></span>
                <span class="profile-tag badge badge-<%= sDeptCode %>">
                    <%= sDeptCode %>
                </span>
            </div>
        </div>
        <div class="profile-actions">
            <a href="editStudent.jsp?id=<%= studentId %>" class="btn-edit-profile">
                &#9998; Edit Profile
            </a>
            <a href="addMarks.jsp?sid=<%= studentId %>" class="btn-qr-profile">
                &#128196; Enter Grades
            </a>
            <button onclick="window.print()" class="btn-qr-profile">
                &#128424; Print Profile
            </button>
        </div>
    </div>

    <!-- Stats Row -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="icon">&#128197;</div>
            <div class="val" style="color:#1a237e;"><%= totalDays %></div>
            <div class="lbl">Total Class Days</div>
        </div>
        <div class="stat-card">
            <div class="icon">&#9989;</div>
            <div class="val" style="color:#1b5e20;"><%= presentDays %></div>
            <div class="lbl">Days Present</div>
        </div>
        <div class="stat-card">
            <div class="icon">&#10060;</div>
            <div class="val" style="color:#dc2626;"><%= absentDays %></div>
            <div class="lbl">Days Absent</div>
        </div>
        <div class="stat-card">
            <div class="icon">&#127979;</div>
            <div class="val"
                 style="color:<%= attPercent>=75?"#1b5e20":attPercent>=50?"#f57c00":"#dc2626" %>;">
                <%= attPercent %>%
            </div>
            <div class="lbl">Attendance Rate</div>
        </div>
    </div>

    <!-- Row 1: Personal Info + Attendance + QR -->
    <div class="three-col">

        <!-- Personal Info -->
        <div class="card">
            <div class="card-title">&#128100; Personal Information</div>
            <div class="info-row">
                <span class="key">Full Name</span>
                <span class="val"><%= sName %></span>
            </div>
            <div class="info-row">
                <span class="key">Reg Number</span>
                <span class="val" style="color:#1a237e;"><%= sReg %></span>
            </div>
            <div class="info-row">
                <span class="key">Department</span>
                <span class="val">
                    <span class="badge badge-<%= sDeptCode %>"><%= sDeptCode %></span>
                </span>
            </div>
            <div class="info-row">
                <span class="key">Year Level</span>
                <span class="val"><%= sYear %></span>
            </div>
            <div class="info-row">
                <span class="key">Course</span>
                <span class="val"><%= sCourse %></span>
            </div>
            <div class="info-row">
                <span class="key">Email</span>
                <span class="val" style="font-size:12px;"><%= sEmail %></span>
            </div>
            <div class="info-row">
                <span class="key">Phone</span>
                <span class="val"><%= sPhone %></span>
            </div>
        </div>

        <!-- Attendance Visual -->
        <div class="card">
            <div class="card-title">&#128197; Attendance Summary</div>

            <div style="text-align:center;margin-bottom:12px;">
                <div style="font-size:42px;font-weight:800;
                     color:<%= attPercent>=75?"#1b5e20":attPercent>=50?"#f57c00":"#dc2626" %>;">
                    <%= attPercent %>%
                </div>
                <div style="font-size:12px;color:#9ca3af;">
                    <%= presentDays %> present / <%= totalDays %> total days
                </div>
            </div>

            <div class="att-bar-wrap">
                <div class="att-bar-bg">
                    <div class="att-bar-fill"
                         style="width:<%= attPercent %>%;
                         background:<%= attPercent>=75?"#1b5e20":attPercent>=50?"#f57c00":"#dc2626" %>;">
                    </div>
                </div>
            </div>

            <div style="background:<%= attPercent>=75?"#e6f4ea":"#fef2f2" %>;
                        border-radius:8px;padding:10px;text-align:center;margin-top:8px;">
                <% if(attPercent >= 75){ %>
                <span style="color:#1b5e20;font-size:13px;font-weight:600;">
                    &#10003; Good Attendance
                </span>
                <% } else if(attPercent >= 50){ %>
                <span style="color:#f57c00;font-size:13px;font-weight:600;">
                    &#9888; Attendance Needs Improvement
                </span>
                <% } else { %>
                <span style="color:#dc2626;font-size:13px;font-weight:600;">
                    &#10060; Critical — Low Attendance
                </span>
                <% } %>
            </div>

            <div style="font-size:12px;color:#9ca3af;text-align:center;margin-top:10px;">
                Minimum required: 75%
            </div>
        </div>

        <!-- QR Code + GPA -->
        <div class="card">
            <div class="card-title">&#9638; QR Code &amp; GPA</div>

            <!-- GPA Circle -->
            <%
            String gpaColor = avgGPA>=3.0?"#1b5e20": avgGPA>=2.0?"#1565c0":"#dc2626";
            String gpaBorder= avgGPA>=3.0?"#a8d5b5": avgGPA>=2.0?"#c7d9ff":"#fecaca";
            %>
            <div class="gpa-circle"
                 style="border-color:<%= gpaBorder %>;margin-bottom:12px;">
                <span class="gpa-num" style="color:<%= gpaColor %>;">
                    <%= String.format("%.2f", avgGPA) %>
                </span>
                <span class="gpa-lbl">CGPA</span>
            </div>
            <div style="text-align:center;margin-bottom:14px;">
                <span style="font-size:13px;color:#6b7280;">
                    Overall Grade: <strong style="color:<%= gpaColor %>;">
                    <%= gpaGrade %></strong>
                </span>
            </div>

            <!-- QR -->
            <div class="qr-box">
                <% if(!sQR.isEmpty()){ %>
                <img src="<%= sQR %>?t=<%= System.currentTimeMillis() %>"
                     alt="QR Code">
                <p>Student attendance QR</p>
                <a href="GenerateQRServlet?id=<%= studentId %>"
                   style="font-size:12px;color:#1a237e;text-decoration:none;">
                    &#8635; Regenerate QR
                </a>
                <% } else { %>
                <div class="no-qr">
                    <span style="font-size:28px;">&#9638;</span>
                    <span>No QR yet</span>
                </div>
                <a href="GenerateQRServlet?id=<%= studentId %>"
                   style="display:block;margin-top:10px;font-size:12px;
                          color:#1a237e;text-decoration:none;text-align:center;">
                    &#9638; Generate QR Code
                </a>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Row 2: Recent Attendance + Marks -->
    <div class="two-col">

        <!-- Recent Attendance -->
        <div class="card">
            <div class="card-title">&#128203; Recent Attendance (Last 10)</div>
            <% if(recentAtt.isEmpty()){ %>
            <div style="text-align:center;padding:24px;color:#9ca3af;font-size:13px;">
                No attendance records found
            </div>
            <% } else {
                for(HashMap<String,String> a : recentAtt){
                    boolean isPresent = "Present".equals(a.get("status"));
            %>
            <div class="att-item">
                <div class="att-status-dot"
                     style="background:<%= isPresent?"#1b5e20":"#dc2626" %>;"></div>
                <span class="att-date"><%= a.get("date") %></span>
                <span class="att-time-text"><%= isPresent ? a.get("time") : "—" %></span>
                <span class="att-badge <%= isPresent?"badge-present":"badge-absent" %>">
                    <%= a.get("status") %>
                </span>
            </div>
            <% } } %>
        </div>

        <!-- Marks by Semester -->
        <div class="card">
            <div class="card-title">&#128196; Marks &amp; Grades</div>
            <% if(semMarks.isEmpty()){ %>
            <div class="empty-marks">No marks recorded yet</div>
            <% } else {
                for(Integer sem : semMarks.keySet()){
                    ArrayList<HashMap<String,String>> sList = semMarks.get(sem);
                    int yr     = (int)Math.ceil((double)sem/2);
                    int semInY = (sem%2==0)?2:1;
                    String yName = (yr>=1&&yr<=4) ? yearNames[yr-1] : "Year "+yr;

                    // Calculate semester GPA
                    double semGPA = 0; int semCount = 0;
                    for(HashMap<String,String> m : sList){
                        if(!"—".equals(m.get("gpa_points"))){
                            try{
                                double pts = Double.parseDouble(m.get("gpa_points"));
                                if(pts >= 0){ semGPA += pts; semCount++; }
                            }catch(Exception ex){}
                        }
                    }
                    double semAvg = semCount>0 ? semGPA/semCount : 0;
            %>
            <div class="sem-block">
                <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px;">
                    <span class="sem-title">
                        Semester <%= sem %> — <%= yName %>
                    </span>
                    <% if(semCount > 0){ %>
                    <span style="font-size:11px;color:#6b7280;">
                        SGPA:
                        <strong style="color:<%= semAvg>=3.0?"#1b5e20":semAvg>=2.0?"#1565c0":"#dc2626" %>;">
                            <%= String.format("%.2f", semAvg) %>
                        </strong>
                    </span>
                    <% } %>
                </div>
                <table class="marks-mini-table">
                    <thead>
                        <tr>
                            <th>Subject</th>
                            <th>Cr</th>
                            <th>Grade</th>
                            <th>GPA</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for(HashMap<String,String> m : sList){
                        String gr = m.get("grade");
                        String grClass = "gN";
                        if(gr.startsWith("A"))      grClass="gA";
                        else if(gr.startsWith("B")) grClass="gB";
                        else if(gr.startsWith("C")) grClass="gC";
                        else if("E".equals(gr)||"NE".equals(gr)||
                                "AB".equals(gr))    grClass="gE";
                    %>
                    <tr>
                        <td><%= m.get("subject_name") %></td>
                        <td style="color:#9ca3af;"><%= m.get("credit_hours") %></td>
                        <td>
                            <span class="grade-chip <%= grClass %>"><%= gr %></span>
                        </td>
                        <td style="color:#6b7280;"><%= m.get("gpa_points") %></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } } %>
        </div>
    </div>

</div>
        
</body>
</html>