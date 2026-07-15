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
    boolean isAdmin = RoleCheck.isAdmin(session);
    boolean isLec   = RoleCheck.isLecturer(session);

    String selDept = request.getParameter("dept");
    String selSem  = request.getParameter("sem");
    if(selDept == null) selDept = "";
    if(selSem  == null) selSem  = "";
    if(isLec && !RoleCheck.getDeptId(session).isEmpty())
        selDept = RoleCheck.getDeptId(session);

    ArrayList<HashMap<String,String>> deptList    = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> subjectCols = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> studentRows = new ArrayList<HashMap<String,String>>();
    String deptName="", deptCode="", courseTitle="";
    int totalSems=4;
    String dbError="";
    int examYear = java.util.Calendar.getInstance()
                       .get(java.util.Calendar.YEAR);
    String[] yearNames={"First Year","Second Year","Third Year","Fourth Year"};

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
            if(d.get("dept_id").equals(selDept)){
                deptName  = drs.getString("dept_name");
                deptCode  = drs.getString("dept_code");
                totalSems = drs.getInt("total_semesters");
            }
        }
        if(!selDept.isEmpty() && !selSem.isEmpty()){
            PreparedStatement sps = conn.prepareStatement(
                "SELECT * FROM subjects WHERE dept_id=? AND semester=? ORDER BY subject_name");
            sps.setInt(1,Integer.parseInt(selDept));
            sps.setInt(2,Integer.parseInt(selSem));
            ResultSet srs=sps.executeQuery();
            while(srs.next()){
                HashMap<String,String> sub=new HashMap<String,String>();
                sub.put("subject_id",   String.valueOf(srs.getInt("subject_id")));
                sub.put("subject_name", srs.getString("subject_name"));
                sub.put("credit_hours", String.valueOf(srs.getInt("credit_hours")));
                subjectCols.add(sub);
            }
            PreparedStatement stps=conn.prepareStatement(
                "SELECT student_id,reg_number,full_name FROM students WHERE dept_id=? ORDER BY full_name");
            stps.setInt(1,Integer.parseInt(selDept));
            ResultSet strs=stps.executeQuery();
            while(strs.next()){
                HashMap<String,String> row=new HashMap<String,String>();
                row.put("student_id",String.valueOf(strs.getInt("student_id")));
                row.put("reg_number",strs.getString("reg_number"));
                row.put("full_name", strs.getString("full_name"));
                double totalGPA=0; int counted=0;
                for(HashMap<String,String> sub : subjectCols){
                    PreparedStatement gps=conn.prepareStatement(
                        "SELECT grade,gpa_points FROM marks WHERE student_id=? AND subject_id=? AND exam_year=?");
                    gps.setInt(1,strs.getInt("student_id"));
                    gps.setInt(2,Integer.parseInt(sub.get("subject_id")));
                    gps.setInt(3,examYear);
                    ResultSet grs=gps.executeQuery();
                    String grade="—"; double pts=-1;
                    if(grs.next()){
                        grade=grs.getString("grade")!=null?grs.getString("grade"):"—";
                        pts=grs.getDouble("gpa_points");
                    }
                    row.put("grade_"+sub.get("subject_id"),grade);
                    if(pts>=0){totalGPA+=pts;counted++;}
                }
                double sgpa=counted>0?totalGPA/counted:0.0;
                row.put("sgpa",    String.format("%.2f",sgpa));
                row.put("counted", String.valueOf(counted));
                studentRows.add(row);
            }
        }
        conn.close();
    }catch(Exception e){ dbError=e.getMessage(); }

    int semInt  = selSem.isEmpty()?1:Integer.parseInt(selSem);
    int yearNum = (int)Math.ceil((double)semInt/2);
    int semInYr = (semInt%2==0)?2:1;
    String yearLabel=(yearNum>=1&&yearNum<=4)?yearNames[yearNum-1]:"";
    if("IT".equals(deptCode))       courseTitle="Higher National Diploma in Information Technology";
    else if("ENG".equals(deptCode)) courseTitle="Higher National Diploma in English";
    else if("THM".equals(deptCode)) courseTitle="Higher National Diploma in Tourism & Hospitality Management";
    else if("MGT".equals(deptCode)) courseTitle="Higher National Diploma in Management";
    else if("ACC".equals(deptCode)) courseTitle="Higher National Diploma in Accountancy";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>SMS – Result Sheet</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
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
.main{margin-left:240px;padding:24px;flex:1;}
.page-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;}
.page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
.page-header p{font-size:13px;color:#6b7280;margin-top:3px;}
.btn-row{display:flex;gap:8px;}
.btn-primary{background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:8px;padding:10px 18px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-block;}
.btn-green{background:linear-gradient(135deg,#1b5e20,#2e7d32);color:white;border:none;border-radius:8px;padding:10px 18px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-block;}
.btn-gray{background:#6b7280;color:white;border:none;border-radius:8px;padding:10px 16px;font-size:13px;font-weight:600;cursor:pointer;}
.alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}

/* Filter */
.filter-card{background:white;border-radius:12px;padding:16px 20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);margin-bottom:20px;display:flex;gap:14px;align-items:flex-end;flex-wrap:wrap;}
.fg{display:flex;flex-direction:column;gap:5px;}
.fg label{font-size:12px;font-weight:500;color:#374151;}
.fg select{padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;min-width:180px;}
.fg select:focus{border-color:#1a237e;}
.btn-filter{background:#1a237e;color:white;border:none;border-radius:8px;padding:10px 20px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}

/* Result Sheet */
.sheet-wrapper{background:white;border-radius:16px;box-shadow:0 1px 4px rgba(0,0,0,0.06);overflow:hidden;}

/* Blue gradient header */
.sheet-header{
    background:linear-gradient(135deg,#1a237e 0%,#1565c0 100%);
    padding:28px 32px;text-align:center;
}
.sheet-header .institute{font-size:14px;font-weight:700;color:white;letter-spacing:0.5px;text-transform:uppercase;}
.sheet-header .campus{font-size:12px;color:rgba(255,255,255,0.8);margin-top:3px;}
.sheet-header .result-label{
    display:inline-block;
    background:rgba(255,255,255,0.15);
    color:white;font-size:11px;font-weight:600;
    letter-spacing:2px;text-transform:uppercase;
    padding:4px 16px;border-radius:20px;margin:12px 0 8px;
}
.sheet-header .exam-title{font-size:18px;font-weight:800;color:white;margin-bottom:4px;}
.sheet-header .course-name{font-size:13px;color:rgba(255,255,255,0.85);}

/* Info strips */
.info-strip{
    display:flex;justify-content:space-between;
    padding:10px 24px;background:#f8f9fa;
    border-bottom:1px solid #e5e7eb;
    font-size:12px;color:#374151;flex-wrap:wrap;gap:8px;
}
.info-strip .info-item{display:flex;gap:6px;}
.info-strip .info-label{color:#9ca3af;font-weight:500;}
.info-strip .info-val{font-weight:700;color:#1a237e;}

/* Students cards layout */
.students-section{padding:20px 24px;}
.section-title{
    font-size:13px;font-weight:600;color:#374151;
    margin-bottom:14px;display:flex;align-items:center;gap:8px;
}

/* Each student as a card */
.student-result-card{
    background:#f8f9ff;border-radius:12px;
    border:1px solid #e8f0fe;margin-bottom:12px;
    overflow:hidden;
}
.student-result-header{
    display:flex;align-items:center;gap:14px;
    padding:12px 18px;background:white;
    border-bottom:1px solid #e8f0fe;
}
.stu-num{
    width:28px;height:28px;border-radius:50%;
    background:#e8f0fe;color:#1a237e;
    font-size:11px;font-weight:700;
    display:flex;align-items:center;justify-content:center;
    flex-shrink:0;
}
.stu-name{font-size:14px;font-weight:700;color:#1a1a2e;flex:1;}
.stu-reg{font-size:12px;color:#1a237e;font-weight:600;background:#e8f0fe;padding:3px 10px;border-radius:10px;}
.sgpa-pill{
    padding:5px 14px;border-radius:20px;font-size:13px;font-weight:700;
    min-width:70px;text-align:center;margin-left:8px;
}
.sgpa-high{background:#e6f4ea;color:#1b5e20;}
.sgpa-mid{background:#e8f0fe;color:#1565c0;}
.sgpa-low{background:#fef2f2;color:#dc2626;}

/* Subject grades grid */
.grades-grid{
    display:grid;padding:14px 18px;gap:8px;
    grid-template-columns:repeat(auto-fill,minmax(180px,1fr));
}
.grade-item{
    display:flex;align-items:center;gap:10px;
    background:white;border-radius:8px;padding:8px 12px;
    border:1px solid #e5e7eb;
}
.grade-item .sub-name{font-size:12px;color:#374151;flex:1;line-height:1.3;}
.grade-chip{
    font-size:13px;font-weight:700;
    padding:3px 10px;border-radius:8px;
    flex-shrink:0;min-width:40px;text-align:center;
}
.gAp,.gA{background:#e6f4ea;color:#1b5e20;}
.gAm{background:#f1f8e9;color:#388e3c;}
.gBp{background:#e3f2fd;color:#1565c0;}
.gB{background:#e8f0fe;color:#1976d2;}
.gBm{background:#ede7f6;color:#5c6bc0;}
.gCp{background:#fff3e0;color:#e65100;}
.gC{background:#fff8e1;color:#ef6c00;}
.gCm{background:#fffde7;color:#f9a825;}
.gE{background:#fef2f2;color:#dc2626;}
.gNE,.gAB{background:#fce4ec;color:#880e4f;}
.gDFR{background:#f3e8fd;color:#6b21a8;}
.gISE,.gDash{background:#f3f4f6;color:#9ca3af;}
.gLate{background:#fff3e0;color:#e65100;}

/* Credit hour label */
.credit-dot{
    width:18px;height:18px;border-radius:50%;background:#f3f4f6;
    font-size:9px;color:#9ca3af;display:flex;align-items:center;
    justify-content:center;flex-shrink:0;font-weight:600;
}

/* Legend + footer */
.sheet-footer{
    padding:16px 24px;border-top:1px solid #e5e7eb;
    display:flex;justify-content:space-between;
    align-items:flex-start;flex-wrap:wrap;gap:12px;
    background:#f8f9fa;
}
.legend-title{font-size:11px;font-weight:600;color:#374151;margin-bottom:6px;}
.legend-grid{display:flex;gap:8px;flex-wrap:wrap;}
.legend-item{font-size:11px;padding:2px 8px;border-radius:6px;}

/* Signature row */
.sig-row{
    display:flex;justify-content:space-between;
    padding:24px 32px 16px;flex-wrap:wrap;gap:16px;
}
.sig-item{text-align:center;}
.sig-line{border-top:1px solid #374151;width:130px;margin:24px auto 5px;}
.sig-label{font-size:11px;color:#6b7280;}

.empty-state{text-align:center;padding:60px;color:#9ca3af;}

/* Summary stats */
.stats-row{
    display:grid;grid-template-columns:repeat(4,1fr);gap:12px;
    padding:16px 24px;border-bottom:1px solid #e5e7eb;
}
.stat-item{text-align:center;}
.stat-item .sv{font-size:20px;font-weight:700;}
.stat-item .sl{font-size:11px;color:#6b7280;margin-top:2px;}

@media print{
    .sidebar,.filter-card,.page-header .btn-row{display:none!important;}
    .main{margin-left:0;padding:4px;}
    .sheet-wrapper{box-shadow:none;}
}
</style>
<script>
function updateSems(){
    var sel=document.getElementById('deptSel');
    var opt=sel.options[sel.selectedIndex];
    var sems=parseInt(opt.getAttribute('data-sems'))||4;
    var ss=document.getElementById('semSel');
    ss.innerHTML='<option value="">-- Select --</option>';
    var yn=["First Year","Second Year","Third Year","Fourth Year"];
    for(var i=1;i<=sems;i++){
        var yr=Math.ceil(i/2); var si=(i%2===0)?2:1;
        ss.innerHTML+='<option value="'+i+'">'+yn[yr-1]+' — Sem '+si+'</option>';
    }
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
        <a href="marks.jsp"         class="nav-item active">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"      class="nav-item">&#128218; Subjects</a>
        <a href="lms.jsp"           class="nav-item">&#128196; LMS</a>
        <a href="notices.jsp"       class="nav-item">&#128276; Notices</a>
        <a href="chatbot.jsp"       class="nav-item">&#129302; Assistant</a>
        <a href="reports.jsp"       class="nav-item">&#128202; Reports</a>
        <a href="emailNotify.jsp"   class="nav-item">&#128231; Email Alerts</a>
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
        <div>
            <h1>&#128196; Result Sheet</h1>
            <p>SLIATE Badulla — Examination Results</p>
        </div>
        <div class="btn-row">
            <a href="addMarks.jsp"   class="btn-primary">&#10133; Enter Marks</a>
            <a href="classMarks.jsp" class="btn-green">&#128203; Class Entry</a>
            <% if(!selDept.isEmpty()&&!selSem.isEmpty()){ %>
            <button onclick="window.print()" class="btn-gray">
                &#128424; Print
            </button>
            <% } %>
        </div>
    </div>

    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <!-- Filter -->
    <div class="filter-card">
        <form method="get" action="marks.jsp"
              style="display:flex;gap:14px;align-items:flex-end;flex-wrap:wrap;width:100%;">
            <div class="fg">
                <label>Department</label>
                <select name="dept" id="deptSel" onchange="updateSems()">
                    <option value="">-- Select Department --</option>
                    <% for(HashMap<String,String> d : deptList){ %>
                    <option value="<%= d.get("dept_id") %>"
                            data-sems="<%= d.get("total_semesters") %>"
                            <%= d.get("dept_id").equals(selDept)?"selected":"" %>>
                        <%= d.get("dept_code") %> — <%= d.get("dept_name") %>
                    </option>
                    <% } %>
                </select>
            </div>
            <div class="fg">
                <label>Year &amp; Semester</label>
                <select name="sem" id="semSel">
                    <option value="">-- Select --</option>
                    <% for(int s=1;s<=totalSems;s++){
                        int yr2=(int)Math.ceil((double)s/2);
                        int siy=(s%2==0)?2:1;
                        String lbl=(yr2>=1&&yr2<=4)?yearNames[yr2-1]:"Year "+yr2;
                    %>
                    <option value="<%= s %>"
                        <%= String.valueOf(s).equals(selSem)?"selected":"" %>>
                        <%= lbl %> — Sem <%= siy %>
                    </option>
                    <% } %>
                </select>
            </div>
            <button type="submit" class="btn-filter">
                &#128202; View Result Sheet
            </button>
        </form>
    </div>

    <!-- Result Sheet -->
    <div class="sheet-wrapper">
        <% if(selDept.isEmpty()||selSem.isEmpty()){ %>
        <div class="empty-state">
            <div style="font-size:48px;margin-bottom:12px;">&#128196;</div>
            <h3 style="color:#6b7280;font-size:15px;margin-bottom:6px;">
                Select Department and Semester
            </h3>
            <p style="font-size:13px;color:#9ca3af;">
                Choose above to view the result sheet
            </p>
        </div>

        <% } else { %>

        <!-- Header -->
        <div class="sheet-header">
            <div class="institute">
                Sri Lanka Institute of Advanced Technological Education
            </div>
            <div class="campus">Badulla Campus</div>
            <div class="result-label">Examination Result Sheet</div>
            <div class="exam-title">
                <%= yearLabel %> — Semester <%= semInYr %> — <%= examYear %>
            </div>
            <div class="course-name"><%= courseTitle %></div>
        </div>

        <!-- Info strip -->
        <div class="info-strip">
            <span class="info-item">
                <span class="info-label">Department:</span>
                <span class="info-val"><%= deptName %></span>
            </span>
            <span class="info-item">
                <span class="info-label">Code:</span>
                <span class="info-val"><%= deptCode %></span>
            </span>
            <span class="info-item">
                <span class="info-label">Semester:</span>
                <span class="info-val"><%= selSem %></span>
            </span>
            <span class="info-item">
                <span class="info-label">Subjects:</span>
                <span class="info-val"><%= subjectCols.size() %></span>
            </span>
            <span class="info-item">
                <span class="info-label">Students:</span>
                <span class="info-val"><%= studentRows.size() %></span>
            </span>
            <span class="info-item">
                <span class="info-label">Generated:</span>
                <span class="info-val">
                    <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %>
                </span>
            </span>
        </div>

        <%
        // Calculate summary stats
        int passCount=0,failCount=0;
        double totalSGPA=0; int sgpaCount=0;
        for(HashMap<String,String> st : studentRows){
            double sgpa=0;
            try{sgpa=Double.parseDouble(st.get("sgpa"));}catch(Exception ex){}
            if(sgpa>=2.0) passCount++; else failCount++;
            if(!"0".equals(st.get("counted"))){ totalSGPA+=sgpa; sgpaCount++; }
        }
        double avgSGPA=sgpaCount>0?totalSGPA/sgpaCount:0;
        %>

        <!-- Stats row -->
        <div class="stats-row">
            <div class="stat-item">
                <div class="sv" style="color:#1a237e;"><%= studentRows.size() %></div>
                <div class="sl">Total Students</div>
            </div>
            <div class="stat-item">
                <div class="sv" style="color:#1b5e20;"><%= passCount %></div>
                <div class="sl">Passed (GPA≥2.0)</div>
            </div>
            <div class="stat-item">
                <div class="sv" style="color:#dc2626;"><%= failCount %></div>
                <div class="sl">Failed</div>
            </div>
            <div class="stat-item">
                <div class="sv" style="color:#1565c0;">
                    <%= String.format("%.2f",avgSGPA) %>
                </div>
                <div class="sl">Avg SGPA</div>
            </div>
        </div>

        <!-- Student cards -->
        <div class="students-section">
            <div class="section-title">
                &#128101; Student Results
            </div>

            <% if(studentRows.isEmpty()){ %>
            <div class="empty-state">
                <p>No students found in this department</p>
            </div>
            <% } else if(subjectCols.isEmpty()){ %>
            <div class="empty-state">
                <p>No subjects found for Semester <%= selSem %>.
                   <a href="subjects.jsp" style="color:#1a237e;">Add subjects</a>
                </p>
            </div>
            <% } else {
                for(int i=0;i<studentRows.size();i++){
                    HashMap<String,String> st=studentRows.get(i);
                    double sgpa=0;
                    try{sgpa=Double.parseDouble(st.get("sgpa"));}
                    catch(Exception ex){}
                    String sgpaClass=sgpa>=3.0?"sgpa-high":sgpa>=2.0?"sgpa-mid":"sgpa-low";
                    boolean hasMarks=!"0".equals(st.get("counted"));
            %>
            <div class="student-result-card">
                <div class="student-result-header">
                    <div class="stu-num"><%= (i+1) %></div>
                    <div class="stu-name"><%= st.get("full_name") %></div>
                    <span class="stu-reg"><%= st.get("reg_number") %></span>
                    <div class="sgpa-pill <%= sgpaClass %>">
                        SGPA: <%= hasMarks?st.get("sgpa"):"—" %>
                    </div>
                </div>
                <div class="grades-grid">
                    <% for(HashMap<String,String> sub : subjectCols){
                        String grade=st.get("grade_"+sub.get("subject_id"));
                        if(grade==null||grade.isEmpty()) grade="—";
                        String gc="gDash";
                        if("A+".equals(grade))     gc="gAp";
                        else if("A".equals(grade)) gc="gA";
                        else if("A-".equals(grade))gc="gAm";
                        else if("B+".equals(grade))gc="gBp";
                        else if("B".equals(grade)) gc="gB";
                        else if("B-".equals(grade))gc="gBm";
                        else if("C+".equals(grade))gc="gCp";
                        else if("C".equals(grade)) gc="gC";
                        else if("C-".equals(grade))gc="gCm";
                        else if("E".equals(grade)) gc="gE";
                        else if("NE".equals(grade))gc="gNE";
                        else if("AB".equals(grade))gc="gAB";
                        else if("DFR".equals(grade))gc="gDFR";
                        else if("I(SE)".equals(grade))gc="gISE";
                    %>
                    <div class="grade-item">
                        <div class="credit-dot">
                            <%= sub.get("credit_hours") %>
                        </div>
                        <div class="sub-name">
                            <%= sub.get("subject_name") %>
                        </div>
                        <div class="grade-chip <%= gc %>">
                            <%= grade %>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } } %>
        </div>

        <!-- Legend -->
        <div class="sheet-footer">
            <div>
                <div class="legend-title">Grade Scale:</div>
                <div class="legend-grid">
                    <span class="legend-item gAp">A+/A=4.0</span>
                    <span class="legend-item gAm">A-=3.7</span>
                    <span class="legend-item gBp">B+=3.3</span>
                    <span class="legend-item gB">B=3.0</span>
                    <span class="legend-item gBm">B-=2.7</span>
                    <span class="legend-item gCp">C+=2.3</span>
                    <span class="legend-item gC">C=2.0</span>
                    <span class="legend-item gCm">C-=1.7</span>
                    <span class="legend-item gE">E=Fail</span>
                    <span class="legend-item gNE">NE=Not Eligible</span>
                    <span class="legend-item gAB">AB=Absent</span>
                    <span class="legend-item gDFR">DFR=Deferred</span>
                    <span class="legend-item gISE">I(SE)=Incomplete</span>
                </div>
            </div>
            <div style="font-size:11px;color:#9ca3af;text-align:right;">
                SLIATE Badulla Campus — SMS System<br>
                <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm")
                       .format(new java.util.Date()) %>
            </div>
        </div>

        <!-- Signature row -->
        <div class="sig-row">
            <div class="sig-item">
                <div class="sig-line"></div>
                <div class="sig-label">Prepared by</div>
            </div>
            <div class="sig-item">
                <div class="sig-line"></div>
                <div class="sig-label">Checked by</div>
            </div>
            <div class="sig-item">
                <div class="sig-line"></div>
                <div class="sig-label">Head of Department</div>
            </div>
            <div class="sig-item">
                <div class="sig-line"></div>
                <div class="sig-label">Principal</div>
            </div>
        </div>

        <% } %>
    </div>
</div>


</body>
</html>