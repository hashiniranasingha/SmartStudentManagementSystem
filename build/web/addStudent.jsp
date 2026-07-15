<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%
    if(session.getAttribute("loggedUser") == null){
        response.sendRedirect("login.jsp"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Add Student</title>
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
        .nav-item:hover, .nav-item.active { background:rgba(255,255,255,0.15); color:white; }
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

        .form-card {
            background:white; border-radius:12px; padding:28px;
            box-shadow:0 1px 4px rgba(0,0,0,0.06); max-width:700px;
        }
        .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:20px; }
        .form-group { display:flex; flex-direction:column; gap:6px; }
        .form-group.full { grid-column:1/-1; }
        label { font-size:13px; font-weight:500; color:#374151; }
        input[type=text], input[type=email], input[type=tel], select {
            padding:11px 14px; border:1.5px solid #e5e7eb; border-radius:8px;
            font-size:14px; font-family:'Inter',sans-serif; outline:none;
            transition:border-color 0.2s;
        }
        input:focus, select:focus { border-color:#1a237e; box-shadow:0 0 0 3px rgba(26,35,126,0.08); }

        .section-divider {
            grid-column:1/-1; border:none; border-top:1px solid #f3f4f6;
            margin:8px 0;
        }
        .section-label {
            grid-column:1/-1; font-size:12px; font-weight:600;
            color:#6b7280; text-transform:uppercase; letter-spacing:0.5px;
        }

        .btn-row { display:flex; gap:12px; margin-top:24px; }
        .btn-save {
            background:linear-gradient(135deg,#1a237e,#1565c0);
            color:white; border:none; border-radius:10px;
            padding:12px 28px; font-size:14px; font-weight:600;
            cursor:pointer; font-family:'Inter',sans-serif;
        }
        .btn-save:hover { opacity:0.9; }
        .btn-cancel {
            background:#f3f4f6; color:#374151; border:1px solid #e5e7eb;
            border-radius:10px; padding:12px 24px; font-size:14px; font-weight:500;
            cursor:pointer; text-decoration:none; font-family:'Inter',sans-serif;
        }

        .error-msg {
            background:#fef2f2; color:#dc2626; border:1px solid #fecaca;
            border-radius:8px; padding:11px 14px; font-size:13px; margin-bottom:20px;
        }

        .course-hint {
            font-size:11px; color:#9ca3af; margin-top:3px;
        }
    </style>
    <script>
        // Auto-fill course name based on department selection
        function updateCourse(){
            var dept = document.getElementById("dept_id");
            var selectedText = dept.options[dept.selectedIndex].text;
            var course = document.getElementById("course_name");
            var hints = {
                "IT"  : "HNDIT",
                "ENG" : "HNDE",
                "THM" : "HNDTHM",
                "MGT" : "HNDM",
                "ACC" : "HNDA"
            };
            var deptVal = dept.options[dept.selectedIndex].getAttribute("data-code");
            if(hints[deptVal]) course.value = hints[deptVal];
        }
    </script>
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
        <a href="dashboard.jsp" class="nav-item">&#9632; Dashboard</a>
        <a href="students.jsp" class="nav-item active">&#128101; Students</a>
        <a href="attendance.jsp" class="nav-item">&#9989; Attendance</a>
        <a href="monthlyReport.jsp" class="nav-item">
    &#128197; Monthly Report
</a>
        <a href="qrScan.jsp" class="nav-item">&#9638; QR Scanner</a>
        <a href="marks.jsp" class="nav-item">&#128196; Marks &amp; GPA</a>
        <a href="reports.jsp" class="nav-item">&#128202; Reports</a>
        <a href="notices.jsp" class="nav-item">&#128276; Notice Board</a>
        <div class="nav-label">Account</div>
        <a href="emailNotify.jsp" class="nav-item">&#128231; Email Alerts</a>
        <a href="chatbot.jsp" class="nav-item">&#129302; Assistant</a>
        <a href="LogoutServlet" class="nav-item">&#128682; Logout</a>
    </div>
    <div class="sidebar-user">
        <strong><%= session.getAttribute("loggedUser") %></strong>
        <%= session.getAttribute("userRole") %>
    </div>
</div>

<!-- MAIN -->
<div class="main">
    <div class="page-header">
        <h1>&#10133; Add New Student</h1>
        <p>Register a new student to a department and year</p>
    </div>

    <div class="form-card">
        <% if(request.getAttribute("errorMsg") != null){ %>
        <div class="error-msg">&#9888; <%= request.getAttribute("errorMsg") %></div>
        <% } %>

        <form action="AddStudentServlet" method="post">
        <div class="form-grid">

            <div class="section-label">Personal Information</div>

            <div class="form-group">
    <label>Registration Number</label>
    <div style="padding:11px 14px;background:#f0f4ff;border:1.5px solid #c7d9ff;
                border-radius:8px;font-size:13px;color:#1a237e;font-weight:600;">
        &#9432; Auto-generated when saved
        (e.g. BAD/IT/2526/F/001)
    </div>
</div>
            
            <div class="form-group">
                <label>Full Name *</label>
                <input type="text" name="full_name" placeholder="Enter full name"
                    value="<%= request.getAttribute("fullName")!=null ? request.getAttribute("fullName") : "" %>"
                    required>
            </div>
            <div class="form-group">
                <label>Email Address</label>
                <input type="email" name="email" placeholder="student@email.com"
                    value="<%= request.getAttribute("email")!=null ? request.getAttribute("email") : "" %>">
            </div>
            <div class="form-group">
                <label>Phone Number</label>
                <input type="tel" name="phone" placeholder="07X XXXXXXX"
                    value="<%= request.getAttribute("phone")!=null ? request.getAttribute("phone") : "" %>">
            </div>

            <hr class="section-divider">
            <div class="section-label">Academic Information</div>

            <div class="form-group">
                <label>Department *</label>
                <select name="dept_id" id="dept_id" onchange="updateCourse()" required>
                    <option value="">-- Select Department --</option>
                    <%
                    try{
                        Connection conn = DBConnection.getConnection();
                        ResultSet rs = conn.createStatement().executeQuery(
                            "SELECT * FROM departments ORDER BY dept_name");
                        while(rs.next()){
                    %>
                    <option value="<%= rs.getInt("dept_id") %>"
                            data-code="<%= rs.getString("dept_code") %>">
                        <%= rs.getString("dept_code") %> – <%= rs.getString("dept_name") %>
                    </option>
                    <% } conn.close(); } catch(Exception ex){} %>
                </select>
            </div>

            <div class="form-group">
                <label>Year Level *</label>
                <select name="year_level" required>
                    <option value="">-- Select Year --</option>
                    <option value="First Year">First Year</option>
                    <option value="Second Year">Second Year</option>
                </select>
            </div>

            <div class="form-group full">
                <label>Course Name</label>
                <input type="text" name="course_name" id="course_name"
                       placeholder="e.g. HNDIT (auto-filled when you select department)">
                <span class="course-hint">This will auto-fill when you select a department above</span>
            </div>

        </div>

        <div class="btn-row">
            <button type="submit" class="btn-save">&#10003; Save Student</button>
            <a href="students.jsp" class="btn-cancel">Cancel</a>
        </div>
        </form>
    </div>
</div>
                
                
</body>
</html>