<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.LinkedHashMap" %>
<%
    if(session.getAttribute("loggedUser") == null){
        response.sendRedirect("login.jsp"); return;
    }

    String filterDept = request.getParameter("dept");
    if(filterDept == null) filterDept = "1";

    // Load departments
    ArrayList<HashMap<String,String>> deptList = new ArrayList<HashMap<String,String>>();

    // Subjects grouped by semester
    LinkedHashMap<Integer, ArrayList<HashMap<String,String>>> semMap =
        new LinkedHashMap<Integer, ArrayList<HashMap<String,String>>>();

    String deptName   = "";
    int totalSemInt   = 4;
    String dbError    = "";

    try{
        Connection conn = DBConnection.getConnection();

        // Load departments
        ResultSet drs = conn.createStatement().executeQuery(
            "SELECT * FROM departments ORDER BY dept_name");
        while(drs.next()){
            HashMap<String,String> d = new HashMap<String,String>();
            d.put("dept_id",         String.valueOf(drs.getInt("dept_id")));
            d.put("dept_code",       drs.getString("dept_code"));
            d.put("dept_name",       drs.getString("dept_name"));
            d.put("total_semesters", String.valueOf(drs.getInt("total_semesters")));
            d.put("duration_years",  String.valueOf(drs.getInt("duration_years")));
            deptList.add(d);
            if(String.valueOf(drs.getInt("dept_id")).equals(filterDept)){
                deptName   = drs.getString("dept_name");
                totalSemInt = drs.getInt("total_semesters");
            }
        }

        // Load subjects for selected dept
        PreparedStatement ps = conn.prepareStatement(
            "SELECT * FROM subjects WHERE dept_id=? ORDER BY semester, subject_name");
        ps.setInt(1, Integer.parseInt(filterDept));
        ResultSet rs = ps.executeQuery();

        while(rs.next()){
            int sem = rs.getInt("semester");
            if(!semMap.containsKey(sem)){
                semMap.put(sem, new ArrayList<HashMap<String,String>>());
            }
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("subject_id",   String.valueOf(rs.getInt("subject_id")));
            row.put("subject_name", rs.getString("subject_name"));
            row.put("credit_hours", String.valueOf(rs.getInt("credit_hours")));
            row.put("semester",     String.valueOf(sem));
            semMap.get(sem).add(row);
        }
        conn.close();

    } catch(Exception e){ dbError = e.getMessage(); }

    // Helper: get year label from semester
    // Sem 1,2 = First Year | Sem 3,4 = Second Year | Sem 5,6 = Third Year | Sem 7,8 = Fourth Year
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Subject Manager</title>
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
        .page-header{margin-bottom:20px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:4px;}
        .alert-success{background:#e6f4ea;color:#1b5e20;border:1px solid #a8d5b5;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}
        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}

        /* Dept tabs */
        .dept-tabs{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:20px;}
        .dept-tab{padding:8px 14px;border-radius:8px;font-size:12px;font-weight:500;text-decoration:none;border:1.5px solid #e5e7eb;color:#374151;background:white;transition:all 0.15s;}
        .dept-tab:hover{border-color:#1a237e;color:#1a237e;}
        .dept-tab.active{background:#1a237e;color:white;border-color:#1a237e;}

        .layout{display:grid;grid-template-columns:1fr 300px;gap:24px;align-items:start;}

        /* Year group */
        .year-group{margin-bottom:20px;}
        .year-label{
            font-size:13px;font-weight:700;color:white;
            background:linear-gradient(135deg,#1a237e,#1565c0);
            padding:10px 16px;border-radius:10px 10px 0 0;
            display:flex;align-items:center;gap:8px;
        }

        /* Semester card */
        .sem-card{background:white;border-radius:0 0 10px 10px;
            box-shadow:0 2px 8px rgba(0,0,0,0.06);margin-bottom:4px;overflow:hidden;}
        .sem-card:not(:last-child){border-radius:0;margin-bottom:1px;}
        .sem-header{
            padding:11px 16px;background:#f8f9fa;
            border-bottom:1px solid #f0f0f0;
            display:flex;justify-content:space-between;align-items:center;
        }
        .sem-header h3{font-size:13px;font-weight:600;color:#374151;}
        .sem-header .sem-badge{
            font-size:11px;background:#e8f0fe;color:#1a237e;
            padding:2px 8px;border-radius:12px;font-weight:600;
        }
        .sem-header small{font-size:11px;color:#9ca3af;}

        .subject-row{
            display:flex;align-items:center;padding:10px 16px;
            border-bottom:1px solid #f9fafb;gap:10px;
        }
        .subject-row:last-child{border-bottom:none;}
        .subject-row:hover{background:#f8f9ff;}
        .subj-num{font-size:12px;color:#9ca3af;width:20px;}
        .subj-name{flex:1;font-size:13px;color:#1a1a2e;font-weight:500;}
        .subj-credit{
            font-size:11px;color:#9ca3af;
            background:#f3f4f6;padding:2px 8px;border-radius:12px;
        }
        .btn-edit-s{
            background:#e8f0fe;color:#1a237e;border:none;border-radius:5px;
            padding:4px 10px;font-size:11px;font-weight:600;cursor:pointer;
            text-decoration:none;white-space:nowrap;
        }
        .btn-del-s{
            background:#fef2f2;color:#dc2626;border:none;border-radius:5px;
            padding:4px 10px;font-size:11px;font-weight:600;cursor:pointer;
            white-space:nowrap;margin-left:4px;
        }
        .btn-edit-s:hover{background:#c7d9ff;}
        .btn-del-s:hover{background:#fecaca;}
        .no-subjects{
            padding:18px 16px;font-size:12px;color:#9ca3af;
            font-style:italic;
        }

        /* Add/Edit form */
        .form-card{
            background:white;border-radius:12px;padding:20px;
            box-shadow:0 1px 4px rgba(0,0,0,0.06);
            position:sticky;top:20px;
        }
        .form-card h3{font-size:14px;font-weight:600;color:#1a1a2e;margin-bottom:16px;}
        .form-group{margin-bottom:13px;}
        .form-group label{display:block;font-size:12px;font-weight:500;color:#374151;margin-bottom:5px;}
        .form-group input,
        .form-group select{
            width:100%;padding:9px 12px;border:1.5px solid #e5e7eb;
            border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;
        }
        .form-group input:focus,
        .form-group select:focus{border-color:#1a237e;}

        /* Year hint below semester */
        .sem-year-hint{
            font-size:11px;color:#9ca3af;margin-top:3px;
        }

        .btn-save-s{
            width:100%;background:linear-gradient(135deg,#1a237e,#1565c0);
            color:white;border:none;border-radius:8px;padding:10px;
            font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;
        }
        .btn-save-s:hover{opacity:0.9;}
        .btn-reset-s{
            width:100%;background:#f3f4f6;color:#374151;
            border:1px solid #e5e7eb;border-radius:8px;padding:9px;
            font-size:13px;cursor:pointer;font-family:'Inter',sans-serif;
            margin-top:8px;
        }
        .divider{border:none;border-top:1px solid #f3f4f6;margin:14px 0;}

        .dept-info{
            background:#e8f0fe;border-radius:8px;padding:10px 14px;
            font-size:12px;color:#1a237e;margin-bottom:16px;
        }
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
        <a href="dashboard.jsp"  class="nav-item">&#9632; Dashboard</a>
        <a href="students.jsp"   class="nav-item">&#128101; Students</a>
        <a href="attendance.jsp" class="nav-item">&#9989; Attendance</a>
        <a href="monthlyReport.jsp" class="nav-item">
    &#128197; Monthly Report
</a>
        <a href="qrCode.jsp"     class="nav-item">&#9638; QR Codes</a>
        <a href="qrScan.jsp"     class="nav-item">&#128247; QR Scanner</a>
        <a href="marks.jsp"      class="nav-item">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"   class="nav-item active">&#128218; Subjects</a>
        <a href="reports.jsp"    class="nav-item">&#128202; Reports</a>
        <a href="lms.jsp" class="nav-item">&#128196; LMS Materials</a>
       <a href="emailNotify.jsp" class="nav-item">&#128231; Email Alerts</a>
        <a href="notices.jsp" class="nav-item">&#128276; Notice Board</a>
        <div class="nav-label">Account</div>
        <a href="chatbot.jsp" class="nav-item">&#129302; Assistant</a>
        <a href="LogoutServlet"  class="nav-item">&#128682; Logout</a>
    </div>
    <div class="sidebar-user">
        <strong><%= session.getAttribute("loggedUser") %></strong>
        <%= session.getAttribute("userRole") %>
    </div>
</div>

<div class="main">
    <div class="page-header">
        <h1>&#128218; Subject Manager</h1>
        <p>Add and manage subjects for each department, year and semester</p>
    </div>

    <% if("added".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Subject added successfully!</div>
    <% } else if("updated".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Subject updated successfully!</div>
    <% } else if("deleted".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Subject deleted!</div>
    <% } %>
    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; Error: <%= dbError %></div>
    <% } %>

    <!-- Department tabs -->
    <div class="dept-tabs">
        <% for(HashMap<String,String> d : deptList){ %>
        <a href="subjects.jsp?dept=<%= d.get("dept_id") %>"
           class="dept-tab <%= d.get("dept_id").equals(filterDept)?"active":"" %>">
            <%= d.get("dept_code") %>
        </a>
        <% } %>
    </div>

    <div class="layout">
        <!-- LEFT: Subjects list grouped by Year → Semester -->
        <div>
            <%
            // Group semesters by year: sem 1-2 = yr1, 3-4 = yr2, 5-6 = yr3, 7-8 = yr4
            String[] yearNames = {"First Year","Second Year","Third Year","Fourth Year"};
            for(int yr = 1; yr <= (totalSemInt/2); yr++){
                int sem1 = (yr-1)*2 + 1;
                int sem2 = yr * 2;
            %>
            <div class="year-group">
                <div class="year-label">
                    &#127979; <%= yearNames[yr-1] %>
                    <span style="font-size:11px;opacity:0.8;margin-left:4px;">
                        (Semester <%= sem1 %> &amp; <%= sem2 %>)
                    </span>
                </div>

                <% for(int s = sem1; s <= sem2; s++){
                    ArrayList<HashMap<String,String>> subjList = semMap.get(s);
                    int semInYear = (s % 2 == 0) ? 2 : 1;
                %>
                <div class="sem-card">
                    <div class="sem-header">
                        <h3>Semester <%= s %></h3>
                        <span class="sem-badge">
                            <%= yearNames[yr-1] %> — Semester <%= semInYear %>
                        </span>
                        <small>
                            <%= (subjList != null ? subjList.size() : 0) %> subject(s)
                        </small>
                    </div>

                    <% if(subjList == null || subjList.isEmpty()){ %>
                    <div class="no-subjects">
                        No subjects yet — add using the form on the right
                    </div>
                    <% } else {
                        for(int idx=0; idx<subjList.size(); idx++){
                            HashMap<String,String> sub = subjList.get(idx);
                            String safeName = sub.get("subject_name").replace("'","\\'").replace("\"","&quot;");
                    %>
                    <div class="subject-row">
                        <span class="subj-num"><%= (idx+1) %></span>
                        <span class="subj-name"><%= sub.get("subject_name") %></span>
                        <span class="subj-credit"><%= sub.get("credit_hours") %> cr</span>
                        <a href="javascript:void(0)"
                           onclick="fillEdit('<%= sub.get("subject_id") %>',
                                            '<%= filterDept %>',
                                            '<%= sub.get("semester") %>',
                                            '<%= safeName %>',
                                            '<%= sub.get("credit_hours") %>')"
                           class="btn-edit-s">&#9998; Edit</a>
                        <button class="btn-del-s"
                            onclick="if(confirm('Delete subject: <%= safeName %>?')){
                                document.getElementById('del_sid').value='<%= sub.get("subject_id") %>';
                                document.getElementById('deleteForm').submit();}">
                            &#128465; Del
                        </button>
                    </div>
                    <% } } %>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>

        <!-- RIGHT: Add / Edit form -->
        <div>
            <div class="form-card">
                <h3 id="formTitle">&#10133; Add Subject</h3>

                <%
                // Get current dept info for the form
                String curDeptCode = "";
                int curTotalSems = 4;
                for(HashMap<String,String> d : deptList){
                    if(d.get("dept_id").equals(filterDept)){
                        curDeptCode = d.get("dept_code");
                        curTotalSems = Integer.parseInt(d.get("total_semesters"));
                    }
                }
                %>

                <div class="dept-info">
                    &#127979; Currently adding to: <strong><%= curDeptCode %> — <%= deptName %></strong>
                </div>

                <form action="SubjectServlet" method="post" id="subjectForm">
                    <input type="hidden" name="action"     id="formAction"    value="add">
                    <input type="hidden" name="subject_id" id="editSubjectId" value="">

                    <div class="form-group">
                        <label>Department</label>
                        <select name="dept_id" id="formDept" onchange="updateFormSems()">
                            <% for(HashMap<String,String> d : deptList){ %>
                            <option value="<%= d.get("dept_id") %>"
                                    data-sems="<%= d.get("total_semesters") %>"
                                    data-name="<%= d.get("dept_name") %>"
                                    data-code="<%= d.get("dept_code") %>"
                                    <%= d.get("dept_id").equals(filterDept)?"selected":"" %>>
                                <%= d.get("dept_code") %> – <%= d.get("dept_name") %>
                            </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Semester</label>
                        <select name="semester" id="formSemester" onchange="showYearHint()">
                            <% for(int s=1; s<=curTotalSems; s++){
                                int yr = (s%2==0) ? s/2 : (s+1)/2;
                                int semInYr = (s%2==0) ? 2 : 1;
                                String label = yearNames[yr-1] + " — Semester " + semInYr;
                            %>
                            <option value="<%= s %>">Sem <%= s %> → <%= label %></option>
                            <% } %>
                        </select>
                        <div class="sem-year-hint" id="yearHint"></div>
                    </div>

                    <div class="form-group">
                        <label>Subject Name</label>
                        <input type="text" name="subject_name" id="formSubjectName"
                               placeholder="e.g. Advanced Programming" required>
                    </div>

                    <div class="form-group">
                        <label>Credit Hours</label>
                        <select name="credit_hours" id="formCredits">
                            <option value="1">1 Credit</option>
                            <option value="2">2 Credits</option>
                            <option value="3" selected>3 Credits</option>
                            <option value="4">4 Credits</option>
                            <option value="5">5 Credits</option>
                            <option value="6">6 Credits</option>
                        </select>
                    </div>

                    <button type="submit" class="btn-save-s" id="formBtn">
                        &#10003; Add Subject
                    </button>
                </form>

                <hr class="divider">

                <button onclick="resetForm()" class="btn-reset-s">
                    &#8635; Reset Form
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Hidden delete form -->
<form id="deleteForm" action="SubjectServlet" method="post" style="display:none;">
    <input type="hidden" name="action"     value="delete">
    <input type="hidden" name="subject_id" id="del_sid" value="">
</form>

<script>
var yearNames = ["First Year","Second Year","Third Year","Fourth Year"];

function fillEdit(id, deptId, sem, name, credits){
    document.getElementById('formTitle').innerHTML        = '&#9998; Edit Subject';
    document.getElementById('formAction').value           = 'edit';
    document.getElementById('editSubjectId').value        = id;
    document.getElementById('formDept').value             = deptId;
    document.getElementById('formSemester').value         = sem;
    document.getElementById('formSubjectName').value      = name;
    document.getElementById('formCredits').value          = credits;
    document.getElementById('formBtn').textContent        = '✓ Update Subject';
    showYearHint();
    document.querySelector('.form-card').scrollIntoView({behavior:'smooth'});
}

function resetForm(){
    document.getElementById('formTitle').innerHTML        = '&#10133; Add Subject';
    document.getElementById('formAction').value           = 'add';
    document.getElementById('editSubjectId').value        = '';
    document.getElementById('formSubjectName').value      = '';
    document.getElementById('formBtn').textContent        = '✓ Add Subject';
    showYearHint();
}

function updateFormSems(){
    var sel     = document.getElementById('formDept');
    var opt     = sel.options[sel.selectedIndex];
    var sems    = parseInt(opt.getAttribute('data-sems')) || 4;
    var semSel  = document.getElementById('formSemester');
    semSel.innerHTML = '';
    for(var i=1; i<=sems; i++){
        var yr      = Math.ceil(i/2);
        var semInYr = (i%2===0) ? 2 : 1;
        var lbl     = yearNames[yr-1] + ' — Semester ' + semInYr;
        semSel.innerHTML += '<option value="'+i+'">Sem '+i+' → '+lbl+'</option>';
    }
    showYearHint();
}

function showYearHint(){
    var sem     = parseInt(document.getElementById('formSemester').value);
    var yr      = Math.ceil(sem/2);
    var semInYr = (sem%2===0) ? 2 : 1;
    var hint    = document.getElementById('yearHint');
    if(hint) hint.textContent = '→ ' + yearNames[yr-1] + ', Semester ' + semInYr;
}

showYearHint();
</script>

</body>
</html>