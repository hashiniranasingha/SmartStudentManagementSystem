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
    if(RoleCheck.isStudent(session)){
        response.sendRedirect("studentDashboard.jsp"); return;
    }

    ArrayList<HashMap<String,String>> deptList = new ArrayList<HashMap<String,String>>();
    String dbError = "";

    try{
        Connection conn = DBConnection.getConnection();
        ResultSet rs = conn.createStatement().executeQuery("SELECT * FROM departments ORDER BY dept_name");
        while(rs.next()){
            HashMap<String,String> d = new HashMap<String,String>();
            d.put("dept_id",         String.valueOf(rs.getInt("dept_id")));
            d.put("dept_code",       rs.getString("dept_code"));
            d.put("dept_name",       rs.getString("dept_name"));
            d.put("total_semesters", String.valueOf(rs.getInt("total_semesters")));
            deptList.add(d);
        }
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }

    String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Reports</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#f0f2f5;display:flex;min-height:100vh;}
        
        /* Sidebar layout styles */
        .sidebar{width:240px;min-height:100vh;background:linear-gradient(180deg,#1a237e 0%,#0d47a1 100%);display:flex;flex-direction:column;position:fixed;left:0;top:0;box-shadow:4px 0 20px rgba(0,0,0,0.15);z-index: 10;}
        .sidebar-logo{padding:24px 20px;border-bottom:1px solid rgba(255,255,255,0.1);}
        .sidebar-logo h2{color:white;font-size:15px;font-weight:700;}
        .sidebar-logo p{color:rgba(255,255,255,0.6);font-size:11px;margin-top:2px;}
        .nav-section{padding:12px;}
        .nav-label{color:rgba(255,255,255,0.4);font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:1px;padding:0 8px;margin-bottom:6px;margin-top:16px;}
        .nav-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:rgba(255,255,255,0.75);font-size:13px;font-weight:500;text-decoration:none;margin-bottom:2px;transition:all 0.15s;}
        .nav-item:hover, .nav-item.active{background:rgba(255,255,255,0.15);color:white;}
        .sidebar-user{margin-top:auto;padding:16px 20px;border-top:1px solid rgba(255,255,255,0.1);color:rgba(255,255,255,0.8);font-size:12px;}
        .sidebar-user strong{display:block;color:white;font-size:13px;}
        
        /* Main Panel container */
        .main{margin-left:240px;padding:28px;flex:1;min-width: 0;}
        .page-header{margin-bottom:24px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:4px;}
        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:18px;font-size:13px;}

        /* CSS Grid matching your exact 3-column layout requirements */
        .reports-grid{
            display:grid;
            grid-template-columns:repeat(auto-fill, minmax(320px, 1fr));
            gap:24px;
            align-items: start;
        }

        .report-card{
            background:white;
            border-radius:14px;
            box-shadow:0 4px 12px rgba(0,0,0,0.05);
            overflow:hidden;
            display: flex;
            flex-direction: column;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .report-card:hover{
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.08);
        }

        .card-top{height:6px;}
        .card-top.blue{background-color: #1a237e;}
        .card-top.green{background-color: #1b5e20;}
        .card-top.purple{background-color: #4a148c;}
        .card-top.orange{background-color: #e65100;}

        .report-card-body{padding:22px; flex: 1; display: flex; flex-direction: column;}
        .report-icon-wrap{
            width:48px;height:48px;border-radius:12px;
            display:flex;align-items:center;justify-content:center;
            font-size:22px;margin-bottom:14px;
        }
        .report-icon-wrap.blue{background: #e8eaf6; color: #1a237e;}
        .report-icon-wrap.green{background: #e8f5e9; color: #1b5e20;}
        .report-icon-wrap.purple{background: #f3e5f5; color: #4a148c;}
        .report-icon-wrap.orange{background: #fff3e0; color: #e65100;}

        .report-card-body h3{font-size:16px;font-weight:700;color:#1a1a2e;margin-bottom:6px;}
        .report-card-body .desc{font-size:12px;color:#6b7280;line-height:1.6;margin-bottom:16px;min-height: 40px;}

        .info-box{background:#f8f9fa;border-radius:8px;padding:10px 14px;font-size:12px;color:#6b7280;margin-bottom:16px;line-height:1.7;}
        .info-box strong{color:#374151;}

        .fg{margin-bottom:14px;}
        .fg label{display:block;font-size:12px;font-weight:500;color:#374151;margin-bottom:5px;}
        .fg select, .fg input{
            width:100%;padding:10px 12px;border:1.5px solid #e5e7eb;
            border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;background-color: #fff;
        }
        .fg select:focus, .fg input:focus{border-color:#1a237e;}

        .divider{border:none;border-top:1px solid #f3f4f6;margin:18px 0;margin-top: auto;}
        .btn-row{display:flex;gap:10px;}

        .btn-view, .btn-download{
            flex:1;padding:11px;border-radius:8px;font-size:13px;font-weight:600;
            cursor:pointer;font-family:'Inter',sans-serif;display:flex;align-items:center;
            justify-content:center;gap:6px;text-decoration:none;transition: background-color 0.2s, color 0.2s;
        }

        .blue-view{background:#1a237e;color:white;border:none;}
        .blue-view:hover{background:#0d47a1;}
        .blue-dl{border:2px solid #1a237e;color:#1a237e;background:white;}
        .blue-dl:hover{background:#1a237e;color:white;}

        .green-view{background:#1b5e20;color:white;border:none;}
        .green-view:hover{background:#2e7d32;}
        .green-dl{border:2px solid #1b5e20;color:#1b5e20;background:white;}
        .green-dl:hover{background:#1b5e20;color:white;}

        .purple-view{background:#4a148c;color:white;border:none;}
        .purple-view:hover{background:#6a1b9a;}
        .purple-dl{border:2px solid #4a148c;color:#4a148c;background:white;}
        .purple-dl:hover{background:#4a148c;color:white;}

        .preview-note{font-size:11px;color:#9ca3af;text-align:center;margin-top:10px;}
    </style>

    <script>
        var yearNames = ["First Year","Second Year","Third Year","Fourth Year"];

        function updateSems(deptSelId, semSelId){
            var sel = document.getElementById(deptSelId);
            var opt = sel.options[sel.selectedIndex];
            var sems = parseInt(opt.getAttribute('data-sems')) || 4;
            var semSel = document.getElementById(semSelId);
            semSel.innerHTML = '<option value="">-- Select Semester --</option>';
            for(var i=1; i<=sems; i++){
                var yr = Math.ceil(i/2);
                var semInY = (i%2===0)?2:1;
                var lbl = yearNames[yr-1] + ' — Semester ' + semInY;
                semSel.innerHTML += '<option value="'+i+'">Sem '+i+' → '+lbl+'</option>';
            }
        }

        function buildUrl(type, deptId, extraParam, extraVal){
            var url = 'GenerateReportServlet?type='+type+'&dept='+deptId;
            if(extraParam) url += '&'+extraParam+'='+extraVal;
            return url;
        }

        function viewReport(type, deptSelId, extraParam, extraInputId){
            var dept = document.getElementById(deptSelId).value;
            var extra = extraInputId ? document.getElementById(extraInputId).value : '';
            if(!dept){ alert('Please select a department first'); return; }
            if(extraParam==='sem' && !extra){ alert('Please select a semester first'); return; }
            var url = buildUrl(type, dept, extraParam, extra) + '&view=1';
            window.open(url, '_blank');
        }

        function downloadReport(type, deptSelId, extraParam, extraInputId){
            var dept = document.getElementById(deptSelId).value;
            var extra = extraInputId ? document.getElementById(extraInputId).value : '';
            if(!dept){ alert('Please select a department first'); return; }
            if(extraParam==='sem' && !extra){ alert('Please select a semester first'); return; }
            var url = buildUrl(type, dept, extraParam, extra) + '&view=0';
            window.location.href = url;
        }
    </script>
</head>
<body>

    <!-- Sidebar Navigation -->
    <div class="sidebar">
        <div class="sidebar-logo">
            <h2>SMS System</h2>
            <p>SLIATE – Badulla ATI</p>
        </div>
        <div class="nav-section">
            <span class="nav-label">Main</span>
            <a href="dashboard.jsp" class="nav-item">Dashboard</a>
            <a href="students.jsp" class="nav-item">Students</a>
            <a href="attendance.jsp" class="nav-item">Attendance</a>
            <a href="reports.jsp" class="nav-item active">Reports</a>
        </div>
        <div class="sidebar-user">
            Logged in as: <strong>Administrative Officer</strong>
        </div>
    </div>

    <!-- Main Workspace Content -->
    <div class="main">
        <div class="page-header">
            <h1>📊 PDF Reports Dashboard</h1>
            <p>View reports directly inside your browser tabs or download clean copies locally.</p>
        </div>

        <% if(!dbError.isEmpty()){ %>
            <div class="alert-error"><strong>Database Error:</strong> <%= dbError %></div>
        <% } %>
        <% if(request.getParameter("error") != null){ %>
            <div class="alert-error"><%= request.getParameter("error") %></div>
        <% } %>

        <!-- Core Clean Grid Container -->
        <div class="reports-grid">

            <!-- Card 1: Student List Report -->
            <div class="report-card">
                <div class="card-top blue"></div>
                <div class="report-card-body">
                    <div class="report-icon-wrap blue">👥</div>
                    <h3>Student List Report</h3>
                    <p class="desc">Complete breakdown of all system records containing contact logs, departments, and course tracks.</p>
                    <div class="info-box"><strong>Includes:</strong> Index mapping, official emails, validation metrics, and active mobile numbers.</div>
                    
                    <div class="fg">
                        <label>Target Department</label>
                        <select id="studentDept">
                            <option value="ALL">All Active Departments</option>
                            <% for(HashMap<String,String> d : deptList){ %>
                                <option value="<%= d.get("dept_id") %>"><%= d.get("dept_name") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="divider"></div>
                    <div class="btn-row">
                        <button class="btn-view blue-view" onclick="viewReport('students','studentDept',null,null)">Preview</button>
                        <button class="btn-download blue-dl" onclick="downloadReport('students','studentDept',null,null)">Download</button>
                    </div>
                    <p class="preview-note">PDF view opens instantly in an adjacent browser window</p>
                </div>
            </div>

            <!-- Card 2: Attendance Report -->
            <div class="report-card">
                <div class="card-top green"></div>
                <div class="report-card-body">
                    <div class="report-icon-wrap green">✅</div>
                    <h3>Attendance Report</h3>
                    <p class="desc">Analytical daily class presence charts showing timestamps and absence rate breakdowns.</p>
                    <div class="info-box"><strong>Includes:</strong> Registry flags, verification timers, total metrics, and present percentages.</div>
                    
                    <div class="fg">
                        <label>Target Department</label>
                        <select id="attendanceDept">
                            <option value="ALL">All Active Departments</option>
                            <% for(HashMap<String,String> d : deptList){ %>
                                <option value="<%= d.get("dept_id") %>"><%= d.get("dept_name") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="fg">
                        <label>Target Date</label>
                        <input type="date" id="attendanceDate" value="<%= today %>">
                    </div>
                    <div class="divider"></div>
                    <div class="btn-row">
                        <button class="btn-view green-view" onclick="viewReport('attendance','attendanceDept','date','attendanceDate')">Preview</button>
                        <button class="btn-download green-dl" onclick="downloadReport('attendance','attendanceDept','date','attendanceDate')">Download</button>
                    </div>
                    <p class="preview-note">PDF view opens instantly in an adjacent browser window</p>
                </div>
            </div>

            <!-- Card 3: Result Sheet Report -->
            <div class="report-card">
                <div class="card-top purple"></div>
                <div class="report-card-body">
                    <div class="report-icon-wrap purple">📄</div>
                    <h3>Result Sheet Report</h3>
                    <p class="desc">Standardized matrix displaying full semester module profiles alongside auto-computed SGPA indexes.</p>
                    <div class="info-box"><strong>Includes:</strong> Letter evaluations, aggregate parameters, custom headers, and standing codes.</div>
                    
                    <div class="fg">
                        <label>Target Department</label>
                        <select id="marksDept" onchange="updateSems('marksDept','marksSem')">
                            <option value="">-- Select Department --</option>
                            <% for(HashMap<String,String> d : deptList){ %>
                                <option value="<%= d.get("dept_id") %>" data-sems="<%= d.get("total_semesters") %>"><%= d.get("dept_name") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="fg">
                        <label>Year & Semester</label>
                        <select id="marksSem">
                            <option value="">-- Select Dept First --</option>
                        </select>
                    </div>
                    <div class="divider"></div>
                    <div class="btn-row">
                        <button class="btn-view purple-view" onclick="viewReport('marks','marksDept','sem','marksSem')">Preview</button>
                        <button class="btn-download purple-dl" onclick="downloadReport('marks','marksDept','sem','marksSem')">Download</button>
                    </div>
                    <p class="preview-note">PDF view opens instantly in an adjacent browser window</p>
                </div>
            </div>

        </div>
    </div>
</body>
</html>