<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%
    if(session.getAttribute("loggedUser") == null){
        response.sendRedirect("login.jsp"); return;
    }

    String selStudent = request.getParameter("sid");
    String selSem     = request.getParameter("sem");
    if(selStudent == null) selStudent = "";
    if(selSem     == null) selSem     = "1";

    ArrayList<HashMap<String,String>> studentList = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> subjectList = new ArrayList<HashMap<String,String>>();
    String studentName = ""; String studentDeptId = "";
    int maxSems = 4;
    String dbError = "";

    try{
        Connection conn = DBConnection.getConnection();

        // All students
        ResultSet srs = conn.createStatement().executeQuery(
            "SELECT s.student_id, s.reg_number, s.full_name, d.dept_code, " +
            "s.dept_id, dep.total_semesters " +
            "FROM students s JOIN departments d ON s.dept_id=d.dept_id " +
            "JOIN departments dep ON s.dept_id=dep.dept_id " +
            "ORDER BY d.dept_code, s.full_name");
        while(srs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("student_id",      String.valueOf(srs.getInt("student_id")));
            row.put("reg_number",      srs.getString("reg_number"));
            row.put("full_name",       srs.getString("full_name"));
            row.put("dept_code",       srs.getString("dept_code"));
            row.put("dept_id",         String.valueOf(srs.getInt("dept_id")));
            row.put("total_semesters", String.valueOf(srs.getInt("total_semesters")));
            studentList.add(row);
            if(String.valueOf(srs.getInt("student_id")).equals(selStudent)){
                studentName   = srs.getString("full_name");
                studentDeptId = String.valueOf(srs.getInt("dept_id"));
                maxSems       = srs.getInt("total_semesters");
            }
        }

        // Subjects for selected student+semester, with existing grade if any
        if(!selStudent.isEmpty() && !studentDeptId.isEmpty()){
            PreparedStatement sps = conn.prepareStatement(
                "SELECT sub.subject_id, sub.subject_name, sub.credit_hours, " +
                "m.grade " +
                "FROM subjects sub " +
                "LEFT JOIN marks m ON sub.subject_id=m.subject_id AND m.student_id=? " +
                "WHERE sub.dept_id=? AND sub.semester=? " +
                "ORDER BY sub.subject_name");
            sps.setInt(1, Integer.parseInt(selStudent));
            sps.setInt(2, Integer.parseInt(studentDeptId));
            sps.setInt(3, Integer.parseInt(selSem));
            ResultSet subRs = sps.executeQuery();
            while(subRs.next()){
                HashMap<String,String> row = new HashMap<String,String>();
                row.put("subject_id",   String.valueOf(subRs.getInt("subject_id")));
                row.put("subject_name", subRs.getString("subject_name"));
                row.put("credit_hours", String.valueOf(subRs.getInt("credit_hours")));
                row.put("grade",        subRs.getString("grade") != null ? subRs.getString("grade") : "");
                subjectList.add(row);
            }
        }
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }

    int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

    // Grade -> GPA map for live preview rendering
    double[] dummy = null; // not used, just keeping structure clear
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Add Marks</title>
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
        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:18px;font-size:13px;}
        .layout{display:grid;grid-template-columns:280px 1fr;gap:24px;}
        .select-card{background:white;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
        .select-card h3{font-size:14px;font-weight:600;color:#1a1a2e;margin-bottom:14px;}
        .form-group{margin-bottom:14px;}
        .form-group label{display:block;font-size:12px;font-weight:500;color:#374151;margin-bottom:5px;}
        .form-group select{width:100%;padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;font-size:13px;font-family:'Inter',sans-serif;outline:none;}
        .form-group select:focus{border-color:#1a237e;}
        .btn-load{width:100%;background:#1a237e;color:white;border:none;border-radius:8px;padding:10px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}

        .marks-card{background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.06);overflow:hidden;}
        .marks-card-header{padding:16px 20px;border-bottom:1px solid #f3f4f6;}
        .marks-card-header h3{font-size:14px;font-weight:600;color:#1a1a2e;}
        .grade-scale{display:flex;gap:8px;flex-wrap:wrap;padding:12px 20px;background:#f8f9fa;border-bottom:1px solid #f3f4f6;}
        .gs-item{font-size:11px;padding:3px 10px;border-radius:12px;}
        .marks-table{width:100%;border-collapse:collapse;}
        .marks-table th{background:#f8f9fa;padding:10px 16px;text-align:left;font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;}
        .marks-table td{padding:10px 16px;border-bottom:1px solid #f3f4f6;font-size:13px;}
        .grade-sel{width:150px;padding:7px 10px;border:1.5px solid #e5e7eb;border-radius:7px;font-size:13px;font-family:'Inter',sans-serif;outline:none;}
        .grade-sel:focus{border-color:#1a237e;}
        .grade-A{color:#1b5e20;font-weight:700;}
        .grade-B{color:#1565c0;font-weight:700;}
        .grade-C{color:#e65100;font-weight:700;}
        .grade-D{color:#880e4f;font-weight:700;}
        .grade-F{color:#dc2626;font-weight:700;}
        .save-bar{padding:16px 20px;border-top:1px solid #f3f4f6;display:flex;gap:12px;align-items:center;}
        .btn-save{background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:10px;padding:12px 28px;font-size:14px;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;}
        .btn-cancel{background:#f3f4f6;color:#374151;border:1px solid #e5e7eb;border-radius:10px;padding:12px 20px;font-size:13px;text-decoration:none;}
        .empty-msg{text-align:center;padding:48px;color:#9ca3af;font-size:13px;}
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
        <a href="students.jsp"  class="nav-item">&#128101; Students</a>
        <a href="attendance.jsp" class="nav-item">&#9989; Attendance</a>
        <a href="monthlyReport.jsp" class="nav-item">
    &#128197; Monthly Report
</a>
        <a href="qrCode.jsp"    class="nav-item">&#9638; QR Codes</a>
        <a href="qrScan.jsp"    class="nav-item">&#128247; QR Scanner</a>
        <a href="marks.jsp"     class="nav-item active">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"  class="nav-item">&#128218; Subjects</a>
        <a href="reports.jsp"   class="nav-item">&#128202; Reports</a>
        <a href="notices.jsp" class="nav-item">&#128276; Notice Board</a>
        <div class="nav-label">Account</div>
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
        <h1>&#10133; Enter Marks</h1>
        <p>Select a student and semester to enter grades</p>
    </div>
    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <div class="layout">
        <div class="select-card">
            <h3>&#128101; Select Student</h3>
            <form method="get" action="addMarks.jsp">
                <div class="form-group">
                    <label>Student</label>
                    <select name="sid" id="studentSel" onchange="updateSems()">
                        <option value="">-- Select Student --</option>
                        <% for(HashMap<String,String> s : studentList){ %>
                        <option value="<%= s.get("student_id") %>"
                                data-sems="<%= s.get("total_semesters") %>"
                                <%= s.get("student_id").equals(selStudent)?"selected":"" %>>
                            [<%= s.get("dept_code") %>] <%= s.get("full_name") %>
                        </option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Semester</label>
                    <select name="sem" id="semSel">
                        <% for(int i=1; i<=maxSems; i++){ %>
                        <option value="<%= i %>" <%= String.valueOf(i).equals(selSem)?"selected":"" %>>
                            Semester <%= i %>
                        </option>
                        <% } %>
                    </select>
                </div>
                <button type="submit" class="btn-load">Load Subjects</button>
            </form>
        </div>

        <div class="marks-card">
            <div class="marks-card-header">
                <h3>
                    <% if(!selStudent.isEmpty()){ %>
                        Semester <%= selSem %> Grades — <%= studentName %>
                    <% } else { %>
                        Select a student to enter grades
                    <% } %>
                </h3>
            </div>

            <div class="grade-scale">
                <span class="gs-item grade-A" style="background:#e6f4ea;">A+/A=4.0 A-=3.7</span>
                <span class="gs-item grade-B" style="background:#e8f0fe;">B+=3.3 B=3.0 B-=2.7</span>
                <span class="gs-item grade-C" style="background:#fff3e0;">C+=2.3 C=2.0 C-=1.7</span>
                <span class="gs-item grade-D" style="background:#fce4ec;">E=0.0 NE=0.0</span>
                <span class="gs-item grade-F" style="background:#fef2f2;">AB=0.0 DFR=0.0 I(SE)=skip</span>
            </div>

            <% if(selStudent.isEmpty()){ %>
            <div class="empty-msg">Select a student and semester on the left, then click Load Subjects</div>
            <% } else if(subjectList.isEmpty()){ %>
            <div class="empty-msg">
                No subjects found for Semester <%= selSem %>.<br>
                <a href="subjects.jsp" style="color:#1a237e;">Go to Subject Manager to add subjects</a>
            </div>
            <% } else { %>
            <form action="SaveMarksServlet" method="post">
                <input type="hidden" name="student_id" value="<%= selStudent %>">
                <input type="hidden" name="semester"   value="<%= selSem %>">
                <input type="hidden" name="exam_year"  value="<%= currentYear %>">

                <table class="marks-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Subject</th>
                            <th>Credits</th>
                            <th>Grade</th>
                            <th>GPA Points</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for(int i=0; i<subjectList.size(); i++){
                        HashMap<String,String> sub = subjectList.get(i);
                        String curGrade = sub.get("grade"); %>
                    <tr>
                        <td style="color:#9ca3af;"><%= (i+1) %></td>
                        <td>
                            <input type="hidden" name="subject_id" value="<%= sub.get("subject_id") %>">
                            <strong><%= sub.get("subject_name") %></strong>
                        </td>
                        <td style="color:#9ca3af;"><%= sub.get("credit_hours") %></td>
                        <td>
                            <select name="grade" class="grade-sel" id="gradeSel_<%= i %>"
                                    onchange="previewGrade(<%= i %>)">
                                <option value="">— Select —</option>
                                <option value="A+"   <%= "A+".equals(curGrade)?"selected":"" %>>A+</option>
                                <option value="A"    <%= "A".equals(curGrade)?"selected":"" %>>A</option>
                                <option value="A-"   <%= "A-".equals(curGrade)?"selected":"" %>>A-</option>
                                <option value="B+"   <%= "B+".equals(curGrade)?"selected":"" %>>B+</option>
                                <option value="B"    <%= "B".equals(curGrade)?"selected":"" %>>B</option>
                                <option value="B-"   <%= "B-".equals(curGrade)?"selected":"" %>>B-</option>
                                <option value="C+"   <%= "C+".equals(curGrade)?"selected":"" %>>C+</option>
                                <option value="C"    <%= "C".equals(curGrade)?"selected":"" %>>C</option>
                                <option value="C-"   <%= "C-".equals(curGrade)?"selected":"" %>>C-</option>
                                <option value="E"    <%= "E".equals(curGrade)?"selected":"" %>>E (Fail)</option>
                                <option value="NE"   <%= "NE".equals(curGrade)?"selected":"" %>>NE (Not Eligible)</option>
                                <option value="AB"   <%= "AB".equals(curGrade)?"selected":"" %>>AB (Absent)</option>
                                <option value="DFR"  <%= "DFR".equals(curGrade)?"selected":"" %>>DFR (Deferred)</option>
                                <option value="I(SE)"<%= "I(SE)".equals(curGrade)?"selected":"" %>>I(SE) (Incomplete)</option>
                            </select>
                        </td>
                        <td id="gpaPreview_<%= i %>" style="color:#9ca3af;font-size:12px;">
                            <%
                                String gp = "—";
                                if(curGrade != null && !curGrade.isEmpty()){
                                    if(curGrade.equals("A+")||curGrade.equals("A")) gp="4.0";
                                    else if(curGrade.equals("A-")) gp="3.7";
                                    else if(curGrade.equals("B+")) gp="3.3";
                                    else if(curGrade.equals("B"))  gp="3.0";
                                    else if(curGrade.equals("B-")) gp="2.7";
                                    else if(curGrade.equals("C+")) gp="2.3";
                                    else if(curGrade.equals("C"))  gp="2.0";
                                    else if(curGrade.equals("C-")) gp="1.7";
                                    else if(curGrade.equals("E")||curGrade.equals("NE")||
                                            curGrade.equals("AB")||curGrade.equals("DFR")) gp="0.0";
                                    else if(curGrade.equals("I(SE)")) gp="Skip";
                                }
                            %>
                            <%= gp %>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>

                <div class="save-bar">
                    <button type="submit" class="btn-save">&#10003; Save All Grades</button>
                    <a href="marks.jsp" class="btn-cancel">Cancel</a>
                    <span style="font-size:12px;color:#9ca3af;margin-left:8px;">
                        Exam Year: <%= currentYear %>
                    </span>
                </div>
            </form>
            <% } %>
        </div>
    </div>
</div>

<script>
function previewGrade(i){
    var sel   = document.getElementById('gradeSel_'+i);
    var grade = sel.value;
    var gpaEl = document.getElementById('gpaPreview_'+i);
    var pts = {
        'A+':'4.0','A':'4.0','A-':'3.7',
        'B+':'3.3','B':'3.0','B-':'2.7',
        'C+':'2.3','C':'2.0','C-':'1.7',
        'E':'0.0','NE':'0.0','AB':'0.0','DFR':'0.0','I(SE)':'Skip'
    };
    gpaEl.textContent = grade ? (pts[grade] !== undefined ? pts[grade] : '—') : '—';
}

function updateSems(){
    var sel  = document.getElementById('studentSel');
    var opt  = sel.options[sel.selectedIndex];
    var sems = parseInt(opt.getAttribute('data-sems')) || 4;
    var semSel = document.getElementById('semSel');
    semSel.innerHTML = '';
    for(var i=1;i<=sems;i++){
        semSel.innerHTML += '<option value="'+i+'">Semester '+i+'</option>';
    }
}
</script>


</body>
</html>