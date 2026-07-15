<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.sms.util.RoleCheck" %>
<%
    if(!RoleCheck.isLoggedIn(session)){
        response.sendRedirect("login.jsp"); return;
    }
    boolean isAdmin = RoleCheck.isAdmin(session);
    boolean isLec   = RoleCheck.isLecturer(session);
    boolean isStu   = RoleCheck.isStudent(session);
    String role     = (String)session.getAttribute("userRole");
    String userName = (String)session.getAttribute("loggedUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SMS – Assistant</title>
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

        .main{margin-left:240px;padding:28px;flex:1;display:flex;flex-direction:column;}
        .page-header{margin-bottom:20px;}
        .page-header h1{font-size:22px;font-weight:700;color:#1a1a2e;}
        .page-header p{font-size:13px;color:#6b7280;margin-top:4px;}

        .chat-container{
            background:white;border-radius:16px;
            box-shadow:0 1px 4px rgba(0,0,0,0.06);
            flex:1;display:flex;flex-direction:column;
            max-height:calc(100vh - 160px);overflow:hidden;
        }

        .chat-header{
            padding:16px 20px;
            background:linear-gradient(135deg,#1a237e,#1565c0);
            border-radius:16px 16px 0 0;
            display:flex;align-items:center;gap:12px;
        }
        .bot-avatar{
            width:42px;height:42px;border-radius:50%;
            background:rgba(255,255,255,0.2);
            display:flex;align-items:center;justify-content:center;
            font-size:20px;
        }
        .chat-header h3{color:white;font-size:15px;font-weight:700;}
        .chat-header p{color:rgba(255,255,255,0.8);font-size:12px;}
        .online-dot{width:8px;height:8px;border-radius:50%;background:#4caf50;display:inline-block;margin-right:4px;}

        .chat-messages{
            flex:1;overflow-y:auto;padding:20px;
            display:flex;flex-direction:column;gap:14px;
        }

        .msg{display:flex;gap:10px;align-items:flex-end;}
        .msg.user{flex-direction:row-reverse;}

        .msg-avatar{
            width:32px;height:32px;border-radius:50%;
            display:flex;align-items:center;justify-content:center;
            font-size:14px;font-weight:700;flex-shrink:0;
        }
        .msg-bot .msg-avatar{background:#e8f0fe;color:#1a237e;}
        .msg-user .msg-avatar{background:#1a237e;color:white;}

        .msg-bubble{
            max-width:70%;padding:12px 16px;border-radius:16px;
            font-size:13px;line-height:1.6;
        }
        .msg-bot .msg-bubble{
            background:#f8f9fa;color:#1a1a2e;
            border-bottom-left-radius:4px;
        }
        .msg-user .msg-bubble{
            background:linear-gradient(135deg,#1a237e,#1565c0);
            color:white;border-bottom-right-radius:4px;
        }
        .msg-time{font-size:11px;color:#9ca3af;margin-top:4px;}

        /* Quick suggestions */
        .suggestions{
            display:flex;gap:8px;flex-wrap:wrap;
            padding:12px 20px;border-top:1px solid #f3f4f6;
        }
        .suggestion-btn{
            background:#e8f0fe;color:#1a237e;border:none;
            border-radius:20px;padding:6px 14px;font-size:12px;
            font-weight:500;cursor:pointer;font-family:'Inter',sans-serif;
            transition:background 0.15s;
        }
        .suggestion-btn:hover{background:#c7d9ff;}

        .chat-input-area{
            padding:16px 20px;border-top:1px solid #f3f4f6;
            display:flex;gap:10px;align-items:center;
        }
        .chat-input{
            flex:1;padding:12px 16px;border:1.5px solid #e5e7eb;
            border-radius:25px;font-size:14px;font-family:'Inter',sans-serif;
            outline:none;
        }
        .chat-input:focus{border-color:#1a237e;}
        .btn-send{
            width:44px;height:44px;border-radius:50%;
            background:linear-gradient(135deg,#1a237e,#1565c0);
            color:white;border:none;font-size:18px;cursor:pointer;
            display:flex;align-items:center;justify-content:center;
            flex-shrink:0;
        }
        .btn-send:hover{opacity:0.9;}
        .btn-send:disabled{opacity:0.5;cursor:not-allowed;}

        .typing-indicator{
            display:none;align-items:center;gap:4px;padding:8px 12px;
        }
        .typing-dot{
            width:6px;height:6px;border-radius:50%;
            background:#9ca3af;animation:typingAnim 1.4s infinite;
        }
        .typing-dot:nth-child(2){animation-delay:0.2s;}
        .typing-dot:nth-child(3){animation-delay:0.4s;}
        @keyframes typingAnim{
            0%,60%,100%{transform:translateY(0);}
            30%{transform:translateY(-6px);}
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
        <a href="dashboard.jsp"     class="nav-item">&#9632; Dashboard</a>
        <a href="students.jsp"      class="nav-item">&#128101; Students</a>
        <a href="attendance.jsp"    class="nav-item">&#9989; Attendance</a>
        <a href="monthlyReport.jsp" class="nav-item">&#128197; Monthly Report</a>
        <a href="qrCode.jsp"        class="nav-item">&#9638; QR Codes</a>
        <a href="qrScan.jsp"        class="nav-item">&#128247; QR Scanner</a>
        <a href="marks.jsp"         class="nav-item">&#128196; Marks &amp; GPA</a>
        <a href="subjects.jsp"      class="nav-item">&#128218; Subjects</a>
        <a href="lms.jsp"           class="nav-item">&#128196; LMS</a>
        <a href="notices.jsp"       class="nav-item">&#128276; Notices</a>
        <a href="chatbot.jsp"       class="nav-item active">&#129302; Assistant</a>
        <a href="reports.jsp"       class="nav-item">&#128202; Reports</a>
       <a href="emailNotify.jsp" class="nav-item">&#128231; Email Alerts</a>
        <% if(isAdmin){ %>
        <a href="manageUsers.jsp"   class="nav-item">&#128272; Manage Users</a>
        <% } %>
        <div class="nav-label">Account</div>
        <a href="LogoutServlet"     class="nav-item">&#128682; Logout</a>
    </div>
    <div class="sidebar-user">
        <strong><%= userName %></strong>
        <%= role %>
    </div>
</div>

<div class="main">
    <div class="page-header">
        <h1>&#129302; SMS Assistant</h1>
        <p>Ask anything about the system — attendance, marks, students</p>
    </div>

    <div class="chat-container">
        <div class="chat-header">
            <div class="bot-avatar">&#129302;</div>
            <div>
                <h3>SMS Assistant</h3>
                <p>
                    <span class="online-dot"></span>
                    Online — SLIATE Badulla ATI
                </p>
            </div>
        </div>

        <div class="chat-messages" id="chatMessages">
            <!-- Welcome message -->
            <div class="msg msg-bot">
                <div class="msg-avatar">&#129302;</div>
                <div>
                    <div class="msg-bubble">
                        Hello <%= userName %>! I am the SMS Assistant for
                        SLIATE Badulla Campus. I can help you with:<br><br>
                        &#9989; Attendance information<br>
                        &#128196; Marks and GPA queries<br>
                        &#128101; Student information<br>
                        &#128218; LMS materials<br>
                        &#128276; Notices<br>
                        &#128202; Reports<br><br>
                        How can I help you today?
                    </div>
                    <div class="msg-time">Just now</div>
                </div>
            </div>
        </div>

        <!-- Typing indicator -->
        <div class="typing-indicator" id="typingIndicator">
            <div class="msg-avatar" style="background:#e8f0fe;color:#1a237e;width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:14px;">
                &#129302;
            </div>
            <div style="background:#f8f9fa;padding:10px 14px;border-radius:16px;border-bottom-left-radius:4px;">
                <div style="display:flex;gap:4px;align-items:center;">
                    <div class="typing-dot"></div>
                    <div class="typing-dot"></div>
                    <div class="typing-dot"></div>
                </div>
            </div>
        </div>

        <!-- Quick suggestions -->
        <div class="suggestions">
            <button class="suggestion-btn"
                onclick="sendSuggestion('How many students are enrolled?')">
                &#128101; Total students
            </button>
            <button class="suggestion-btn"
                onclick="sendSuggestion('Who are absent today?')">
                &#128197; Absent today
            </button>
            <button class="suggestion-btn"
                onclick="sendSuggestion('How to mark attendance?')">
                &#9989; Mark attendance
            </button>
            <button class="suggestion-btn"
                onclick="sendSuggestion('How to view results?')">
                &#128196; View results
            </button>
            <button class="suggestion-btn"
                onclick="sendSuggestion('How to generate QR code?')">
                &#9638; QR codes
            </button>
        </div>

        <div class="chat-input-area">
            <input type="text" class="chat-input" id="chatInput"
                   placeholder="Type your question here..."
                   onkeydown="if(event.key==='Enter') sendMessage()">
            <button class="btn-send" id="sendBtn" onclick="sendMessage()">
                &#10148;
            </button>
        </div>
    </div>
</div>

<script>
var chatHistory = [];
var userRole    = '<%= role %>';
var userName    = '<%= userName %>';

// System prompt with SMS context
var systemPrompt =
    "You are the SMS Assistant for SLIATE Badulla Campus Student " +
    "Management System. You help " + userRole + " users named " +
    userName + " with questions about the system.\n\n" +
    "The system has these features:\n" +
    "- Student management (5 departments: IT, ENG, THM, MGT, ACC)\n" +
    "- QR-based attendance marking\n" +
    "- Marks and GPA tracking (A+/A/B+/B/C+/C/E/NE grades)\n" +
    "- LMS materials (notes, past papers, videos, links)\n" +
    "- Monthly attendance reports\n" +
    "- Email notifications for low attendance\n" +
    "- Notice board\n" +
    "- PDF report generation\n" +
    "- 3 user roles: admin, lecturer, student\n\n" +
    "Answer questions clearly and helpfully. If asked about specific " +
    "data like 'how many students', say you cannot access live database " +
    "data but guide them to the correct page. Keep answers concise.";

function getCurrentTime(){
    var now = new Date();
    var h   = now.getHours();
    var m   = now.getMinutes();
    var ampm= h >= 12 ? 'PM' : 'AM';
    h = h % 12; h = h ? h : 12;
    m = m < 10 ? '0'+m : m;
    return h + ':' + m + ' ' + ampm;
}

function addMessage(text, isUser){
    var msgs = document.getElementById('chatMessages');
    var div  = document.createElement('div');
    div.className = 'msg ' + (isUser ? 'msg-user' : 'msg-bot');

    var initials = isUser ?
        userName.charAt(0).toUpperCase() : '🤖';

    div.innerHTML =
        '<div class="msg-avatar">' + initials + '</div>' +
        '<div>' +
        '<div class="msg-bubble">' + text + '</div>' +
        '<div class="msg-time">' + getCurrentTime() + '</div>' +
        '</div>';

    msgs.appendChild(div);
    msgs.scrollTop = msgs.scrollHeight;
}

function showTyping(show){
    document.getElementById('typingIndicator').style.display =
        show ? 'flex' : 'none';
    var msgs = document.getElementById('chatMessages');
    msgs.scrollTop = msgs.scrollHeight;
}

function sendSuggestion(text){
    document.getElementById('chatInput').value = text;
    sendMessage();
}

function sendMessage(){
    var input = document.getElementById('chatInput');
    var text  = input.value.trim();
    if(!text) return;

    addMessage(text, true);
    input.value = '';
    document.getElementById('sendBtn').disabled = true;

    chatHistory.push({role:'user', content: text});

    showTyping(true);

    // Call Anthropic API
    fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'anthropic-version': '2023-06-01',
            'anthropic-dangerous-direct-browser-access': 'true'
        },
        body: JSON.stringify({
            model:      'claude-sonnet-4-6',
            max_tokens: 500,
            system:     systemPrompt,
            messages:   chatHistory
        })
    })
    .then(function(r){ return r.json(); })
    .then(function(data){
        showTyping(false);
        document.getElementById('sendBtn').disabled = false;

        var reply = '';
        if(data.content && data.content[0]){
            reply = data.content[0].text;
        } else if(data.error){
            reply = 'Sorry, I encountered an error. Please try again.';
        }

        chatHistory.push({role:'assistant', content: reply});
        addMessage(reply, false);
    })
    .catch(function(err){
        showTyping(false);
        document.getElementById('sendBtn').disabled = false;
        addMessage(
            'Sorry, I could not connect. Please check your internet ' +
            'connection and try again.', false);
    });
}
</script>


</body>
</html>