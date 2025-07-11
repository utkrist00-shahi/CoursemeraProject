<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login - Coursemera</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: Arial, sans-serif;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            overflow: hidden;
        }
        .background-container {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            display: flex;
            z-index: 0;
        }
        .background-left {
            width: 60%;
            height: 100%;
            background-image: url('https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=1471&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1350&q=80');
            background-size: cover;
            background-position: center;
            filter: blur(5px);
        }
        .background-right {
            width: 40%;
            height: 100%;
            background-image: url('https://images.unsplash.com/photo-1592355591829-aaae33fcff1d?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            filter: blur(5px);
        }
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            display: flex;
            align-items: center;
            z-index: 2;
        }
        .logo img {
            height: 30px;
            margin-right: 5px;
            filter: none;
        }
        .logo span {
            font-size: 1.5rem;
            font-weight: bold;
            color: #1a3c34;
        }
        .login-container {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 0 20px rgba(0,0,0,0.2);
            width: 350px;
            z-index: 2;
            filter: none;
        }
        h2 {
            text-align: left;
            color: #333;
            font-size: 1.5rem;
            margin-bottom: 1.5rem;
            font-weight: normal;
        }
        h2::after {
            content: ' 👋';
            font-size: 1.2rem;
        }
        .form-group {
            margin-bottom: 1.2rem;
        }
        label {
            display: block;
            margin-bottom: 0.3rem;
            color: #555;
            font-size: 0.9rem;
        }
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 0.7rem;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 1rem;
        }
        .checkbox-group {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
        }
        .checkbox-group label {
            display: inline;
            color: #555;
        }
        .forgot-password {
            color: #d9534f;
            text-decoration: none;
        }
        .forgot-password:hover {
            text-decoration: underline;
        }
        button.login-btn {
            width: 100%;
            padding: 0.8rem;
            background-color: #1a3c34;
            border: none;
            border-radius: 4px;
            color: white;
            font-size: 1rem;
            cursor: pointer;
            margin-bottom: 1rem;
        }
        button.login-btn:hover {
            background-color: #15332d;
        }
        .divider {
            display: flex;
            align-items: center;
            text-align: center;
            margin: 1rem 0;
            color: #555;
            font-size: 0.9rem;
        }
        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            border-bottom: 1px solid #ddd;
            margin: 0 10px;
        }
        .social-login {
            display: flex;
            justify-content: space-between;
            margin-bottom: 1rem;
        }
        .social-login button {
            width: 48%;
            padding: 0.6rem;
            background-color: white;
            border: 1px solid #ddd;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            color: #333;
        }
        .social-login button img {
            width: 20px;
            margin-right: 5px;
        }
        .signup-link {
            text-align: center;
            font-size: 0.9rem;
            color: #555;
            margin-bottom: 1rem;
        }
        .signup-link a {
            color: #0056d2;
            text-decoration: none;
            font-weight: bold;
        }
        .signup-link a:hover {
            text-decoration: underline;
        }
        .back-to-home {
            text-align: center;
            font-size: 0.9rem;
        }
        .back-to-home a {
            color: #0056d2;
            text-decoration: none;
            font-weight: bold;
        }
        .back-to-home a:hover {
            text-decoration: underline;
        }
        .error {
            color: #d9534f;
            text-align: center;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }
        .success {
            color: #5cb85c;
            text-align: center;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="background-container">
        <div class="background-left"></div>
        <div class="background-right"></div>
    </div>
    <div class="logo">
        <img src="logo.png" alt="Coursemera Logo">
        <span>Coursemera</span>
    </div>
    <div class="login-container">
        <h2>Hi, Welcome Back!</h2>
        
        <%-- Check for existing session with cookie validation --%>
        <%
            HttpSession existingSession = request.getSession(false);
            Cookie[] cookies = request.getCookies();
            String sessionToken = null;
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("sessionToken".equals(cookie.getName())) {
                        sessionToken = cookie.getValue();
                        break;
                    }
                }
            }
            String role = (existingSession != null) ? (String) existingSession.getAttribute("role") : null;
            String storedSessionToken = (existingSession != null) ? (String) existingSession.getAttribute("sessionToken") : null;

            if (sessionToken != null && storedSessionToken != null && sessionToken.equals(storedSessionToken)) {
                if ("ADMIN".equals(role)) {
                    response.sendRedirect(request.getContextPath() + "/admin_panel");
                    return;
                } else {
                    response.sendRedirect(request.getContextPath() + "/index.jsp");
                    return;
                }
            }

            String error = (String) request.getAttribute("error");
            String message = request.getParameter("message");
        %>
        
        <% if (error != null) { %>
            <div class="error"><%= error %></div>
        <% } %>
        
        <% if (message != null) { %>
            <div class="success"><%= message %></div>
        <% } %>
        <% String success = request.getParameter("success"); %>
        <% if (success != null) { %>
            <div class="success"><%= success %></div>
        <% } %>
        
        <form action="login" method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" name="username" 
                       value="<%= (existingSession != null && existingSession.getAttribute("tempUsername") != null) ? 
                               existingSession.getAttribute("tempUsername") : "" %>" 
                       required placeholder="Enter Username">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" name="password" 
                       value="<%= (existingSession != null && existingSession.getAttribute("tempPassword") != null) ? 
                               existingSession.getAttribute("tempPassword") : "" %>" 
                       required placeholder="Enter Your Password">
            </div>
            <% if (existingSession != null && existingSession.getAttribute("awaitingSecret") != null) { %>
                <div class="form-group">
                    <label for="secretKey">Admin Secret Key</label>
                    <input type="password" id="secretKey" name="secretKey" required placeholder="Enter Secret Key">
                </div>
            <% } %>
            <div class="checkbox-group">
                <div>
                    <input type="checkbox" id="remember" name="remember">
                    <label for="remember">Remember Me</label>
                </div>
                <a href="#" class="forgot-password">Forgot Password?</a>
            </div>
            <button type="submit" class="login-btn">Login</button>
        </form>
        
        <div class="divider">or</div>
        
        <div class="social-login">
            <button>
                <img src="https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg" alt="Facebook">
                Facebook
            </button>
            <button>
                <img src="https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png" alt="Google">
                Google
            </button>
        </div>
        
        <div class="signup-link">
            Don't have an account? <a href="signup.jsp">Sign up</a>
        </div>
        
        <div class="back-to-home">
            <a href="<%= request.getContextPath() %>/index.jsp">Back to Home</a>
        </div>
    </div>
</body>
</html>