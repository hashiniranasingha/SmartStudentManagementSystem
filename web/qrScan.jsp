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

    String sessionParam = request.getParameter("session");
    String sessionDept  = request.getParameter("dept");
    String sessionMins  = request.getParameter("mins");
    if(sessionParam == null) sessionParam = "";
    if(sessionDept  == null) sessionDept  = "";
    if(sessionMins  == null) sessionMins  = "";

    String baseUrl    = request.getScheme()+"://"+
                        request.getServerName()+":"+
                        request.getServerPort()+
                        request.getContextPath();
    String checkinUrl = baseUrl+"/studentCheckin.jsp?s="+sessionParam;

    ArrayList<HashMap<String,String>> deptListSes =
        new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> studentList =
        new ArrayList<HashMap<String,String>>();
    String dbError = "";

    try{
        Connection conn = DBConnection.getConnection();
        ResultSet drs = conn.createStatement().executeQuery(
            "SELECT * FROM departments ORDER BY dept_name");
        while(drs.next()){
            HashMap<String,String> d = new HashMap<String,String>();
            d.put("dept_id",   String.valueOf(drs.getInt("dept_id")));
            d.put("dept_code", drs.getString("dept_code"));
            d.put("dept_name", drs.getString("dept_name"));
            deptListSes.add(d);
        }
        ResultSet srs = conn.createStatement().executeQuery(
            "SELECT s.student_id, s.reg_number, s.full_name, "+
            "d.dept_code, s.year_level "+
            "FROM students s "+
            "JOIN departments d ON s.dept_id=d.dept_id "+
            "ORDER BY d.dept_code, s.year_level, s.full_name");
        while(srs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("student_id", String.valueOf(srs.getInt("student_id")));
            row.put("reg_number", srs.getString("reg_number"));
            row.put("full_name",  srs.getString("full_name"));
            row.put("dept_code",  srs.getString("dept_code"));
            row.put("year_level", srs.getString("year_level") != null ?
                    srs.getString("year_level") : "");
            studentList.add(row);
        }
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>SMS – QR Scanner</title>
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
.nav-section{padding:12px;overflow-y:auto;max-height:calc(100vh - 100px);}
.nav-section::-webkit-scrollbar{width:4px;}
.nav-section::-webkit-scrollbar-thumb{background:rgba(255,255,255,0.2);border-radius:4px;}
.sidebar-user{padding:16px 20px;border-top:1px solid rgba(255,255,255,0.1);color:rgba(255,255,255,0.8);font-size:12px;}
.sidebar-user strong{display:block;color:white;font-size:13px;}
.main{margin-left:240px;padding:28px;flex:1;}
.page-header{margin-bottom:20px;}
.page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
.page-header p{font-size:13px;color:#6b7280;margin-top:4px;}

/* Session */
.session-panel{background:white;border-radius:14px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);margin-bottom:20px;}
.session-panel h3{font-size:14px;font-weight:700;color:#1a1a2e;margin-bottom:4px;}
.session-panel p{font-size:12px;color:#6b7280;margin-bottom:14px;}
.active-session{background:#e6f4ea;border:2px solid #a8d5b5;border-radius:10px;padding:14px;margin-bottom:14px;}
.link-box{background:white;border-radius:8px;padding:10px 14px;font-size:12px;color:#1a237e;font-weight:600;word-break:break-all;border:1px solid #c7d9ff;margin:8px 0;}
.session-btn-row{display:flex;gap:8px;flex-wrap:wrap;}
.btn-copy{background:#1a237e;color:white;border:none;border-radius:8px;padding:8px 16px;font-size:12px;font-weight:600;cursor:pointer;}
.btn-qr-proj{background:#1b5e20;color:white;border:none;border-radius:8px;padding:8px 16px;font-size:12px;font-weight:600;cursor:pointer;}
.create-form{display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap;}
.fg-s{display:flex;flex-direction:column;gap:5px;}
.fg-s label{font-size:12px;font-weight:500;color:#374151;}
.fg-s select{padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;}
.btn-create{background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:8px;padding:10px 20px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}

/* Tabs */
.method-tabs{display:flex;gap:0;margin-bottom:20px;background:white;border-radius:12px;padding:6px;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
.method-tab{flex:1;padding:11px;text-align:center;border-radius:8px;cursor:pointer;font-size:13px;font-weight:600;color:#6b7280;transition:all 0.2s;border:none;background:none;font-family:'Inter',sans-serif;}
.method-tab.active{background:linear-gradient(135deg,#1a237e,#1565c0);color:white;}
.method-panel{display:none;}
.method-panel.active{display:block;}

.scan-layout{display:grid;grid-template-columns:1fr 1fr;gap:20px;}

/* Upload */
.scan-card{background:white;border-radius:14px;padding:22px;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
.scan-card h3{font-size:14px;font-weight:600;color:#1a1a2e;margin-bottom:6px;}
.scan-card > p{font-size:12px;color:#6b7280;margin-bottom:14px;}
.upload-area{border:2px dashed #c7d9ff;border-radius:12px;padding:32px 20px;text-align:center;cursor:pointer;transition:all 0.2s;background:#f8f9ff;margin-bottom:14px;}
.upload-area:hover{border-color:#1a237e;background:#e8f0fe;}
.upload-icon{font-size:40px;margin-bottom:10px;}
.upload-area h4{font-size:14px;font-weight:600;color:#1a237e;margin-bottom:4px;}
.upload-area p{font-size:12px;color:#9ca3af;margin:0;}
.preview-box{margin-bottom:14px;display:none;text-align:center;}
.preview-box img{max-width:200px;border-radius:8px;border:2px solid #e8f0fe;}
.preview-box p{font-size:11px;color:#9ca3af;margin-top:6px;}
.btn-scan-upload{width:100%;background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:10px;padding:12px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
.btn-scan-upload:disabled{opacity:0.5;cursor:not-allowed;}
.scan-progress{display:none;text-align:center;padding:10px;font-size:13px;color:#1a237e;background:#e8f0fe;border-radius:8px;margin-top:8px;}

/* Webcam */
.camera-wrapper{position:relative;width:100%;padding-top:75%;background:#1a1a2e;border-radius:10px;overflow:hidden;margin-bottom:10px;}
#video{position:absolute;top:0;left:0;width:100%;height:100%;object-fit:cover;}
#canvas{display:none;}
.scan-overlay{position:absolute;top:0;left:0;width:100%;height:100%;display:flex;align-items:center;justify-content:center;pointer-events:none;}
.scan-frame{width:60%;height:60%;border:3px solid rgba(255,255,255,0.8);border-radius:14px;position:relative;}
.scan-line{position:absolute;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,#4fc3f7,transparent);animation:scanMove 2s linear infinite;}
@keyframes scanMove{0%{top:0;}100%{top:100%;}}
.camera-placeholder{position:absolute;top:0;left:0;width:100%;height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;color:white;gap:10px;}
.camera-placeholder .icon{font-size:40px;opacity:0.5;}
.camera-placeholder p{font-size:12px;opacity:0.6;text-align:center;padding:0 16px;}
.scan-status{text-align:center;padding:8px;font-size:12px;color:#6b7280;margin-bottom:10px;background:#f8f9fa;border-radius:8px;}
.scan-status.active{color:#1b5e20;background:#e6f4ea;}
.btn-start{width:100%;background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:8px;padding:10px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
.btn-stop{width:100%;background:#dc2626;color:white;border:none;border-radius:8px;padding:10px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;display:none;margin-top:8px;}

/* Manual */
.filter-row{display:flex;gap:8px;margin-bottom:12px;}
.filter-row select{flex:1;padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;}
.filter-row select:focus{border-color:#1a237e;}
.search-box{position:relative;margin-bottom:12px;}
.search-box input{width:100%;padding:11px 14px;border:1.5px solid #e5e7eb;border-radius:10px;font-size:13px;font-family:'Inter',sans-serif;outline:none;}
.search-box input:focus{border-color:#1a237e;}
.search-results{position:absolute;top:100%;left:0;right:0;background:white;border:1.5px solid #e5e7eb;border-top:none;border-radius:0 0 10px 10px;max-height:200px;overflow-y:auto;z-index:100;display:none;box-shadow:0 4px 12px rgba(0,0,0,0.1);}
.search-item{padding:10px 14px;cursor:pointer;border-bottom:1px solid #f3f4f6;display:flex;align-items:center;gap:10px;}
.search-item:hover{background:#f8f9ff;}
.si-avatar{width:30px;height:30px;border-radius:50%;background:#e8f0fe;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;color:#1a237e;flex-shrink:0;}
.si-info strong{font-size:13px;color:#1a1a2e;display:block;}
.si-info span{font-size:11px;color:#9ca3af;}
.selected-student{background:#e8f0fe;border-radius:10px;padding:12px;margin-bottom:14px;display:none;}
.selected-student h4{font-size:13px;font-weight:600;color:#1a237e;}
.selected-student p{font-size:11px;color:#6b7280;margin-top:2px;}
.btn-mark{width:100%;background:linear-gradient(135deg,#1b5e20,#2e7d32);color:white;border:none;border-radius:10px;padding:12px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
.btn-mark:disabled{opacity:0.5;cursor:not-allowed;}

/* Results */
.result-card{background:white;border-radius:14px;padding:22px;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
.result-card h3{font-size:14px;font-weight:600;color:#1a1a2e;margin-bottom:14px;}
.counter-row{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:14px;}
.counter-box{background:#f8f9fa;border-radius:10px;padding:12px;text-align:center;}
.counter-box .num{font-size:22px;font-weight:700;color:#1a237e;}
.counter-box .lbl{font-size:11px;color:#9ca3af;margin-top:2px;}
.result-box{border-radius:10px;padding:16px;margin-bottom:14px;display:none;}
.result-box.success{background:#e6f4ea;border:2px solid #a8d5b5;}
.result-box.already{background:#fff8e1;border:2px solid #ffe082;}
.result-box.error{background:#fef2f2;border:2px solid #fecaca;}
.result-icon{font-size:32px;text-align:center;margin-bottom:8px;}
.result-name{font-size:16px;font-weight:700;color:#1a1a2e;text-align:center;}
.result-reg{font-size:12px;color:#6b7280;text-align:center;margin-top:3px;}
.result-dept{text-align:center;margin-top:6px;}
.result-time{font-size:11px;color:#9ca3af;text-align:center;margin-top:4px;}
.result-msg{font-size:12px;font-weight:600;text-align:center;margin-top:6px;}
.badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;}
.badge-IT{background:#e8f0fe;color:#1a237e;}
.badge-ENG{background:#e6f4ea;color:#1b5e20;}
.badge-THM{background:#fff3e0;color:#e65100;}
.badge-MGT{background:#fce4ec;color:#880e4f;}
.badge-ACC{background:#f3e8fd;color:#4a148c;}
.log-title{font-size:12px;font-weight:600;color:#374151;margin-bottom:8px;}
.log-list{max-height:260px;overflow-y:auto;}
.log-item{display:flex;align-items:center;gap:10px;padding:9px 10px;border-radius:8px;border:1px solid #f3f4f6;margin-bottom:5px;background:#fafafa;}
.log-avatar{width:32px;height:32px;border-radius:50%;background:#e8f0fe;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:#1a237e;flex-shrink:0;}
.log-info{flex:1;}
.log-info strong{font-size:12px;color:#1a1a2e;display:block;}
.log-info span{font-size:11px;color:#9ca3af;}
.log-time{font-size:11px;color:#6b7280;}
.log-empty{text-align:center;padding:20px;color:#9ca3af;font-size:12px;}

/* QR popup */
.qr-popup{display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.85);z-index:1000;align-items:center;justify-content:center;}
.qr-popup-inner{background:white;border-radius:20px;padding:32px;text-align:center;max-width:420px;width:90%;}
.alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}

/* Info steps */
.info-steps{background:#f8f9ff;border-radius:8px;padding:12px;margin-bottom:14px;}
.info-steps h4{font-size:11px;font-weight:700;color:#1a237e;margin-bottom:8px;text-transform:uppercase;}
.step-item{display:flex;gap:8px;margin-bottom:6px;}
.step-num{width:20px;height:20px;border-radius:50%;background:#1a237e;color:white;font-size:10px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;margin-top:1px;}
.step-text{font-size:12px;color:#374151;line-height:1.5;}
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
        <a href="attendance.jsp"    class="nav-item">&#9989; Attendance</a>
        <a href="monthlyReport.jsp" class="nav-item">&#128197; Monthly Report</a>
        <a href="qrCode.jsp"        class="nav-item">&#9638; QR Codes</a>
        <a href="qrScan.jsp"        class="nav-item active">&#128247; QR Scanner</a>
        <a href="marks.jsp"         class="nav-item">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"      class="nav-item">&#128218; Subjects</a>
        <a href="lms.jsp"           class="nav-item">&#128196; LMS</a>
        <a href="notices.jsp"       class="nav-item">&#128276; Notices</a>
        <a href="chatbot.jsp"       class="nav-item">&#129302; Assistant</a>
        <a href="reports.jsp"       class="nav-item">&#128202; Reports</a>
        <a href="emailNotify.jsp"   class="nav-item">&#128231; Email Alerts</a>
        <a href="manageUsers.jsp"   class="nav-item">&#128272; Manage Users</a>
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
        <h1>&#128247; Attendance Scanner</h1>
        <p>Mark attendance — Upload QR, Webcam, or Manual Entry</p>
    </div>

    <% if(dbError != null && !dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <!-- Auto Session Panel -->
    <div class="session-panel">
        <h3>&#9889; Auto Session — Students Mark Themselves</h3>
        <p>Create a session link — students open on phone and select their name</p>
        <% if(!sessionParam.isEmpty()){ %>
        <div class="active-session">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
                <span style="font-size:16px;">&#9989;</span>
                <strong style="font-size:13px;color:#1b5e20;">
                    Session Active: <%= sessionParam %>
                </strong>
                <span style="font-size:11px;color:#6b7280;margin-left:auto;">
                    <%= sessionMins %> min
                </span>
            </div>
            <p style="font-size:12px;color:#374151;margin-bottom:8px;">
                Share this link with students:
            </p>
            <div class="link-box"><%= checkinUrl %></div>
            <div class="session-btn-row">
                <button class="btn-copy"
                        onclick="copyLink('<%= checkinUrl %>')">
                    &#128203; Copy Link
                </button>
                <button class="btn-qr-proj"
                        onclick="showSessionQR('<%= checkinUrl %>')">
                    &#9638; Show QR on Screen
                </button>
            </div>
        </div>
        <% } %>
        <form action="CreateSessionServlet" method="post"
              class="create-form">
            <div class="fg-s">
                <label>Department</label>
                <select name="dept_id">
                    <% for(HashMap<String,String> d : deptListSes){ %>
                    <option value="<%= d.get("dept_id") %>"
                        <%= d.get("dept_id").equals(sessionDept)?"selected":"" %>>
                        <%= d.get("dept_code") %> — <%= d.get("dept_name") %>
                    </option>
                    <% } %>
                </select>
            </div>
            <div class="fg-s">
                <label>Duration</label>
                <select name="minutes">
                    <option value="10">10 minutes</option>
                    <option value="15" selected>15 minutes</option>
                    <option value="20">20 minutes</option>
                    <option value="30">30 minutes</option>
                    <option value="60">1 hour</option>
                </select>
            </div>
            <button type="submit" class="btn-create">
                &#9889; Create Session
            </button>
        </form>
    </div>

    <!-- Method Tabs -->
    <div class="method-tabs">
        <button class="method-tab active" onclick="switchTab(0)">
            &#128444; Upload QR Image
        </button>
        <button class="method-tab" onclick="switchTab(1)">
            &#128247; Live Webcam
        </button>
        <button class="method-tab" onclick="switchTab(2)">
            &#128101; Manual Entry
        </button>
    </div>

    <div class="scan-layout">
        <div>
            <!-- TAB 0: Upload QR -->
            <div class="method-panel active" id="panel0">
                <div class="scan-card">
                    <h3>&#128444; Upload QR Image</h3>
                    <p>Save student QR image and upload here to mark attendance</p>
                    <div class="info-steps">
                        <h4>Steps:</h4>
                        <div class="step-item">
                            <div class="step-num">1</div>
                            <div class="step-text">Go to QR Codes → Generate QR → View → Right-click → Save image</div>
                        </div>
                        <div class="step-item">
                            <div class="step-num">2</div>
                            <div class="step-text">Click upload area → select the PNG file</div>
                        </div>
                        <div class="step-item">
                            <div class="step-num">3</div>
                            <div class="step-text">Click Scan &amp; Mark Attendance</div>
                        </div>
                    </div>
                    <div class="upload-area" id="uploadArea"
                         onclick="document.getElementById('qrFileInput').click()"
                         ondragover="event.preventDefault();"
                         ondrop="handleDrop(event)">
                        <div class="upload-icon">&#128444;</div>
                        <h4>Click to upload QR image</h4>
                        <p>PNG, JPG files supported</p>
                    </div>
                    <input type="file" id="qrFileInput"
                           accept="image/*"
                           onchange="handleFileSelect(this)"
                           style="display:none;">
                    <div class="preview-box" id="previewBox">
                        <img id="previewImg" src="" alt="QR Preview">
                        <p id="previewName"></p>
                    </div>
                    <div class="scan-progress" id="scanProgress">
                        &#128247; Reading QR code...
                    </div>
                    <button class="btn-scan-upload" id="btnScanUpload"
                            onclick="scanUploadedImage()" disabled>
                        &#128247; Scan &amp; Mark Attendance
                    </button>
                </div>
            </div>

            <!-- TAB 1: Webcam -->
            <div class="method-panel" id="panel1">
                <div class="scan-card">
                    <h3>&#128247; Live Webcam Scanner</h3>
                    <p>Print QR on paper and hold to webcam</p>
                    <div class="camera-wrapper">
                        <div class="camera-placeholder" id="placeholder">
                            <div class="icon">&#128247;</div>
                            <p>Click Start Scanner to begin</p>
                        </div>
                        <video id="video" autoplay playsinline
                               style="display:none;"></video>
                        <canvas id="canvas"></canvas>
                        <div class="scan-overlay" id="overlay"
                             style="display:none;">
                            <div class="scan-frame">
                                <div class="scan-line"></div>
                            </div>
                        </div>
                    </div>
                    <div class="scan-status" id="scanStatus">
                        Scanner not started
                    </div>
                    <button class="btn-start" id="btnStart"
                            onclick="startScanner()">
                        &#9654; Start Scanner
                    </button>
                    <button class="btn-stop" id="btnStop"
                            onclick="stopScanner()">
                        &#9646;&#9646; Stop Scanner
                    </button>
                </div>
            </div>

            <!-- TAB 2: Manual Entry with Dept/Year filter -->
            <div class="method-panel" id="panel2">
                <div class="scan-card">
                    <h3>&#128101; Manual Entry</h3>
                    <p>Filter by department and year, then search student name</p>

                    <!-- Filter row -->
                    <div class="filter-row">
                        <select id="manDept"
                                onchange="filterStudents()"
                                title="Filter by Department">
                            <option value="ALL">All Departments</option>
                            <% for(HashMap<String,String> d : deptListSes){ %>
                            <option value="<%= d.get("dept_code") %>">
                                &#128205; <%= d.get("dept_code") %>
                            </option>
                            <% } %>
                        </select>
                        <select id="manYear"
                                onchange="filterStudents()"
                                title="Filter by Year">
                            <option value="ALL">All Years</option>
                            <option value="First Year">1st Year</option>
                            <option value="Second Year">2nd Year</option>
                            <option value="Third Year">3rd Year</option>
                            <option value="Fourth Year">4th Year</option>
                        </select>
                    </div>

                    <!-- Search -->
                    <div class="search-box">
                        <input type="text" id="searchInput"
                               placeholder="&#128269; Type name or reg number..."
                               oninput="searchStudents(this.value)"
                               autocomplete="off">
                        <div class="search-results" id="searchResults"></div>
                    </div>

                    <!-- Selected student -->
                    <div class="selected-student" id="selectedStudent">
                        <h4 id="selName">—</h4>
                        <p id="selReg">—</p>
                    </div>

                    <input type="hidden" id="selStudentId" value="">
                    <input type="hidden" id="selDeptCode"  value="">

                    <button class="btn-mark" id="btnMark"
                            onclick="markManual()" disabled>
                        &#9989; Mark Attendance Now
                    </button>
                </div>
            </div>
        </div>

        <!-- Results panel -->
        <div>
            <div class="result-card">
                <h3>&#128203; Results</h3>
                <div class="counter-row">
                    <div class="counter-box">
                        <div class="num" id="countSuccess">0</div>
                        <div class="lbl">Marked Today</div>
                    </div>
                    <div class="counter-box">
                        <div class="num" id="countAlready">0</div>
                        <div class="lbl">Already Marked</div>
                    </div>
                </div>
                <div class="result-box" id="resultBox">
                    <div class="result-icon" id="resultIcon"></div>
                    <div class="result-name" id="resultName"></div>
                    <div class="result-reg"  id="resultReg"></div>
                    <div class="result-dept" id="resultDept"></div>
                    <div class="result-time" id="resultTime"></div>
                    <div class="result-msg"  id="resultMsg"></div>
                </div>
                <div class="log-title">&#128203; Today's Log</div>
                <div class="log-list" id="logList">
                    <div class="log-empty">No attendance marked yet</div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- QR Popup -->
<div class="qr-popup" id="qrPopup">
    <div class="qr-popup-inner">
        <h3 style="margin-bottom:8px;">&#9638; Scan to Mark Attendance</h3>
        <p style="font-size:13px;color:#6b7280;margin-bottom:16px;">
            Students scan with phone camera
        </p>
        <div id="qrDisplay" style="margin:0 auto 14px;"></div>
        <p style="font-size:11px;color:#9ca3af;word-break:break-all;
                  margin-bottom:16px;" id="qrUrlDisplay"></p>
        <button onclick="document.getElementById('qrPopup').style.display='none'"
                style="background:#f3f4f6;color:#374151;border:1px solid #e5e7eb;
                       border-radius:8px;padding:10px 24px;font-size:13px;cursor:pointer;">
            Close
        </button>
    </div>
</div>

<!-- jsQR from local file -->
<script src="<%=request.getContextPath()%>/js/jsQR.js"></script>

<script>
// ── All students data ─────────────────────────────
var allStudents = [
<% for(int i=0;i<studentList.size();i++){
    HashMap<String,String> s = studentList.get(i);
    String safeName = s.get("full_name")
        .replace("\\","\\\\").replace("'","\\'")
        .replace("\"","\\\"").replace("\n","").replace("\r","");
%>
    {id:'<%= s.get("student_id") %>',
     reg:'<%= s.get("reg_number") %>',
     name:'<%= safeName %>',
     dept:'<%= s.get("dept_code") %>',
     year:'<%= s.get("year_level") %>'}
    <%= i<studentList.size()-1?",":"" %>
<% } %>
];
var filteredStudents = allStudents.slice();

// ── Tab switching ─────────────────────────────────
function switchTab(idx){
    document.querySelectorAll('.method-panel').forEach(function(p,i){
        p.classList.toggle('active', i===idx);
    });
    document.querySelectorAll('.method-tab').forEach(function(t,i){
        t.classList.toggle('active', i===idx);
    });
    if(idx !== 1) stopScanner();
}

// ── Session helpers ───────────────────────────────
function copyLink(url){
    navigator.clipboard.writeText(url).then(function(){
        alert('Link copied! Share via WhatsApp.');
    }).catch(function(){
        prompt('Copy this link:', url);
    });
}
function showSessionQR(url){
    var qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=260x260&data='
              + encodeURIComponent(url);
    document.getElementById('qrDisplay').innerHTML =
        '<img src="'+qrUrl+'" style="width:260px;height:260px;border-radius:8px;">';
    document.getElementById('qrUrlDisplay').textContent = url;
    document.getElementById('qrPopup').style.display = 'flex';
}

// ── Upload QR ─────────────────────────────────────
var uploadedFile = null;
function handleFileSelect(input){
    if(input.files && input.files[0]){
        uploadedFile = input.files[0];
        showPreview(uploadedFile);
    }
}
function handleDrop(event){
    event.preventDefault();
    var file = event.dataTransfer.files[0];
    if(file && file.type.startsWith('image/')){
        uploadedFile = file;
        showPreview(file);
    }
}
function showPreview(file){
    var reader = new FileReader();
    reader.onload = function(e){
        document.getElementById('previewImg').src = e.target.result;
        document.getElementById('previewName').textContent = file.name;
        document.getElementById('previewBox').style.display = 'block';
        document.getElementById('btnScanUpload').disabled = false;
    };
    reader.readAsDataURL(file);
}
function scanUploadedImage(){
    if(!uploadedFile){alert('Please select a QR image first.');return;}
    if(typeof jsQR === 'undefined'){
        showResult({status:'error',message:'jsQR library not loaded. Check js/jsQR.js file exists.'});
        return;
    }
    document.getElementById('scanProgress').style.display = 'block';
    document.getElementById('btnScanUpload').disabled = true;
    var reader = new FileReader();
    reader.onload = function(e){
        var img = new Image();
        img.onload = function(){
            var cv  = document.createElement('canvas');
            cv.width  = img.width;
            cv.height = img.height;
            var ctx = cv.getContext('2d');
            ctx.drawImage(img, 0, 0);
            var imageData = ctx.getImageData(0, 0, cv.width, cv.height);
            var code = jsQR(imageData.data, imageData.width, imageData.height,
                            {inversionAttempts:'attemptBoth'});
            document.getElementById('scanProgress').style.display = 'none';
            document.getElementById('btnScanUpload').disabled = false;
            if(code && code.data){
                if(code.data.indexOf('SMS|') !== 0){
                    showResult({status:'error',message:'Not an SMS QR code.'});
                    return;
                }
                sendAttendance(code.data.trim());
            } else {
                showResult({status:'error',
                    message:'Could not read QR. Make sure image is clear.'});
            }
        };
        img.src = e.target.result;
    };
    reader.readAsDataURL(uploadedFile);
}

// ── Webcam ────────────────────────────────────────
var video = document.getElementById('video');
var canvas= document.getElementById('canvas');
var ctx   = canvas.getContext('2d');
var scanning=false, stream=null, scanInterval=null;
var lastScanned='', lastScanTime=0;

function startScanner(){
    if(typeof jsQR==='undefined'){
        alert('jsQR not loaded. Check js/jsQR.js.');return;
    }
    navigator.mediaDevices.getUserMedia({video:{facingMode:'environment'}})
    .catch(function(){ return navigator.mediaDevices.getUserMedia({video:true}); })
    .then(function(s){
        stream=s; scanning=true;
        video.srcObject=s;
        video.style.display='block';
        document.getElementById('placeholder').style.display='none';
        document.getElementById('overlay').style.display='flex';
        document.getElementById('btnStart').style.display='none';
        document.getElementById('btnStop').style.display='block';
        document.getElementById('scanStatus').className='scan-status active';
        document.getElementById('scanStatus').innerHTML='&#128247; Scanning — hold QR to camera';
        video.onloadedmetadata=function(){
            video.play();
            canvas.width=video.videoWidth||640;
            canvas.height=video.videoHeight||480;
            scanInterval=setInterval(scanFrame,200);
        };
    }).catch(function(err){
        alert('Camera error: '+err.message);
    });
}
function stopScanner(){
    scanning=false;
    if(scanInterval) clearInterval(scanInterval);
    if(stream) stream.getTracks().forEach(function(t){t.stop();});
    video.style.display='none';
    document.getElementById('placeholder').style.display='flex';
    document.getElementById('overlay').style.display='none';
    document.getElementById('btnStart').style.display='block';
    document.getElementById('btnStop').style.display='none';
    document.getElementById('scanStatus').className='scan-status';
    document.getElementById('scanStatus').innerHTML='Scanner stopped';
}
function scanFrame(){
    if(!scanning||video.readyState!==video.HAVE_ENOUGH_DATA) return;
    ctx.drawImage(video,0,0,canvas.width,canvas.height);
    var imgData=ctx.getImageData(0,0,canvas.width,canvas.height);
    var code=jsQR(imgData.data,imgData.width,imgData.height,
                  {inversionAttempts:'attemptBoth'});
    if(code && code.data){
        var now=Date.now();
        if(code.data===lastScanned&&(now-lastScanTime)<4000) return;
        lastScanned=code.data; lastScanTime=now;
        if(code.data.indexOf('SMS|')!==0) return;
        sendAttendance(code.data.trim());
    }
}

// ── Manual Entry with dept/year filter ───────────
function filterStudents(){
    var dept = document.getElementById('manDept').value;
    var year = document.getElementById('manYear').value;
    filteredStudents = allStudents.filter(function(s){
        return (dept==='ALL'||s.dept===dept) &&
               (year==='ALL'||s.year===year);
    });
    // Reset search
    document.getElementById('searchInput').value='';
    document.getElementById('searchResults').style.display='none';
    document.getElementById('selectedStudent').style.display='none';
    document.getElementById('btnMark').disabled=true;
    document.getElementById('selStudentId').value='';
    document.getElementById('selDeptCode').value='';
}

function searchStudents(query){
    var res=document.getElementById('searchResults');
    if(query.length<1){res.style.display='none';return;}
    var q=query.toLowerCase();
    var matches=filteredStudents.filter(function(s){
        return s.name.toLowerCase().indexOf(q)>=0||
               s.reg.toLowerCase().indexOf(q)>=0;
    }).slice(0,10);
    if(!matches.length){res.style.display='none';return;}
    var html='';
    matches.forEach(function(s){
        var init=s.name.charAt(0).toUpperCase();
        var yearShort=s.year.replace(' Year','Y').replace('First','1').
            replace('Second','2').replace('Third','3').replace('Fourth','4');
        html+='<div class="search-item" onclick="selectStudent(\''+s.id+
              '\',\''+s.name.replace(/'/g,"\\'")+'\',\''+s.reg+
              '\',\''+s.dept+'\')">'
            +'<div class="si-avatar">'+init+'</div>'
            +'<div class="si-info"><strong>'+s.name+'</strong>'
            +'<span>'+s.reg+' | '
            +'<span class="badge badge-'+s.dept+'">'+s.dept+'</span>'
            +' | '+yearShort+'</span></div></div>';
    });
    res.innerHTML=html;
    res.style.display='block';
}

function selectStudent(id,name,reg,dept){
    document.getElementById('selStudentId').value=id;
    document.getElementById('selDeptCode').value=dept;
    document.getElementById('selName').textContent=name;
    document.getElementById('selReg').textContent=reg+' — '+dept;
    document.getElementById('selectedStudent').style.display='block';
    document.getElementById('btnMark').disabled=false;
    document.getElementById('searchResults').style.display='none';
    document.getElementById('searchInput').value=name;
    console.log('Selected student ID:',id,'Name:',name,'Dept:',dept);
}

function markManual(){
    var sid  =document.getElementById('selStudentId').value;
    var name =document.getElementById('selName').textContent.trim();
    var regFull=document.getElementById('selReg').textContent.trim();
    var reg  =regFull.split(' — ')[0].trim();
    var dept =document.getElementById('selDeptCode').value.trim();
    if(!sid||sid===''){
        alert('Please search and select a student first.');return;
    }
    var qrData='SMS|'+sid+'|'+reg+'|'+name+'|'+dept;
    console.log('Sending qrData:',qrData);
    sendAttendance(qrData);
    // Reset
    document.getElementById('searchInput').value='';
    document.getElementById('selectedStudent').style.display='none';
    document.getElementById('btnMark').disabled=true;
    document.getElementById('selStudentId').value='';
    document.getElementById('selDeptCode').value='';
}

document.addEventListener('click',function(e){
    if(!e.target.closest('.search-box'))
        document.getElementById('searchResults').style.display='none';
});

// ── Send to Servlet ───────────────────────────────
var countSuccess=0, countAlready=0, logItems=[];

function sendAttendance(qrData){
    console.log('sendAttendance:',qrData);
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MarkAttendanceServlet',true);
    xhr.setRequestHeader('Content-Type',
        'application/x-www-form-urlencoded');
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4){
            console.log('Response:',xhr.responseText);
            var d;
            try{d=JSON.parse(xhr.responseText);}
            catch(e){
                d={status:'error',
                   message:'Server error: '+xhr.responseText.substring(0,100)};
            }
            showResult(d);
        }
    };
    xhr.send('qrData='+encodeURIComponent(qrData));
}

function showResult(data){
    var box=document.getElementById('resultBox');
    box.style.display='block';
    box.className='result-box';
    document.getElementById('resultIcon').textContent='';
    document.getElementById('resultName').textContent='';
    document.getElementById('resultReg').textContent='';
    document.getElementById('resultDept').innerHTML='';
    document.getElementById('resultTime').textContent='';
    document.getElementById('resultMsg').textContent='';

    if(data.status==='success'){
        box.classList.add('success');
        document.getElementById('resultIcon').textContent=
            data.attStatus==='Late'?'⚠️':'✅';
        document.getElementById('resultName').textContent=data.name||'';
        document.getElementById('resultReg').textContent=data.reg||'';
        document.getElementById('resultDept').innerHTML=
            '<span class="badge badge-'+(data.dept||'')+'">'+(data.dept||'')+'</span>';
        document.getElementById('resultTime').textContent=
            'Time: '+(data.time||'');
        document.getElementById('resultMsg').textContent=
            data.attStatus==='Late'?'Marked LATE':'Attendance marked — Present!';
        document.getElementById('resultMsg').style.color=
            data.attStatus==='Late'?'#f57c00':'#1b5e20';
        countSuccess++;
        document.getElementById('countSuccess').textContent=countSuccess;
        addToLog(data.name,data.reg,data.dept,data.time,data.attStatus);
        playBeep(true);

    } else if(data.status==='already'){
        box.classList.add('already');
        document.getElementById('resultIcon').textContent='⚠️';
        document.getElementById('resultName').textContent=data.name||'';
        document.getElementById('resultDept').innerHTML=
            '<span class="badge badge-'+(data.dept||'')+'">'+(data.dept||'')+'</span>';
        document.getElementById('resultMsg').textContent=
            'Already marked present today!';
        document.getElementById('resultMsg').style.color='#f57f17';
        countAlready++;
        document.getElementById('countAlready').textContent=countAlready;
        playBeep(false);

    } else {
        box.classList.add('error');
        document.getElementById('resultIcon').textContent='❌';
        document.getElementById('resultName').textContent='Error';
        document.getElementById('resultMsg').textContent=
            data.message||'Unknown error';
        document.getElementById('resultMsg').style.color='#dc2626';
    }
}

function addToLog(name,reg,dept,time,attStatus){
    var init='?';
    if(name){
        var p=name.split(' ');
        init=p[0].charAt(0).toUpperCase();
        if(p.length>1) init+=p[p.length-1].charAt(0).toUpperCase();
    }
    logItems.unshift({init:init,name:name,reg:reg,dept:dept,
                      time:time,status:attStatus});
    var html='';
    logItems.forEach(function(item){
        html+='<div class="log-item">'
            +'<div class="log-avatar">'+item.init+'</div>'
            +'<div class="log-info"><strong>'+item.name+'</strong>'
            +'<span>'+item.reg+' | '+item.dept+'</span></div>'
            +'<div class="log-time">'
            +(item.status==='Late'?'<span style="color:#f57c00;">Late</span> ':'')
            +item.time+'</div></div>';
    });
    document.getElementById('logList').innerHTML=html;
}

function playBeep(ok){
    try{
        var ac=new(window.AudioContext||window.webkitAudioContext)();
        var o=ac.createOscillator();
        var g=ac.createGain();
        o.connect(g);g.connect(ac.destination);
        o.frequency.value=ok?880:440;
        o.type='sine';
        g.gain.setValueAtTime(0.3,ac.currentTime);
        g.gain.exponentialRampToValueAtTime(0.001,ac.currentTime+0.3);
        o.start(ac.currentTime);o.stop(ac.currentTime+0.3);
    }catch(e){}
}
</script>
</body>
</html>