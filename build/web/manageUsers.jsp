<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="com.sms.util.RoleCheck" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%
    if(!RoleCheck.isLoggedIn(session) || !RoleCheck.isAdmin(session)){
        response.sendRedirect("login.jsp"); return;
    }

    String action    = request.getParameter("action");
    String dbError   = "";
    String dbSuccess = "";

    // Handle Add User
    if("add".equals(action)){
        String uname    = request.getParameter("username");
        String pwd      = request.getParameter("password");
        String fname    = request.getParameter("full_name");
        String role     = request.getParameter("role");
        String deptId   = request.getParameter("dept_id");
        String stuId    = request.getParameter("student_id");
        try{
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO users (username,password,full_name,role,dept_id,student_id) " +
                "VALUES (?,?,?,?,?,?)");
            ps.setString(1, uname);
            ps.setString(2, pwd);
            ps.setString(3, fname);
            ps.setString(4, role);
            if(deptId != null && !deptId.isEmpty() && !"0".equals(deptId))
                ps.setInt(5, Integer.parseInt(deptId));
            else ps.setNull(5, java.sql.Types.INTEGER);
            if(stuId != null && !stuId.isEmpty() && !"0".equals(stuId))
                ps.setInt(6, Integer.parseInt(stuId));
            else ps.setNull(6, java.sql.Types.INTEGER);
            ps.executeUpdate();
            conn.close();
            dbSuccess = "User added successfully!";
        } catch(Exception e){ dbError = "Error: " + e.getMessage(); }
    }

    // Handle Delete User
    if("delete".equals(action)){
        String uid = request.getParameter("uid");
        try{
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM users WHERE user_id=? AND role != 'admin'");
            ps.setInt(1, Integer.parseInt(uid));
            ps.executeUpdate();
            conn.close();
            dbSuccess = "User deleted!";
        } catch(Exception e){ dbError = "Error: " + e.getMessage(); }
    }

    // Load all users
    ArrayList<HashMap<String,String>> userList = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> deptList = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> stuList  = new ArrayList<HashMap<String,String>>();

    try{
        Connection conn = DBConnection.getConnection();

        ResultSet urs = conn.createStatement().executeQuery(
            "SELECT u.*, d.dept_code, d.dept_name, " +
            "s.full_name as stu_name, s.reg_number " +
            "FROM users u " +
            "LEFT JOIN departments d ON u.dept_id=d.dept_id " +
            "LEFT JOIN students s ON u.student_id=s.student_id " +
            "ORDER BY u.role, u.full_name");
        while(urs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("user_id",   String.valueOf(urs.getInt("user_id")));
            row.put("username",  urs.getString("username"));
            row.put("full_name", urs.getString("full_name"));
            row.put("role",      urs.getString("role"));
            row.put("dept_code", urs.getString("dept_code") != null ? urs.getString("dept_code") : "-");
            row.put("dept_name", urs.getString("dept_name") != null ? urs.getString("dept_name") : "-");
            row.put("stu_name",  urs.getString("stu_name")  != null ? urs.getString("stu_name")  : "-");
            row.put("reg_number",urs.getString("reg_number")!= null ? urs.getString("reg_number"): "-");
            userList.add(row);
        }

        ResultSet drs = conn.createStatement().executeQuery(
            "SELECT * FROM departments ORDER BY dept_name");
        while(drs.next()){
            HashMap<String,String> d = new HashMap<String,String>();
            d.put("dept_id",   String.valueOf(drs.getInt("dept_id")));
            d.put("dept_code", drs.getString("dept_code"));
            d.put("dept_name", drs.getString("dept_name"));
            deptList.add(d);
        }

        ResultSet srs = conn.createStatement().executeQuery(
            "SELECT s.student_id, s.full_name, s.reg_number, d.dept_code " +
            "FROM students s JOIN departments d ON s.dept_id=d.dept_id " +
            "ORDER BY d.dept_code, s.full_name");
        while(srs.next()){
            HashMap<String,String> s = new HashMap<String,String>();
            s.put("student_id", String.valueOf(srs.getInt("student_id")));
            s.put("full_name",  srs.getString("full_name"));
            s.put("reg_number", srs.getString("reg_number"));
            s.put("dept_code",  srs.getString("dept_code"));
            stuList.add(s);
        }
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Manage Users</title>
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
        .nav-section{padding:12px;}
        .sidebar-user{margin-top:auto;padding:16px 20px;border-top:1px solid rgba(255,255,255,0.1);color:rgba(255,255,255,0.8);font-size:12px;}
        .sidebar-user strong{display:block;color:white;font-size:13px;}
        .main{margin-left:240px;padding:28px;flex:1;}
        .page-header{margin-bottom:24px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:4px;}
        .alert-success{background:#e6f4ea;color:#1b5e20;border:1px solid #a8d5b5;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}
        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}

        .layout{display:grid;grid-template-columns:1fr 340px;gap:24px;}

        /* User table */
        .table-card{background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.06);overflow:hidden;}
        .table-header{padding:16px 20px;border-bottom:1px solid #f3f4f6;display:flex;justify-content:space-between;align-items:center;}
        .table-header span{font-size:14px;font-weight:600;color:#1a1a2e;}
        table{width:100%;border-collapse:collapse;}
        thead th{background:#f8f9fa;padding:11px 14px;text-align:left;font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;}
        tbody tr{border-bottom:1px solid #f3f4f6;}
        tbody tr:hover{background:#f8f9ff;}
        tbody td{padding:11px 14px;font-size:13px;color:#1a1a2e;}

        .role-badge{display:inline-block;padding:4px 12px;border-radius:20px;font-size:11px;font-weight:700;}
        .role-admin{background:#fef2f2;color:#dc2626;}
        .role-lecturer{background:#e8f0fe;color:#1a237e;}
        .role-student{background:#e6f4ea;color:#1b5e20;}

        .badge-IT{background:#e8f0fe;color:#1a237e;}
        .badge-ENG{background:#e6f4ea;color:#1b5e20;}
        .badge-THM{background:#fff3e0;color:#e65100;}
        .badge-MGT{background:#fce4ec;color:#880e4f;}
        .badge-ACC{background:#f3e8fd;color:#4a148c;}
        .badge{display:inline-block;padding:3px 8px;border-radius:10px;font-size:11px;font-weight:600;}

        .btn-del{background:#fef2f2;color:#dc2626;border:none;border-radius:6px;padding:5px 10px;font-size:11px;font-weight:600;cursor:pointer;}
        .btn-del:hover{background:#fecaca;}

        /* Add form */
        .form-card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);position:sticky;top:20px;}
        .form-card h3{font-size:14px;font-weight:600;color:#1a1a2e;margin-bottom:16px;}
        .form-group{margin-bottom:13px;}
        .form-group label{display:block;font-size:12px;font-weight:500;color:#374151;margin-bottom:5px;}
        .form-group input,.form-group select{width:100%;padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;}
        .form-group input:focus,.form-group select:focus{border-color:#1a237e;}
        .btn-add-user{width:100%;background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:8px;padding:11px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
        .hint{font-size:11px;color:#9ca3af;margin-top:4px;}
        .divider{border:none;border-top:1px solid #f3f4f6;margin:14px 0;}

        /* Role sections */
        .section-title{font-size:13px;font-weight:700;color:#374151;margin:16px 0 8px;display:flex;align-items:center;gap:8px;}
    </style>
    <script>
    function updateRoleFields(){
        var role = document.getElementById('roleSelect').value;
        document.getElementById('deptGroup').style.display =
            (role==='lecturer') ? 'block' : 'none';
        document.getElementById('stuGroup').style.display =
            (role==='student') ? 'block' : 'none';
    }
    </script>
</head>
<body>
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
        <a href="lms.jsp" class="nav-item">&#128196; LMS Materials</a>
        <a href="emailNotify.jsp" class="nav-item">&#128231; Email Alerts</a>
        <a href="notices.jsp" class="nav-item">&#128276; Notice Board</a>
        <a href="manageUsers.jsp" class="nav-item active">&#128272; Manage Users</a>
        <div class="nav-label">Account</div>
        <a href="LogoutServlet"   class="nav-item">&#128682; Logout</a>
    </div>
    <div class="sidebar-user">
        <strong><%= session.getAttribute("loggedUser") %></strong>
        Admin
    </div>
</div>

<div class="main">
    <div class="page-header">
        <h1>&#128272; Manage Users</h1>
        <p>Add and manage admin, lecturer and student login accounts</p>
    </div>

    <% if(!dbSuccess.isEmpty()){ %>
    <div class="alert-success">&#10003; <%= dbSuccess %></div>
    <% } %>
    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <div class="layout">
        <!-- User List -->
        <div>
            <!-- Admin users -->
            <div class="section-title">
                <span class="role-badge role-admin">ADMIN</span>
                Admin Accounts
            </div>
            <div class="table-card" style="margin-bottom:16px;">
                <table>
                    <thead><tr>
                        <th>Username</th><th>Full Name</th><th>Role</th><th>Action</th>
                    </tr></thead>
                    <tbody>
                    <% for(HashMap<String,String> u : userList){
                        if(!"admin".equals(u.get("role"))) continue; %>
                    <tr>
                        <td style="font-weight:600;color:#1a237e;">
                            &#128272; <%= u.get("username") %>
                        </td>
                        <td><%= u.get("full_name") %></td>
                        <td><span class="role-badge role-admin">Admin</span></td>
                        <td><span style="font-size:11px;color:#9ca3af;">Protected</span></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Lecturer users -->
            <div class="section-title">
                <span class="role-badge role-lecturer">LECTURER</span>
                Lecturer Accounts
            </div>
            <div class="table-card" style="margin-bottom:16px;">
                <table>
                    <thead><tr>
                        <th>Username</th><th>Full Name</th>
                        <th>Department</th><th>Action</th>
                    </tr></thead>
                    <tbody>
                    <% boolean hasLec = false;
                       for(HashMap<String,String> u : userList){
                        if(!"lecturer".equals(u.get("role"))) continue;
                        hasLec = true; %>
                    <tr>
                        <td style="font-weight:600;color:#1a237e;">
                            &#127979; <%= u.get("username") %>
                        </td>
                        <td><strong><%= u.get("full_name") %></strong></td>
                        <td>
                            <% if(!"-".equals(u.get("dept_code"))){ %>
                            <span class="badge badge-<%= u.get("dept_code") %>">
                                <%= u.get("dept_code") %>
                            </span>
                            <%= u.get("dept_name") %>
                            <% } else { %>—<% } %>
                        </td>
                        <td>
                            <button class="btn-del"
                                onclick="if(confirm('Delete <%= u.get("full_name") %>?'))
                                    window.location='manageUsers.jsp?action=delete&uid=<%= u.get("user_id") %>'">
                                &#128465; Delete
                            </button>
                        </td>
                    </tr>
                    <% } if(!hasLec){ %>
                    <tr><td colspan="4" style="text-align:center;padding:20px;color:#9ca3af;">
                        No lecturer accounts yet
                    </td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Student users -->
            <div class="section-title">
                <span class="role-badge role-student">STUDENT</span>
                Student Accounts
            </div>
            <div class="table-card">
                <table>
                    <thead><tr>
                        <th>Username</th><th>Full Name</th>
                        <th>Student</th><th>Reg No</th><th>Action</th>
                    </tr></thead>
                    <tbody>
                    <% boolean hasStu = false;
                       for(HashMap<String,String> u : userList){
                        if(!"student".equals(u.get("role"))) continue;
                        hasStu = true; %>
                    <tr>
                        <td style="font-weight:600;color:#1b5e20;">
                            &#128100; <%= u.get("username") %>
                        </td>
                        <td><%= u.get("full_name") %></td>
                        <td><%= u.get("stu_name") %></td>
                        <td style="color:#1a237e;font-weight:600;">
                            <%= u.get("reg_number") %>
                        </td>
                        <td>
                            <button class="btn-del"
                                onclick="if(confirm('Delete account for <%= u.get("full_name") %>?'))
                                    window.location='manageUsers.jsp?action=delete&uid=<%= u.get("user_id") %>'">
                                &#128465; Delete
                            </button>
                        </td>
                    </tr>
                    <% } if(!hasStu){ %>
                    <tr><td colspan="5" style="text-align:center;padding:20px;color:#9ca3af;">
                        No student accounts yet — add one using the form
                    </td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Add User Form -->
        <div class="form-card">
            <h3>&#10133; Add New User</h3>
            <form action="manageUsers.jsp" method="post">
                <input type="hidden" name="action" value="add">

                <div class="form-group">
                    <label>Role *</label>
                    <select name="role" id="roleSelect"
                            onchange="updateRoleFields()" required>
                        <option value="lecturer">Lecturer</option>
                        <option value="student">Student</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Full Name *</label>
                    <input type="text" name="full_name"
                           placeholder="e.g. Mr. K.A. Perera" required>
                </div>

                <div class="form-group">
                    <label>Username *</label>
                    <input type="text" name="username"
                           placeholder="e.g. it_lecturer2" required>
                    <div class="hint">Used to login — no spaces</div>
                </div>

                <div class="form-group">
                    <label>Password *</label>
                    <input type="text" name="password"
                           placeholder="e.g. lecturer123" required>
                    <div class="hint">Share this with the user</div>
                </div>

                <!-- Dept — show for lecturer only -->
                <div class="form-group" id="deptGroup">
                    <label>Department (for Lecturer) *</label>
                    <select name="dept_id">
                        <option value="0">-- Select Department --</option>
                        <% for(HashMap<String,String> d : deptList){ %>
                        <option value="<%= d.get("dept_id") %>">
                            <%= d.get("dept_code") %> — <%= d.get("dept_name") %>
                        </option>
                        <% } %>
                    </select>
                </div>

                <!-- Student link — show for student only -->
                <div class="form-group" id="stuGroup" style="display:none;">
                    <label>Link to Student *</label>
                    <select name="student_id">
                        <option value="0">-- Select Student --</option>
                        <% for(HashMap<String,String> s : stuList){ %>
                        <option value="<%= s.get("student_id") %>">
                            [<%= s.get("dept_code") %>]
                            <%= s.get("full_name") %>
                            (<%= s.get("reg_number") %>)
                        </option>
                        <% } %>
                    </select>
                    <div class="hint">This links the login to the student's record</div>
                </div>

                <button type="submit" class="btn-add-user">
                    &#10003; Add User Account
                </button>
            </form>

            <hr class="divider">

            <div style="background:#f8f9fa;border-radius:8px;padding:12px;">
                <p style="font-size:12px;font-weight:600;color:#374151;margin-bottom:8px;">
                    Default Login Credentials:
                </p>
                <p style="font-size:12px;color:#6b7280;line-height:1.8;">
                    &#128272; Admin: <strong>admin</strong> / admin123<br>
                    &#127979; Lecturers: <strong>it_lecturer</strong> / lecturer123<br>
                    &#128100; Students: set when you add them
                </p>
            </div>
        </div>
    </div>
</div>
                    
                    
</body>
</html>