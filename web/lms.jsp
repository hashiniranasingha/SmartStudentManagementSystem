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
    boolean isStu   = RoleCheck.isStudent(session);

    String filterDept = request.getParameter("dept");
    String filterType = request.getParameter("type");
    String filterSem  = request.getParameter("sem");
    if(filterDept == null) filterDept = "ALL";
    if(filterType == null) filterType = "ALL";
    if(filterSem  == null) filterSem  = "ALL";

    ArrayList<HashMap<String,String>> materials =
        new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> deptList  =
        new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> subjectList =
        new ArrayList<HashMap<String,String>>();
    String dbError = "";

    try{
        Connection conn = DBConnection.getConnection();

        ResultSet drs = conn.createStatement().executeQuery(
            "SELECT * FROM departments ORDER BY dept_name");
        while(drs.next()){
            HashMap<String,String> d = new HashMap<String,String>();
            d.put("dept_id",         String.valueOf(drs.getInt("dept_id")));
            d.put("dept_code",       drs.getString("dept_code"));
            d.put("dept_name",       drs.getString("dept_name"));
            d.put("total_semesters", String.valueOf(drs.getInt("total_semesters")));
            deptList.add(d);
        }

        if(!"ALL".equals(filterDept)){
            PreparedStatement sps = conn.prepareStatement(
                "SELECT subject_id, subject_name, semester " +
                "FROM subjects WHERE dept_id=? " +
                "ORDER BY semester, subject_name");
            sps.setInt(1, Integer.parseInt(filterDept));
            ResultSet srs = sps.executeQuery();
            while(srs.next()){
                HashMap<String,String> s = new HashMap<String,String>();
                s.put("subject_id",   String.valueOf(srs.getInt("subject_id")));
                s.put("subject_name", srs.getString("subject_name"));
                s.put("semester",     String.valueOf(srs.getInt("semester")));
                subjectList.add(s);
            }
        }

        String sql =
            "SELECT m.*, d.dept_code, d.dept_name, s.subject_name " +
            "FROM lms_materials m " +
            "LEFT JOIN departments d ON m.dept_id=d.dept_id " +
            "LEFT JOIN subjects s ON m.subject_id=s.subject_id " +
            "WHERE 1=1 ";
        if(!"ALL".equals(filterDept))
            sql += " AND m.dept_id=" + filterDept;
        if(!"ALL".equals(filterType))
            sql += " AND m.material_type='" + filterType + "'";
        if(!"ALL".equals(filterSem))
            sql += " AND m.semester=" + filterSem;
        sql += " ORDER BY m.created_at DESC";

        ResultSet rs = conn.createStatement().executeQuery(sql);
        while(rs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("material_id",  String.valueOf(rs.getInt("material_id")));
            row.put("title",        rs.getString("title") != null ? rs.getString("title") : "");
            row.put("description",  rs.getString("description") != null ? rs.getString("description") : "");
            row.put("material_type",rs.getString("material_type") != null ? rs.getString("material_type") : "notes");
            row.put("link_url",     rs.getString("link_url") != null ? rs.getString("link_url") : "");
            row.put("dept_code",    rs.getString("dept_code") != null ? rs.getString("dept_code") : "");
            row.put("dept_name",    rs.getString("dept_name") != null ? rs.getString("dept_name") : "All");
            row.put("subject_name", rs.getString("subject_name") != null ? rs.getString("subject_name") : "General");
            row.put("semester",     rs.getString("semester") != null ? rs.getString("semester") : "");
            row.put("uploaded_by",  rs.getString("uploaded_by") != null ? rs.getString("uploaded_by") : "");
            row.put("created_at",   rs.getString("created_at") != null ? rs.getString("created_at").substring(0,10) : "");
            materials.add(row);
        }
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Learning Materials</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#f0f2f5;display:flex;min-height:100vh;}
        .sidebar{width:240px;min-height:100vh;background:linear-gradient(180deg,#1a237e 0%,#0d47a1 100%);display:flex;flex-direction:column;position:fixed;left:0;top:0;}
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
        .layout{display:grid;grid-template-columns:1fr 320px;gap:20px;align-items:start;}
        .type-tabs{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:16px;}
        .type-tab{padding:7px 16px;border-radius:20px;font-size:12px;font-weight:600;text-decoration:none;border:1.5px solid #e5e7eb;color:#374151;background:white;transition:all 0.15s;}
        .type-tab.active{background:#1a237e;color:white;border-color:#1a237e;}
        .filter-bar{background:white;border-radius:12px;padding:14px 20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);margin-bottom:16px;display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap;}
        .fg{display:flex;flex-direction:column;gap:5px;}
        .fg label{font-size:12px;font-weight:500;color:#374151;}
        .fg select{padding:8px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;min-width:150px;}
        .btn-filter{background:#1a237e;color:white;border:none;border-radius:8px;padding:9px 18px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
        .btn-reset{background:#f3f4f6;color:#374151;border:1px solid #e5e7eb;border-radius:8px;padding:9px 14px;font-size:13px;text-decoration:none;}
        .materials-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:14px;}
        .material-card{background:white;border-radius:12px;padding:18px;box-shadow:0 1px 4px rgba(0,0,0,0.06);border-left:4px solid #e5e7eb;}
        .material-card.notes{border-left-color:#1a237e;}
        .material-card.pastpaper{border-left-color:#dc2626;}
        .material-card.video{border-left-color:#1b5e20;}
        .material-card.link{border-left-color:#e65100;}
        .material-card.other{border-left-color:#880e4f;}
        .card-header{display:flex;align-items:flex-start;gap:12px;margin-bottom:10px;}
        .type-icon{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;}
        .card-title{font-size:14px;font-weight:700;color:#1a1a2e;margin-bottom:3px;}
        .card-desc{font-size:12px;color:#6b7280;line-height:1.5;}
        .card-meta{display:flex;gap:6px;flex-wrap:wrap;margin-top:8px;}
        .meta-tag{font-size:11px;padding:2px 8px;border-radius:10px;font-weight:500;background:#f3f4f6;color:#374151;}
        .card-footer{display:flex;justify-content:space-between;align-items:center;margin-top:12px;padding-top:10px;border-top:1px solid #f3f4f6;}
        .card-info{font-size:11px;color:#9ca3af;}
        .btn-open{background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:8px;padding:7px 14px;font-size:12px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-block;}
        .btn-del-m{background:#fef2f2;color:#dc2626;border:none;border-radius:8px;padding:7px 10px;font-size:12px;font-weight:600;cursor:pointer;margin-left:4px;}
        .badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:10px;font-weight:600;}
        .badge-IT{background:#e8f0fe;color:#1a237e;}
        .badge-ENG{background:#e6f4ea;color:#1b5e20;}
        .badge-THM{background:#fff3e0;color:#e65100;}
        .badge-MGT{background:#fce4ec;color:#880e4f;}
        .badge-ACC{background:#f3e8fd;color:#4a148c;}
        .empty-state{text-align:center;padding:40px;color:#9ca3af;grid-column:1/-1;}
        .form-card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);position:sticky;top:20px;}
        .form-card h3{font-size:14px;font-weight:700;color:#1a1a2e;margin-bottom:14px;}
        .form-group{margin-bottom:12px;}
        .form-group label{display:block;font-size:12px;font-weight:500;color:#374151;margin-bottom:5px;}
        .form-group input,.form-group select,.form-group textarea{width:100%;padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;}
        .form-group input:focus,.form-group select:focus,.form-group textarea:focus{border-color:#1a237e;}
        .form-group textarea{resize:vertical;min-height:70px;}
        .hint{font-size:11px;color:#9ca3af;margin-top:3px;}
        .btn-upload{width:100%;background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:8px;padding:11px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
    </style>
    <script>
    function toggleUpload(){
        var t = document.getElementById('uploadType').value;
        document.getElementById('linkGroup').style.display =
            t==='link' ? 'block' : 'none';
        document.getElementById('fileGroup').style.display =
            t==='file' ? 'block' : 'none';
    }
    </script>
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
        <a href="lms.jsp"           class="nav-item active">&#128196; LMS Materials</a>
        <a href="notices.jsp"       class="nav-item">&#128276; Notice Board</a>
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
        <h1>&#128196; Learning Materials</h1>
        <p>Access notes, past papers, videos and study links</p>
    </div>

    <% if("added".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Material added!</div>
    <% } else if("deleted".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Material deleted!</div>
    <% } %>
    <% if(dbError != null && !dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <!-- Type tabs -->
    <div class="type-tabs">
        <a href="lms.jsp?dept=<%= filterDept %>&type=ALL&sem=<%= filterSem %>"
           class="type-tab <%= "ALL".equals(filterType)?"active":"" %>">
            &#128196; All
        </a>
        <a href="lms.jsp?dept=<%= filterDept %>&type=notes&sem=<%= filterSem %>"
           class="type-tab <%= "notes".equals(filterType)?"active":"" %>">
            &#128196; Notes
        </a>
        <a href="lms.jsp?dept=<%= filterDept %>&type=pastpaper&sem=<%= filterSem %>"
           class="type-tab <%= "pastpaper".equals(filterType)?"active":"" %>">
            &#128221; Past Papers
        </a>
        <a href="lms.jsp?dept=<%= filterDept %>&type=video&sem=<%= filterSem %>"
           class="type-tab <%= "video".equals(filterType)?"active":"" %>">
            &#127916; Videos
        </a>
        <a href="lms.jsp?dept=<%= filterDept %>&type=link&sem=<%= filterSem %>"
           class="type-tab <%= "link".equals(filterType)?"active":"" %>">
            &#128279; Links
        </a>
    </div>

    <div class="layout">
        <!-- Materials -->
        <div>
            <% if(!isStu){ %>
            <div class="filter-bar">
                <form method="get" action="lms.jsp"
                      style="display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap;width:100%;">
                    <input type="hidden" name="type" value="<%= filterType %>">
                    <div class="fg">
                        <label>Department</label>
                        <select name="dept">
                            <option value="ALL">All Departments</option>
                            <% for(HashMap<String,String> d : deptList){ %>
                            <option value="<%= d.get("dept_id") %>"
                                <%= d.get("dept_id").equals(filterDept)?"selected":"" %>>
                                <%= d.get("dept_code") %> — <%= d.get("dept_name") %>
                            </option>
                            <% } %>
                        </select>
                    </div>
                    <div class="fg">
                        <label>Semester</label>
                        <select name="sem">
                            <option value="ALL">All Semesters</option>
                            <% for(int s=1; s<=8; s++){ %>
                            <option value="<%= s %>"
                                <%= String.valueOf(s).equals(filterSem)?"selected":"" %>>
                                Semester <%= s %>
                            </option>
                            <% } %>
                        </select>
                    </div>
                    <button type="submit" class="btn-filter">Filter</button>
                    <a href="lms.jsp" class="btn-reset">Reset</a>
                </form>
            </div>
            <% } %>

            <div class="materials-grid">
                <% if(materials.isEmpty()){ %>
                <div class="empty-state">
                    <div style="font-size:40px;margin-bottom:10px;">&#128196;</div>
                    <h3 style="color:#6b7280;font-size:15px;margin-bottom:6px;">
                        No materials found
                    </h3>
                    <p style="font-size:13px;">
                        <% if(isAdmin||isLec){ %>
                        Add materials using the form on the right
                        <% } else { %>
                        No materials uploaded yet for your department
                        <% } %>
                    </p>
                </div>
                <% } else {
                    for(HashMap<String,String> m : materials){
                        String mtype = m.get("material_type");
                        String icon = "&#128196;";
                        String iconBg = "background:#e8f0fe;";
                        if("pastpaper".equals(mtype)){
                            icon="&#128221;"; iconBg="background:#fef2f2;";
                        } else if("video".equals(mtype)){
                            icon="&#127916;"; iconBg="background:#e6f4ea;";
                        } else if("link".equals(mtype)){
                            icon="&#128279;"; iconBg="background:#fff3e0;";
                        } else if("other".equals(mtype)){
                            icon="&#128230;"; iconBg="background:#f3e8fd;";
                        }
                        String dc = m.get("dept_code");
                        String linkUrl = m.get("link_url");
                        boolean isFile = linkUrl != null &&
                                         linkUrl.startsWith("uploads/");
                        String openUrl = isFile ?
                            request.getContextPath() + "/" + linkUrl :
                            linkUrl;
                %>
                <div class="material-card <%= mtype %>">
                    <div class="card-header">
                        <div class="type-icon" style="<%= iconBg %>">
                            <%= icon %>
                        </div>
                        <div>
                            <div class="card-title">
                                <%= m.get("title") %>
                            </div>
                            <% if(!m.get("description").isEmpty()){ %>
                            <div class="card-desc">
                                <%= m.get("description") %>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <div class="card-meta">
                        <% if(dc != null && !dc.isEmpty()){ %>
                        <span class="badge badge-<%= dc %>">
                            <%= dc %>
                        </span>
                        <% } %>
                        <% if(!"General".equals(m.get("subject_name"))){ %>
                        <span class="meta-tag">
                            <%= m.get("subject_name") %>
                        </span>
                        <% } %>
                        <% if(!m.get("semester").isEmpty()){ %>
                        <span class="meta-tag"
                              style="background:#e8f0fe;color:#1a237e;">
                            Sem <%= m.get("semester") %>
                        </span>
                        <% } %>
                        <span class="meta-tag"
                              style="background:#f3f4f6;color:#374151;">
                            <%= isFile ? "&#128196; PDF" : "&#128279; Link" %>
                        </span>
                    </div>
                    <div class="card-footer">
                        <div class="card-info">
                            &#128197; <%= m.get("created_at") %><br>
                            &#128100; <%= m.get("uploaded_by") %>
                        </div>
                        <div>
                            <a href="<%= openUrl %>"
                               target="_blank"
                               class="btn-open">
                                <%= isFile ?
                                    "&#128196; View PDF" :
                                    "&#128279; Open" %>
                            </a>
                            <% if(isAdmin||isLec){ %>
                            <button class="btn-del-m"
                                onclick="if(confirm('Delete?')){
                                    var f=document.createElement('form');
                                    f.method='post';
                                    f.action='LMSServlet';
                                    var a=document.createElement('input');
                                    a.name='action';a.value='delete';
                                    f.appendChild(a);
                                    var b=document.createElement('input');
                                    b.name='material_id';
                                    b.value='<%= m.get("material_id") %>';
                                    f.appendChild(b);
                                    document.body.appendChild(f);
                                    f.submit();}">
                                &#128465;
                            </button>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } } %>
            </div>
        </div>

        <!-- Upload form -->
        <% if(isAdmin||isLec){ %>
        <div>
            <div class="form-card">
                <h3>&#10133; Add Material</h3>
                <form action="LMSServlet" method="post"
                      enctype="multipart/form-data">
                    <input type="hidden" name="action" value="add">

                    <div class="form-group">
                        <label>Type *</label>
                        <select name="material_type" required>
                            <option value="notes">&#128196; Notes</option>
                            <option value="pastpaper">&#128221; Past Paper</option>
                            <option value="video">&#127916; Video</option>
                            <option value="link">&#128279; Link</option>
                            <option value="other">&#128230; Other</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Title *</label>
                        <input type="text" name="title"
                               placeholder="e.g. Database Notes Ch1"
                               required>
                    </div>

                    <div class="form-group">
                        <label>Description</label>
                        <textarea name="description"
                                  placeholder="Brief description (optional)">
                        </textarea>
                    </div>

                    <div class="form-group">
                        <label>Upload Method</label>
                        <select name="upload_type" id="uploadType"
                                onchange="toggleUpload()">
                            <option value="link">
                                &#128279; Paste Link
                            </option>
                            <option value="file">
                                &#128196; Upload PDF File
                            </option>
                        </select>
                    </div>

                    <div class="form-group" id="linkGroup">
                        <label>Link / URL</label>
                        <input type="text" name="link_url"
                               placeholder="https://drive.google.com/...">
                        <div class="hint">
                            Google Drive, YouTube or any web link
                        </div>
                    </div>

                    <div class="form-group" id="fileGroup"
                         style="display:none;">
                        <label>Upload PDF File</label>
                        <input type="file" name="pdf_file"
                               accept=".pdf,.doc,.docx,.ppt,.pptx">
                        <div class="hint">Max 10MB</div>
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
                        <label>Semester</label>
                        <select name="semester">
                            <option value="0">All Semesters</option>
                            <% for(int s=1; s<=8; s++){ %>
                            <option value="<%= s %>">
                                Semester <%= s %>
                            </option>
                            <% } %>
                        </select>
                    </div>

                    <input type="hidden" name="subject_id" value="0">

                    <button type="submit" class="btn-upload">
                        &#10003; Add Material
                    </button>
                </form>
            </div>
        </div>
        <% } %>
    </div>
</div>
    
    
</body>
</html>