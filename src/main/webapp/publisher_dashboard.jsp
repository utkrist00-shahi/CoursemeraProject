<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Publisher Dashboard - Coursemera</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f1f1f1;
            color: #333;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        header {
            background-color: #fff;
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        header .logo-container {
            display: flex;
            align-items: center;
        }
        header .logo {
            width: 80px;
            height: 80px;
            margin-right: 10px;
        }
        header h1 {
            font-size: 24px;
            margin: 0;
            background: linear-gradient(135deg, #3498db, #1e90ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
        }
        header nav {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        header nav .publisher-info {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #fff;
            font-size: 16px;
            background: linear-gradient(135deg, #2ecc71, #27ae60);
            padding: 8px 16px;
            border-radius: 20px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
        }
        header nav .publisher-info i {
            color: #fff;
        }
        header nav .publisher-info:hover {
            background: linear-gradient(135deg, #27ae60, #219653);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            transform: scale(1.05);
        }
        header nav a.logout-button {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: #fff;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
            text-decoration: none;
        }
        header nav a.logout-button:hover {
            background: linear-gradient(135deg, #ff6655, #e74c3c);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            transform: scale(1.05);
        }
        .dashboard-container {
            flex: 1;
            padding: 40px 20px;
            text-align: center;
        }
        .dashboard-container h2 {
            font-size: 28px;
            margin: 0 0 20px;
            color: #333;
        }
        .dashboard-nav {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-bottom: 30px;
        }
        .dashboard-nav button {
            padding: 12px 24px;
            border: none;
            border-radius: 20px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .dashboard-nav button.active {
            background: linear-gradient(135deg, #3498db, #1e90ff);
            color: #fff;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        }
        .dashboard-nav button:not(.active) {
            background: linear-gradient(135deg, #ccc, #aaa);
            color: #333;
        }
        .dashboard-nav button:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        }
        .dashboard-content {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .dashboard-content p {
            font-size: 16px;
            color: #666;
            margin: 0 0 20px;
        }
        .dashboard-content a {
            background: linear-gradient(135deg, #3498db, #1e90ff);
            color: #fff;
            padding: 10px 20px;
            border-radius: 20px;
            font-size: 16px;
            text-decoration: none;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
        }
        .dashboard-content a:hover {
            background: linear-gradient(135deg, #2980b9, #1e90ff);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            transform: scale(1.05);
        }
        footer {
            background-color: #1a1a1a;
            color: #fff;
            padding: 60px 40px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 40px;
        }
        .footer-sections {
            display: flex;
            gap: 40px;
            flex-wrap: wrap;
            justify-content: center;
        }
        .footer-section {
            min-width: 200px;
        }
        .footer-section h3 {
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 15px;
            color: #fff;
        }
        .footer-section p, .footer-section a {
            font-size: 14px;
            color: #ccc;
            margin: 0 0 10px;
            text-decoration: none;
        }
        .footer-section a:hover {
            color: #fff;
        }
        .footer-section .social-links {
            display: flex;
            gap: 15px;
        }
        .footer-section .social-links a {
            font-size: 18px;
        }
        .footer-copyright {
            font-size: 14px;
            color: #ccc;
            text-align: center;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header>
        <div class="logo-container">
            <img src="logo.png" alt="Coursemera Logo" class="logo">
            <h1>Coursemera</h1>
        </div>
        <nav>
            <div class="publisher-info">
                <i class="fas fa-user"></i>
                <span><%= session.getAttribute("username") != null ? session.getAttribute("username") : "Publisher" %></span>
                <span><%= session.getAttribute("email") != null ? session.getAttribute("email") : "publisher@coursemera.com" %></span>
            </div>
            <a href="publisher_dashboard.jsp?logout=true" class="logout-button">Logout</a>
        </nav>
    </header>

    <!-- Dashboard Content -->
    <div class="dashboard-container">
        <h2>Publisher Dashboard</h2>
        <div class="dashboard-nav">
            <button onclick="showSection('manage-courses')">Manage Courses</button>
            <button onclick="showSection('my-courses')">My Courses</button>
            <button class="active" onclick="showSection('manage-profile')">Manage Profile</button>
        </div>
        <div class="dashboard-content" id="manage-courses-section" style="display: none;">
            <h3>Manage Courses</h3>
            <p>Create, edit, or delete your courses here.</p>
        </div>
        <div class="dashboard-content" id="my-courses-section" style="display: none;">
            <h3>My Courses</h3>
            <p>View your published courses and their performance.</p>
        </div>
        <div class="dashboard-content" id="manage-profile-section">
            <h3>Manage Profile</h3>
            <p>Welcome, <%= session.getAttribute("firstName") %>!</p>
            <p>Manage your publisher profile on Coursemera.</p>
            <% if (session.getAttribute("resume") != null && session.getAttribute("resumeFilename") != null) { %>
                <p>Your uploaded resume: <a href="download_resume"><%= session.getAttribute("resumeFilename") %></a></p>
            <% } else { %>
                <p>No resume uploaded.</p>
            <% } %>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        <div class="footer-sections">
            <div class="footer-section">
                <h3>CourseMera</h3>
                <p>Learn from the best instructors worldwide</p>
            </div>
            <div class="footer-section">
                <h3>Quick Links</h3>
                <p><a href="about.jsp">About us</a></p>
                <p><a href="#">Certified Instructors</a></p>
                <p><a href="#">Contact</a></p>
            </div>
            <div class="footer-section">
                <h3>Contact Info</h3>
                <p>Email us today</p>
            </div>
            <div class="footer-section">
                <h3>Follow Us</h3>
                <div class="social-links">
                    <a href="#"><i class="fab fa-facebook"></i></a>
                    <a href="#"><i class="fab fa-twitter"></i></a>
                    <a href="#"><i class="fab fa-instagram"></i></a>
                </div>
            </div>
        </div>
        <div class="footer-copyright">
            © 2025 CourseMera. All rights reserved.
        </div>
    </footer>

    <!-- Handle logout -->
    <% 
        String logout = request.getParameter("logout");
        if ("true".equals(logout)) {
            session.invalidate();
            response.sendRedirect("index.jsp");
        }
    %>

    <script>
        function showSection(sectionId) {
            document.getElementById('manage-courses-section').style.display = sectionId === 'manage-courses' ? 'block' : 'none';
            document.getElementById('my-courses-section').style.display = sectionId === 'my-courses' ? 'block' : 'none';
            document.getElementById('manage-profile-section').style.display = sectionId === 'manage-profile' ? 'block' : 'none';

            document.querySelectorAll('.dashboard-nav button').forEach(btn => {
                btn.classList.remove('active');
                if (btn.getAttribute('onclick').includes(sectionId)) {
                    btn.classList.add('active');
                }
            });
        }
    </script>
</body>
</html>