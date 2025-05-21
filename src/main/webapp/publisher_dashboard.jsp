<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Courses, dao.CoursesDAO, model.Publisher, dao.PublisherDAO, java.nio.file.Paths" %>
<%
// Prevent caching
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

// Check for session token cookie
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

// Validate session token
String role = (String) session.getAttribute("role");
Integer publisherId = (Integer) session.getAttribute("publisherId");
String email = (String) session.getAttribute("email");
String storedSessionToken = (String) session.getAttribute("sessionToken");

if (sessionToken == null || storedSessionToken == null || !sessionToken.equals(storedSessionToken) || !"PUBLISHER".equals(role) || publisherId == null) {
    System.out.println("publisher_dashboard.jsp: Invalid session token or unauthorized access, redirecting to publisher_login.jsp");
    response.sendRedirect("publisher_login.jsp");
    return;
}

// Debug session attributes
System.out.println("publisher_dashboard.jsp: role=" + role + ", publisherId=" + publisherId + ", email=" + email + ", sessionId=" + (session != null ? session.getId() : "null"));

// Fetch publisher's courses with null check
CoursesDAO coursesDAO = new CoursesDAO();
List<Courses> publisherCourses = null;
if (publisherId != null) {
    publisherCourses = coursesDAO.getCoursesByPublisher(publisherId);
} else {
    publisherCourses = List.of(); // Empty list if publisherId is null
}

// Fetch publisher details for profile
PublisherDAO publisherDAO = new PublisherDAO();
Publisher publisher = publisherDAO.getPublisherByEmail(email);

// Handle messages from session
String message = (String) session.getAttribute("message");
String error = (String) session.getAttribute("error");
// Clear session attributes after retrieving them
if (message != null) {
    session.removeAttribute("message");
}
if (error != null) {
    session.removeAttribute("error");
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Publisher Dashboard - Coursemera</title>
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
            --box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s ease;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            background-color: var(--light-color);
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 24px;
        }

        header {
            background-color: #fff;
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
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
        header nav a {
            color: #666;
            font-size: 16px;
            position: relative;
            transition: color 0.3s ease;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
        }
        header nav a:hover {
            color: #333;
        }
        header nav a.nav-link {
            background: linear-gradient(135deg, #3498db, #1e6bb8);
            color: #fff;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
        }
        header nav a.nav-link:hover {
            background: linear-gradient(135deg, #4aa3e8, #2b82d1);
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
        }
        header nav a.logout-button:hover {
            background: linear-gradient(135deg, #ff6655, #e74c3c);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            transform: scale(1.05);
        }
        .logo {
            width: 80px;
            height: 80px;
        }

        .main-content {
            flex: 1;
            padding: 40px 20px;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .section-title {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 16px;
            text-align: center;
        }

        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 24px;
        }

        .course-card {
            background: white;
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: var(--box-shadow);
            transition: var(--transition);
            position: relative;
        }

        .course-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
        }

        .course-image {
            width: 100%;
            height: 160px;
            object-fit: cover;
        }

        .course-content {
            padding: 16px;
        }

        .course-category {
            font-size: 12px;
            color: var(--primary-color);
            font-weight: 600;
            margin-bottom: 8px;
        }

        .course-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .course-instructor {
            font-size: 14px;
            color: var(--light-text);
            margin-bottom: 12px;
        }

        .course-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }

        .course-price {
            font-weight: 700;
            color: var(--dark-color);
        }

        .course-rating {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .stars {
            color: #ffc107;
        }

        .rating-count {
            font-size: 12px;
            color: var(--light-text);
        }

        .edit-form, .upload-form, .profile-form {
            display: block;
            padding: 16px;
            background: #f0f4ff;
            border-radius: var(--border-radius);
            margin-bottom: 20px;
            position: relative;
        }

        .edit-form label, .upload-form label, .profile-form label {
            display: block;
            margin: 5px 0 2px;
            font-size: 14px;
            color: var(--text-color);
        }

        .edit-form input[type="text"],
        .edit-form input[type="number"],
        .edit-form input[type="file"],
        .upload-form input[type="text"],
        .upload-form input[type="number"],
        .upload-form input[type="file"],
        .profile-form input[type="text"],
        .profile-form input[type="file"] {
            width: 100%;
            padding: 8px;
            margin: 5px 0;
            border: 1px solid #ccc;
            border-radius: var(--border-radius);
            box-sizing: border-box;
        }

        .edit-form img {
            max-width: 100px;
            max-height: 100px;
            margin: 5px 0;
            border-radius: var(--border-radius);
        }

        .profile-form .profile-pic-container {
            position: absolute;
            top: 16px;
            right: 16px;
        }

        .profile-form img {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--primary-color);
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
        }

        .profile-form .no-pic {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background-color: #e0e0e0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            font-size: 14px;
        }

        .edit-btn, .delete-btn, .save-btn, .cancel-btn, .upload-btn {
            padding: 10px;
            border-radius: var(--border-radius);
            font-weight: 600;
            border: none;
            cursor: pointer;
            transition: var(--transition);
            font-size: 14px;
            text-align: center;
            box-sizing: border-box;
            min-height: 40px;
            width: 100%;
        }

        .button-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            margin-top: 10px;
        }

        .edit-btn {
            background: #f1c40f;
            color: #fff;
        }

        .delete-btn {
            background: #e74c3c;
            color: #fff;
        }

        .save-btn, .upload-btn {
            background: var(--primary-color);
            color: white;
        }

        .cancel-btn {
            background: #ccc;
            color: black;
        }

        .edit-btn:hover, .delete-btn:hover, .save-btn:hover, .cancel-btn:hover, .upload-btn:hover {
            transform: translateY(-2px);
        }

        .error {
            color: #e74c3c;
            font-size: 14px;
            text-align: center;
            margin: 10px 0;
        }

        .message {
            color: #27ae60;
            font-size: 14px;
            text-align: center;
            margin: 10px 0;
        }

        footer {
            background-color: #1a1a1a;
            color: #fff;
            padding: 60px 40px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 40px;
            margin-top: auto;
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

        @media (max-width: 768px) {
            header {
                flex-direction: column;
                gap: 16px;
            }
            header nav {
                width: 100%;
                justify-content: center;
                flex-wrap: wrap;
            }
            .profile-form .profile-pic-container {
                position: static;
                text-align: center;
                margin-bottom: 20px;
            }
            .profile-form img, .profile-form .no-pic {
                margin: 0 auto;
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="flex items-center">
            <img src="logo.png" alt="Coursemera Logo" class="logo">
            <h1>Coursemera</h1>
        </div>
        <nav>
            <a href="#" class="nav-link" onclick="showSection('manage-courses')">Manage Courses</a>
            <a href="#" class="nav-link" onclick="showSection('my-courses')">My Courses</a>
            <a href="#" class="nav-link" onclick="showSection('manage-profile')">Manage Profile</a>
            <a href="${pageContext.request.contextPath}/logout" class="logout-button">Logout</a>
        </nav>
    </header>

    <div class="main-content">
        <section id="manage-courses" class="courses-section">
            <div class="container">
                <div class="section-header">
                    <h2 class="section-title">Manage Courses</h2>
                </div>
                <% if (message != null) { %>
                    <p class="message"><%= message %></p>
                <% } %>
                <% if (error != null) { %>
                    <p class="error"><%= error %></p>
                <% } %>
                <div class="upload-form">
                    <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" enctype="multipart/form-data" onsubmit="return validateUploadForm(this)">
                        <input type="hidden" name="action" value="create">
                        <input type="hidden" name="publisherId" value="<%= publisherId %>">
                        <label for="title">Title:</label>
                        <input type="text" id="title" name="title" required>
                        <label for="category">Category:</label>
                        <input type="text" id="category" name="category" required>
                        <label for="instructor">Instructor:</label>
                        <input type="text" id="instructor" name="instructor" required>
                        <label for="price">Price:</label>
                        <input type="number" id="price" name="price" step="0.01" min="0" required>
                        <label for="image">Image:</label>
                        <input type="file" id="image" name="image" accept="image/*" required>
                        <label for="bookPdf">Book PDF (optional):</label>
                        <input type="file" id="bookPdf" name="bookPdf" accept="application/pdf">
                        <div style="display: flex; gap: 8px;">
                            <button type="submit" class="upload-btn">Upload</button>
                            <button type="reset" class="cancel-btn">Reset</button>
                        </div>
                    </form>
                </div>
            </div>
        </section>

        <section id="my-courses" class="courses-section" style="display: none;">
            <div class="container">
                <div class="section-header">
                    <h2 class="section-title">My Courses</h2>
                </div>
                <% if (message != null) { %>
                    <p class="message"><%= message %></p>
                <% } %>
                <% if (error != null) { %>
                    <p class="error"><%= error %></p>
                <% } %>
                <div class="course-grid">
                    <% 
                        if (publisherCourses != null && !publisherCourses.isEmpty()) {
                            for (Courses course : publisherCourses) {
                                if (course != null) {
                                    Integer courseId = course.getId();
                                    if (courseId != null && courseId > 0) {
                                        String courseIdStr = String.valueOf(courseId);
                                        String imagePath = course.getImagePath() != null && !course.getImagePath().isEmpty() ? 
                                            request.getContextPath() + "/" + course.getImagePath() : 
                                            "https://images.unsplash.com/photo-1593642632823-8f785ba67e45?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60";
                                        // Safely extract the filename from book_pdf_filename
                                        String pdfDisplayName = "Not uploaded";
                                        if (course.getBookPdfFilename() != null && !course.getBookPdfFilename().isEmpty()) {
                                            try {
                                                pdfDisplayName = Paths.get(course.getBookPdfFilename()).getFileName().toString();
                                            } catch (Exception e) {
                                                pdfDisplayName = course.getBookPdfFilename(); // Fallback to raw value
                                                System.err.println("Error parsing PDF filename for course ID " + courseId + ": " + e.getMessage());
                                            }
                                        }
                    %>
                        <div class="course-card" id="course-<%= courseIdStr %>">
                            <div class="course-display">
                                <img src="<%= imagePath %>" alt="<%= course.getTitle() != null ? course.getTitle() : "Course" %>" class="course-image">
                                <div class="course-content">
                                    <div class="course-category"><%= course.getCategory() != null ? course.getCategory() : "No Category" %></div>
                                    <h3 class="course-title"><%= course.getTitle() != null ? course.getTitle() : "No Title" %></h3>
                                    <div class="course-instructor"><%= course.getInstructor() != null ? course.getInstructor() : "No Instructor" %></div>
                                    <div class="course-meta">
                                        <div class="course-price">$<%= String.format("%.2f", course.getPrice()) %></div>
                                        <div class="course-rating">
                                            <div class="stars">★★★★★</div>
                                            <div class="rating-count">(0)</div>
                                        </div>
                                    </div>
                                    <p><strong>Book PDF:</strong> <%= pdfDisplayName %></p>
                                    <div class="button-container">
                                        <button class="edit-btn" onclick="toggleEditForm('<%= courseIdStr %>')">Edit</button>
                                        <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" style="width: 100%;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="courseId" value="<%= courseIdStr %>">
                                            <button type="submit" class="delete-btn">Delete</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                            <div class="edit-form" id="edit-form-<%= courseIdStr %>" style="display: none;">
                                <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" enctype="multipart/form-data" onsubmit="return validateForm(this)">
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="courseId" value="<%= courseIdStr %>">
                                    <label for="title-<%= courseIdStr %>">Title:</label>
                                    <input type="text" id="title-<%= courseIdStr %>" name="title" value="<%= course.getTitle() != null ? course.getTitle() : "" %>" required>
                                    <label for="category-<%= courseIdStr %>">Category:</label>
                                    <input type="text" id="category-<%= courseIdStr %>" name="category" value="<%= course.getCategory() != null ? course.getCategory() : "" %>" required>
                                    <label for="instructor-<%= courseIdStr %>">Instructor:</label>
                                    <input type="text" id="instructor-<%= courseIdStr %>" name="instructor" value="<%= course.getInstructor() != null ? course.getInstructor() : "" %>" required>
                                    <label for="price-<%= courseIdStr %>">Price:</label>
                                    <input type="number" id="price-<%= courseIdStr %>" name="price" step="0.01" min="0" value="<%= String.format("%.2f", course.getPrice()) %>" required>
                                    <label for="image-<%= courseIdStr %>">Image (optional):</label>
                                    <input type="file" id="image-<%= courseIdStr %>" name="image" accept="image/*">
                                    <% if (course.getImagePath() != null && !course.getImagePath().isEmpty()) { %>
                                        <p>Current Image: <img src="<%= request.getContextPath() + "/" + course.getImagePath() %>" alt="Course Image"></p>
                                    <% } %>
                                    <label for="bookPdf-<%= courseIdStr %>">Book PDF (optional):</label>
                                    <input type="file" id="bookPdf-<%= courseIdStr %>" name="bookPdf" accept="application/pdf">
                                    <% if (course.getBookPdfFilename() != null && !course.getBookPdfFilename().isEmpty()) { %>
                                        <p>Current Book PDF: <%= pdfDisplayName %></p>
                                    <% } else { %>
                                        <p>Current Book PDF: Not uploaded</p>
                                    <% } %>
                                    <div style="display: flex; gap: 8px;">
                                        <button type="submit" class="save-btn">Save</button>
                                        <button type="button" class="cancel-btn" onclick="toggleEditForm('<%= courseIdStr %>')">Cancel</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    <% 
                                    } else {
                                        out.println("<p class='error'>Invalid course data (ID: " + (courseId != null ? courseId : "null") + "). Skipping display.</p>");
                                    }
                                } else {
                                    out.println("<p class='error'>Null course object encountered. Skipping display.</p>");
                                }
                            }
                        } else {
                    %>
                        <p class="error">No courses found.</p>
                    <% } %>
                </div>
            </div>
        </section>

        <section id="manage-profile" class="courses-section" style="display: none;">
            <div class="container">
                <div class="section-header">
                    <h2 class="section-title">Manage Profile</h2>
                </div>
                <% if (message != null) { %>
                    <p class="message"><%= message %></p>
                <% } %>
                <% if (error != null) { %>
                    <p class="error"><%= error %></p>
                <% } %>
                <div class="profile-form">
                    <div class="profile-pic-container">
                        <% if (publisher != null && publisher.getProfilePicture() != null) { %>
                            <img src="data:image/jpeg;base64,<%= java.util.Base64.getEncoder().encodeToString(publisher.getProfilePicture()) %>" alt="Profile Picture">
                        <% } else { %>
                            <div class="no-pic">No Image</div>
                        <% } %>
                    </div>
                    <div class="profile-details">
                        <p><strong>First Name:</strong> <%= publisher != null && publisher.getFirstName() != null ? publisher.getFirstName() : "Not set" %></p>
                        <p><strong>Last Name:</strong> <%= publisher != null && publisher.getLastName() != null ? publisher.getLastName() : "Not set" %></p>
                        <p><strong>Email:</strong> <%= publisher != null && publisher.getEmail() != null ? publisher.getEmail() : "Not set" %></p>
                        <p><strong>Resume:</strong> <%= publisher != null && publisher.getResumeFilename() != null ? "<a href='download_resume?publisherId=" + publisherId + "' target='_blank'>" + publisher.getResumeFilename() + "</a>" : "No resume uploaded." %></p>
                    </div>
                    <form action="${pageContext.request.contextPath}/ProfileManagementServlet" method="post" enctype="multipart/form-data" onsubmit="return validateProfileForm(this)">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="publisherId" value="<%= publisherId %>">
                        <label for="firstName">Update First Name:</label>
                        <input type="text" id="firstName" name="firstName" value="<%= publisher != null && publisher.getFirstName() != null ? publisher.getFirstName() : "" %>" required>
                        <label for="lastName">Update Last Name:</label>
                        <input type="text" id="lastName" name="lastName" value="<%= publisher != null && publisher.getLastName() != null ? publisher.getLastName() : "" %>" required>
                        <label for="email">Update Email:</label>
                        <input type="text" id="email" name="email" value="<%= publisher != null && publisher.getEmail() != null ? publisher.getEmail() : "" %>" required>
                        <label for="profilePicture">Update Profile Picture (optional):</label>
                        <input type="file" id="profilePicture" name="profilePicture" accept="image/*">
                        <label for="resume">Update Resume (optional):</label>
                        <input type="file" id="resume" name="resume" accept="application/pdf">
                        <% if (publisher != null && publisher.getResumeFilename() != null) { %>
                            <p>Current Resume: <%= publisher.getResumeFilename() %></p>
                        <% } else { %>
                            <p>Current Resume: Not uploaded</p>
                        <% } %>
                        <div style="display: flex; gap: 8px;">
                            <button type="submit" class="save-btn">Save Changes</button>
                            <button type="reset" class="cancel-btn">Reset</button>
                        </div>
                    </form>
                </div>
            </div>
        </section>
    </div>

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

    <script>
        function showSection(sectionId) {
            const sections = ['manage-courses', 'my-courses', 'manage-profile'];
            sections.forEach(id => {
                const section = document.getElementById(id);
                if (section) {
                    section.style.display = id === sectionId ? 'block' : 'none';
                }
            });
        }
        window.onload = function() {
            showSection('manage-courses');
        };

        function toggleEditForm(courseId) {
            try {
                if (!courseId || courseId === 'null' || courseId === '' || isNaN(Number(courseId))) {
                    console.error('Invalid courseId passed to toggleEditForm:', courseId, 'Type:', typeof courseId);
                    alert('Error: Invalid course ID (' + courseId + '). Cannot open edit form.');
                    return;
                }

                const numericId = Number(courseId);
                const display = document.getElementById('course-' + courseId)?.querySelector('.course-display');
                const form = document.getElementById('edit-form-' + courseId);

                if (!display || !form) {
                    console.error('Elements not found: course-' + courseId + ' or edit-form-' + courseId);
                    console.log('DOM check:', {
                        courseElement: document.getElementById('course-' + courseId),
                        formElement: document.getElementById('edit-form-' + courseId),
                        courseId: courseId
                    });
                    alert('Error: Unable to toggle edit form for course ID ' + courseId + '. Check the console for details.');
                    return;
                }

                console.log('Toggling form for courseId:', courseId);
                const isFormVisible = form.style.display === 'block';
                display.style.display = isFormVisible ? 'block' : 'none';
                form.style.display = isFormVisible ? 'none' : 'block';
            } catch (error) {
                console.error('Error in toggleEditForm for courseId ' + courseId + ':', error);
                alert('An error occurred while opening the edit form for course ID ' + courseId + '. Check the console for details.');
            }
        }

        function validateForm(form) {
            try {
                const title = form.querySelector('input[name="title"]').value.trim();
                const category = form.querySelector('input[name="category"]').value.trim();
                const instructor = form.querySelector('input[name="instructor"]').value.trim();
                const price = parseFloat(form.querySelector('input[name="price"]').value);
                const bookPdf = form.querySelector('input[name="bookPdf"]').files[0];

                if (title === '') {
                    alert('Title is required.');
                    return false;
                }
                if (category === '') {
                    alert('Category is required.');
                    return false;
                }
                if (instructor === '') {
                    alert('Instructor is required.');
                    return false;
                }
                if (isNaN(price) || price < 0) {
                    alert('Price must be a non-negative number.');
                    return false;
                }
                if (bookPdf && bookPdf.size > 10 * 1024 * 1024) { // 10MB limit
                    alert('Book PDF must be less than 10MB.');
                    return false;
                }
                return true;
            } catch (error) {
                console.error('Error in validateForm:', error);
                alert('An error occurred while validating the form.');
                return false;
            }
        }

        function validateUploadForm(form) {
            try {
                const title = form.querySelector('input[name="title"]').value.trim();
                const category = form.querySelector('input[name="category"]').value.trim();
                const instructor = form.querySelector('input[name="instructor"]').value.trim();
                const price = parseFloat(form.querySelector('input[name="price"]').value);
                const image = form.querySelector('input[name="image"]').files.length;
                const bookPdf = form.querySelector('input[name="bookPdf"]').files[0];

                if (title === '') {
                    alert('Title is required.');
                    return false;
                }
                if (category === '') {
                    alert('Category is required.');
                    return false;
                }
                if (instructor === '') {
                    alert('Instructor is required.');
                    return false;
                }
                if (isNaN(price) || price < 0) {
                    alert('Price must be a non-negative number.');
                    return false;
                }
                if (image === 0) {
                    alert('An image is required for new courses.');
                    return false;
                }
                if (bookPdf && bookPdf.size > 10 * 1024 * 1024) { // 10MB limit
                    alert('Book PDF must be less than 10MB.');
                    return false;
                }
                return true;
            } catch (error) {
                console.error('Error in validateUploadForm:', error);
                alert('An error occurred while validating the upload form.');
                return false;
            }
        }

        function validateProfileForm(form) {
            try {
                const firstName = form.querySelector('input[name="firstName"]').value.trim();
                const lastName = form.querySelector('input[name="lastName"]').value.trim();
                const email = form.querySelector('input[name="email"]').value.trim();
                const profilePicture = form.querySelector('input[name="profilePicture"]').files[0];
                const resume = form.querySelector('input[name="resume"]').files[0];

                if (firstName === '') {
                    alert('First name is required.');
                    return false;
                }
                if (lastName === '') {
                    alert('Last name is required.');
                    return false;
                }
                if (email === '') {
                    alert('Email is required.');
                    return false;
                }
                if (profilePicture && profilePicture.size > 2 * 1024 * 1024) { // 2MB limit
                    alert('Profile picture must be less than 2MB.');
                    return false;
                }
                if (resume && resume.size > 5 * 1024 * 1024) { // 5MB limit for resume
                    alert('Resume must be less than 5MB.');
                    return false;
                }
                return true;
            } catch (error) {
                console.error('Error in validateProfileForm:', error);
                alert('An error occurred while validating the profile form.');
                return false;
            }
        }
    </script>
</body>
</html>