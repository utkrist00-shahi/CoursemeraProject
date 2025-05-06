<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="java.util.Base64" %>
<%
// Caching prevention
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

User user = (User) request.getAttribute("user");
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard - Coursemera</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', Arial, sans-serif;
            background: linear-gradient(135deg, #e6f0fa 0%, #d1e8e2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }
        .dashboard-title {
            text-align: center;
            font-size: 3rem;
            font-weight: 700;
            letter-spacing: 1px;
            background: linear-gradient(135deg, #1a3c34 0%, #2c7a7b 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin: 20px 0;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        .dashboard-title:hover {
            transform: translateY(-5px);
        }
        .dashboard-container {
            max-width: 1400px;
            width: 100%;
            margin: 0 auto;
        }
        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 40px;
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .user-profile {
            display: flex;
            align-items: center;
            gap: 25px;
        }
        .profile-pic {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: linear-gradient(135deg, #1a3c34 0%, #2c7a7b 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 40px;
            font-weight: bold;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
            border: 2px solid #fff;
            transition: transform 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .profile-pic img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
        }
        .profile-pic:hover {
            transform: scale(1.05);
        }
        .user-info h2 {
            margin: 0;
            color: #1a3c34;
            font-size: 2rem;
            letter-spacing: 0.5px;
        }
        .user-info p {
            margin: 5px 0 0;
            color: #666;
            font-size: 1.1rem;
        }
        .dashboard-header .home-btn,
        .dashboard-header .logout-btn {
            padding: 12px 25px;
            margin-left: 15px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: bold;
            font-size: 1rem;
            transition: background 0.3s ease;
        }
        .dashboard-header .home-btn {
            background: linear-gradient(135deg, #1a3c34 0%, #2c7a7b 100%);
            color: white;
        }
        .dashboard-header .home-btn:hover {
            background: linear-gradient(135deg, #15332d 0%, #226b6c 100%);
        }
        .dashboard-header .logout-btn {
            background-color: #e74c3c;
            color: white;
        }
        .dashboard-header .logout-btn:hover {
            background-color: #c0392b;
        }
        .dashboard-content {
            display: grid;
            grid-template-columns: 300px 1fr;
            gap: 25px;
        }
        .sidebar {
            background: #f9fafb;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            align-self: start;
        }
        .sidebar-nav a {
            display: flex;
            align-items: center;
            padding: 15px 20px;
            color: #333;
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 8px;
            font-size: 1.1rem;
            transition: background 0.3s ease, color 0.3s ease;
        }
        .sidebar-nav a:hover {
            background: linear-gradient(135deg, #1a3c34 0%, #2c7a7b 100%);
            color: white;
        }
        .sidebar-nav a.active {
            background: linear-gradient(135deg, #1a3c34 0%, #2c7a7b 100%);
            color: white;
        }
        .sidebar-nav a i {
            margin-right: 12px;
            width: 24px;
            text-align: center;
            font-size: 1.2rem;
            transition: transform 0.3s ease;
        }
        .sidebar-nav a:hover i {
            transform: translateX(5px);
        }
        .main-content {
            background: #f9fafb;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            align-self: start;
        }
        .section-title {
            margin-top: 0;
            color: #1a3c34;
            font-size: 1.8rem;
            position: relative;
            padding-bottom: 12px;
        }
        .section-title::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 60px;
            height: 4px;
            background: linear-gradient(135deg, #1a3c34 0%, #2c7a7b 100%);
        }
        .info-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            border: 1px solid transparent;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .info-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.1);
            border: 1px solid #2c7a7b;
        }
        .info-card h3 {
            margin-top: 0;
            color: #1a3c34;
            font-size: 1.4rem;
        }
        .info-row {
            display: flex;
            margin-bottom: 12px;
            align-items: center;
        }
        .info-label {
            font-weight: bold;
            width: 180px;
            color: #555;
            font-size: 1.1rem;
        }
        .info-value {
            color: #333;
            font-size: 1.1rem;
        }
        .edit-form {
            margin-top: 15px;
        }
        .edit-form input[type="text"],
        .edit-form input[type="email"],
        .edit-form input[type="password"],
        .edit-form input[type="file"] {
            padding: 8px;
            margin-bottom: 10px;
            width: 100%;
            max-width: 300px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .edit-form button {
            padding: 8px 16px;
            background: linear-gradient(135deg, #1a3c34 0%, #2c7a7b 100%);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        .edit-form button:hover {
            background: linear-gradient(135deg, #15332d 0%, #226b6c 100%);
        }
        .message {
            margin-bottom: 15px;
            padding: 10px;
            border-radius: 4px;
        }
        .message.success {
            background-color: #d4edda;
            color: #155724;
        }
        .message.error {
            background-color: #f8d7da;
            color: #721c24;
        }
        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
        }
    </style>
</head>
<body>
    <h1 class="dashboard-title">User Dashboard</h1>
    <div class="dashboard-container">
        <div class="dashboard-header">
            <div class="user-profile">
                <div class="profile-pic">
                    <% 
                        String profileImageSrc = "https://via.placeholder.com/100?text=" + 
                            (user.getUsername() != null && user.getUsername().length() > 0 ? 
                                user.getUsername().substring(0, 1).toUpperCase() : "U");
                        if (user.getImage() != null && user.getImage().length > 0) {
                            try {
                                String base64Image = Base64.getEncoder().encodeToString(user.getImage());
                                profileImageSrc = "data:image/jpeg;base64," + base64Image;
                                System.out.println("JSP: Rendering image for user ID " + user.getId() + ", Base64 length: " + base64Image.length());
                            } catch (Exception e) {
                                System.out.println("JSP: Error encoding image for user ID " + user.getId() + ": " + e.getMessage());
                            }
                        }
                    %>
                    <img src="<%= profileImageSrc %>" alt="Profile Picture" 
                         onerror="this.src='https://via.placeholder.com/100?text=Default'; console.log('Image load error for user ID <%= user.getId() %>');">
                </div>
                <div class="user-info">
                    <h2><%= user.getUsername() != null ? user.getUsername() : "Unknown User" %></h2>
                    <p><%= user.getEmail() != null ? user.getEmail() : "No Email" %></p>
                </div>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/" class="home-btn">
                    <i class="fas fa-home"></i> Home
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Logout</a>
            </div>
        </div>

        <div class="dashboard-content">
            <div class="sidebar">
                <nav class="sidebar-nav">
                    <a href="#" class="active" data-tab="profile"><i class="fas fa-user"></i> Profile</a>
                    <a href="#" data-tab="courses"><i class="fas fa-book"></i> My Courses</a>
                    <a href="#" data-tab="settings"><i class="fas fa-cog"></i> Settings</a>
                </nav>
            </div>

            <div class="main-content">
                <div id="profile" class="tab-content active">
                    <h2 class="section-title">Profile Information</h2>
                    
                    <% 
                        String successMessage = (String) request.getAttribute("success");
                        String errorMessage = (String) request.getAttribute("error");
                    %>
                    <% if (successMessage != null) { %>
                        <div class="message success"><%= successMessage %></div>
                    <% } %>
                    <% if (errorMessage != null) { %>
                        <div class="message error"><%= errorMessage %></div>
                    <% } %>

                    <div class="info-card">
                        <h3>Basic Information</h3>
                        <div class="info-row">
                            <span class="info-label">Username:</span>
                            <span class="info-value"><%= user.getUsername() != null ? user.getUsername() : "N/A" %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Email:</span>
                            <span class="info-value"><%= user.getEmail() != null ? user.getEmail() : "N/A" %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Account Type:</span>
                            <span class="info-value"><%= user.getRole() != null ? user.getRole() : "N/A" %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Member Since:</span>
                            <span class="info-value"><%= user.getCreatedAt() != null ? user.getCreatedAt() : "N/A" %></span>
                        </div>
                    </div>

                    <div class="info-card">
                        <h3>Course Progress</h3>
                        <p>You haven't enrolled in any courses yet.</p>
                    </div>
                </div>

                <div id="courses" class="tab-content">
                    <h2 class="section-title">My Courses</h2>
                    <div class="info-card">
                        <h3>Enrolled Courses</h3>
                        <p>You haven't enrolled in any courses yet.</p>
                    </div>
                </div>

                <div id="settings" class="tab-content">
                    <h2 class="section-title">Settings</h2>
                    <div class="info-card">
                        <h3>Update Credentials</h3>
                        <form action="${pageContext.request.contextPath}/user_dashboard" method="post" class="edit-form">
                            <input type="hidden" name="action" value="updateCredentials">
                            <div>
                                <label for="username">Username:</label>
                                <input type="text" id="username" name="username" 
                                       value="<%= user.getUsername() != null ? user.getUsername() : "" %>" required>
                            </div>
                            <div>
                                <label for="email">Email:</label>
                                <input type="email" id="email" name="email" 
                                       value="<%= user.getEmail() != null ? user.getEmail() : "" %>" required>
                            </div>
                            <div>
                                <label for="currentPassword">Current Password:</label>
                                <input type="password" id="currentPassword" name="currentPassword" required>
                            </div>
                            <div>
                                <label for="newPassword">New Password:</label>
                                <input type="password" id="newPassword" name="newPassword">
                            </div>
                            <div>
                                <label for="confirmNewPassword">Confirm New Password:</label>
                                <input type="password" id="confirmNewPassword" name="confirmNewPassword">
                            </div>
                            <button type="submit">Update</button>
                        </form>
                    </div>

                    <div class="info-card">
                        <h3>Update Profile Image</h3>
                        <form action="${pageContext.request.contextPath}/user_dashboard" method="post" 
                              class="edit-form" enctype="multipart/form-data" 
                              onsubmit="return validateImageForm(this)">
                            <input type="hidden" name="action" value="uploadImage">
                            <div>
                                <label for="settingsProfileImage">Profile Image (PNG/JPG, max 5MB):</label>
                                <input type="file" id="settingsProfileImage" name="profileImage" 
                                       accept="image/png,image/jpeg" required>
                            </div>
                            <button type="submit">Upload Image</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Tab switching logic
        document.querySelectorAll('.sidebar-nav a').forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                const tab = this.getAttribute('data-tab');

                // Remove active class from all links and tabs
                document.querySelectorAll('.sidebar-nav a').forEach(a => a.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

                // Add active class to clicked link and corresponding tab
                this.classList.add('active');
                document.getElementById(tab).classList.add('active');
            });
        });

        // Client-side form validation for image upload
        function validateImageForm(form) {
            const fileInput = form.querySelector('#settingsProfileImage');
            const file = fileInput.files[0];
            if (!file) {
                alert('Please select an image file.');
                return false;
            }
            const validTypes = ['image/png', 'image/jpeg'];
            if (!validTypes.includes(file.type)) {
                alert('Only PNG or JPEG images are allowed.');
                return false;
            }
            if (file.size > 5 * 1024 * 1024) {
                alert('Image size exceeds 5MB limit.');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>