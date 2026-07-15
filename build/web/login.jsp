<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SMS – Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: #0f172a;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
            padding: 24px;
        }

        /* Ambient background glow accents */
        body::before {
            content: '';
            position: absolute;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(37, 99, 235, 0.12) 0%, rgba(0,0,0,0) 70%);
            top: -10%;
            left: -10%;
            z-index: 0;
        }
        body::after {
            content: '';
            position: absolute;
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(124, 58, 237, 0.08) 0%, rgba(0,0,0,0) 70%);
            bottom: -20%;
            right: -10%;
            z-index: 0;
        }

        .login-wrapper {
            display: flex;
            align-items: center;
            gap: 80px;
            z-index: 10;
            width: 100%;
            max-width: 960px;
            justify-content: center;
        }

        .login-info {
            color: #f8fafc;
            max-width: 380px;
        }

        @media (max-width: 768px) {
            .login-info { display: none; }
            .login-wrapper { justify-content: center; }
        }

        .login-info h2 {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 16px;
            line-height: 1.25;
            letter-spacing: -0.75px;
            color: #ffffff;
        }

        .login-info p {
            font-size: 14px;
            color: #94a3b8;
            line-height: 1.6;
            font-weight: 500;
        }

        /* Modernized Dark Slate Login Card Panel */
        .login-card {
            background: #1e293b;
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 24px;
            padding: 48px;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4);
        }

        .logo-area {
            text-align: center;
            margin-bottom: 32px;
        }

        .logo-icon {
            width: 54px;
            height: 54px;
            background: rgba(37, 99, 235, 0.15);
            color: #3b82f6;
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
            border: 1px solid rgba(37, 99, 235, 0.25);
        }
        .logo-icon i {
            width: 26px;
            height: 26px;
        }

        .logo-area h1 {
            font-size: 24px;
            font-weight: 800;
            color: #ffffff;
            letter-spacing: -0.5px;
        }

        .logo-area p {
            font-size: 13.5px;
            color: #94a3b8;
            margin-top: 4px;
            font-weight: 600;
        }

        .badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.06);
            color: #cbd5e1;
            font-size: 11px;
            font-weight: 700;
            padding: 5px 14px;
            border-radius: 99px;
            margin-top: 12px;
            letter-spacing: 0.2px;
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #cbd5e1;
            margin-bottom: 8px;
        }

        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-wrapper i {
            position: absolute;
            left: 14px;
            color: #64748b;
            width: 18px;
            height: 18px;
            pointer-events: none;
        }

        input[type=text], input[type=password] {
            width: 100%;
            padding: 12px 16px 12px 42px;
            border: 1.5px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            font-size: 14px;
            font-weight: 500;
            font-family: inherit;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            outline: none;
            color: #ffffff;
            background: #0f172a;
        }

        input:focus {
            background: #0f172a;
            border-color: #3b82f6;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.25);
        }

        .btn-login {
            width: 100%;
            padding: 14px;
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            font-family: inherit;
            transition: all 0.15s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
        }

        .btn-login i {
            width: 16px;
            height: 16px;
            transition: transform 0.15s ease;
        }

        .btn-login:hover {
            background: #1d4ed8;
            box-shadow: 0 6px 20px rgba(37, 99, 235, 0.3);
        }
        
        .btn-login:hover i {
            transform: translateX(2px);
        }

        .btn-login:active {
            transform: scale(0.98);
        }

        .error-msg {
            background: rgba(220, 38, 38, 0.1);
            color: #fca5a5;
            border: 1px solid rgba(220, 38, 38, 0.2);
            border-radius: 12px;
            padding: 12px 16px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .error-msg i {
            width: 16px;
            height: 16px;
            flex-shrink: 0;
        }

        .divider {
            border: none;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            margin: 28px 0 20px 0;
        }

        .footer-text {
            text-align: center;
            font-size: 11px;
            color: #64748b;
            font-weight: 500;
        }
    </style>
</head>
<body>

<div class="login-wrapper">

    <!-- Left info panel -->
    <div class="login-info">
        <h2>Smart Student Management System</h2>
        <p>A modern platform designed to manage students, track QR-based attendance data, monitor dynamic marks metrics, and generate precise institutional reports effortlessly.</p>
    </div>

    <!-- Login card -->
    <div class="login-card">
        <div class="logo-area">
            <div class="logo-icon">
                <i data-lucide="graduation-cap"></i>
            </div>
            <h1>Welcome Back</h1>
            <p>SLIATE – Badulla ATI</p>
            <span class="badge">Department of Information Technology</span>
        </div>

        <% if(request.getAttribute("errorMsg") != null){ %>
        <div class="error-msg">
            <i data-lucide="alert-circle"></i>
            <span><%= request.getAttribute("errorMsg") %></span>
        </div>
        <% } %>

        <form action="LoginServlet" method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <div class="input-wrapper">
                    <i data-lucide="user"></i>
                    <input type="text" id="username" name="username"
                           placeholder="Enter your username" required
                           autocomplete="off">
                </div>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrapper">
                    <i data-lucide="lock"></i>
                    <input type="password" id="password" name="password"
                           placeholder="Enter your password" required>
                </div>
            </div>
            <button type="submit" class="btn-login">
                Sign In <i data-lucide="arrow-right"></i>
            </button>
        </form>

        <hr class="divider">
       
        <p class="footer-text">Smart Student Management System v1.0 &copy; 2024</p>
    </div>

</div>

<script>
    // Initialize Lucide Vector Icons Engine
    lucide.createIcons();
</script>
</body>
</html>