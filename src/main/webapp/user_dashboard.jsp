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
    <title>Dashboard - Coursemera</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        :root {
            --primary-color: #005f73;
            --secondary-color: #0a9396;
            --accent-color: #94d2bd;
            --dark-color: #001219;
            --light-color: #f8fafc;
            --text-color: #1e293b;
            --light-text: #64748b;
            --border-radius: 6px;
            --box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            --transition: all 0.2s ease;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html, body {
            height: 100%;
            margin: 0;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f1f5f9;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            color: var(--text-color);
            line-height: 1.5;
        }

        .dashboard-container {
            width: 100vw;
            height: 100vh;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #ffffff;
            padding: 20px 24px;
            border-bottom: 1px solid #e2e8f0;
            box-shadow: var(--box-shadow);
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .profile-pic {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 24px;
            font-weight: 600;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            border: 2px solid #fff;
            transition: var(--transition);
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
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--dark-color);
        }

        .user-info p {
            margin: 4px 0 0;
            color: var(--light-text);
            font-size: 0.875rem;
        }

        .dashboard-header .button-container {
            display: flex;
            gap: 12px;
        }

        .dashboard-header .home-btn,
        .dashboard-header .logout-btn {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.875rem;
            transition: var(--transition);
        }

        .dashboard-header .home-btn {
            background: var(--primary-color);
            color: #fff;
        }

        .dashboard-header .home-btn:hover {
            background: var(--secondary-color);
        }

        .dashboard-header .logout-btn {
            background: #dc2626;
            color: #fff;
        }

        .dashboard-header .logout-btn:hover {
            background: #b91c1c;
        }

        .dashboard-content {
            display: grid;
            grid-template-columns: 240px 1fr;
            flex: 1;
            overflow: hidden;
        }

        .sidebar {
            background: #ffffff;
            border-right: 1px solid #e2e8f0;
            padding: 16px;
            overflow-y: auto;
            height: 100%;
        }

        .sidebar-nav a {
            display: flex;
            align-items: center;
            padding: 10px 12px;
            color: var(--text-color);
            text-decoration: none;
            border-radius: var(--border-radius);
            margin-bottom: 4px;
            font-size: 0.875rem;
            font-weight: 500;
            transition: var(--transition);
        }

        .sidebar-nav a:hover {
            background: var(--light-color);
            color: var(--primary-color);
        }

        .sidebar-nav a.active {
            background: var(--primary-color);
            color: #fff;
        }

        .sidebar-nav a i {
            margin-right: 8px;
            width: 20px;
            text-align: center;
            font-size: 1rem;
        }

        .main-content {
            background: #ffffff;
            padding: 20px;
            overflow-y: auto;
            height: 100%;
            width: 100%;
            margin: 0;
        }

        .section-title {
            margin: 0 0 16px;
            color: var(--dark-color);
            font-size: 1.5rem;
            font-weight: 600;
            position: relative;
            padding-bottom: 8px;
        }

        .section-title::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 40px;
            height: 3px;
            background: var(--primary-color);
        }

        .info-card {
            background: #ffffff;
            border-radius: var(--border-radius);
            padding: 16px;
            margin-bottom: 16px;
            border: 1px solid #e2e8f0;
            transition: var(--transition);
        }

        .info-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .info-card h3 {
            margin: 0 0 12px;
            color: var(--dark-color);
            font-size: 1.125rem;
            font-weight: 600;
        }

        .info-row {
            display: flex;
            margin-bottom: 8px;
            align-items: center;
        }

        .info-label {
            font-weight: 500;
            width: 140px;
            color: var(--light-text);
            font-size: 0.875rem;
        }

        .info-value {
            color: var(--text-color);
            font-size: 0.875rem;
            font-weight: 400;
        }

        .edit-form {
            margin-top: 12px;
        }

        .edit-form input[type="text"],
        .edit-form input[type="email"],
        .edit-form input[type="password"],
        .edit-form input[type="file"] {
            padding: 8px;
            margin-bottom: 8px;
            width: 100%;
            max-width: 240px;
            border: 1px solid #d1d5db;
            border-radius: var(--border-radius);
            font-size: 0.875rem;
            transition: var(--transition);
        }

        .edit-form input:focus {
            border-color: var(--primary-color);
            outline: none;
        }

        .edit-form button {
            padding: 8px 16px;
            background: var(--primary-color);
            color: #fff;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-size: 0.875rem;
            font-weight: 500;
            transition: var(--transition);
        }

        .edit-form button:hover {
            background: var(--secondary-color);
        }

        .message {
            margin-bottom: 12px;
            padding: 10px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 0.875rem;
            text-align: center;
            max-width: 480px;
            margin-left: auto;
            margin-right: auto;
        }

        .message.success {
            background: #ecfdf5;
            color: #065f46;
            border: 1px solid #6ee7b7;
        }

        .message.error {
            background: #fef2f2;
            color: #991b1b;
            border: 1px solid #f87171;
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 16px;
            margin-top: 16px;
        }

        .course-item {
            background: #ffffff;
            border-radius: var(--border-radius);
            padding: 12px;
            box-shadow: var(--box-shadow);
            display: flex;
            flex-direction: column;
            transition: var(--transition);
        }

        .course-item:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .course-item img {
            width: 100%;
            height: 120px;
            object-fit: cover;
            border-radius: var(--border-radius);
            margin-bottom: 12px;
        }

        .course-item h4 {
            margin: 0 0 8px;
            color: var(--dark-color);
            font-size: 1rem;
            font-weight: 600;
        }

        .course-item p {
            margin: 4px 0;
            color: var(--light-text);
            font-size: 0.75rem;
        }

        .course-item .button-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
            margin-top: 12px;
        }

        .view-book-btn,
        .delete-course-btn {
            padding: 8px;
            border-radius: var(--border-radius);
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: var(--transition);
            font-size: 0.75rem;
            text-align: center;
            width: 100px;
            min-height: 32px;
        }

        .view-book-btn {
            background: var(--primary-color);
            color: #fff;
        }

        .view-book-btn:hover {
            background: var(--secondary-color);
        }

        .delete-course-btn {
            background: #dc2626;
            color: #fff;
        }

        .delete-course-btn:hover {
            background: #b91c1c;
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            z-index: 1000;
        }

        .modal-content {
            background: #ffffff;
            margin: 5% auto;
            padding: 20px;
            border-radius: var(--border-radius);
            width: 90%;
            max-width: 720px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            position: relative;
        }

        .modal-content h3 {
            margin: 0 0 12px;
            color: var(--dark-color);
            font-size: 1.25rem;
            font-weight: 600;
        }

        .modal-content p {
            margin: 8px 0;
            color: var(--light-text);
            font-size: 0.875rem;
        }

        .modal-content iframe {
            width: 100%;
            height: 360px;
            border: 1px solid #e2e8f0;
            border-radius: var(--border-radius);
        }

        .modal-content .download-btn {
            background: #7c3aed;
            color: #fff;
            padding: 8px 16px;
            border: none;
            border-radius: var(--border-radius);
            font-size: 0.875rem;
            cursor: pointer;
            margin-top: 12px;
            transition: var(--transition);
        }

        .modal-content .download-btn:hover {
            background: #6d28d9;
        }

        .close {
            position: absolute;
            top: 12px;
            right: 16px;
            font-size: 20px;
            cursor: pointer;
            color: var(--light-text);
            transition: var(--transition);
        }

        .close:hover {
            color: var(--text-color);
        }
    </style>
</head>
<body>
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
            <div class="button-container">
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
                            <div class="course-grid">
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
                                <% } %>
                            </div>
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