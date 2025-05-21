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
            margin: 0;
        }

        header nav {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        header nav .admin-info {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 0.875rem;
            transition: var(--transition);
            color: #fff;
            background: var(--primary-color);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        header nav .admin-info:hover {
            background: var(--secondary-color);
        }

        header nav a.logout-button {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 0.875rem;
            transition: var(--transition);
            color: #fff;
            background: #dc2626;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
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

        .admin-nav {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-bottom: 20px;
        }

        .admin-nav button {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 0.875rem;
            border: none;
            cursor: pointer;
            transition: var(--transition);
            background: #e2e8f0;
            color: var(--text-color);
        }

        .admin-nav button.active {
            background: var(--primary-color);
            color: #fff;
        }

        .admin-nav button:hover {
            background: var(--secondary-color);
            color: #fff;
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

        .delete-btn {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 0.875rem;
            border: none;
            cursor: pointer;
            transition: var(--transition);
            background: #dc2626;
            color: #fff;
            width: 100%;
            text-align: center;
        }

        .delete-btn:hover {
            background: #b91c1c;
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
            padding: 20px 24px;
            text-align: center;
        }

        footer p {
            font-size: 0.875rem;
            color: var(--light-text);
            margin: 0;
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
            .admin-nav {
                flex-direction: column;
                gap: 8px;
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
                <div class="admin-info">
                    <i class="fas fa-user"></i>
                    <span><%= session.getAttribute("username") != null ? session.getAttribute("username") : "Admin" %></span>
                    <span><%= session.getAttribute("email") != null ? session.getAttribute("email") : "admin@coursemera.com" %></span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="logout-button"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </nav>
        </header>

        <div class="main-content">
            <section id="courses-section">
                <div class="section-header">
                    <h2 class="section-title">Admin Panel - Manage Courses</h2>
                </div>
                <div class="admin-nav">
                    <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel'">Manage Publishers</button>
                    <button class="active">Manage Courses</button>
                    <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel_users.jsp'">Manage Users</button>
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
            </section>
        </div>

        <footer>
            <p>© 2025 CourseMera. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>