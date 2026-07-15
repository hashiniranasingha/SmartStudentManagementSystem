<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%
    if(session.getAttribute("loggedUser") == null){
        response.sendRedirect("login.jsp"); return;
    }

    // Load departments
    ArrayList<HashMap<String,String>> deptList = new ArrayList<HashMap<String,String>>();

    // Load students with attendance percentage
    ArrayList<HashMap<String,String>> lowAttList  = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> goodAttList = new ArrayList<HashMap<String,String>>();
    String dbError = "";
    int threshold  = 75;
    String filterDept = request.getParameter("dept_id");
    if(filterDept == null) filterDept = "ALL";

    try{
        String thStr = request.getParameter("threshold");
        if(thStr != null && !thStr.isEmpty())
            threshold = Integer.parseInt(thStr);
    } catch(Exception e){}

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

        // Students with attendance %
        String sql =
            "SELECT s.student_id, s.full_name, s.email, s.reg_number, " +
            "d.dept_name, d.dept_code, s.year_level, " +
            "COUNT(a.att_id) as present_days, " +
            "(SELECT COUNT(DISTINCT att_date) FROM attendance " +
            " WHERE dept_id = d.dept_id) as total_days " +
            "FROM students s " +
            "JOIN departments d ON s.dept_id = d.dept_id " +
            "LEFT JOIN attendance a ON s.student_id = a.student_id " +
            "AND a.status='Present' " +
            "WHERE 1=1 ";

        if(!"ALL".equals(filterDept)){
            sql += " AND s.dept_id = " + filterDept;
        }
        sql += " GROUP BY s.student_id, s.full_name, s.email, " +
               "s.reg_number, d.dept_name, d.dept_code, s.year_level";

        ResultSet rs = conn.createStatement().executeQuery(sql);
        while(rs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            int present = rs.getInt("present_days");
            int total   = rs.getInt("total_days");
            int pct     = total > 0 ? (present * 100 / total) : 0;

            row.put("student_id",  String.valueOf(rs.getInt("student_id")));
            row.put("full_name",   rs.getString("full_name"));
            row.put("email",       rs.getString("email") != null ? rs.getString("email") : "-");
            row.put("reg_number",  rs.getString("reg_number"));
            row.put("dept_name",   rs.getString("dept_name"));
            row.put("dept_code",   rs.getString("dept_code"));
            row.put("year_level",  rs.getString("year_level"));
            row.put("present",     String.valueOf(present));
            row.put("total",       String.valueOf(total));
            row.put("percentage",  String.valueOf(pct));
            row.put("has_email",   (rs.getString("email") != null &&
                                    rs.getString("email").contains("@")) ? "yes" : "no");

            if(pct < threshold){
                lowAttList.add(row);
            } else {
                goodAttList.add(row);
            }
        }
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }

    // Email send results from session
    Integer emailSent    = (Integer) session.getAttribute("emailSent");
    Integer emailSkipped = (Integer) session.getAttribute("emailSkipped");
    Integer emailFailed  = (Integer) session.getAttribute("emailFailed");
    String  emailLog     = (String)  session.getAttribute("emailLog");
    boolean showResults  = "1".equals(request.getParameter("done"));

    if(showResults){
        session.removeAttribute("emailSent");
        session.removeAttribute("emailSkipped");
        session.removeAttribute("emailFailed");
        session.removeAttribute("emailLog");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Email Notifications</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#f0f2f5;display:flex;min-height:100vh;}
        .sidebar{width:240px;min-height:100vh;background:linear-gradient(180deg,#1a237e 0%,#0d47a1 100%);display:flex;flex-direction:column;position:fixed;left:0;top:0;box-shadow:4px 0 20px rgba(0,0,0,0.15);}
        .sidebar-logo{padding:24px 20px;border-bottom:1px solid rgba(255,255,255,0.1);}
        .sidebar-logo h2{color:white;font-size:15px;font-weight:700;}
        .sidebar-logo p{color:rgba(255,255,255,0.6);font-size:11px;margin-top:2px;}
        .nav-label{color:rgba(255,255,255,0.4);font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:1px;padding:0 8px;margin-bottom:6px;margin-top:16px;}
        .nav-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:rgba(255,255,255,0.75);font-size:13px;font-weight:500;text-decoration:none;margin-bottom:2px;transition:all 0.15s;}
        .nav-item:hover,.nav-item.active{background:rgba(255,255,255,0.15);color:white;}
        .nav-sub{padding-left:28px !important;font-size:12px !important;}
        .dept-dot{width:8px;height:8px;border-radius:50%;display:inline-block;flex-shrink:0;}
        .nav-section{padding:12px;}
        .sidebar-user{margin-top:auto;padding:16px 20px;border-top:1px solid rgba(255,255,255,0.1);color:rgba(255,255,255,0.8);font-size:12px;}
        .sidebar-user strong{display:block;color:white;font-size:13px;}
        .main{margin-left:240px;padding:28px;flex:1;}
        .page-header{margin-bottom:24px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:4px;}

        .alert-success{background:#e6f4ea;color:#1b5e20;border:1px solid #a8d5b5;border-radius:8px;padding:14px 18px;margin-bottom:20px;font-size:13px;}
        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:14px 18px;margin-bottom:20px;font-size:13px;}
        .alert-info{background:#e8f0fe;color:#1a237e;border:1px solid #c7d9ff;border-radius:8px;padding:14px 18px;margin-bottom:20px;font-size:13px;}

        /* Result cards */
        .result-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:20px;}
        .result-card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);text-align:center;}
        .result-card .num{font-size:32px;font-weight:800;}
        .result-card .lbl{font-size:12px;color:#6b7280;margin-top:4px;}
        .log-box{background:#1a1a2e;border-radius:10px;padding:16px;font-size:12px;color:#e2e8f0;line-height:1.8;margin-bottom:20px;max-height:200px;overflow-y:auto;}

        /* Filter card */
        .filter-card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);margin-bottom:20px;}
        .filter-card h3{font-size:14px;font-weight:600;color:#1a1a2e;margin-bottom:14px;}
        .filter-row{display:flex;gap:14px;align-items:flex-end;flex-wrap:wrap;}
        .fg{display:flex;flex-direction:column;gap:5px;}
        .fg label{font-size:12px;font-weight:500;color:#374151;}
        .fg select,.fg input{padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;min-width:160px;}
        .fg select:focus,.fg input:focus{border-color:#1a237e;}
        .btn-filter{background:#f3f4f6;color:#374151;border:1px solid #e5e7eb;border-radius:8px;padding:10px 18px;font-size:13px;cursor:pointer;font-family:'Inter',sans-serif;}

        /* Stats row */
        .stats-row{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:20px;}
        .stat-box{background:white;border-radius:12px;padding:16px 20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);display:flex;align-items:center;gap:14px;}
        .stat-icon{font-size:28px;}
        .stat-val{font-size:22px;font-weight:700;}
        .stat-lbl{font-size:12px;color:#6b7280;}

        /* Table */
        .section-title{font-size:15px;font-weight:700;color:#1a1a2e;margin-bottom:12px;display:flex;align-items:center;gap:10px;}
        .table-card{background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.06);overflow:hidden;margin-bottom:24px;}
        table{width:100%;border-collapse:collapse;}
        thead th{background:#f8f9fa;padding:11px 16px;text-align:left;font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;}
        tbody tr{border-bottom:1px solid #f3f4f6;}
        tbody tr:hover{background:#f8f9ff;}
        tbody td{padding:11px 16px;font-size:13px;color:#1a1a2e;}

        .badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;}
        .badge-IT{background:#e8f0fe;color:#1a237e;}
        .badge-ENG{background:#e6f4ea;color:#1b5e20;}
        .badge-THM{background:#fff3e0;color:#e65100;}
        .badge-MGT{background:#fce4ec;color:#880e4f;}
        .badge-ACC{background:#f3e8fd;color:#4a148c;}

        /* Progress bar */
        .pct-bar{width:100px;height:8px;background:#f3f4f6;border-radius:4px;display:inline-block;vertical-align:middle;margin-right:6px;}
        .pct-fill{height:100%;border-radius:4px;}

        /* Send button */
        .send-section{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);margin-bottom:20px;}
        .send-section h3{font-size:14px;font-weight:600;color:#1a1a2e;margin-bottom:8px;}
        .send-section p{font-size:13px;color:#6b7280;margin-bottom:16px;line-height:1.6;}
        .btn-send{background:linear-gradient(135deg,#dc2626,#b91c1c);color:white;border:none;border-radius:10px;padding:13px 28px;font-size:14px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
        .btn-send:hover{opacity:0.9;}
        .btn-send:disabled{opacity:0.5;cursor:not-allowed;}
        .no-email-badge{font-size:11px;color:#9ca3af;background:#f3f4f6;padding:2px 8px;border-radius:10px;}
        .has-email-badge{font-size:11px;color:#1b5e20;background:#e6f4ea;padding:2px 8px;border-radius:10px;}
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
        <a href="lms.jsp" class="nav-item">&#128196; LMS Materials</a>
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

<div class="main">
    <div class="page-header">
        <h1>&#128231; Email Notifications</h1>
        <p>Send low attendance alerts to students automatically</p>
    </div>

    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <!-- Show send results -->
    <% if(showResults && emailSent != null){ %>
    <div class="alert-success">
        &#10003; Email sending complete!
    </div>
    <div class="result-grid">
        <div class="result-card">
            <div class="num" style="color:#1b5e20;"><%= emailSent %></div>
            <div class="lbl">Emails Sent</div>
        </div>
        <div class="result-card">
            <div class="num" style="color:#9ca3af;"><%= emailSkipped %></div>
            <div class="lbl">Skipped (good att. / no email)</div>
        </div>
        <div class="result-card">
            <div class="num" style="color:#dc2626;"><%= emailFailed %></div>
            <div class="lbl">Failed</div>
        </div>
    </div>
    <% if(emailLog != null && !emailLog.isEmpty()){ %>
    <div class="log-box"><%= emailLog %></div>
    <% } %>
    <% } %>

    <!-- Filter -->
    <div class="filter-card">
        <h3>&#128269; Filter Students</h3>
        <form method="get" action="emailNotify.jsp">
        <div class="filter-row">
            <div class="fg">
                <label>Department</label>
                <select name="dept_id">
                    <option value="ALL" <%= "ALL".equals(filterDept)?"selected":"" %>>
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
                <label>Threshold (%)</label>
                <input type="number" name="threshold"
                       value="<%= threshold %>" min="1" max="100"
                       style="width:100px;">
            </div>
            <button type="submit" class="btn-filter">&#128269; Filter</button>
        </div>
        </form>
    </div>

    <!-- Stats -->
    <div class="stats-row">
        <div class="stat-box">
            <div class="stat-icon">&#128721;</div>
            <div>
                <div class="stat-val" style="color:#dc2626;"><%= lowAttList.size() %></div>
                <div class="stat-lbl">Below <%= threshold %>% attendance</div>
            </div>
        </div>
        <div class="stat-box">
            <div class="stat-icon">&#9989;</div>
            <div>
                <div class="stat-val" style="color:#1b5e20;"><%= goodAttList.size() %></div>
                <div class="stat-lbl">Above <%= threshold %>% attendance</div>
            </div>
        </div>
        <div class="stat-box">
            <div class="stat-icon">&#128231;</div>
            <div>
                <%
                int withEmail = 0;
                for(HashMap<String,String> s : lowAttList){
                    if("yes".equals(s.get("has_email"))) withEmail++;
                }
                %>
                <div class="stat-val" style="color:#1a237e;"><%= withEmail %></div>
                <div class="stat-lbl">Will receive email</div>
            </div>
        </div>
    </div>

    <!-- Low attendance students -->
    <% if(!lowAttList.isEmpty()){ %>
    <div class="section-title">
        <span style="color:#dc2626;">&#9888;</span>
        Low Attendance Students — Below <%= threshold %>%
        <span style="font-size:12px;color:#9ca3af;font-weight:400;">
            (These students will receive alerts)
        </span>
    </div>
    <div class="table-card">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Reg Number</th>
                    <th>Full Name</th>
                    <th>Dept</th>
                    <th>Year</th>
                    <th>Attendance</th>
                    <th>Email</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
            <% for(int i=0; i<lowAttList.size(); i++){
                HashMap<String,String> s = lowAttList.get(i);
                int pct = Integer.parseInt(s.get("percentage"));
                String barColor = pct < 50 ? "#dc2626" : pct < 65 ? "#f57c00" : "#e65100";
            %>
            <tr>
                <td style="color:#9ca3af;"><%= (i+1) %></td>
                <td style="font-weight:600;color:#1a237e;"><%= s.get("reg_number") %></td>
                <td><strong><%= s.get("full_name") %></strong></td>
                <td><span class="badge badge-<%= s.get("dept_code") %>">
                    <%= s.get("dept_code") %></span></td>
                <td style="font-size:12px;color:#6b7280;"><%= s.get("year_level") %></td>
                <td>
                    <div class="pct-bar">
                        <div class="pct-fill"
                             style="width:<%= pct %>%;background:<%= barColor %>;"></div>
                    </div>
                    <strong style="color:<%= barColor %>;">
                        <%= pct %>%
                    </strong>
                    <span style="font-size:11px;color:#9ca3af;">
                        (<%= s.get("present") %>/<%= s.get("total") %> days)
                    </span>
                </td>
                <td style="font-size:12px;color:#6b7280;"><%= s.get("email") %></td>
                <td>
                    <% if("yes".equals(s.get("has_email"))){ %>
                    <span class="has-email-badge">&#9993; Will send</span>
                    <% } else { %>
                    <span class="no-email-badge">No email</span>
                    <% } %>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <!-- Send button -->
    <div class="send-section">
        <h3>&#128231; Send Alerts Now</h3>
        <p>
            This will send an email to all <strong><%= withEmail %></strong>
            students above who have an email address.<br>
            Students without an email address will be skipped automatically.<br>
            Make sure student emails are entered in their profile before sending.
        </p>
        <% if(withEmail > 0){ %>
        <form action="SendEmailServlet" method="post"
              onsubmit="return confirm('Send low attendance alert emails to <%= withEmail %> student(s)?\n\nThis cannot be undone.');">
            <input type="hidden" name="action"     value="send">
            <input type="hidden" name="dept_id"    value="<%= filterDept %>">
            <input type="hidden" name="threshold"  value="<%= threshold %>">
            <button type="submit" class="btn-send">
                &#128231; Send <%= withEmail %> Alert Email(s)
            </button>
        </form>
        <% } else { %>
        <div class="alert-info">
            &#8505; No students with valid email addresses found.
            Go to <a href="students.jsp" style="color:#1a237e;font-weight:600;">
            Students</a> and add email addresses for students first.
        </div>
        <% } %>
    </div>

    <% } else { %>
    <div style="background:white;border-radius:12px;padding:40px;text-align:center;
                box-shadow:0 1px 4px rgba(0,0,0,0.06);">
        <div style="font-size:48px;margin-bottom:12px;">&#127881;</div>
        <h3 style="font-size:16px;color:#1b5e20;margin-bottom:8px;">
            All students have good attendance!
        </h3>
        <p style="font-size:13px;color:#6b7280;">
            No students are below <%= threshold %>% attendance threshold.
        </p>
    </div>
    <% } %>

</div>
    
    
</body>
</html>