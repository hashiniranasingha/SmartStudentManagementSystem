<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="com.sms.util.RoleCheck" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.LinkedHashMap" %>
<%
    if(!RoleCheck.isLoggedIn(session) || !RoleCheck.isStudent(session)){
        response.sendRedirect("login.jsp"); return;
    }

    String studentId = (String) session.getAttribute("studentId");
    if(studentId == null){ response.sendRedirect("login.jsp"); return; }

    // Student info
    String sName="",sReg="",sDept="",sDeptCode="",sYear="",sCourse="",sQR="";
    int sDeptId=0;

    // Attendance
    int totalDays=0,presentDays=0,absentDays=0,attPct=0;

    // Marks
    LinkedHashMap<Integer,ArrayList<HashMap<String,String>>> semMarks =
        new LinkedHashMap<Integer,ArrayList<HashMap<String,String>>>();
    double totalGPA=0; int gpaCount=0;

    // Recent attendance
    ArrayList<HashMap<String,String>> recentAtt =
        new ArrayList<HashMap<String,String>>();

    String dbError="";
    int examYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

    try{
        Connection conn = DBConnection.getConnection();

        // Student info
        PreparedStatement ps = conn.prepareStatement(
            "SELECT s.*, d.dept_name, d.dept_code FROM students s " +
            "JOIN departments d ON s.dept_id=d.dept_id WHERE s.student_id=?");
        ps.setInt(1, Integer.parseInt(studentId));
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            sName     = rs.getString("full_name")    != null ? rs.getString("full_name")    : "";
            sReg      = rs.getString("reg_number")   != null ? rs.getString("reg_number")   : "";
            sDept     = rs.getString("dept_name")    != null ? rs.getString("dept_name")    : "";
            sDeptCode = rs.getString("dept_code")    != null ? rs.getString("dept_code")    : "";
            sYear     = rs.getString("year_level")   != null ? rs.getString("year_level")   : "";
            sCourse   = rs.getString("course_name")  != null ? rs.getString("course_name")  : "";
            sQR       = rs.getString("qr_code_path") != null ? rs.getString("qr_code_path") : "";
            sDeptId   = rs.getInt("dept_id");
        }

        // Attendance
        PreparedStatement aps = conn.prepareStatement(
            "SELECT COUNT(*) as total, " +
            "SUM(CASE WHEN status='Present' THEN 1 ELSE 0 END) as present " +
            "FROM attendance WHERE student_id=?");
        aps.setInt(1, Integer.parseInt(studentId));
        ResultSet ars = aps.executeQuery();
        if(ars.next()){
            totalDays   = ars.getInt("total");
            presentDays = ars.getInt("present");
            absentDays  = totalDays - presentDays;
            attPct      = totalDays>0 ? (presentDays*100/totalDays) : 0;
        }

        // Recent attendance
        PreparedStatement rps = conn.prepareStatement(
            "SELECT att_date,att_time,status FROM attendance " +
            "WHERE student_id=? ORDER BY att_date DESC LIMIT 7");
        rps.setInt(1, Integer.parseInt(studentId));
        ResultSet rrs = rps.executeQuery();
        while(rrs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("date",   rrs.getString("att_date"));
            row.put("time",   rrs.getString("att_time")  != null ? rrs.getString("att_time")  : "—");
            row.put("status", rrs.getString("status")    != null ? rrs.getString("status")    : "Absent");
            recentAtt.add(row);
        }

        // Marks by semester
        PreparedStatement mps = conn.prepareStatement(
            "SELECT sub.subject_name, sub.semester, sub.credit_hours, " +
            "m.grade, m.gpa_points " +
            "FROM subjects sub " +
            "LEFT JOIN marks m ON sub.subject_id=m.subject_id " +
            "AND m.student_id=? AND m.exam_year=? " +
            "WHERE sub.dept_id=? ORDER BY sub.semester, sub.subject_name");
        mps.setInt(1, Integer.parseInt(studentId));
        mps.setInt(2, examYear);
        mps.setInt(3, sDeptId);
        ResultSet mrs = mps.executeQuery();
        while(mrs.next()){
            int sem = mrs.getInt("semester");
            if(!semMarks.containsKey(sem))
                semMarks.put(sem, new ArrayList<HashMap<String,String>>());
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("subject_name", mrs.getString("subject_name"));
            row.put("grade",        mrs.getString("grade")      != null ? mrs.getString("grade")      : "—");
            row.put("gpa_points",   mrs.getString("gpa_points") != null ?
                    String.format("%.1f",mrs.getDouble("gpa_points")) : "—");
            row.put("credit_hours", String.valueOf(mrs.getInt("credit_hours")));
            semMarks.get(sem).add(row);
            if(mrs.getString("gpa_points")!=null){
                double pts=mrs.getDouble("gpa_points");
                if(pts>=0){totalGPA+=pts;gpaCount++;}
            }
        }
        conn.close();
    }catch(Exception e){ dbError=e.getMessage(); }

    double avgGPA = gpaCount>0 ? totalGPA/gpaCount : 0.0;
    String[] yearNames={"First Year","Second Year","Third Year","Fourth Year"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Dashboard — <%= sName %></title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <a href="lms.jsp" class="btn-logout" style="background:rgba(255,255,255,0.25);">
    &#128196; Study Materials
</a>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#f0f2f5;min-height:100vh;}

        /* Top navbar for student */
        .topbar{
            background:linear-gradient(135deg,#1a237e,#1565c0);
            padding:0 28px;height:60px;
            display:flex;align-items:center;justify-content:space-between;
            position:fixed;top:0;left:0;right:0;z-index:100;
            box-shadow:0 2px 10px rgba(0,0,0,0.2);
        }
        .topbar-logo{display:flex;align-items:center;gap:12px;}
        .topbar-logo h2{color:white;font-size:15px;font-weight:700;}
        .topbar-logo p{color:rgba(255,255,255,0.6);font-size:11px;}
        .topbar-right{display:flex;align-items:center;gap:16px;}
        .topbar-user{color:rgba(255,255,255,0.9);font-size:13px;font-weight:500;}
        .btn-logout{background:rgba(255,255,255,0.15);color:white;border:1px solid rgba(255,255,255,0.3);border-radius:8px;padding:7px 14px;font-size:12px;font-weight:600;cursor:pointer;text-decoration:none;}

        .main{padding:88px 28px 28px;}

        /* Profile banner */
        .profile-banner{
            background:linear-gradient(135deg,#1a237e,#1565c0);
            border-radius:16px;padding:24px 28px;margin-bottom:24px;
            display:flex;align-items:center;gap:20px;
            box-shadow:0 4px 20px rgba(26,35,126,0.25);
        }
        .p-avatar{
            width:70px;height:70px;border-radius:18px;
            background:rgba(255,255,255,0.2);
            display:flex;align-items:center;justify-content:center;
            font-size:24px;font-weight:800;color:white;flex-shrink:0;
        }
        .p-info h1{font-size:20px;font-weight:800;color:white;margin-bottom:4px;}
        .p-info .reg{font-size:13px;color:rgba(255,255,255,0.8);}
        .p-tags{display:flex;gap:8px;margin-top:8px;flex-wrap:wrap;}
        .p-tag{background:rgba(255,255,255,0.15);color:white;padding:3px 12px;border-radius:20px;font-size:12px;}
        .p-qr{margin-left:auto;text-align:center;}
        .p-qr img{width:80px;height:80px;border-radius:8px;border:2px solid rgba(255,255,255,0.3);}
        .p-qr p{font-size:10px;color:rgba(255,255,255,0.6);margin-top:4px;}

        /* Stat cards */
        .stat-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px;}
        .stat-card{background:white;border-radius:12px;padding:18px;box-shadow:0 1px 4px rgba(0,0,0,0.06);text-align:center;}
        .stat-card .icon{font-size:24px;margin-bottom:8px;}
        .stat-card .val{font-size:24px;font-weight:800;}
        .stat-card .lbl{font-size:12px;color:#6b7280;margin-top:4px;}

        /* Two col */
        .two-col{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px;}
        .card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
        .card-title{font-size:14px;font-weight:700;color:#1a1a2e;margin-bottom:14px;}

        /* Attendance bar */
        .att-bar-bg{background:#f3f4f6;border-radius:20px;height:12px;overflow:hidden;margin:12px 0;}
        .att-bar-fill{height:100%;border-radius:20px;}

        /* Attendance log */
        .att-item{display:flex;align-items:center;gap:10px;padding:8px 0;border-bottom:1px solid #f3f4f6;}
        .att-item:last-child{border-bottom:none;}
        .att-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0;}
        .att-date{font-size:13px;font-weight:500;flex:1;}
        .att-time{font-size:12px;color:#9ca3af;}
        .att-pill{font-size:11px;padding:2px 8px;border-radius:10px;font-weight:600;}
        .p-pill{background:#e6f4ea;color:#1b5e20;}
        .a-pill{background:#fef2f2;color:#dc2626;}

        /* Marks */
        .sem-label{font-size:12px;font-weight:700;color:#1a237e;background:#e8f0fe;padding:5px 12px;border-radius:6px;display:inline-block;margin-bottom:8px;}
        table{width:100%;border-collapse:collapse;}
        thead th{background:#f8f9fa;padding:8px 12px;text-align:left;font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;}
        tbody td{padding:8px 12px;border-bottom:1px solid #f3f4f6;font-size:13px;}
        .gc{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:700;}
        .gA{background:#e6f4ea;color:#1b5e20;}
        .gB{background:#e8f0fe;color:#1565c0;}
        .gC{background:#fff3e0;color:#e65100;}
        .gE{background:#fef2f2;color:#dc2626;}
        .gN{background:#f3f4f6;color:#9ca3af;}

        /* GPA circle */
        .gpa-wrap{text-align:center;margin-bottom:16px;}
        .gpa-circle{width:90px;height:90px;border-radius:50%;border:6px solid #c7d9ff;display:inline-flex;flex-direction:column;align-items:center;justify-content:center;}
        .gpa-num{font-size:20px;font-weight:800;color:#1a237e;}
        .gpa-lbl{font-size:10px;color:#9ca3af;}

        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}

        .badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;}
        .badge-IT{background:#e8f0fe;color:#1a237e;}
        .badge-ENG{background:#e6f4ea;color:#1b5e20;}
        .badge-THM{background:#fff3e0;color:#e65100;}
        .badge-MGT{background:#fce4ec;color:#880e4f;}
        .badge-ACC{background:#f3e8fd;color:#4a148c;}
    </style>
</head>
<body>

<!-- Top bar -->
<div class="topbar">
    <div class="topbar-logo">
        <div>
            <h2>&#128218; SLIATE Badulla — Student Portal</h2>
        </div>
    </div>
    <div class="topbar-right">
        <span class="topbar-user">&#128100; <%= sName %></span>
        <a href="LogoutServlet" class="btn-logout">&#128682; Logout</a>
    </div>
</div>

<div class="main">
    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <!-- Profile Banner -->
    <%
    String ini="S";
    if(sName.length()>0){
        String[] pts=sName.split(" ");
        ini=pts[0].substring(0,1).toUpperCase();
        if(pts.length>1) ini+=pts[pts.length-1].substring(0,1).toUpperCase();
    }
    %>
    <div class="profile-banner">
        <div class="p-avatar"><%= ini %></div>
        <div class="p-info">
            <h1><%= sName %></h1>
            <div class="reg"><%= sReg %></div>
            <div class="p-tags">
                <span class="p-tag">&#127979; <%= sDept %></span>
                <span class="p-tag"><%= sYear %></span>
                <span class="p-tag"><%= sCourse %></span>
            </div>
        </div>
        <% if(!sQR.isEmpty()){ %>
        <div class="p-qr">
            <img src="<%= sQR %>" alt="My QR">
            <p>My Attendance QR</p>
        </div>
        <% } %>
    </div>

    <!-- Stats -->
    <div class="stat-grid">
        <div class="stat-card">
            <div class="icon">&#128197;</div>
            <div class="val" style="color:#1a237e;"><%= totalDays %></div>
            <div class="lbl">Total Days</div>
        </div>
        <div class="stat-card">
            <div class="icon">&#9989;</div>
            <div class="val" style="color:#1b5e20;"><%= presentDays %></div>
            <div class="lbl">Present</div>
        </div>
        <div class="stat-card">
            <div class="icon">&#10060;</div>
            <div class="val" style="color:#dc2626;"><%= absentDays %></div>
            <div class="lbl">Absent</div>
        </div>
        <div class="stat-card">
            <div class="icon">&#128202;</div>
            <div class="val"
                 style="color:<%= attPct>=75?"#1b5e20":attPct>=50?"#f57c00":"#dc2626" %>;">
                <%= attPct %>%
            </div>
            <div class="lbl">Attendance</div>
        </div>
    </div>

    <div class="two-col">

        <!-- Attendance card -->
        <div class="card">
            <div class="card-title">&#128197; My Attendance</div>

            <div style="text-align:center;">
                <div style="font-size:40px;font-weight:800;
                     color:<%= attPct>=75?"#1b5e20":attPct>=50?"#f57c00":"#dc2626" %>;">
                    <%= attPct %>%
                </div>
                <div style="font-size:12px;color:#9ca3af;margin-top:4px;">
                    <%= presentDays %> present / <%= totalDays %> days
                </div>
            </div>

            <div class="att-bar-bg">
                <div class="att-bar-fill"
                     style="width:<%= attPct %>%;
                     background:<%= attPct>=75?"#1b5e20":attPct>=50?"#f57c00":"#dc2626" %>;">
                </div>
            </div>

            <div style="background:<%= attPct>=75?"#e6f4ea":"#fef2f2" %>;
                        border-radius:8px;padding:10px;text-align:center;margin-bottom:14px;">
                <span style="font-size:13px;font-weight:600;
                      color:<%= attPct>=75?"#1b5e20":"#dc2626" %>;">
                    <% if(attPct>=75){ %>&#10003; Good Attendance
                    <% } else { %>&#9888; Below required 75% — Please improve!
                    <% } %>
                </span>
            </div>

            <div style="font-size:12px;font-weight:600;color:#374151;margin-bottom:8px;">
                Recent Attendance
            </div>
            <% for(HashMap<String,String> a : recentAtt){
                boolean isP="Present".equals(a.get("status")); %>
            <div class="att-item">
                <div class="att-dot"
                     style="background:<%= isP?"#1b5e20":"#dc2626" %>;"></div>
                <span class="att-date"><%= a.get("date") %></span>
                <span class="att-time"><%= isP?a.get("time"):"" %></span>
                <span class="att-pill <%= isP?"p-pill":"a-pill" %>">
                    <%= a.get("status") %>
                </span>
            </div>
            <% } %>
            <% if(recentAtt.isEmpty()){ %>
            <div style="text-align:center;padding:20px;color:#9ca3af;font-size:13px;">
                No attendance records yet
            </div>
            <% } %>
        </div>

        <!-- Marks card -->
        <div class="card">
            <div class="card-title">&#128196; My Grades &amp; GPA</div>

            <div class="gpa-wrap">
                <div class="gpa-circle">
                    <span class="gpa-num"><%= String.format("%.2f",avgGPA) %></span>
                    <span class="gpa-lbl">CGPA</span>
                </div>
                <div style="font-size:12px;color:#6b7280;margin-top:6px;">
                    Based on <%= gpaCount %> graded subjects
                </div>
            </div>

            <% if(semMarks.isEmpty()){ %>
            <div style="text-align:center;padding:20px;color:#9ca3af;font-size:13px;">
                No grades recorded yet
            </div>
            <% } else {
                for(Integer sem : semMarks.keySet()){
                    ArrayList<HashMap<String,String>> sList = semMarks.get(sem);
                    int yr=(int)Math.ceil((double)sem/2);
                    int siy=(sem%2==0)?2:1;
                    String yName=(yr>=1&&yr<=4)?yearNames[yr-1]:"Year "+yr;
            %>
            <div style="margin-bottom:14px;">
                <span class="sem-label">
                    Semester <%= sem %> — <%= yName %>
                </span>
                <table>
                    <thead><tr>
                        <th>Subject</th><th>Grade</th><th>GPA</th>
                    </tr></thead>
                    <tbody>
                    <% for(HashMap<String,String> m : sList){
                        String gr=m.get("grade");
                        String gc="gN";
                        if(gr.startsWith("A"))      gc="gA";
                        else if(gr.startsWith("B")) gc="gB";
                        else if(gr.startsWith("C")) gc="gC";
                        else if("E".equals(gr)||"NE".equals(gr)||"AB".equals(gr)) gc="gE";
                    %>
                    <tr>
                        <td><%= m.get("subject_name") %></td>
                        <td><span class="gc <%= gc %>"><%= gr %></span></td>
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