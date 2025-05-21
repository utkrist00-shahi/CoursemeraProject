<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Courses, java.nio.file.Paths" %>
<%
// Session check before any output
if (session == null || session.getAttribute("role") == null || !"ADMIN".equals(session.getAttribute("role"))) {
    System.out.println("admin_panel_courses.jsp: Unauthorized access, redirecting to login");
    response.sendRedirect(request.getContextPath() + "/login");
    return; // Stop further processing
}
System.out.println("admin_panel_courses.jsp: Authorized access, username: " + session.getAttribute("username"));

// Fetch courses
List<Courses> courses = (List<Courses>) request.getAttribute("courses");
if (courses == null) {
    System.out.println("admin_panel_courses.jsp: courses null, redirecting to /CourseManagementServlet");
    response.sendRedirect(request.getContextPath() + "/CourseManagementServlet");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Manage Courses - Coursemera</title>
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

        header nav .admin-info {
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

        header nav .admin-info i {
            color: #fff;
        }

        header nav .admin-info:hover {
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

        .admin-container {
            flex: 1;
            padding: 40px 20px;
        }

        .admin-nav {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-bottom: 30px;
        }

        .admin-nav button {
            padding: 12px 24px;
            border: none;
            border-radius: 20px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .admin-nav button.active {
            background: linear-gradient(135deg, #3498db, #1e90ff);
            color: #fff;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        }

        .admin-nav button:not(.active) {
            background: linear-gradient(135deg, #ccc, #aaa);
            color: #333;
        }

        .admin-nav button:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
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

        .delete-btn {
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
            background: #e74c3c;
            color: #fff;
        }

        .delete-btn:hover {
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
            padding: 20px 40px;
            text-align: center;
        }

        footer p {
            margin: 0;
            font-size: 14px;
            color: #ccc;
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
            <div class="admin-info">
                <i class="fas fa-user"></i>
                <span><%= session.getAttribute("username") != null ? session.getAttribute("username") : "Admin" %></span>
                <span><%= session.getAttribute("email") != null ? session.getAttribute("email") : "admin@coursemera.com" %></span>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="logout-button">Logout</a>
        </nav>
    </header>

    <!-- Admin Panel Content -->
    <div class="admin-container">
        <h2>Admin Panel - Manage Courses</h2>
        <div class="admin-nav">
            <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel'">Manage Publishers</button>
            <button class="active">Manage Courses</button>
            <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel_users.jsp'">Manage Users</button>
        </div>
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">All Courses</h2>
            </div>
            <% 
                String message = (String) request.getAttribute("message");
                String error = (String) request.getAttribute("error");
                if (message != null) { 
            %>
                <p class="message"><%= message %></p>
            <% } %>
            <% if (error != null) { %>
                <p class="error"><%= error %></p>
            <% } %>
            <div class="course-grid">
                <% 
                    if (courses != null && !courses.isEmpty()) {
                        for (Courses course : courses) {
                            if (course != null) {
                                Integer courseId = course.getId();
                                if (courseId != null && courseId > 0) {
                                    String courseIdStr = String.valueOf(courseId);
                                    String imagePath = course.getImagePath() != null && !course.getImagePath().isEmpty() ? 
                                        request.getContextPath() + "/" + course.getImagePath() : 
                                        "https://images.unsplash.com/photo-1593642632823-8f785ba67e45?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60";
                                    String pdfDisplayName = "Not uploaded";
                                    if (course.getBookPdfFilename() != null && !course.getBookPdfFilename().isEmpty()) {
                                        try {
                                            pdfDisplayName = Paths.get(course.getBookPdfFilename()).getFileName().toString();
                                        } catch (Exception e) {
                                            pdfDisplayName = course.getBookPdfFilename();
                                            System.err.println("admin_panel_courses.jsp: Error parsing PDF filename for course ID " + courseId + ": " + e.getMessage());
                                        }
                                    }
                %>
                    <div class="course-card" id="course-<%= courseIdStr %>">
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
                            <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" style="width: 100%;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="courseId" value="<%= courseIdStr %>">
                                <button type="submit" class="delete-btn" onclick="return confirm('Are you sure you want to delete this course?')">Delete</button>
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
    </div>

    <!-- Footer -->
    <footer>
        <p>© 2025 CourseMera. All rights reserved.</p>
    </footer>
</body>
</html>