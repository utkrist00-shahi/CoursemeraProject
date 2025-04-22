<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Publisher Signup - Coursemera</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
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
            flex-direction: column;
            justify-content: center;
            align-items: center;
            position: relative;
            overflow: hidden;
        }
        .background {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('https://images.unsplash.com/photo-1521737852567-6949f3f9f2b5?q=80&w=1447&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1350&q=80');
            background-size: cover;
            background-position: center;
            filter: blur(5px);
            z-index: 0;
        }
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            display: flex;
            align-items: center;
            z-index: 2;
            filter: none;
        }
        .logo img {
            height: 30px;
            margin-right: 5px;
        }
        .logo span {
            font-size: 1.5rem;
            font-weight: bold;
            color: #1a3c34;
        }
        .nav-link {
            position: absolute;
            top: 20px;
            right: 20px;
            z-index: 2;
            filter: none;
        }
        .nav-link a {
            color: #2c5282;
            font-size: 1rem;
            font-weight: bold;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 5px;
            transition: background-color 0.3s, color 0.3s;
        }
        .nav-link a:hover {
            background-color: #2c5282;
            color: white;
        }
        .signup-container {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 0 20px rgba(0,0,0,0.2);
            width: 350px;
            z-index: 2;
            filter: none;
            text-align: center;
        }
        .signup-container h2 {
            text-align: left;
            color: #333;
            font-size: 1.5rem;
            margin-bottom: 1.5rem;
            font-weight: normal;
        }
        .signup-container h2::after {
            content: ' 👋';
            font-size: 1.2rem;
        }
        .signup-container form {
            display: flex;
            flex-direction: column;
        }
        .form-group {
            position: relative;
            margin-bottom: 1.2rem;
        }
        .form-group label {
            display: block;
            text-align: left;
            margin-bottom: 0.3rem;
            color: #555;
            font-size: 0.9rem;
        }
        .form-group input {
            width: 100%;
            padding: 0.7rem 0.7rem 0.7rem 2.5rem;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 1rem;
        }
        .form-group i {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #555;
            font-size: 1rem;
        }
        .file-upload {
            position: relative;
            margin-bottom: 1.2rem;
        }
        .file-upload label {
            display: block;
            text-align: left;
            margin-bottom: 0.3rem;
            color: #555;
            font-size: 0.9rem;
        }
        .file-upload input[type="file"] {
            width: 100%;
            padding: 0.7rem 0.7rem 0.7rem 2.5rem;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 1rem;
            background-color: #fff;
            color: #555;
        }
        .file-upload i {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #555;
            font-size: 1rem;
        }
        .signup-container form button {
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
        .signup-container form button:hover {
            background-color: #15332d;
        }
        .signup-container .error {
            color: #e74c3c;
            font-size: 0.9rem;
            margin: 10px 0;
        }
        .signup-container .success {
            color: #2ecc71;
            font-size: 0.9rem;
            margin: 10px 0;
        }
        .signup-container .login-link {
            text-align: center;
            font-size: 0.9rem;
            color: #555;
            margin-bottom: 1rem;
        }
        .signup-container .login-link a {
            color: #0056d2;
            text-decoration: none;
            font-weight: bold;
        }
        .signup-container .login-link a:hover {
            text-decoration: underline;
        }
        .back-to-home {
            text-align: center;
            font-size: 0.9rem;
            color: #555;
            margin-bottom: 1rem;
        }
        .back-to-home a {
            color: #0056d2;
            text-decoration: none;
            font-weight: bold;
        }
        .back-to-home a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="background"></div>
    <div class="logo">
        <img src="logo.png" alt="Coursemera Logo">
        <span>Coursemera</span>
    </div>
    <div class="nav-link">
        <a href="publisher_login.jsp">Login</a>
    </div>

    <div class="signup-container">
        <h2>Publisher Signup</h2>
        <% if (request.getAttribute("error") != null) { %>
            <p class="error"><%= request.getAttribute("error") %></p>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <p class="success"><%= request.getAttribute("success") %></p>
        <% } %>
        <form action="publisher_signup" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <i class="fas fa-user"></i>
                <input type="text" name="firstName" placeholder="First Name" required>
            </div>
            <div class="form-group">
                <i class="fas fa-user"></i>
                <input type="text" name="lastName" placeholder="Last Name" required>
            </div>
            <div class="form-group">
                <i class="fas fa-envelope"></i>
                <input type="email" name="email" placeholder="Email" required>
            </div>
            <div class="form-group">
                <i class="fas fa-lock"></i>
                <input type="password" name="password" placeholder="Password" required>
            </div>
            <div class="file-upload">
                <label for="resume">Upload Your Resume</label>
                <i class="fas fa-file-upload"></i>
                <input type="file" id="resume" name="resume" accept=".pdf" required>
            </div>
            <button type="submit">Sign Up</button>
        </form>
        <div class="login-link">
            <p>Already have an account? <a href="publisher_login.jsp">Login</a></p>
        </div>
        <div class="back-to-home">
            <a href="<%= request.getContextPath() %>/index.jsp">Back to Home</a>
        </div>
    </div>
</body>
</html>