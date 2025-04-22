<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sign Up - Coursemera</title>
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
        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 0.7rem;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 1rem;
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
        <h2>Sign Up</h2>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getSession().getAttribute("successMessage") != null) { %>
            <div class="success"><%= request.getSession().getAttribute("successMessage") %></div>
        <% } %>
        
        <form action="signup" method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required maxlength="50" placeholder="Enter Username">
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" required maxlength="100" placeholder="Enter Email">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required minlength="8" maxlength="100" placeholder="Enter Password">
            </div>
            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required minlength="8" placeholder="Confirm Password">
            </div>
            <button type="submit" class="login-btn">Sign Up</button>
        </form>
        
        <div class="signup-link">
            Already have an account? <a href="login.jsp">Login</a>
        </div>
        
        <div class="back-to-home">
            <a href="<%= request.getContextPath() %>/index.jsp">Back to Home</a>
        </div>
    </div>
</body>
</html>