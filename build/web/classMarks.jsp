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

    String selDept    = request.getParameter("dept");
    String selSem     = request.getParameter("sem");
    String selSubject = request.getParameter("subject");
    if(selDept    == null) selDept    = "";
    if(selSem     == null) selSem     = "1";
    if(selSubject == null) selSubject = "";

    // Lecturer restriction
    boolean isLec = RoleCheck.isLecturer(session);
    if(isLec && !RoleCheck.getDeptId(session).isEmpty()){
        selDept = RoleCheck.getDeptId(session);
    }

    ArrayList<HashMap<String,String>> deptList    = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> subjectList = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> studentList = new ArrayList<HashMap<String,String>>();
    String dbError = "";
    int maxSems = 4;
    int currentYear = java.util.Calendar.getInstance()
                          .get(java.util.Calendar.YEAR);

    try{
        Connection conn = DBConnection.getConnection();

        // Departments
        ResultSet drs = conn.createStatement().executeQuery(
            "SELECT * FROM departments ORDER BY dept_name");
        while(drs.next()){
            HashMap<String,String> d = new HashMap<String,String>();
            d.put("dept_id",         String.valueOf(drs.getInt("dept_id")));
            d.put("dept_code",       drs.getString("dept_code"));
            d.put("dept_name",       drs.getString("dept_name"));
            d.put("total_semesters", String.valueOf(drs.getInt("total_semesters")));
            deptList.add(d);
            if(d.get("dept_id").equals(selDept)){
                maxSems = drs.getInt("total_semesters");
            }
        }

        // Subjects for selected dept+sem
        if(!selDept.isEmpty()){
            PreparedStatement sps = conn.prepareStatement(
                "SELECT subject_id, subject_name FROM subjects " +
                "WHERE dept_id=? AND semester=? ORDER BY subject_name");
            sps.setInt(1, Integer.parseInt(selDept));
            sps.setInt(2, Integer.parseInt(selSem));
            ResultSet srs = sps.executeQuery();
            while(srs.next()){
                HashMap<String,String> row = new HashMap<String,String>();
                row.put("subject_id",   String.valueOf(srs.getInt("subject_id")));
                row.put("subject_name", srs.getString("subject_name"));
                subjectList.add(row);
            }
        }

        // Students with existing marks for selected subject
        if(!selDept.isEmpty() && !selSubject.isEmpty()){
            PreparedStatement stps = conn.prepareStatement(
                "SELECT s.student_id, s.reg_number, s.full_name, " +
                "s.year_level, m.grade " +
                "FROM students s " +
                "LEFT JOIN marks m ON s.student_id=m.student_id " +
                "AND m.subject_id=? AND m.exam_year=? " +
                "WHERE s.dept_id=? " +
                "ORDER BY s.year_level, s.full_name");
            stps.setInt(1, Integer.parseInt(selSubject));
            stps.setInt(2, currentYear);
            stps.setInt(3, Integer.parseInt(selDept));
            ResultSet strs = stps.executeQuery();
            while(strs.next()){
                HashMap<String,String> row = new HashMap<String,String>();
                row.put("student_id",  String.valueOf(strs.getInt("student_id")));
                row.put("reg_number",  strs.getString("reg_number"));
                row.put("full_name",   strs.getString("full_name"));
                row.put("year_level",  strs.getString("year_level"));
                row.put("grade",       strs.getString("grade") != null ?
                        strs.getString("grade") : "");
                studentList.add(row);
            }
        }
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Class Marks Entry</title>
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
        .nav-section{padding:12px;overflow-y:auto;max-height:calc(100vh - 100px);}
        .nav-section::-webkit-scrollbar{width:4px;}
        .nav-section::-webkit-scrollbar-thumb{background:rgba(255,255,255,0.2);border-radius:4px;}
        .sidebar-user{padding:16px 20px;border-top:1px solid rgba(255,255,255,0.1);color:rgba(255,255,255,0.8);font-size:12px;}
        .sidebar-user strong{display:block;color:white;font-size:13px;}
        .main{margin-left:240px;padding:28px;flex:1;}
        .page-header{margin-bottom:24px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:4px;}
        .alert-success{background:#e6f4ea;color:#1b5e20;border:1px solid #a8d5b5;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}
        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}

        .filter-card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);margin-bottom:20px;}
        .filter-card h3{font-size:14px;font-weight:600;color:#1a1a2e;margin-bottom:14px;}
        .filter-row{display:flex;gap:14px;align-items:flex-end;flex-wrap:wrap;}
        .fg{display:flex;flex-direction:column;gap:5px;min-width:180px;}
        .fg label{font-size:12px;font-weight:500;color:#374151;}
        .fg select{padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;}
        .fg select:focus{border-color:#1a237e;}
        .btn-load{background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:8px;padding:10px 20px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}

        .class-card{background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.06);overflow:hidden;}
        .class-header{padding:16px 20px;border-bottom:1px solid #f3f4f6;display:flex;justify-content:space-between;align-items:center;}
        .class-header h3{font-size:14px;font-weight:600;color:#1a1a2e;}
        .grade-scale{display:flex;gap:8px;flex-wrap:wrap;padding:10px 20px;background:#f8f9fa;border-bottom:1px solid #f3f4f6;}
        .gs{font-size:11px;padding:2px 8px;border-radius:10px;}
        .gA{color:#1b5e20;font-weight:700;} .gB{color:#1565c0;font-weight:700;}
        .gC{color:#e65100;font-weight:700;} .gE{color:#dc2626;font-weight:700;}

        table{width:100%;border-collapse:collapse;}
        thead th{background:#f8f9fa;padding:10px 16px;text-align:left;font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;}
        tbody tr{border-bottom:1px solid #f3f4f6;}
        tbody tr:hover{background:#f8f9ff;}
        tbody td{padding:10px 16px;font-size:13px;color:#1a1a2e;}

        .grade-sel{padding:7px 10px;border:1.5px solid #e5e7eb;border-radius:7px;font-size:13px;font-family:'Inter',sans-serif;outline:none;min-width:120px;}
        .grade-sel:focus{border-color:#1a237e;}

        .year-badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;background:#e8f5e9;color:#2e7d32;}
        .year2-badge{background:#fff8e1;color:#f57f17;}
        .year3-badge{background:#e3f2fd;color:#1565c0;}
        .year4-badge{background:#fce4ec;color:#880e4f;}

        .save-bar{padding:16px 20px;border-top:1px solid #f3f4f6;display:flex;gap:12px;}
        .btn-save{background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:10px;padding:12px 28px;font-size:14px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
        .btn-cancel{background:#f3f4f6;color:#374151;border:1px solid #e5e7eb;border-radius:10px;padding:12px 20px;font-size:13px;text-decoration:none;}
        .empty-msg{text-align:center;padding:48px;color:#9ca3af;font-size:13px;}
    </style>
    <script>
    function updateSems(){
        var sel  = document.getElementById('deptSel');
        var opt  = sel.options[sel.selectedIndex];
        var sems = parseInt(opt.getAttribute('data-sems')) || 4;
        var ss   = document.getElementById('semSel2');
        ss.innerHTML = '';
        for(var i=1;i<=sems;i++){
            ss.innerHTML += '<option value="'+i+'">Semester '+i+'</option>';
        }
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
        <a href="dashboard.jsp"     class="nav-item">&#9632; Dashboard</a>
        <a href="students.jsp"      class="nav-item">&#128101; Students</a>
        <a href="attendance.jsp"    class="nav-item">&#9989; Attendance</a>
        <a href="monthlyReport.jsp" class="nav-item">&#128197; Monthly Report</a>
        <a href="qrCode.jsp"        class="nav-item">&#9638; QR Codes</a>
        <a href="qrScan.jsp"        class="nav-item">&#128247; QR Scanner</a>
        <a href="marks.jsp"         class="nav-item active">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"      class="nav-item">&#128218; Subjects</a>
        <a href="lms.jsp"           class="nav-item">&#128196; LMS</a>
        <a href="notices.jsp"       class="nav-item">&#128276; Notices</a>
        <a href="chatbot.jsp"       class="nav-item">&#129302; Assistant</a>
        <a href="reports.jsp"       class="nav-item">&#128202; Reports</a>
        <a href="emailNotify.jsp"   class="nav-item">&#128231; Email Alerts</a>
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
        <h1>&#128203; Class Marks Entry</h1>
        <p>Enter marks for all students in a department and subject at once</p>
    </div>

    <% if("saved".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Class marks saved!</div>
    <% } %>
    <% if(dbError != null && !dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <!-- Filter -->
    <div class="filter-card">
        <h3>&#128203; Select Department, Semester and Subject</h3>
        <form method="get" action="classMarks.jsp">
        <div class="filter-row">
            <div class="fg">
                <label>Department</label>
                <select name="dept" id="deptSel" onchange="updateSems()">
                    <option value="">-- Select Department --</option>
                    <% for(HashMap<String,String> d : deptList){ %>
                    <option value="<%= d.get("dept_id") %>"
                            data-sems="<%= d.get("total_semesters") %>"
                            <%= d.get("dept_id").equals(selDept)?"selected":"" %>>
                        <%= d.get("dept_code") %> – <%= d.get("dept_name") %>
                    </option>
                    <% } %>
                </select>
            </div>
            <div class="fg">
                <label>Semester</label>
                <select name="sem" id="semSel2">
                    <% for(int i=1; i<=maxSems; i++){ %>
                    <option value="<%= i %>"
                        <%= String.valueOf(i).equals(selSem)?"selected":"" %>>
                        Semester <%= i %>
                    </option>
                    <% } %>
                </select>
            </div>
            <div class="fg">
                <label>Subject</label>
                <select name="subject">
                    <option value="">-- Select Subject --</option>
                    <% for(HashMap<String,String> sub : subjectList){ %>
                    <option value="<%= sub.get("subject_id") %>"
                        <%= sub.get("subject_id").equals(selSubject)?"selected":"" %>>
                        <%= sub.get("subject_name") %>
                    </option>
                    <% } %>
                </select>
            </div>
            <button type="submit" class="btn-load">
                &#128101; Load Students
            </button>
        </div>
        </form>
    </div>

    <!-- Students table -->
    <div class="class-card">
        <div class="class-header">
            <h3>
                <% if(!selSubject.isEmpty() && !studentList.isEmpty()){ %>
                Grade Entry — <%= studentList.size() %> Students
                <% } else { %>
                Select dept, semester and subject above then click Load Students
                <% } %>
            </h3>
        </div>

        <div class="grade-scale">
            <span class="gs gA" style="background:#e6f4ea;">A+/A=4.0</span>
            <span class="gs gA" style="background:#f1f8e9;">A-=3.7</span>
            <span class="gs gB" style="background:#e8f0fe;">B+=3.3</span>
            <span class="gs gB" style="background:#e8f4fe;">B=3.0</span>
            <span class="gs gB" style="background:#e3f2fd;">B-=2.7</span>
            <span class="gs gC" style="background:#fff3e0;">C+=2.3</span>
            <span class="gs gC" style="background:#fff8e1;">C=2.0</span>
            <span class="gs gC" style="background:#fffde7;">C-=1.7</span>
            <span class="gs gE" style="background:#fef2f2;">E=Fail</span>
            <span class="gs" style="background:#f3f4f6;color:#9ca3af;">I(SE)=Skip</span>
        </div>

        <% if(selSubject.isEmpty() || studentList.isEmpty()){ %>
        <div class="empty-msg">
            <% if(selDept.isEmpty()){ %>
                Select a department, semester and subject above
            <% } else if(subjectList.isEmpty()){ %>
                No subjects found for Semester <%= selSem %> in this department.
                <a href="subjects.jsp" style="color:#1a237e;">Add subjects first</a>
            <% } else if(selSubject.isEmpty()){ %>
                Select a subject then click Load Students
            <% } else { %>
                No students found in this department
            <% } %>
        </div>
        <% } else { %>
        <form action="SaveClassMarksServlet" method="post">
            <input type="hidden" name="dept_id"    value="<%= selDept %>">
            <input type="hidden" name="semester"   value="<%= selSem %>">
            <input type="hidden" name="subject_id" value="<%= selSubject %>">
            <input type="hidden" name="exam_year"  value="<%= currentYear %>">

            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Reg Number</th>
                        <th>Full Name</th>
                        <th>Year</th>
                        <th>Grade</th>
                    </tr>
                </thead>
                <tbody>
                <% for(int i=0; i<studentList.size(); i++){
                    HashMap<String,String> s = studentList.get(i);
                    String yr = s.get("year_level");
                    String yrBadge = "First Year".equals(yr) ? "year-badge" :
                                     "Second Year".equals(yr) ? "year2-badge" :
                                     "Third Year".equals(yr)  ? "year3-badge" : "year4-badge";
                    String curGrade = s.get("grade");
                %>
                <tr>
                    <td style="color:#9ca3af;"><%= (i+1) %></td>
                    <td style="font-weight:600;color:#1a237e;">
                        <input type="hidden" name="student_id"
                               value="<%= s.get("student_id") %>">
                        <%= s.get("reg_number") %>
                    </td>
                    <td><strong><%= s.get("full_name") %></strong></td>
                    <td>
                        <span class="<%= yrBadge %>">
                            <%= yr %>
                        </span>
                    </td>
                    <td>
                        <select name="grade" class="grade-sel">
                            <option value="">— Select —</option>
                            <option value="A+"  <%= "A+".equals(curGrade)?"selected":"" %>>A+</option>
                            <option value="A"   <%= "A".equals(curGrade)?"selected":"" %>>A</option>
                            <option value="A-"  <%= "A-".equals(curGrade)?"selected":"" %>>A-</option>
                            <option value="B+"  <%= "B+".equals(curGrade)?"selected":"" %>>B+</option>
                            <option value="B"   <%= "B".equals(curGrade)?"selected":"" %>>B</option>
                            <option value="B-"  <%= "B-".equals(curGrade)?"selected":"" %>>B-</option>
                            <option value="C+"  <%= "C+".equals(curGrade)?"selected":"" %>>C+</option>
                            <option value="C"   <%= "C".equals(curGrade)?"selected":"" %>>C</option>
                            <option value="C-"  <%= "C-".equals(curGrade)?"selected":"" %>>C-</option>
                            <option value="E"   <%= "E".equals(curGrade)?"selected":"" %>>E (Fail)</option>
                            <option value="NE"  <%= "NE".equals(curGrade)?"selected":"" %>>NE</option>
                            <option value="AB"  <%= "AB".equals(curGrade)?"selected":"" %>>AB</option>
                            <option value="DFR" <%= "DFR".equals(curGrade)?"selected":"" %>>DFR</option>
                            <option value="I(SE)"<%= "I(SE)".equals(curGrade)?"selected":"" %>>I(SE)</option>
                        </select>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>

            <div class="save-bar">
                <button type="submit" class="btn-save">
                    &#10003; Save All Grades
                </button>
                <a href="marks.jsp" class="btn-cancel">Cancel</a>
            </div>
        </form>
        <% } %>
    </div>
</div>
</body>
</html>