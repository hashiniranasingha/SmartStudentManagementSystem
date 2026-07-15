<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%
    String statusParam  = request.getParameter("status");
    String errorParam   = request.getParameter("error");
    String nameParam    = request.getParameter("name");
    String regParam     = request.getParameter("reg");
    String deptParam    = request.getParameter("dept");
    String timeParam    = request.getParameter("time");
    String sessionParam = request.getParameter("s");

    if(statusParam  == null) statusParam  = "";
    if(errorParam   == null) errorParam   = "";
    if(nameParam    == null) nameParam    = "";
    if(regParam     == null) regParam     = "";
    if(deptParam    == null) deptParam    = "";
    if(timeParam    == null) timeParam    = "";
    if(sessionParam == null) sessionParam = "";

    ArrayList<HashMap<String,String>> studentList =
        new ArrayList<HashMap<String,String>>();
    String deptName = "";

    if(!sessionParam.isEmpty() &&
       statusParam.isEmpty() && errorParam.isEmpty()){
        try{
            Connection conn = DBConnection.getConnection();
            PreparedStatement sps = conn.prepareStatement(
                "SELECT d.dept_id, d.dept_name " +
                "FROM attendance_sessions a " +
                "JOIN departments d ON a.dept_id=d.dept_id " +
                "WHERE a.session_code=? AND a.is_active=1 " +
                "AND a.expires_at > NOW()");
            sps.setString(1, sessionParam);
            ResultSet srs = sps.executeQuery();
            if(srs.next()){
                deptName = srs.getString("dept_name");
                int deptId = srs.getInt("dept_id");
                PreparedStatement stps = conn.prepareStatement(
                    "SELECT student_id, reg_number, full_name " +
                    "FROM students WHERE dept_id=? ORDER BY full_name");
                stps.setInt(1, deptId);
                ResultSet strs = stps.executeQuery();
                while(strs.next()){
                    HashMap<String,String> row =
                        new HashMap<String,String>();
                    row.put("student_id",
                        String.valueOf(strs.getInt("student_id")));
                    row.put("reg_number", strs.getString("reg_number"));
                    row.put("full_name",  strs.getString("full_name"));
                    studentList.add(row);
                }
            }
            conn.close();
        } catch(Exception e){}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
    <title>SLIATE Attendance Check-In</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{
            font-family:'Inter',sans-serif;
            background:linear-gradient(135deg,#1a237e,#1565c0);
            min-height:100vh;display:flex;
            align-items:center;justify-content:center;padding:20px;
        }
        .card{
            background:white;border-radius:20px;
            padding:32px 24px;width:100%;max-width:420px;
            box-shadow:0 20px 60px rgba(0,0,0,0.3);
        }
        .logo{text-align:center;margin-bottom:24px;}
        .logo h2{font-size:15px;font-weight:700;color:#1a237e;}
        .logo p{font-size:12px;color:#6b7280;margin-top:2px;}
        .logo .icon{font-size:44px;margin-bottom:8px;}

        /* Success */
        .success-box{text-align:center;}
        .success-icon{font-size:64px;margin-bottom:14px;}
        .success-box h2{font-size:20px;font-weight:700;color:#1b5e20;margin-bottom:8px;}
        .student-name{font-size:17px;font-weight:600;color:#1a1a2e;margin:14px 0 8px;}
        .info-row{display:flex;justify-content:center;gap:8px;margin-bottom:6px;flex-wrap:wrap;}
        .info-badge{background:#e8f0fe;color:#1a237e;padding:4px 12px;border-radius:20px;font-size:12px;font-weight:600;}
        .time-badge{background:#e6f4ea;color:#1b5e20;padding:4px 12px;border-radius:20px;font-size:12px;font-weight:600;}

        /* Already */
        .already-box{text-align:center;}
        .already-icon{font-size:56px;margin-bottom:14px;}
        .already-box h2{font-size:18px;font-weight:700;color:#f57f17;margin-bottom:8px;}

        /* Error */
        .error-box{text-align:center;}
        .error-icon{font-size:56px;margin-bottom:14px;}
        .error-box h2{font-size:18px;font-weight:700;color:#dc2626;margin-bottom:8px;}
        .error-box p{font-size:13px;color:#6b7280;line-height:1.6;}

        /* Select form */
        .select-title{font-size:16px;font-weight:700;color:#1a1a2e;margin-bottom:4px;}
        .select-sub{font-size:13px;color:#6b7280;margin-bottom:16px;}
        .dept-badge-big{display:inline-block;background:#e8f0fe;color:#1a237e;padding:5px 14px;border-radius:20px;font-size:13px;font-weight:600;margin-bottom:14px;}

        .search-wrap{position:relative;margin-bottom:12px;}
        .search-wrap input{
            width:100%;padding:13px 16px;
            border:2px solid #e5e7eb;border-radius:12px;
            font-size:14px;font-family:'Inter',sans-serif;outline:none;
        }
        .search-wrap input:focus{border-color:#1a237e;}
        .search-drop{
            position:absolute;top:100%;left:0;right:0;
            background:white;border:2px solid #e5e7eb;
            border-top:none;border-radius:0 0 12px 12px;
            max-height:200px;overflow-y:auto;
            z-index:100;display:none;
            box-shadow:0 4px 12px rgba(0,0,0,0.1);
        }
        .search-opt{
            padding:11px 16px;cursor:pointer;
            border-bottom:1px solid #f3f4f6;font-size:13px;
        }
        .search-opt:hover{background:#f8f9ff;}
        .search-opt strong{display:block;color:#1a1a2e;}
        .search-opt span{font-size:11px;color:#9ca3af;}

        .selected-box{
            background:#f0f4ff;border:2px solid #c7d9ff;
            border-radius:12px;padding:14px;margin-bottom:16px;display:none;
        }
        .selected-box h4{font-size:15px;font-weight:600;color:#1a237e;}
        .selected-box p{font-size:12px;color:#6b7280;margin-top:3px;}

        .btn-checkin{
            width:100%;background:linear-gradient(135deg,#1a237e,#1565c0);
            color:white;border:none;border-radius:12px;
            padding:15px;font-size:15px;font-weight:700;
            cursor:pointer;font-family:'Inter',sans-serif;
        }
        .btn-checkin:hover{opacity:0.9;}

        .footer-note{
            text-align:center;font-size:11px;color:#9ca3af;
            margin-top:16px;line-height:1.6;
        }
    </style>
</head>
<body>
<div class="card">
    <div class="logo">
        <div class="icon">&#127979;</div>
        <h2>SLIATE – Badulla Campus</h2>
        <p>Student Attendance Check-In</p>
    </div>

    <% if("success".equals(statusParam)){ %>
    <div class="success-box">
        <div class="success-icon">&#9989;</div>
        <h2>Attendance Marked!</h2>
        <p style="font-size:13px;color:#6b7280;">
            Your attendance has been recorded
        </p>
        <div class="student-name"><%= nameParam %></div>
        <div class="info-row">
            <span class="info-badge"><%= regParam %></span>
            <span class="info-badge"><%= deptParam %></span>
        </div>
        <div class="info-row">
            <span class="time-badge">&#128336; <%= timeParam %></span>
        </div>
    </div>

    <% } else if("already".equals(statusParam)){ %>
    <div class="already-box">
        <div class="already-icon">&#9888;&#65039;</div>
        <h2>Already Marked!</h2>
        <p style="font-size:13px;color:#6b7280;">
            Your attendance was already recorded today
        </p>
        <div class="student-name" style="color:#f57f17;">
            <%= nameParam %>
        </div>
        <div class="info-row">
            <span class="info-badge"><%= regParam %></span>
            <span class="info-badge"><%= deptParam %></span>
        </div>
    </div>

    <% } else if("expired".equals(errorParam)){ %>
    <div class="error-box">
        <div class="error-icon">&#9200;</div>
        <h2>Session Expired</h2>
        <p>This attendance session has expired.<br>
           Ask your lecturer to create a new session.</p>
    </div>

    <% } else if("dept".equals(errorParam)){ %>
    <div class="error-box">
        <div class="error-icon">&#10060;</div>
        <h2>Wrong Department</h2>
        <p>You are not enrolled in the department for this session.</p>
    </div>

    <% } else if("student".equals(errorParam)){ %>
    <div class="error-box">
        <div class="error-icon">&#10060;</div>
        <h2>Student Not Found</h2>
        <p>Your record was not found. Contact your lecturer.</p>
    </div>

    <% } else if(!sessionParam.isEmpty() && !studentList.isEmpty()){ %>
    <div class="select-title">Select Your Name</div>
    <div class="select-sub">
        Search and select to mark attendance
    </div>
    <div class="dept-badge-big">
        &#127979; <%= deptName %>
    </div>

    <div class="search-wrap">
        <input type="text" id="stuSearch"
               placeholder="&#128269; Type your name..."
               oninput="searchStu(this.value)"
               autocomplete="off">
        <div class="search-drop" id="stuDrop"></div>
    </div>

    <div class="selected-box" id="selectedBox">
        <h4 id="selectedName">—</h4>
        <p id="selectedReg">—</p>
    </div>

    <a href="#" id="checkinLink" style="display:none;">
        <button class="btn-checkin">
            &#9989; Mark My Attendance
        </button>
    </a>

    <p class="footer-note">
        Select YOUR name only.<br>
        Marking attendance for others is not allowed.
    </p>

    <% } else { %>
    <div class="error-box">
        <div class="error-icon">&#10060;</div>
        <h2>Invalid Link</h2>
        <p>This link is invalid or has expired.<br>
           Ask your lecturer for a new link.</p>
    </div>
    <% } %>
</div>

<% if(!sessionParam.isEmpty() && !studentList.isEmpty()){ %>
<script>
var students = [
    <% for(int i=0; i<studentList.size(); i++){
        HashMap<String,String> s = studentList.get(i);
        String safeName = s.get("full_name")
            .replace("'","\\'").replace("\"","");
    %>
    {id:'<%= s.get("student_id") %>',
     reg:'<%= s.get("reg_number") %>',
     name:'<%= safeName %>'}
    <%= i<studentList.size()-1?",":"" %>
    <% } %>
];
var sessionCode = '<%= sessionParam %>';

function searchStu(q){
    var drop = document.getElementById('stuDrop');
    if(q.length < 1){ drop.style.display='none'; return; }
    var matches = students.filter(function(s){
        return s.name.toLowerCase().indexOf(q.toLowerCase()) >= 0 ||
               s.reg.toLowerCase().indexOf(q.toLowerCase())  >= 0;
    }).slice(0,10);
    if(!matches.length){ drop.style.display='none'; return; }
    var html = '';
    matches.forEach(function(s){
        html += '<div class="search-opt" onclick="selectStu(\''+
                s.id+'\',\''+s.name.replace("'","\\'")+
                '\',\''+s.reg+'\')">'
              + '<strong>'+s.name+'</strong>'
              + '<span>'+s.reg+'</span>'
              + '</div>';
    });
    drop.innerHTML = html;
    drop.style.display = 'block';
}

function selectStu(id, name, reg){
    document.getElementById('stuDrop').style.display = 'none';
    document.getElementById('stuSearch').value       = name;
    document.getElementById('selectedBox').style.display = 'block';
    document.getElementById('selectedName').textContent  = name;
    document.getElementById('selectedReg').textContent   = reg;
    var link = document.getElementById('checkinLink');
    link.href = 'checkin?s='+sessionCode+'&id='+id;
    link.style.display = 'block';
}

document.addEventListener('click', function(e){
    if(!e.target.closest('.search-wrap')){
        document.getElementById('stuDrop').style.display = 'none';
    }
});
</script>
<% } %>
</body>
</html>