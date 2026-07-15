<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.sms.util.RoleCheck" %>
<%
    if(!RoleCheck.isLoggedIn(session)){
        response.sendRedirect("login.jsp"); return;
    }
    // Block students from admin pages
    if(RoleCheck.isStudent(session)){
        response.sendRedirect("studentDashboard.jsp"); return;
    }
%>
<%
    if(session.getAttribute("loggedUser") == null){
        response.sendRedirect("login.jsp"); return;
    }

    String filterDept = request.getParameter("dept");
    if(filterDept == null) filterDept = "IT"; // default to IT

    // Dept info
    String[] deptCodes  = {"IT","ENG","THM","MGT","ACC"};
    String[] deptNames  = {"Information Technology","English",
                           "Tourism & Hospitality","Management","Accountancy"};
    String[] deptColors = {"#1a237e","#1b5e20","#e65100","#880e4f","#4a148c"};
    String[] deptBgs    = {"#e8f0fe","#e6f4ea","#fff3e0","#fce4ec","#f3e8fd"};
    String[] deptCourses= {"HNDIT","HNDE","HNDTHM","HNDM","HNDA"};

    // Get selected dept full name and color
    String selDeptName   = "Information Technology";
    String selDeptColor  = "#1a237e";
    String selDeptBg     = "#e8f0fe";
    for(int di=0; di<deptCodes.length; di++){
        if(deptCodes[di].equals(filterDept)){
            selDeptName  = deptNames[di];
            selDeptColor = deptColors[di];
            selDeptBg    = deptBgs[di];
        }
    }

    // Load students for selected department grouped by year
    ArrayList<HashMap<String,String>> firstYearList  = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> secondYearList = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> thirdYearList  = new ArrayList<HashMap<String,String>>();
    ArrayList<HashMap<String,String>> fourthYearList = new ArrayList<HashMap<String,String>>();

    // Count per dept for tab badges
    int[] deptCounts = new int[5];
    String dbError = "";

    try{
        Connection conn = DBConnection.getConnection();

        // Count per dept
        for(int di=0; di<deptCodes.length; di++){
            PreparedStatement cps = conn.prepareStatement(
                "SELECT COUNT(*) FROM students s " +
                "JOIN departments d ON s.dept_id=d.dept_id " +
                "WHERE d.dept_code=?");
            cps.setString(1, deptCodes[di]);
            ResultSet crs = cps.executeQuery();
            if(crs.next()) deptCounts[di] = crs.getInt(1);
        }

        // Load students for selected dept
        PreparedStatement ps = conn.prepareStatement(
            "SELECT s.student_id, s.reg_number, s.full_name, " +
            "s.email, s.phone, s.year_level, s.course_name, d.dept_code " +
            "FROM students s " +
            "JOIN departments d ON s.dept_id=d.dept_id " +
            "WHERE d.dept_code=? " +
            "ORDER BY s.year_level, s.full_name");
        ps.setString(1, filterDept);
        ResultSet rs = ps.executeQuery();

        while(rs.next()){
            HashMap<String,String> row = new HashMap<String,String>();
            row.put("student_id", String.valueOf(rs.getInt("student_id")));
            row.put("reg_number", rs.getString("reg_number") != null ? rs.getString("reg_number") : "");
            row.put("full_name",  rs.getString("full_name")  != null ? rs.getString("full_name")  : "");
            row.put("email",      rs.getString("email")      != null ? rs.getString("email")      : "-");
            row.put("phone",      rs.getString("phone")      != null ? rs.getString("phone")      : "-");
            row.put("year_level", rs.getString("year_level") != null ? rs.getString("year_level") : "");
            row.put("course_name",rs.getString("course_name")!= null ? rs.getString("course_name"): "-");
            row.put("dept_code",  rs.getString("dept_code")  != null ? rs.getString("dept_code")  : "");

            String yr = row.get("year_level");
            if("First Year".equals(yr))        firstYearList.add(row);
            else if("Second Year".equals(yr))  secondYearList.add(row);
            else if("Third Year".equals(yr))   thirdYearList.add(row);
            else if("Fourth Year".equals(yr))  fourthYearList.add(row);
            else                               firstYearList.add(row);
        }
        conn.close();
    } catch(Exception e){ dbError = e.getMessage(); }

    int totalInDept = firstYearList.size() + secondYearList.size() +
                      thirdYearList.size() + fourthYearList.size();

    String[] yearLabels = {"First Year","Second Year","Third Year","Fourth Year"};
    ArrayList[] yearArrays = {firstYearList,secondYearList,thirdYearList,fourthYearList};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Students</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#f0f2f5;display:flex;min-height:100vh;}

        /* Sidebar */
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

        /* Page header */
        .page-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:3px;}
        .btn-add{background:linear-gradient(135deg,#1a237e,#1565c0);color:white;border:none;border-radius:10px;padding:11px 20px;font-size:13px;font-weight:600;text-decoration:none;}

        /* Alerts */
        .alert-success{background:#e6f4ea;color:#1b5e20;border:1px solid #a8d5b5;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}
        .alert-error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;border-radius:8px;padding:11px 16px;margin-bottom:16px;font-size:13px;}

        /* Department tab buttons */
        .dept-tabs{
            display:flex;gap:8px;flex-wrap:wrap;
            margin-bottom:20px;
        }
        .dept-tab{
            display:flex;align-items:center;gap:8px;
            padding:10px 18px;border-radius:10px;
            cursor:pointer;font-size:13px;font-weight:600;
            text-decoration:none;border:2px solid transparent;
            transition:all 0.15s;
        }
        .dept-tab:hover{transform:translateY(-1px);box-shadow:0 4px 12px rgba(0,0,0,0.1);}
        .dept-tab .tab-count{
            font-size:11px;font-weight:700;
            background:rgba(255,255,255,0.4);
            padding:2px 7px;border-radius:10px;
        }
        .dept-tab.active .tab-count{
            background:rgba(255,255,255,0.3);
        }

        /* Dept banner */
        .dept-banner{
            border-radius:14px;padding:20px 24px;margin-bottom:20px;
            display:flex;align-items:center;gap:16px;
        }
        .dept-banner-icon{
            width:52px;height:52px;border-radius:14px;
            background:rgba(255,255,255,0.2);
            display:flex;align-items:center;justify-content:center;
            font-size:18px;font-weight:800;color:white;flex-shrink:0;
        }
        .dept-banner h2{font-size:18px;font-weight:700;color:white;}
        .dept-banner p{font-size:12px;color:rgba(255,255,255,0.8);margin-top:2px;}
        .dept-banner .total-badge{
            margin-left:auto;background:rgba(255,255,255,0.2);
            color:white;padding:6px 16px;border-radius:20px;
            font-size:13px;font-weight:600;
        }

        /* Year section */
        .year-section{margin-bottom:24px;}
        .year-header{
            display:flex;align-items:center;gap:10px;
            margin-bottom:10px;padding:10px 16px;
            background:white;border-radius:10px;
            box-shadow:0 1px 4px rgba(0,0,0,0.06);
        }
        .year-icon{font-size:18px;}
        .year-title{font-size:14px;font-weight:700;color:#1a1a2e;}
        .year-count{
            font-size:12px;color:#6b7280;
            background:#f3f4f6;padding:3px 10px;
            border-radius:12px;font-weight:500;
        }

        /* Table */
        .table-card{background:white;border-radius:10px;box-shadow:0 1px 4px rgba(0,0,0,0.06);overflow:hidden;}
        table{width:100%;border-collapse:collapse;}
        thead th{background:#f8f9fa;padding:11px 16px;text-align:left;font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;letter-spacing:0.5px;}
        tbody tr{border-bottom:1px solid #f3f4f6;transition:background 0.1s;}
        tbody tr:hover{background:#f8f9ff;}
        tbody td{padding:12px 16px;font-size:13px;color:#1a1a2e;}

        .badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;}
        .badge-IT{background:#e8f0fe;color:#1a237e;}
        .badge-ENG{background:#e6f4ea;color:#1b5e20;}
        .badge-THM{background:#fff3e0;color:#e65100;}
        .badge-MGT{background:#fce4ec;color:#880e4f;}
        .badge-ACC{background:#f3e8fd;color:#4a148c;}

        .btn-view{background:#f3e8fd;color:#4a148c;border:none;border-radius:6px;padding:5px 10px;font-size:12px;font-weight:600;text-decoration:none;display:inline-block;margin-right:4px;}
        .btn-edit{background:#e8f0fe;color:#1a237e;border:none;border-radius:6px;padding:5px 10px;font-size:12px;font-weight:600;text-decoration:none;display:inline-block;margin-right:4px;}
        .btn-delete{background:#fef2f2;color:#dc2626;border:none;border-radius:6px;padding:5px 10px;font-size:12px;font-weight:600;cursor:pointer;}
        .btn-view:hover{background:#e9d5ff;}
        .btn-edit:hover{background:#c7d9ff;}
        .btn-delete:hover{background:#fecaca;}

        .empty-state{text-align:center;padding:32px;color:#9ca3af;}
        .empty-state p{font-size:13px;}

        /* No students in year */
        .no-year-data{
            background:#f8f9fa;border-radius:8px;
            padding:16px;text-align:center;
            font-size:13px;color:#9ca3af;
            margin-top:8px;
        }
    </style>
</head>
<body>

<!-- SIDEBAR — clean, only one Students link -->
<div class="sidebar">
    <div class="sidebar-logo">
        <h2>&#128218; SMS System</h2>
        <p>SLIATE – Badulla ATI</p>
    </div>
    <div class="nav-section">
        <div class="nav-label">Main</div>
        <a href="dashboard.jsp"   class="nav-item">&#9632; Dashboard</a>
        <a href="students.jsp"    class="nav-item active">&#128101; Students</a>
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
        <div class="nav-label">Account</div>
        <a href="chatbot.jsp" class="nav-item">&#129302; Assistant</a>
        <a href="LogoutServlet"   class="nav-item">&#128682; Logout</a>
    </div>
    <div class="sidebar-user">
        <strong><%= session.getAttribute("loggedUser") %></strong>
        <%= session.getAttribute("userRole") %>
    </div>
</div>

<!-- MAIN -->
<div class="main">

    <div class="page-header">
        <div>
            <h1>&#128101; Students</h1>
            <p>View students department by department</p>
        </div>
        <a href="addStudent.jsp" class="btn-add">&#10133; Add New Student</a>
    </div>

    <!-- Alerts -->
    <% if("added".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Student added successfully!</div>
    <% } else if("updated".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Student updated successfully!</div>
    <% } else if("deleted".equals(request.getParameter("success"))){ %>
    <div class="alert-success">&#10003; Student deleted successfully!</div>
    <% } %>
    <% if(!dbError.isEmpty()){ %>
    <div class="alert-error">&#9888; <%= dbError %></div>
    <% } %>

    <!-- Department Tab Buttons -->
    <div class="dept-tabs">
        <% for(int di=0; di<deptCodes.length; di++){ %>
        <a href="students.jsp?dept=<%= deptCodes[di] %>"
           class="dept-tab <%= deptCodes[di].equals(filterDept)?"active":"" %>"
           style="
               background:<%= deptCodes[di].equals(filterDept) ? deptColors[di] : "white" %>;
               color:<%= deptCodes[di].equals(filterDept) ? "white" : deptColors[di] %>;
               border-color:<%= deptColors[di] %>;
               box-shadow:<%= deptCodes[di].equals(filterDept) ?
                   "0 4px 14px "+deptColors[di]+"55" : "0 1px 4px rgba(0,0,0,0.06)" %>;
           ">
            <%= deptCodes[di] %> — <%= deptNames[di] %>
            <span class="tab-count"
                  style="background:<%= deptCodes[di].equals(filterDept) ?
                      "rgba(255,255,255,0.3)" : deptBgs[di] %>;
                         color:<%= deptCodes[di].equals(filterDept) ?
                      "white" : deptColors[di] %>;">
                <%= deptCounts[di] %>
            </span>
        </a>
        <% } %>
    </div>

    <!-- Department Banner -->
    <div class="dept-banner"
         style="background:linear-gradient(135deg,<%= selDeptColor %>,<%= selDeptColor %>cc);">
        <div class="dept-banner-icon"><%= filterDept %></div>
        <div>
            <h2>Department of <%= selDeptName %></h2>
            <p>SLIATE Badulla Campus</p>
        </div>
        <span class="total-badge"><%= totalInDept %> Students</span>
    </div>

    <!-- Students grouped by Year -->
    <%
    for(int yi=0; yi<yearLabels.length; yi++){
        ArrayList<HashMap<String,String>> yList = yearArrays[yi];
        if(yList.isEmpty()) continue;
    %>
    <div class="year-section">
        <div class="year-header">
            <span class="year-icon">&#127979;</span>
            <span class="year-title"><%= yearLabels[yi] %></span>
            <span class="year-count"><%= yList.size() %> student(s)</span>
        </div>

        <div class="table-card">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Reg Number</th>
                        <th>Full Name</th>
                        <th>Course</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% for(int i=0; i<yList.size(); i++){
                    HashMap<String,String> s = yList.get(i); %>
                <tr>
                    <td style="color:#9ca3af;font-size:12px;"><%= (i+1) %></td>
                    <td style="font-weight:700;color:<%= selDeptColor %>;">
                        <%= s.get("reg_number") %>
                    </td>
                    <td><strong><%= s.get("full_name") %></strong></td>
                    <td style="font-size:12px;color:#6b7280;">
                        <span class="badge badge-<%= filterDept %>">
                            <%= s.get("course_name") %>
                        </span>
                    </td>
                    <td style="font-size:12px;color:#6b7280;"><%= s.get("email") %></td>
                    <td style="font-size:12px;color:#6b7280;"><%= s.get("phone") %></td>
                    <td>
                        <a href="studentProfile.jsp?id=<%= s.get("student_id") %>"
                           class="btn-view">&#128100; View</a>
                        <a href="editStudent.jsp?id=<%= s.get("student_id") %>"
                           class="btn-edit">&#9998; Edit</a>
                        <a href="javascript:void(0)"
                           onclick="if(confirm('Delete <%= s.get("full_name") %>?'))
                               window.location='DeleteStudentServlet?id=<%= s.get("student_id") %>'"
                           class="btn-delete">&#128465;</a>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>

    <!-- If no students at all in this dept -->
    <% if(totalInDept == 0){ %>
    <div style="background:white;border-radius:12px;padding:48px;text-align:center;box-shadow:0 1px 4px rgba(0,0,0,0.06);">
        <div style="font-size:48px;margin-bottom:12px;">&#128101;</div>
        <h3 style="font-size:16px;color:#6b7280;margin-bottom:8px;">
            No students in <%= selDeptName %> yet
        </h3>
        <p style="font-size:13px;color:#9ca3af;margin-bottom:20px;">
            Add students to this department to see them here
        </p>
        <a href="addStudent.jsp" class="btn-add"
           style="display:inline-block;padding:11px 24px;border-radius:10px;
                  background:linear-gradient(135deg,<%= selDeptColor %>,<%= selDeptColor %>cc);
                  color:white;text-decoration:none;font-weight:600;font-size:13px;">
            &#10133; Add <%= filterDept %> Student
        </a>
    </div>
    <% } %>

</div>
    
</body>
</html>