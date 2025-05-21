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
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #f1f5f9;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            color: var(--text-color);
            line-height: 1.5;
        }

        .dashboard-container {
            width: 100vw;
            min-height: 100vh;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
        }

        header {
            background: #ffffff;
            padding: 20px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e2e8f0;
            box-shadow: var(--box-shadow);
        }

        header .logo-container {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        header .logo {
            width: 48px;
            height: 48px;
        }

        header h1 {
            font-size: 1.75rem;
            font-weight: 600;
            color: var(--dark-color);
           background: linear-gradient(135deg, #3498db, #1e90ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
            margin:0
        }

        header nav {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        header nav a {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.875rem;
            transition: var(--transition);
            color: #fff;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        header nav a.nav-link {
            background: var(--primary-color);
        }

        header nav a.nav-link:hover {
            background: var(--secondary-color);
        }

        header nav a.logout-button {
            background: #dc2626;
        }

        header nav a.logout-button:hover {
            background: #b91c1c;
        }

        .main-content {
            flex: 1;
            padding: 24px;
            overflow-y: auto;
            background: #ffffff;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--dark-color);
            margin: 0;
            padding-bottom: 8px;
            position: relative;
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

        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 16px;
        }

        .course-card {
            background: #ffffff;
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: var(--box-shadow);
            transition: var(--transition);
        }

        .course-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .course-image {
            width: 100%;
            height: 120px;
            object-fit: cover;
            border-radius: var(--border-radius) var(--border-radius) 0 0;
        }

        .course-content {
            padding: 12px;
        }

        .course-category {
            font-size: 0.75rem;
            color: var(--primary-color);
            font-weight: 600;
            margin-bottom: 8px;
        }

        .course-title {
            font-size: 1rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 8px;
        }

        .course-instructor {
            font-size: 0.75rem;
            color: var(--light-text);
            margin-bottom: 8px;
        }

        .course-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }

        .course-price {
            font-weight: 600;
            color: var(--dark-color);
            font-size: 0.875rem;
        }

        .course-rating {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .stars {
            color: #f59e0b;
            font-size: 0.75rem;
        }

        .rating-count {
            font-size: 0.75rem;
            color: var(--light-text);
        }

        .course-card p {
            font-size: 0.75rem;
            color: var(--light-text);
            margin-bottom: 8px;
        }

        .edit-form, .upload-form, .profile-form {
            padding: 16px;
            background: #f8fafc;
            border-radius: var(--border-radius);
            margin-bottom: 16px;
            border: 1px solid #e2e8f0;
        }

        .edit-form label, .upload-form label, .profile-form label {
            display: block;
            margin: 4px 0;
            font-size: 0.875rem;
            color: var(--text-color);
            font-weight: 500;
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
            margin-bottom: 8px;
            border: 1px solid #d1d5db;
            border-radius: var(--border-radius);
            font-size: 0.875rem;
            transition: var(--transition);
        }

        .edit-form input:focus,
        .upload-form input:focus,
        .profile-form input:focus {
            border-color: var(--primary-color);
            outline: none;
        }

        .edit-form img {
            max-width: 80px;
            max-height: 80px;
            margin: 4px 0;
            border-radius: var(--border-radius);
        }

        .profile-form .profile-pic-container {
            margin-bottom: 12px;
        }

        .profile-form img {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--primary-color);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .profile-form .no-pic {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--light-text);
            font-size: 0.75rem;
        }

        .profile-details {
            margin-bottom: 16px;
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
        }

        .profile-details .profile-pic-container {
            flex: 0 0 auto;
        }

        .profile-details .details-text {
            flex: 1;
            min-width: 200px;
        }

        .profile-details p {
            font-size: 0.875rem;
            color: var(--text-color);
            margin-bottom: 8px;
        }

        .profile-details a {
            color: var(--primary-color);
            text-decoration: none;
        }

        .profile-details a:hover {
            text-decoration: underline;
        }

        .edit-btn,.ConcurrentModificationException .delete-btn, .save-btn, .cancel-btn, .upload-btn {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: var(--transition);
            font-size: 0.875rem;
            text-align: center;
            min-height: 32px;
        }

        .button-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
        }

        .edit-btn {
            background: var(--primary-color);
            color: #fff;
        }

        .edit-btn:hover {
            background: var(--secondary-color);
        }

        .delete-btn {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: var(--transition);
            font-size: 0.875rem;
            text-align: center;
            min-height: 32px;
            background: #dc2626;
            color: #fff;
        }

        .delete-btn:hover {
            background: #b91c1c;
        }

        .save-btn, .upload-btn {
            background: var(--primary-color);
            color: #fff;
        }

        .save-btn:hover, .upload-btn:hover {
            background: var(--secondary-color);
        }

        .cancel-btn {
            background: #e2e8f0;
            color: var(--text-color);
        }

        .cancel-btn:hover {
            background: #d1d5db;
        }

        .error {
            color: #dc2626;
            font-size: 0.875rem;
            text-align: center;
            margin: 8px 0;
            padding: 8px;
            background: #fef2f2;
            border: 1px solid #f87171;
            border-radius: var(--border-radius);
        }

        .message {
            color: #065f46;
            font-size: 0.875rem;
            text-align: center;
            margin: 8px 0;
            padding: 8px;
            background: #ecfdf5;
            border: 1px solid #6ee7b7;
            border-radius: var(--border-radius);
        }

        footer {
            background: var(--dark-color);
            color: var(--light-color);
            padding: 40px 24px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 24px;
        }

        .footer-sections {
            display: flex;
            gap: 32px;
            flex-wrap: wrap;
            justify-content: center;
        }

        .footer-section {
            min-width: 160px;
        }

        .footer-section h3 {
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 12px;
            color: var(--light-color);
        }

        .footer-section p, .footer-section a {
            font-size: 0.875rem;
            color: var(--light-text);
            margin: 0 0 8px;
            text-decoration: none;
        }

        .footer-section a:hover {
            color: var(--accent-color);
        }

        .footer-section .social-links {
            display: flex;
            gap: 12px;
        }

        .footer-section .social-links a {
            font-size: 1rem;
            color: var(--light-text);
        }

        .footer-section .social-links a:hover {
            color: var(--accent-color);
        }

        .footer-copyright {
            font-size: 0.875rem;
            color: var(--light-text);
            text-align: center;
        }

        @media (max-width: 768px) {
            header {
                flex-direction: column;
                gap: 12px;
                padding: 16px;
            }
            header nav {
                width: 100%;
                justify-content: center;
                flex-wrap: wrap;
                gap: 8px;
            }
            .main-content {
                padding: 16px;
            }
            .course-grid {
                grid-template-columns: 1fr;
            }
            .profile-details {
                flex-direction: column;
            }
            .profile-details .profile-pic-container {
                margin: 0 auto 12px;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <header>
            <div class="logo-container">
                <img src="logo.png" alt="Coursemera Logo" class="logo">
                <h1>Coursemera</h1>
            </div>
            <nav>
                <a href="#" class="nav-link" onclick="showSection('manage-courses')"><i class="fas fa-plus"></i> Manage Courses</a>
                <a href="#" class="nav-link" onclick="showSection('my-courses')"><i class="fas fa-book"></i> My Courses</a>
                <a href="#" class="nav-link" onclick="showSection('manage-profile')"><i class="fas fa-user"></i> Manage Profile</a>
                <a href="${pageContext.request.contextPath}/logout" class="logout-button"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </nav>
        </header>

        <div class="main-content">
            <section id="manage-courses" class="courses-section">
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
                        <div class="button-container">
                            <button type="submit" class="upload-btn">Upload</button>
                            <button type="reset" class="cancel-btn">Reset</button>
                        </div>
                    </form>
                </div>
            </section>

            <section id="my-courses" class="courses-section" style="display: none;">
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
                                            "https://via.placeholder.com/100?text=Course";
                                        String pdfDisplayName = "Not uploaded";
                                        if (course.getBookPdfFilename() != null && !course.getBookPdfFilename().isEmpty()) {
                                            try {
                                                pdfDisplayName = Paths.get(course.getBookPdfFilename()).getFileName().toString();
                                            } catch (Exception e) {
                                                pdfDisplayName = course.getBookPdfFilename();
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
                                    <div class="button-container">
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
            </section>

            <section id="manage-profile" class="courses-section" style="display: none;">
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
                    <div class="profile-details">
                        <div class="profile-pic-container">
                            <% if (publisher != null && publisher.getProfilePicture() != null) { %>
                                <img src="data:image/jpeg;base64,<%= java.util.Base64.getEncoder().encodeToString(publisher.getProfilePicture()) %>" alt="Profile Picture">
                            <% } else { %>
                                <div class="no-pic">No Image</div>
                            <% } %>
                        </div>
                        <div class="details-text">
                            <p><strong>First Name:</strong> <%= publisher != null && publisher.getFirstName() != null ? publisher.getFirstName() : "Not set" %></p>
                            <p><strong>Last Name:</strong> <%= publisher != null && publisher.getLastName() != null ? publisher.getLastName() : "Not set" %></p>
                            <p><strong>Email:</strong> <%= publisher != null && publisher.getEmail() != null ? publisher.getEmail() : "Not set" %></p>
                            <p><strong>Resume:</strong> <%= publisher != null && publisher.getResumeFilename() != null ? "<a href='download_resume?publisherId=" + publisherId + "' target='_blank'>" + publisher.getResumeFilename() + "</a>" : "No resume uploaded." %></p>
                        </div>
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
                        <div class="button-container">
                            <button type="submit" class="save-btn">Save Changes</button>
                            <button type="reset" class="cancel-btn">Reset</button>
                        </div>
                    </form>
                </div>
            </section>
        </div>

 <!-- Footer -->
    <footer>
        <p>© 2025 CourseMera. All rights reserved.</p>
    </footer>    </div>

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
                if (bookPdf && bookPdf.size > 10 * 1024 * 1024) {
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
                if (bookPdf && bookPdf.size > 10 * 1024 * 1024) {
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
                if (profilePicture && profilePicture.size > 2 * 1024 * 1024) {
                    alert('Profile picture must be less than 2MB.');
                    return false;
                }
                if (resume && resume.size > 5 * 1024 * 1024) {
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