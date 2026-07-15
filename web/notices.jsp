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
    boolean isAdmin = RoleCheck.isAdmin(session);
    boolean isLec   = RoleCheck.isLecturer(session);

    ArrayList<HashMap<String,String>> notices =
        new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> deptList =
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
            deptList.add(d);
        }

        ResultSet rs = conn.createStatement().executeQuery(
            "SELECT n.*, d.dept_code, d.dept_name " +
            "FROM notices n " +
            "LEFT JOIN departments d ON n.dept_id=d.dept_id " +
            "WHERE (n.expires_at IS NULL OR n.expires_at >= CURDATE()) " +
            "ORDER BY FIELD(n.priority,'urgent','important','normal'), " +
            "n.created_at DESC");
        while(rs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("notice_id", String.valueOf(rs.getInt("notice_id")));
            row.put("title",     rs.getString("title"));
            row.put("content",   rs.getString("content"));
            row.put("priority",  rs.getString("priority"));
            row.put("posted_by", rs.getString("posted_by") != null ?
                    rs.getString("posted_by") : "");
            row.put("dept_code", rs.getString("dept_code") != null ?
                    rs.getString("dept_code") : "ALL");
            row.put("created_at",rs.getString("created_at") != null ?
                    rs.getString("created_at").substring(0,10) : "");
            row.put("expires_at",rs.getString("expires_at") != null ?
                    rs.getString("expires_at") : "");
            notices.add(row);
        }
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Notice Board</title>
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
        .page-header{margin-bottom:20px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:4px;}
        .alert-success{background:#e6f4ea;color:#1b5e20;border:1px solid #a8d5b5;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}
        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}

        .layout{display:grid;grid-template-columns:1fr 300px;gap:20px;align-items:start;}

        /* Notice cards */
        .notice-card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);margin-bottom:14px;border-left:5px solid #e5e7eb;}
        .notice-card.urgent{border-left-color:#dc2626;}
        .notice-card.important{border-left-color:#f57c00;}
        .notice-card.normal{border-left-color:#1a237e;}

        .notice-header{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:10px;}
        .notice-title{font-size:15px;font-weight:700;color:#1a1a2e;}
        .priority-badge{padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;}
        .p-urgent{background:#fef2f2;color:#dc2626;}
        .p-important{background:#fff3e0;color:#f57c00;}
        .p-normal{background:#e8f0fe;color:#1a237e;}
        .notice-content{font-size:13px;color:#374151;line-height:1.7;margin-bottom:12px;white-space:pre-wrap;}
        .notice-footer{display:flex;justify-content:space-between;align-items:center;font-size:12px;color:#9ca3af;}
        .badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;}
        .badge-IT{background:#e8f0fe;color:#1a237e;}
        .badge-ENG{background:#e6f4ea;color:#1b5e20;}
        .badge-THM{background:#fff3e0;color:#e65100;}
        .badge-MGT{background:#fce4ec;color:#880e4f;}
        .badge-ACC{background:#f3e8fd;color:#4a148c;}
        .badge-ALL{background:#f3f4f6;color:#374151;}
        .btn-del-n{background:#fef2f2;color:#dc2626;border:none;border-radius:6px;padding:4px 10px;font-size:11px;font-weight:600;cursor:pointer;}

        /* Add notice form */
        .form-card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);position:sticky;top:20px;}
        .form-card h3{font-size:14px;font-weight:700;color:#1a1a2e;margin-bottom:14px;}
        .form-group{margin-bottom:12px;}
        .form-group label{display:block;font-size:12px;font-weight:500;color:#374151;margin-bottom:5px;}
        .form-group input,.form-group select,.form-group textarea{width:100%;padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;}
        .form-group input:focus,.form-group select:focus,.form-group textarea:focus{border-color:#1a237e;}
        .form-group textarea{min-height:100px;resize:vertical;}
        .btn-post{width:100%;background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:8px;padding:11px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}

        .empty-state{text-align:center;padding:48px;color:#9ca3af;}
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
        <a href="qrScan.jsp"        class="nav-item">&#128247; QR Scanner</a>
        <a href="marks.jsp"         class="nav-item">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"      class="nav-item">&#128218; Subjects</a>
        <a href="lms.jsp"           class="nav-item">&#128196; LMS</a>
        <a href="notices.jsp"       class="nav-item active">&#128276; Notice Board</a>
        <a href="chatbot.jsp" class="nav-item">&#129302; Assistant</a>
        <a href="reports.jsp"       class="nav-item">&#128202; Reports</a>
        <a href="emailNotify.jsp" class="nav-item">&#128231; Email Alerts</a>
        <% if(isAdmin){ %>
        <a href="manageUsers.jsp"   class="nav-item">&#128272; Manage Users</a>
        <% } %>
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
        <h1>&#128276; Notice Board</h1>
        <p>Important announcements and notices</p>
    </div>

    <% if("added".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Notice posted!</div>
    <% } else if("deleted".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Notice deleted!</div>
    <% } %>
    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <div class="layout">
        <!-- Notices list -->
        <div>
            <% if(notices.isEmpty()){ %>
            <div class="empty-state">
                <div style="font-size:48px;margin-bottom:12px;">&#128276;</div>
                <h3 style="color:#6b7280;">No notices yet</h3>
                <p style="font-size:13px;">
                    Post a notice using the form on the right
                </p>
            </div>
            <% } else {
                for(HashMap<String,String> n : notices){ %>
            <div class="notice-card <%= n.get("priority") %>">
                <div class="notice-header">
                    <div class="notice-title">
                        <%
                        String p = n.get("priority");
                        if("urgent".equals(p)){%>&#128721;
                        <%}else if("important".equals(p)){%>&#9888;
                        <%}else{%>&#128276;<%}%>
                        <%= n.get("title") %>
                    </div>
                    <div style="display:flex;gap:6px;align-items:center;">
                        <span class="priority-badge p-<%= n.get("priority") %>">
                            <%= n.get("priority").toUpperCase() %>
                        </span>
                        <% if(isAdmin||isLec){ %>
                        <button class="btn-del-n"
                            onclick="if(confirm('Delete this notice?')){
                                var f=document.createElement('form');
                                f.method='post';f.action='NoticeServlet';
                                var a=document.createElement('input');
                                a.name='action';a.value='delete';
                                f.appendChild(a);
                                var b=document.createElement('input');
                                b.name='notice_id';
                                b.value='<%= n.get("notice_id") %>';
                                f.appendChild(b);
                                document.body.appendChild(f);
                                f.submit();}">
                            &#128465;
                        </button>
                        <% } %>
                    </div>
                </div>
                <div class="notice-content"><%= n.get("content") %></div>
                <div class="notice-footer">
                    <div>
                        <span class="badge badge-<%= n.get("dept_code") %>">
                            <%= n.get("dept_code") %>
                        </span>
                        &nbsp; Posted by: <%= n.get("posted_by") %>
                        &nbsp; Date: <%= n.get("created_at") %>
                        <% if(!n.get("expires_at").isEmpty()){ %>
                        &nbsp; Expires: <%= n.get("expires_at") %>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } } %>
        </div>

        <!-- Post notice form -->
        <% if(isAdmin||isLec){ %>
        <div>
            <div class="form-card">
                <h3>&#10133; Post Notice</h3>
                <form action="NoticeServlet" method="post">
                    <input type="hidden" name="action" value="add">

                    <div class="form-group">
                        <label>Priority *</label>
                        <select name="priority">
                            <option value="normal">
                                &#128276; Normal
                            </option>
                            <option value="important">
                                &#9888; Important
                            </option>
                            <option value="urgent">
                                &#128721; Urgent
                            </option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Title *</label>
                        <input type="text" name="title"
                               placeholder="Notice title"
                               required>
                    </div>

                    <div class="form-group">
                        <label>Content *</label>
                        <textarea name="content"
                                  placeholder="Write notice here..."
                                  required></textarea>
                    </div>

                    <div class="form-group">
                        <label>Department</label>
                        <select name="dept_id">
                            <option value="0">All Departments</option>
                            <% for(HashMap<String,String> d : deptList){ %>
                            <option value="<%= d.get("dept_id") %>">
                                <%= d.get("dept_code") %> —
                                <%= d.get("dept_name") %>
                            </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Expires On (optional)</label>
                        <input type="date" name="expires_at">
                    </div>

                    <button type="submit" class="btn-post">
                        &#128276; Post Notice
                    </button>
                </form>
            </div>
        </div>
        <% } %>
    </div>
</div>
</body>
</html>