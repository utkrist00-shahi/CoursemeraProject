<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, model.Courses, dao.CoursesDAO" %>
<%
// Prevent caching
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

// Check logout
String loggedOut = request.getParameter("loggedOut");
if ("true".equals(loggedOut)) {
    System.out.println("courses.jsp: Logout detected via query parameter, ensuring unauthenticated state");
    if (session != null) {
        session.invalidate();
    }
    response.sendRedirect("index.jsp");
    return;
}

// Determine authentication status
String role = (String) session.getAttribute("role");
String username = (String) session.getAttribute("username");
boolean isAuthenticated = (role != null && username != null);
boolean isPublisher = "PUBLISHER".equals(role);
Integer publisherId = (Integer) session.getAttribute("publisherId");

// Fetch all courses and distribute to sections
CoursesDAO coursesDAO = new CoursesDAO();
List<Courses> allCourses = coursesDAO.getRecentlyAddedCourses(64); // Fetch up to 64 courses
List<Courses> popularCourses = new ArrayList<>();
List<Courses> trendingCourses = new ArrayList<>();
List<Courses> learnerFavorites = new ArrayList<>();
List<Courses> justLaunched = new ArrayList<>();

// Distribute courses to sections (up to 16 per section)
if (allCourses != null && !allCourses.isEmpty()) {
    for (int i = 0; i < allCourses.size(); i++) {
        Courses course = allCourses.get(i);
        if (i % 4 == 0 && popularCourses.size() < 16) {
            popularCourses.add(course);
        } else if (i % 4 == 1 && trendingCourses.size() < 16) {
            trendingCourses.add(course);
        } else if (i % 4 == 2 && learnerFavorites.size() < 16) {
            learnerFavorites.add(course);
        } else if (i % 4 == 3 && justLaunched.size() < 16) {
            justLaunched.add(course);
        }
    }
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Coursemera - Expand Your Knowledge</title>
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
            min-height: 100vh;
            display: flex;
            flex-direction: column;
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
        }
        header nav a:hover {
            color: #333;
        }
        header nav a.nav-home {
            font-weight: 600;
        }
        header nav a.nav-home.active {
            color: #3498db;
            border-bottom: 2px solid #3498db;
        }
        header nav a.nav-link {
            font-weight: 600;
        }
        header nav a.nav-link.active {
            color: #3498db;
            border-bottom: 2px solid #3498db;
        }
        header nav a.nav-link:hover {
            color: #3498db;
            background: linear-gradient(90deg, transparent, #3498db, transparent);
            background-size: 100% 2px;
            background-repeat: no-repeat;
            background-position: bottom;
        }
        header nav a.login-button {
            background: linear-gradient(135deg, #444, #222);
            color: #fff;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
        }
        header nav a.login-button:hover {
            background: linear-gradient(135deg, #555, #333);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        }
        header nav .user-info {
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
        header nav .user-info i {
            color: #fff;
        }
        header nav .user-info:hover {
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
        }
        header nav a.logout-button:hover {
            background: linear-gradient(135deg, #ff6655, #e74c3c);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            transform: scale(1.05);
        }
        .publisher-button {
            background: linear-gradient(135deg, #3498db, #1e6bb8);
            color: #fff;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 16px;
            font-weight: 600;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
        }
        .publisher-button:hover {
            background: linear-gradient(135deg, #4aa3e8, #2b82d1);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            transform: scale(1.05);
        }
        .logo {
            width: 80px;
            height: 80px;
        }

        .hero {
            padding: 80px 0;
            background: url('https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D/1920x600') no-repeat center center/cover;
            text-align: center;
            position: relative;
        }
        .hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
        }
        .hero .container {
            position: relative;
            z-index: 1;
        }
        .hero h1 {
            font-size: 48px;
            font-weight: 800;
            margin-bottom: 16px;
            color: #fff;
            opacity: 0;
            animation: fadeIn 1.5s ease-in-out forwards;
        }
        .hero p {
            font-size: 18px;
            color: rgba(255, 255, 255, 0.8);
            max-width: 700px;
            margin: 0 auto 32px;
            opacity: 0;
            animation: fadeIn 1.5s ease-in-out forwards 0.5s;
        }
        @keyframes fadeIn {
            0% { opacity: 0; transform: translateY(20px); }
            100% { opacity: 1; transform: translateY(0); }
        }
        .hero-buttons {
            display: flex;
            justify-content: center;
            gap: 16px;
        }
        .secondary-btn {
            background: white;
            color: var(--primary-color);
            padding: 14px 28px;
            border-radius: var(--border-radius);
            font-weight: 600;
            border: 1px solid var(--primary-color);
            cursor: pointer;
            transition: var(--transition);
            text-decoration: none;
        }
        .secondary-btn:hover {
            background: rgba(74, 107, 255, 0.1);
            transform: translateY(-2px);
        }

        .categories {
            padding: 60px 0;
        }
        .section-title {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 16px;
            text-align: center;
        }
        .section-subtitle {
            color: var(--light-text);
            text-align: center;
            max-width: 600px;
            margin: 0 auto 40px;
        }
        .category-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
        }
        .category-card {
            background: white;
            border-radius: var(--border-radius);
            padding: 24px;
            text-align: center;
            box-shadow: var(--box-shadow);
            transition: var(--transition);
            cursor: pointer;
        }
        .category-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
        }
        .category-icon {
            width: 60px;
            height: 60px;
            background: rgba(74, 107, 255, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            color: var(--primary-color);
            font-size: 24px;
        }
        .category-card h3 {
            font-size: 18px;
            margin-bottom: 8px;
        }
        .category-card p {
            font-size: 14px;
            color: var(--light-text);
        }

        .courses-section {
            padding: 60px 0;
            background: #f8fafc;
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }
        .view-all {
            color: var(--primary-color);
            font-weight: 600;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 4px;
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
        .enroll-btn {
            background: var(--primary-color);
            color: white;
            padding: 10px 20px;
            border-radius: var(--border-radius);
            font-weight: 600;
            border: none;
            cursor: pointer;
            width: 100%;
            text-align: center;
            transition: var(--transition);
            display: inline-block;
            text-decoration: none;
        }
        .enroll-btn:hover {
            background: #3a5bef;
            transform: translateY(-2px);
        }
        .edit-btn, .delete-btn {
            padding: 10px 20px;
            border-radius: var(--border-radius);
            font-weight: 600;
            border: none;
            cursor: pointer;
            width: 48%;
            text-align: center;
            transition: var(--transition);
        }
        .edit-btn {
            background: #f1c40f;
            color: #fff;
        }
        .delete-btn {
            background: #e74c3c;
            color: #fff;
        }
        .edit-btn:hover, .delete-btn:hover {
            transform: translateY(-2px);
        }

        .testimonials {
            padding: 80px 0;
            background: #f8fafc;
            text-align: center;
        }
        .testimonial-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
            margin-top: 40px;
        }
        .testimonial-card {
            background: white;
            padding: 32px;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            text-align: left;
        }
        .testimonial-text {
            font-style: italic;
            margin-bottom: 24px;
            color: var(--text-color);
        }
        .testimonial-author {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .author-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            object-fit: cover;
        }
        .author-info h4 {
            font-size: 16px;
            margin-bottom: 4px;
        }
        .author-info p {
            font-size: 14px;
            color: var(--light-text);
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
            width: 100%;
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
            .hero h1 {
                font-size: 36px;
            }
            .hero p {
                font-size: 16px;
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
            <%
                System.out.println("courses.jsp: Session check - role: " + role + ", username: " + username + ", session ID: " + (session != null ? session.getId() : "null"));
                if (role == null || username == null) {
                    System.out.println("courses.jsp: No session, displaying unauthenticated navbar without home, courses, and about");
            %>
                    <a href="#" class="login-button" data-action="login">login</a>
                    <a href="#" class="publisher-button" data-action="publisher-login">Become a Publisher</a>
            <%
                } else if ("USER".equals(role)) {
                    System.out.println("courses.jsp: User session detected, displaying authenticated navbar for USER");
            %>
                    <a href="index.jsp" class="nav-home">Home</a>
                    <a href="courses.jsp" class="nav-link active">courses</a>
                    <a href="about.jsp" class="nav-link">about</a>
                    <a href="${pageContext.request.contextPath}/user_dashboard" class="user-info">
                        <i class="fas fa-user"></i>
                        <span><%= username %></span>
                    </a>
                    <a href="?loggedOut=true" class="logout-button">logout</a>
            <%
                } else if ("PUBLISHER".equals(role)) {
                    System.out.println("courses.jsp: Publisher session detected, displaying authenticated navbar for PUBLISHER");
            %>
                    <a href="index.jsp" class="nav-home">Home</a>
                    <a href="courses.jsp" class="nav-link active">courses</a>
                    <a href="about.jsp" class="nav-link">about</a>
                    <a href="${pageContext.request.contextPath}/publisher_dashboard" class="user-info">
                        <i class="fas fa-user"></i>
                        <span><%= username %></span>
                    </a>
                    <a href="?loggedOut=true" class="logout-button">logout</a>
            <%
                } else if ("ADMIN".equals(role)) {
                    System.out.println("courses.jsp: Role ADMIN detected, redirecting to admin_panel");
                    response.sendRedirect(request.getContextPath() + "/admin_panel");
                    return;
                } else {
                    System.out.println("courses.jsp: Invalid or unsupported role (" + role + "), displaying unauthenticated navbar without home, courses, and about");
            %>
                    <a href="#" class="login-button" data-action="login">login</a>
                    <a href="#" class="publisher-button" data-action="publisher-login">Become a Publisher</a>
            <%
                }
            %>
        </nav>
    </header>

    <section class="hero">
        <div class="container">
            <h1>Learn without limits</h1>
            <p>Start, switch, or advance your career with over 5,000 courses, Professional Certificates, and degrees from world-class universities and companies.</p>
            <div class="hero-buttons">
                <a href="#" class="secondary-btn" id="explore-courses">Explore Courses</a>
            </div>
        </div>
    </section>

    <section class="categories">
        <div class="container">
            <h2 class="section-title">Browse by category</h2>
            <p class="section-subtitle">Learn new skills with our wide range of categories. Whatever your goal, we have a course to get you there.</p>
            <div class="category-grid">
                <div class="category-card">
                    <div class="category-icon">💻</div>
                    <h3>Technology</h3>
                    <p>Programming, IT, Cybersecurity</p>
                </div>
                <div class="category-card">
                    <div class="category-icon">📊</div>
                    <h3>Business</h3>
                    <p>Finance, Management, Marketing</p>
                </div>
                <div class="category-card">
                    <div class="category-icon">🎨</div>
                    <h3>Design</h3>
                    <p>Graphic, UX/UI, 3D Modeling</p>
                </div>
                <div class="category-card">
                    <div class="category-icon">🔬</div>
                    <h3>Science</h3>
                    <p>Data Science, Biology, Physics</p>
                </div>
                <div class="category-card">
                    <div class="category-icon">🧠</div>
                    <h3>Personal Growth</h3>
                    <p>Productivity, Leadership, Psychology</p>
                </div>
            </div>
        </div>
    </section>

    <section class="courses-section" id="popular-courses">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Popular Courses</h2>
                <a href="#" class="view-all">View all →</a>
            </div>
            <div class="course-grid">
                <% 
                    if (popularCourses != null && !popularCourses.isEmpty()) {
                        for (Courses course : popularCourses) {
                            String imagePath = course.getImagePath();
                            String imageUrl = (imagePath != null && !imagePath.trim().isEmpty()) ? 
                                request.getContextPath() + "/" + imagePath : 
                                "https://via.placeholder.com/160?text=No+Image";
                            System.out.println("courses.jsp: Rendering popular course " + course.getId() + ", imagePath: " + imagePath + ", imageUrl: " + imageUrl);
                %>
                    <div class="course-card">
                        <img src="<%= imageUrl %>" alt="<%= course.getTitle() != null ? course.getTitle() : "Course" %>" class="course-image" 
                             onerror="this.src='https://via.placeholder.com/160?text=Image+Error'; this.onerror=null; console.log('Image load failed for course ID <%= course.getId() %>: ' + this.src);">
                        <div class="course-content">
                            <div class="course-category"><%= course.getCategory() != null ? course.getCategory() : "Unknown" %></div>
                            <h3 class="course-title"><%= course.getTitle() != null ? course.getTitle() : "No Title" %></h3>
                            <div class="course-instructor"><%= course.getInstructor() != null ? course.getInstructor() : "Unknown Instructor" %></div>
                            <div class="course-meta">
                                <div class="course-price">$<%= String.format("%.2f", course.getPrice()) %></div>
                                <div class="course-rating">
                                    <div class="stars">★★★★★</div>
                                    <div class="rating-count">(0)</div>
                                </div>
                            </div>
                            <% if (isPublisher && publisherId != null && course.getPublisherId() == publisherId) { %>
                                <div style="display: flex; gap: 8px;">
                                    <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" style="display: inline; width: 48%;">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="courseId" value="<%= course.getId() %>">
                                        <button type="submit" class="edit-btn">Edit</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" style="display: inline; width: 48%;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="courseId" value="<%= course.getId() %>">
                                        <button type="submit" class="delete-btn">Delete</button>
                                    </form>
                                </div>
                            <% } else { %>
                                <a href="${pageContext.request.contextPath}/payment?courseId=<%= course.getId() %>" class="enroll-btn">Enroll Now</a>
                            <% } %>
                        </div>
                    </div>
                <% 
                        }
                    } else {
                %>
                    <p>No popular courses available.</p>
                <% } %>
            </div>
        </div>
    </section>

    <section class="courses-section" id="trending-now">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Trending Now</h2>
                <a href="#" class="view-all">View all →</a>
            </div>
            <div class="course-grid">
                <% 
                    if (trendingCourses != null && !trendingCourses.isEmpty()) {
                        for (Courses course : trendingCourses) {
                            String imagePath = course.getImagePath();
                            String imageUrl = (imagePath != null && !imagePath.trim().isEmpty()) ? 
                                request.getContextPath() + "/" + imagePath : 
                                "https://via.placeholder.com/160?text=No+Image";
                            System.out.println("courses.jsp: Rendering trending course " + course.getId() + ", imagePath: " + imagePath + ", imageUrl: " + imageUrl);
                %>
                    <div class="course-card">
                        <img src="<%= imageUrl %>" alt="<%= course.getTitle() != null ? course.getTitle() : "Course" %>" class="course-image" 
                             onerror="this.src='https://via.placeholder.com/160?text=Image+Error'; this.onerror=null; console.log('Image load failed for course ID <%= course.getId() %>: ' + this.src);">
                        <div class="course-content">
                            <div class="course-category"><%= course.getCategory() != null ? course.getCategory() : "Unknown" %></div>
                            <h3 class="course-title"><%= course.getTitle() != null ? course.getTitle() : "No Title" %></h3>
                            <div class="course-instructor"><%= course.getInstructor() != null ? course.getInstructor() : "Unknown Instructor" %></div>
                            <div class="course-meta">
                                <div class="course-price">$<%= String.format("%.2f", course.getPrice()) %></div>
                                <div class="course-rating">
                                    <div class="stars">★★★★★</div>
                                    <div class="rating-count">(0)</div>
                                </div>
                            </div>
                            <% if (isPublisher && publisherId != null && course.getPublisherId() == publisherId) { %>
                                <div style="display: flex; gap: 8px;">
                                    <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" style="display: inline; width: 48%;">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="courseId" value="<%= course.getId() %>">
                                        <button type="submit" class="edit-btn">Edit</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" style="display: inline; width: 48%;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="courseId" value="<%= course.getId() %>">
                                        <button type="submit" class="delete-btn">Delete</button>
                                    </form>
                                </div>
                            <% } else { %>
                                <a href="${pageContext.request.contextPath}/payment?courseId=<%= course.getId() %>" class="enroll-btn">Enroll Now</a>
                            <% } %>
                        </div>
                    </div>
                <% 
                        }
                    } else {
                %>
                    <p>No trending courses available.</p>
                <% } %>
            </div>
        </div>
    </section>

    <section class="courses-section" id="learner-favorites">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Learner Favorites</h2>
                <a href="#" class="view-all">View all →</a>
            </div>
            <div class="course-grid">
                <% 
                    if (learnerFavorites != null && !learnerFavorites.isEmpty()) {
                        for (Courses course : learnerFavorites) {
                            String imagePath = course.getImagePath();
                            String imageUrl = (imagePath != null && !imagePath.trim().isEmpty()) ? 
                                request.getContextPath() + "/" + imagePath : 
                                "https://via.placeholder.com/160?text=No+Image";
                            System.out.println("courses.jsp: Rendering favorite course " + course.getId() + ", imagePath: " + imagePath + ", imageUrl: " + imageUrl);
                %>
                    <div class="course-card">
                        <img src="<%= imageUrl %>" alt="<%= course.getTitle() != null ? course.getTitle() : "Course" %>" class="course-image" 
                             onerror="this.src='https://via.placeholder.com/160?text=Image+Error'; this.onerror=null; console.log('Image load failed for course ID <%= course.getId() %>: ' + this.src);">
                        <div class="course-content">
                            <div class="course-category"><%= course.getCategory() != null ? course.getCategory() : "Unknown" %></div>
                            <h3 class="course-title"><%= course.getTitle() != null ? course.getTitle() : "No Title" %></h3>
                            <div class="course-instructor"><%= course.getInstructor() != null ? course.getInstructor() : "Unknown Instructor" %></div>
                            <div class="course-meta">
                                <div class="course-price">$<%= String.format("%.2f", course.getPrice()) %></div>
                                <div class="course-rating">
                                    <div class="stars">★★★★★</div>
                                    <div class="rating-count">(0)</div>
                                </div>
                            </div>
                            <% if (isPublisher && publisherId != null && course.getPublisherId() == publisherId) { %>
                                <div style="display: flex; gap: 8px;">
                                    <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" style="display: inline; width: 48%;">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="courseId" value="<%= course.getId() %>">
                                        <button type="submit" class="edit-btn">Edit</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" style="display: inline; width: 48%;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="courseId" value="<%= course.getId() %>">
                                        <button type="submit" class="delete-btn">Delete</button>
                                    </form>
                                </div>
                            <% } else { %>
                                <a href="${pageContext.request.contextPath}/payment?courseId=<%= course.getId() %>" class="enroll-btn">Enroll Now</a>
                            <% } %>
                        </div>
                    </div>
                <% 
                        }
                    } else {
                %>
                    <p>No learner favorite courses available.</p>
                <% } %>
            </div>
        </div>
    </section>

    <section class="courses-section" id="just-launched">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Just Launched</h2>
                <a href="#" class="view-all">View all →</a>
            </div>
            <div class="course-grid">
                <% 
                    if (justLaunched != null && !justLaunched.isEmpty()) {
                        for (Courses course : justLaunched) {
                            String imagePath = course.getImagePath();
                            String imageUrl = (imagePath != null && !imagePath.trim().isEmpty()) ? 
                                request.getContextPath() + "/" + imagePath : 
                                "https://via.placeholder.com/160?text=No+Image";
                            System.out.println("courses.jsp: Rendering just launched course " + course.getId() + ", imagePath: " + imagePath + ", imageUrl: " + imageUrl);
                %>
                    <div class="course-card">
                        <img src="<%= imageUrl %>" alt="<%= course.getTitle() != null ? course.getTitle() : "Course" %>" class="course-image" 
                             onerror="this.src='https://via.placeholder.com/160?text=Image+Error'; this.onerror=null; console.log('Image load failed for course ID <%= course.getId() %>: ' + this.src);">
                        <div class="course-content">
                            <div class="course-category"><%= course.getCategory() != null ? course.getCategory() : "Unknown" %></div>
                            <h3 class="course-title"><%= course.getTitle() != null ? course.getTitle() : "No Title" %></h3>
                            <div class="course-instructor"><%= course.getInstructor() != null ? course.getInstructor() : "Unknown Instructor" %></div>
                            <div class="course-meta">
                                <div class="course-price">$<%= String.format("%.2f", course.getPrice()) %></div>
                                <div class="course-rating">
                                    <div class="stars">★★★★★</div>
                                    <div class="rating-count">(0)</div>
                                </div>
                            </div>
                            <% if (isPublisher && publisherId != null && course.getPublisherId() == publisherId) { %>
                                <div style="display: flex; gap: 8px;">
                                    <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" style="display: inline; width: 48%;">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="courseId" value="<%= course.getId() %>">
                                        <button type="submit" class="edit-btn">Edit</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/CourseManagementServlet" method="post" style="display: inline; width: 48%;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="courseId" value="<%= course.getId() %>">
                                        <button type="submit" class="delete-btn">Delete</button>
                                    </form>
                                </div>
                            <% } else { %>
                                <a href="${pageContext.request.contextPath}/payment?courseId=<%= course.getId() %>" class="enroll-btn">Enroll Now</a>
                            <% } %>
                        </div>
                    </div>
                <% 
                        }
                    } else {
                %>
                    <p>No recently launched courses available.</p>
                <% } %>
            </div>
        </div>
    </section>

    <section class="testimonials">
        <div class="container">
            <h2 class="section-title">What our learners say</h2>
            <p class="section-subtitle">Don't just take our word for it - hear from some of our amazing students</p>
            <div class="testimonial-grid">
                <div class="testimonial-card">
                    <p class="testimonial-text">"Coursemera completely changed my career trajectory. The web development course gave me the skills I needed to land my dream job as a front-end developer."</p>
                    <div class="testimonial-author">
                        <img src="https://randomuser.me/api/portraits/women/44.jpg" alt="Sarah J." class="author-avatar">
                        <div class="author-info">
                            <h4>Sarah J.</h4>
                            <p>Web Developer</p>
                        </div>
                    </div>
                </div>
                <div class="testimonial-card">
                    <p class="testimonial-text">"The data science courses on Coursemera helped me transition from marketing to a data analyst role. The instructors make complex topics easy to understand."</p>
                    <div class="testimonial-author">
                        <img src="https://randomuser.me/api/portraits/men/32.jpg" alt="Michael T." class="author-avatar">
                        <div class="author-info">
                            <h4>Michael T.</h4>
                            <p>Data Analyst</p>
                        </div>
                    </div>
                </div>
                <div class="testimonial-card">
                    <p class="testimonial-text">"As a small business owner, the digital marketing courses have been invaluable. I've been able to double my online sales in just three months!"</p>
                    <div class="testimonial-author">
                        <img src="https://randomuser.me/api/portraits/women/68.jpg" alt="Lisa M." class="author-avatar">
                        <div class="author-info">
                            <h4>Lisa M.</h4>
                            <p>Entrepreneur</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="hero" style="background: var(--primary-color); padding: 60px 0;">
        <div class="container" style="text-align: center;">
            <h1 style="color: white;">Start learning today</h1>
            <p style="color: rgba(255,255,255,0.8); margin-bottom: 32px;">Join over 10 million learners worldwide and gain new skills today.</p>
        </div>
    </section>

    <footer>
        <div class="footer-sections">
            <div class="footer-section">
                <h3>CourseMera</h3>
                <p>Learn from the best instructors worldwide</p>
            </div>
            <div class="footer-section">
                <h3>Quick Links</h3>
                <p><a href="about.jsp" class="action-link">About us</a></p>
                <p><a href="about.jsp" class="action-link">Certified Instructors</a></p>
                <p><a href="about.jsp" class="action-link">Contact</a></p>
            </div>
            <div class="footer-section">
                <h3>Contact Info</h3>
                <p>Email us today</p>
            </div>
            <div class="footer-section">
                <h3>Follow Us</h3>
                <div class="social-links">
                    <a href="#" class="action-link"><i class="fab fa-facebook"></i></a>
                    <a href="#" class="action-link"><i class="fab fa-twitter"></i></a>
                    <a href="#" class="action-link"><i class="fab fa-instagram"></i></a>
                </div>
            </div>
        </div>
        <div class="footer-copyright">
            © ALL RIGHTS RESERVED
        </div>
    </footer>

    <script>
        const isAuthenticated = <%= isAuthenticated %>;

        document.querySelectorAll('.action-link, [data-action], .enroll-btn, #explore-courses').forEach(element => {
            element.addEventListener('click', (e) => {
                const action = element.getAttribute('data-action');
                const isQuickLink = element.parentElement.parentElement.querySelector('h3')?.textContent === 'Quick Links';
                const isExploreCourses = element.id === 'explore-courses';

                if (action === 'login') {
                    e.preventDefault();
                    console.log('Redirecting to login.jsp');
                    window.location.href = 'login.jsp';
                } else if (action === 'publisher-login') {
                    e.preventDefault();
                    console.log('Redirecting to publisher_login.jsp');
                    window.location.href = 'publisher_login.jsp';
                } else if (isQuickLink) {
                    e.preventDefault();
                    console.log('Redirecting to about.jsp from Quick Links');
                    window.location.href = 'about.jsp';
                } else if (isExploreCourses) {
                    e.preventDefault();
                    console.log('Scrolling to Popular Courses section');
                    document.getElementById('popular-courses').scrollIntoView({ behavior: 'smooth' });
                } else if (!isAuthenticated && element.classList.contains('enroll-btn')) {
                    e.preventDefault();
                    console.log('Unauthenticated user, redirecting to login.jsp');
                    window.location.href = 'login.jsp';
                } else if (element.classList.contains('enroll-btn')) {
                    console.log('Enroll Now clicked for: ' + element.closest('.course-card').querySelector('.course-title').textContent);
                }
            });
        });

        document.querySelectorAll('.course-card').forEach(card => {
            card.addEventListener('click', function(e) {
                if (!e.target.classList.contains('enroll-btn') && !e.target.classList.contains('edit-btn') && !e.target.classList.contains('delete-btn')) {
                    console.log('Course clicked: ' + this.querySelector('.course-title').textContent);
                }
            });
        });
    </script>
</body>
</html>