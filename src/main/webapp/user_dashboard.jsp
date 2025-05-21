<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User, java.util.List, model.Courses, dao.CoursesDAO" %>
<%@ page import="java.util.Base64" %>
<%
// Caching prevention
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

// Fetch session attributes safely
Integer userId = null;
String role = null;
try {
    userId = (Integer) session.getAttribute("userId");
    role = (String) session.getAttribute("role");
} catch (Exception e) {
    System.out.println("user_dashboard.jsp: Error fetching session attributes - " + e.getMessage());
}

if (userId == null || role == null || !"USER".equals(role)) {
    System.out.println("user_dashboard.jsp: Invalid session - userId: " + userId + ", role: " + role + ", redirecting to login");
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

User user = (User) request.getAttribute("user");
if (user == null) {
    System.out.println("user_dashboard.jsp: User not found in request attributes, redirecting to login");
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

// Fetch enrolled courses
CoursesDAO coursesDAO = new CoursesDAO();
List<Courses> enrolledCourses = null;
try {
    enrolledCourses = coursesDAO.getEnrolledCourses(userId);
    System.out.println("user_dashboard.jsp: Successfully fetched " + (enrolledCourses != null ? enrolledCourses.size() : 0) + " enrolled courses for userId: " + userId);
} catch (Exception e) {
    System.err.println("user_dashboard.jsp: Error fetching enrolled courses for userId " + userId + ": " + e.getMessage());
    request.setAttribute("error", "Failed to load enrolled courses. Please try again later.");
}

// Check for session-based messages
String successMessage = (String) session.getAttribute("successMessage");
String errorMessage = (String) session.getAttribute("errorMessage");

// Log the error message to trace "invalid action"
if (errorMessage != null) {
    System.out.println("user_dashboard.jsp: Displaying error message: " + errorMessage);
}

// Clear session messages after retrieving them to prevent repeated display
if (successMessage != null || errorMessage != null) {
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
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
        :root {
            --primary-color: #4a6bff;
            --secondary-color: #ff6b6b;
            --accent-color: #6bceff;
            --dark-color: #2b2d42;
            --light-color: #f8f9fa;
            --text-color: #2d3436;
            --light-text: #636e72;
            --border-radius: 8px;
            --box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            --transition: all 0.3s ease;
        }

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
            padding: 12px 20px;
            border-radius: 6px;
            font-weight: 600;
            text-align: center;
            display: block;
            width: 100%;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        .message.success {
            background-color: #d4edda;
            color: #155724;
            border: 2px solid #c3e6cb;
        }
        .message.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 2px solid #f5c6cb;
        }
        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
        }
        .course-item {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 1px solid #eee;
            padding-bottom: 20px;
        }
        .course-item img {
            width: 100px;
            height: 100px;
            object-fit: cover;
            border-radius: 8px;
            margin-right: 20px;
        }
        .course-item h4 {
            margin: 0;
            color: #1a3c34;
        }
        .course-item p {
            margin: 5px 0;
            color: #666;
        }
        .course-item .button-container {
            display: flex;
            justify-content: flex-start;
            align-items: center;
            gap: 10px;
            margin-top: 10px;
        }
        .view-book-btn, .delete-course-btn {
            padding: 10px;
            border-radius: var(--border-radius);
            font-weight: 600;
            border: none;
            cursor: pointer;
            transition: var(--transition);
            font-size: 14px;
            text-align: center;
            box-sizing: border-box;
            width: 120px;
            min-height: 40px;
        }
        .view-book-btn {
            background-color: #3498db;
            color: #fff;
        }
        .view-book-btn:hover {
            transform: translateY(-2px);
        }
        .delete-course-btn {
            background-color: #e74c3c;
            color: #fff;
        }
        .delete-course-btn:hover {
            transform: translateY(-2px);
        }
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1000;
        }
        .modal-content {
            background-color: #fff;
            margin: 5% auto;
            padding: 20px;
            border-radius: 10px;
            width: 90%;
            max-width: 800px;
            text-align: center;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            position: relative;
        }
        .modal-content h3 {
            margin: 0 0 15px;
            color: #333;
            font-size: 20px;
        }
        .modal-content p {
            margin: 10px 0;
            color: #666;
        }
        .modal-content iframe {
            width: 100%;
            height: 400px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .modal-content .download-btn {
            background-color: #8a2be2;
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 20px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 15px;
            transition: background-color 0.3s;
        }
        .modal-content .download-btn:hover {
            background-color: #6a1ab6;
        }
        .close {
            position: absolute;
            top: 10px;
            right: 15px;
            font-size: 24px;
            cursor: pointer;
            color: #888;
        }
        .close:hover {
            color: #555;
        }
        footer {
            background-color: #1a1a1a;
            color: #fff;
            padding: 20px 40px;
            text-align: center;
            width: 100%;
            margin-top: auto;
        }
        footer p {
            margin: 0;
            font-size: 14px;
            color: #ccc;
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
                        String profileImageSrc = "https://via.placeholder.com/100?text=U";
                        try {
                            if (user.getUsername() != null && user.getUsername().length() > 0) {
                                profileImageSrc = "https://via.placeholder.com/100?text=" + user.getUsername().substring(0, 1).toUpperCase();
                            }
                            if (user.getImage() != null && user.getImage().length > 0) {
                                String base64Image = Base64.getEncoder().encodeToString(user.getImage());
                                profileImageSrc = "data:image/jpeg;base64," + base64Image;
                                System.out.println("JSP: Rendering image for user ID " + user.getId() + ", Base64 length: " + base64Image.length());
                            }
                        } catch (Exception e) {
                            System.err.println("JSP: Error encoding image for user ID " + user.getId() + ": " + e.getMessage());
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
                        <p>Track your learning journey and course completion status here.</p>
                        <!-- Placeholder for future course progress functionality -->
                        <p>Coming soon: Detailed progress tracking with completion percentages and milestones.</p>
                    </div>
                </div>

                <div id="courses" class="tab-content">
                    <h2 class="section-title">My Courses</h2>
                    <div class="info-card">
                        <h3>Enrolled Courses</h3>
                        <% if (successMessage != null) { %>
                            <div class="message success"><%= successMessage %></div>
                        <% } %>
                        <% if (errorMessage != null) { %>
                            <div class="message error"><%= errorMessage %></div>
                        <% } %>
                        <% if (enrolledCourses != null && !enrolledCourses.isEmpty()) { %>
                            <% for (Courses course : enrolledCourses) { %>
                                <div class="course-item">
                                    <% 
                                        String imagePath = null;
                                        String courseImageSrc = "https://via.placeholder.com/100?text=Course";
                                        try {
                                            imagePath = course.getImagePath();
                                            courseImageSrc = (imagePath != null && !imagePath.isEmpty()) ? 
                                                request.getContextPath() + "/" + imagePath : 
                                                "https://via.placeholder.com/100?text=Course";
                                        } catch (Exception e) {
                                            System.err.println("JSP: Error accessing course image path for course ID " + course.getId() + ": " + e.getMessage());
                                        }
                                    %>
                                    <img src="<%= courseImageSrc %>" alt="<%= course.getTitle() != null ? course.getTitle() : "Course" %>">
                                    <div>
                                        <h4><%= (course.getTitle() != null ? course.getTitle() : "Untitled Course") %></h4>
                                        <p>Instructor: <%= (course.getInstructor() != null ? course.getInstructor() : "Unknown") %></p>
                                        <p>Category: <%= (course.getCategory() != null ? course.getCategory() : "N/A") %></p>
                                        <div class="button-container">
                                            <% if (course.getBookPdfFilename() != null && !course.getBookPdfFilename().isEmpty()) { %>
                                                <button class="view-book-btn" onclick="openModal('<%= course.getId() %>', '<%= course.getBookPdfFilename() %>')">View Book</button>
                                            <% } else { %>
                                                <p>No book available</p>
                                            <% } %>
                                            <form action="${pageContext.request.contextPath}/payment" method="post" style="display: inline;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="courseId" value="<%= course.getId() %>">
                                                <button type="submit" class="delete-course-btn" onclick="return confirm('Are you sure you want to unenroll from this course?')">Delete</button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        <% } else { %>
                            <p>No courses enrolled yet. <a href="${pageContext.request.contextPath}/courses.jsp">Explore courses now!</a></p>
                        <% } %>
                    </div>
                </div>

                <div id="settings" class="tab-content">
                    <h2 class="section-title">Account Settings</h2>
                    <div class="info-card">
                        <h3>Update Profile Picture</h3>
                        <form class="edit-form" action="${pageContext.request.contextPath}/user_dashboard" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="uploadImage">
                            <label for="profileImage">Profile Picture:</label>
                            <input type="file" id="profileImage" name="profileImage" accept="image/*">
                            <button type="submit">Update Picture</button>
                        </form>
                    </div>
                    <div class="info-card">
                        <h3>Update Credentials</h3>
                        <form class="edit-form" action="${pageContext.request.contextPath}/user_dashboard" method="post">
                            <input type="hidden" name="action" value="updateCredentials">
                            <label for="username">Username:</label>
                            <input type="text" id="username" name="username" value="<%= user.getUsername() != null ? user.getUsername() : "" %>" required><br>
                            <label for="email">Email:</label>
                            <input type="email" id="email" name="email" value="<%= user.getEmail() != null ? user.getEmail() : "" %>" required><br>
                            <label for="currentPassword">Current Password:</label>
                            <input type="password" id="currentPassword" name="currentPassword" required><br>
                            <label for="newPassword">New Password (optional):</label>
                            <input type="password" id="newPassword" name="newPassword"><br>
                            <label for="confirmNewPassword">Confirm New Password:</label>
                            <input type="password" id="confirmNewPassword" name="confirmNewPassword"><br>
                            <button type="submit">Update Credentials</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal -->
    <div id="bookModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">×</span>
            <h3>Course PDF Overview</h3>
            <p id="modalFilename"></p>
            <iframe id="pdfPreview" src="" frameborder="0"></iframe>
            <button class="download-btn" onclick="downloadBook()">Download</button>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        <p>© 2025 CourseMera. All rights reserved.</p>
    </footer>

    <script>
        document.querySelectorAll('.sidebar-nav a').forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                document.querySelectorAll('.sidebar-nav a').forEach(l => l.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
                this.classList.add('active');
                const tabId = this.getAttribute('data-tab');
                document.getElementById(tabId).classList.add('active');
            });
        });

        function openModal(courseId, filename) {
            try {
                console.log('openModal called with courseId:', courseId, 'filename:', filename);
                if (!courseId || courseId === 'null' || courseId === '' || isNaN(Number(courseId))) {
                    console.error('Invalid courseId:', courseId, 'Type:', typeof courseId);
                    alert('Error: Invalid course ID (' + courseId + '). Please check the course data.');
                    return;
                }

                const modalFilename = document.getElementById('modalFilename');
                const pdfPreview = document.getElementById('pdfPreview');
                const bookModal = document.getElementById('bookModal');

                if (!modalFilename || !pdfPreview || !bookModal) {
                    console.error('Modal elements missing:', {
                        modalFilename: !!modalFilename,
                        pdfPreview: !!pdfPreview,
                        bookModal: !!bookModal
                    });
                    alert('Error: PDF modal components not found. Please check the browser console.');
                    return;
                }

                modalFilename.innerText = filename;
                pdfPreview.src = '';
                const baseUrl = '${pageContext.request.contextPath}/user_download_book?courseId=' + encodeURIComponent(courseId) + '&download=false';
                let pdfUrl = baseUrl;
                if (!filename.startsWith('Uploads/')) {
                    pdfUrl = baseUrl + '&fallback=true';
                    console.log('Using fallback URL for non-prefixed filename:', filename);
                }
                console.log('Setting pdfPreview src to:', pdfUrl);

                bookModal.style.display = 'block';
                setTimeout(() => {
                    pdfPreview.src = pdfUrl;
                    console.log('pdfPreview src set to:', pdfUrl);
                }, 100);

                window.currentCourseId = courseId;
                window.currentFilename = filename;
                console.log('Modal opened, currentCourseId set to:', window.currentCourseId, 'filename:', filename);
            } catch (error) {
                console.error('Error in openModal for courseId ' + courseId + ':', error);
                alert('An error occurred while opening the PDF modal. Please check the browser console.');
            }
        }

        function closeModal() {
            try {
                const bookModal = document.getElementById('bookModal');
                const pdfPreview = document.getElementById('pdfPreview');

                if (!bookModal || !pdfPreview) {
                    console.error('Modal elements missing:', {
                        bookModal: !!bookModal,
                        pdfPreview: !!pdfPreview
                    });
                    alert('Error: PDF modal components not found. Please check the browser console.');
                    return;
                }

                bookModal.style.display = 'none';
                pdfPreview.src = '';
                window.currentCourseId = null;
                window.currentFilename = null;
                console.log('Modal closed, currentCourseId and filename cleared');
            } catch (error) {
                console.error('Error in closeModal:', error);
                alert('An error occurred while closing the PDF modal. Please check the browser console.');
            }
        }

        function downloadBook() {
            try {
                console.log('downloadBook called, currentCourseId:', window.currentCourseId, 'filename:', window.currentFilename);
                if (!window.currentCourseId) {
                    console.error('No courseId set for downloadBook');
                    alert('Error: No course selected for download. Please try opening the modal again.');
                    return;
                }

                let downloadUrl = '${pageContext.request.contextPath}/user_download_book?courseId=' + encodeURIComponent(window.currentCourseId) + '&download=true';
                if (window.currentFilename && !window.currentFilename.startsWith('Uploads/')) {
                    downloadUrl += '&fallback=true';
                    console.log('Using fallback URL for download:', window.currentFilename);
                }
                console.log('Initiating download with URL:', downloadUrl);

                const link = document.createElement('a');
                link.href = downloadUrl;
                link.download = '';
                link.target = '_blank';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);

                console.log('Download triggered for courseId:', window.currentCourseId);
                closeModal();
            } catch (error) {
                console.error('Error in downloadBook:', error);
                alert('An error occurred while downloading the PDF. Please check the browser console.');
            }
        }

        window.onclick = function(event) {
            const modal = document.getElementById('bookModal');
            if (event.target == modal) {
                closeModal();
            }
        }
    </script>
</body>
</html>