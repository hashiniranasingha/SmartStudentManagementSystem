<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%
    if(session.getAttribute("loggedUser") == null){
        response.sendRedirect("login.jsp"); return;
    }
    String studentId = request.getParameter("id");
    String sRegNumber="", sFullName="", sEmail="", sPhone="", sYearLevel="", sCourseName="";
    int sDeptId = 0;
    try{
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM students WHERE student_id=?");
        ps.setInt(1, Integer.parseInt(studentId));
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            sRegNumber  = rs.getString("reg_number");
            sFullName   = rs.getString("full_name");
            sEmail      = rs.getString("email")      != null ? rs.getString("email")      : "";
            sPhone      = rs.getString("phone")      != null ? rs.getString("phone")      : "";
            sDeptId     = rs.getInt("dept_id");
            sYearLevel  = rs.getString("year_level");
            sCourseName = rs.getString("course_name") != null ? rs.getString("course_name") : "";
        }
        conn.close();
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Edit Student</title>
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
        .nav-item:hover,.nav-item.active{background:rgba(255,255,255,0.15);color:white;}
        .nav-section{padding:12px;}
        .sidebar-user{margin-top:auto;padding:16px 20px;border-top:1px solid rgba(255,255,255,0.1);color:rgba(255,255,255,0.8);font-size:12px;}
        .sidebar-user strong{display:block;color:white;font-size:13px;}
        .main{margin-left:240px;padding:28px;flex:1;}
        .page-header{margin-bottom:24px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:4px;}
        .form-card{background:white;border-radius:12px;padding:28px;box-shadow:0 1px 4px rgba(0,0,0,0.06);max-width:700px;}
        .form-grid{display:grid;grid-template-columns:1fr 1fr;gap:20px;}
        .form-group{display:flex;flex-direction:column;gap:6px;}
        .form-group.full{grid-column:1/-1;}
        label{font-size:13px;font-weight:500;color:#374151;}
        input[type=text],input[type=email],input[type=tel],select{padding:11px 14px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:14px;font-family:'Inter',sans-serif;outline:none;transition:border-color 0.2s;}
        input:focus,select:focus{border-color:#1a237e;box-shadow:0 0 0 3px rgba(26,35,126,0.08);}
        .section-divider{grid-column:1/-1;border:none;border-top:1px solid #f3f4f6;margin:8px 0;}
        .section-label{grid-column:1/-1;font-size:12px;font-weight:600;color:#6b7280;text-transform:uppercase;letter-spacing:0.5px;}
        .btn-row{display:flex;gap:12px;margin-top:24px;}
        .btn-save{background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:10px;padding:12px 28px;font-size:14px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
        .btn-cancel{background:#f3f4f6;color:#374151;border:1px solid #e5e7eb;border-radius:10px;padding:12px 24px;font-size:14px;font-weight:500;cursor:pointer;text-decoration:none;font-family:'Inter',sans-serif;}
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

<div class="main">
    <div class="page-header">
        <h1>&#9998; Edit Student</h1>
        <p>Update student details below</p>
    </div>
    <div class="form-card">
        <form action="EditStudentServlet" method="post">
        <input type="hidden" name="student_id" value="<%= studentId %>">
        <div class="form-grid">
            <div class="section-label">Personal Information</div>
            <div class="form-group">
                <label>Registration Number *</label>
                <input type="text" name="reg_number" value="<%= sRegNumber %>" required>
            </div>
            <div class="form-group">
                <label>Full Name *</label>
                <input type="text" name="full_name" value="<%= sFullName %>" required>
            </div>
            <div class="form-group">
                <label>Email Address</label>
                <input type="email" name="email" value="<%= sEmail %>">
            </div>
            <div class="form-group">
                <label>Phone Number</label>
                <input type="tel" name="phone" value="<%= sPhone %>">
            </div>
            <hr class="section-divider">
            <div class="section-label">Academic Information</div>
            <div class="form-group">
                <label>Department *</label>
                <select name="dept_id" required>
                    <%
                    try{
                        Connection conn2 = DBConnection.getConnection();
                        ResultSet rs2 = conn2.createStatement().executeQuery("SELECT * FROM departments ORDER BY dept_name");
                        while(rs2.next()){
                            String sel = (rs2.getInt("dept_id") == sDeptId) ? "selected" : "";
                    %>
                    <option value="<%= rs2.getInt("dept_id") %>" <%= sel %>>
                        <%= rs2.getString("dept_code") %> – <%= rs2.getString("dept_name") %>
                    </option>
                    <% } conn2.close(); }catch(Exception ex){} %>
                </select>
            </div>
            <div class="form-group">
                <label>Year Level *</label>
                <select name="year_level" required>
                    <option value="First Year"  <%= "First Year".equals(sYearLevel)  ? "selected":"" %>>First Year</option>
                    <option value="Second Year" <%= "Second Year".equals(sYearLevel) ? "selected":"" %>>Second Year</option>
                </select>
            </div>
            <div class="form-group full">
                <label>Course Name</label>
                <input type="text" name="course_name" value="<%= sCourseName %>">
            </div>
        </div>
        <div class="btn-row">
            <button type="submit" class="btn-save">&#10003; Update Student</button>
            <a href="students.jsp" class="btn-cancel">Cancel</a>
        </div>
        </form>
    </div>
</div>
            
            
</body>
</html>