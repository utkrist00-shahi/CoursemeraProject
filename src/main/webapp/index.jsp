
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
//  caching prevention
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

// Checking if logout occurred
String loggedOut = request.getParameter("loggedOut");
if ("true".equals(loggedOut)) {
    System.out.println("index.jsp: Logout detected via query parameter, ensuring unauthenticated state");
    // Using the implicit session variable
    if (session != null) {
        session.invalidate();
    }
}

// Determining authentication status
String role = (String) session.getAttribute("role");
String username = (String) session.getAttribute("username");
boolean isAuthenticated = (role != null && username != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Coursemera</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f1f1f1;
            color: #333;
        }
        a {
            text-decoration: none;
        }
        /* Header */
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
        }
        header nav a:hover {
            color: #333;
        }
        /* Home button */
        header nav a.nav-home {
            font-weight: 600;
        }
        header nav a.nav-home.active {
            color: #3498db;
            border-bottom: 2px solid #3498db;
        }
        /* Courses and About links */
        header nav a.nav-link {
            font-weight: 600;
        }
        header nav a.nav-link:hover {
            color: #3498db;
            background: linear-gradient(90deg, transparent, #3498db, transparent);
            background-size: 100% 2px;
            background-repeat: no-repeat;
            background-position: bottom;
        }
        /* Login button */
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
        /* User info */
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
        /* Logout button */
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
        /* Publisher button */
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

        /* Hero Section */
        .hero {
            background: url('https://images.unsplash.com/photo-1532618500676-2e0cbf7ba8b8?q=80&w=1420&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D/1920x400') no-repeat center center/cover;
            text-align: center;
            padding: 60px 20px;
            color: #fff;
            position: relative;
            margin-bottom: 40px;
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
        .hero h2 {
            font-size: 36px;
            margin: 0 0 20px;
            line-height: 1.4;
            position: relative;
            z-index: 1;
        }
        .hero h2 span {
            font-weight: 800;
        }
        .hero a.browse-courses-button {
            background: linear-gradient(135deg, #333, #555);
            color: #fff;
            padding: 12px 24px;
            border-radius: 20px;
            font-size: 16px;
            font relief: 600;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            position: relative;
            z-index: 1;
            transition: all 0.3s ease;
        }
        .hero a.browse-courses-button:hover {
            background: linear-gradient(135deg, #555, #777);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            transform: scale(1.05);
        }

        /* Featured Courses */
        .courses {
            padding: 60px 40px;
            text-align: center;
            margin-bottom: 40px;
            background-color: #f1f1f1; 
        }
        .courses h2 {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 30px;
            color: #333; 
        }
        .course-grid {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .course-card {
            background-color: #fff;
            width: 300px;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s;
        }
        .course-card:hover {
            transform: scale(1.05);
        }
        .course-card img {
            width: 100%;
            height: 180px;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 15px;
        }
        .course-card h3 {
            font-size: 18px;
            font-weight: bold;
            margin: 0 0 10px;
            color: #333; 
        }
        .course-card p {
            font-size: 14px;
            color: #666;
            margin: 0 0 15px;
        }
        .course-card .price-preview {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .course-card .price {
            font-size: 18px;
            font-weight: bold;
            color: #e74c3c;
        }
        .course-card a {
            color: #3498db;
            font-size: 14px;
        }
        .course-card a:hover {
            text-decoration: underline;
        }

        /* How It Works */
        .how-it-works {
            background-color: #f1f1f1;
            padding: 60px 40px;
            text-align: center;
            margin-bottom: 40px;
        }
        .how-it-works h2 {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 30px;
            color: #333; 
        }
        .steps {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .step {
            width: 200px;
            text-align: center;
        }
        .step-circle {
            width: 60px;
            height: 60px;
            border: 2px solid #000;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 10px;
            font-size: 24px;
        }
        .step h3 {
            font-size: 16px;
            font-weight: bold;
            margin: 0 0 10px;
            color: #333; 
        }
        .step p {
            font-size: 14px;
            color: #666;
            margin: 0;
        }

        /* Why Choose Coursemera */
        .features {
            padding: 80px 40px;
            background: white;
            text-align: center;
        }
        .features-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 40px;
            align-items: center;
            max-width: 1200px;
            margin: 0 auto;
        }
        .features-content {
            max-width: 500px;
        }
        .features-content h2 {
            font-size: 36px;
            font-weight: 800;
            margin-bottom: 16px;
            color: #2b2d42;
        }
        .features-content p {
            color: #636e72;
            margin-bottom: 24px;
        }
        .feature-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .feature-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }
        .feature-icon {
            color: #4a6bff;
            font-size: 20px;
            margin-top: 2px;
        }
        .feature-text h4 {
            font-size: 18px;
            margin-bottom: 4px;
        }
        .feature-text p {
            font-size: 14px;
            color: #636e72;
            margin-bottom: 0;
        }
        .features-image {
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        .features-image img {
            width: 100%;
            height: auto;
            display: block;
        }

        /* Testimonial Section */
        .testimonials {
            padding: 60px 40px;
            text-align: center;
            background-color: #fff;
            margin-bottom: 40px;
        }
        .testimonials h2 {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 30px;
            color: #333; 
        }
        .testimonial-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 20px;
            max-width: 900px;
            margin: 0 auto;
        }
        .testimonial-container {
            max-width: 800px;
            border: 2px solid #333;
            border-radius: 10px;
            padding: 20px;
            background-color: #f9f9f9;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            flex: 1;
        }
        .testimonial {
            display: none;
            text-align: left;
        }
        .testimonial.active {
            display: block;
        }
        .testimonial .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
        }
        .testimonial .user-info img {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
        }
        .testimonial .user-info .name {
            font-size: 18px;
            font-weight: bold;
            color: #333;
        }
        .testimonial .user-info .title {
            font-size: 14px;
            color: #666;
        }
        .testimonial p {
            font-size: 16px;
            color: #333;
            line-height: 1.5;
            margin: 0;
        }
        .testimonial-nav {
            cursor: pointer;
            width: 40px;
            height: 40px;
            background-color: #333;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            transition: background-color 0.3s;
        }
        .testimonial-nav:hover {
            background-color: #555;
        }

        /* Footer */
        footer {
            background-color: #1a1a1a;
            color: #fff;
            padding: 60px 40px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 40px;
            margin-bottom: 40px;
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
        .logo {
            width: 80px;
            height: 80px;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header>
        <div class="flex items-center">
            <img src="logo.png" alt="Coursemera Logo" class="logo">
            <h1>Coursemera</h1>
        </div>
        <nav>
            <%
                System.out.println("index.jsp: Session check - role: " + role + ", username: " + username + ", session ID: " + (session != null ? session.getId() : "null"));
                if (role == null || username == null) {
                    System.out.println("index.jsp: No session, displaying unauthenticated navbar without home, courses, and about");
            %>
                    <a href="#" class="login-button" data-action="login">login</a>
                    <a href="#" class="publisher-button" data-action="publisher-login">Become a Publisher</a>
            <%
                } else if ("USER".equals(role)) {
                    System.out.println("index.jsp: User session detected, displaying authenticated navbar for USER");
            %>
                    <a href="index.jsp" class="nav-home">Home</a>
                    <a href="courses.jsp" class="nav-link">courses</a>
                    <a href="about.jsp" class="nav-link">about</a>
                    <a href="${pageContext.request.contextPath}/user_dashboard" class="user-info">
                        <i class="fas fa-user"></i>
                        <span><%= username %></span>
                    </a>
                    <a href="${pageContext.request.contextPath}/logout" class="logout-button">logout</a>
            <%
                } else if ("ADMIN".equals(role)) {
                    System.out.println("index.jsp: Role ADMIN detected, redirecting to admin_panel");
                    response.sendRedirect(request.getContextPath() + "/admin_panel");
                    return;
                } else {
                    System.out.println("index.jsp: Invalid or unsupported role (" + role + "), displaying unauthenticated navbar without home, courses, and about");
            %>
                    <a href="#" class="login-button" data-action="login">login</a>
                    <a href="#" class="publisher-button" data-action="publisher-login">Become a Publisher</a>
            <%
                }
            %>
        </nav>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <h2>Learn from the best<br><span>Anytime, Anywhere.</span></h2>
        <a href="#" class="browse-courses-button action-link">Browse courses</a>
    </section>

    <!-- Featured Courses -->
    <section class="courses">
        <h2>Featured Courses</h2>
        <div class="course-grid">
            <!-- Course 1 -->
            <div class="course-card">
                <img src="https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Web Development Basics">
                <h3>Web Development Basics</h3>
                <p>Learn the fundamentals of Web Development with HTML, CSS, and JavaScript.</p>
                <div class="price-preview">
                    <span class="price">$30</span>
                    <a href="#" class="action-link">preview</a>
                </div>
            </div>
            <!-- Course 2 -->
            <div class="course-card">
                <img src="https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=1415&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1w974fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Digital Marketing">
                <h3>Digital Marketing</h3>
                <p>Master the art of Digital Marketing with practical examples and case studies.</p>
                <div class="price-preview">
                    <span class="price">$45</span>
                    <a href="#" class="action-link">preview</a>
                </div>
            </div>
            <!-- Course 3 -->
            <div class="course-card">
                <img src="https://images.unsplash.com/photo-1666875753105-c63a6f3bdc86?q=80&w=1473&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Data Science Essentials">
                <h3>Data Science Essentials</h3>
                <p>Start your journey in data science with Python and Statistical Analysis.</p>
                <div class="price-preview">
                    <span class="price">$50</span>
                    <a href="#" class="action-link">preview</a>
                </div>
            </div>
            <!-- Course 4 -->
            <div class="course-card">
                <img src="https://plus.unsplash.com/premium_photo-1683121710572-7723bd2e235d?q=80&w=1632&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Machine Learning Fundamentals">
                <h3>Machine Learning Fundamentals</h3>
                <p>Dive into the basics of Machine Learning with hands-on projects and examples.</p>
                <div class="price-preview">
                    <span class="price">$70</span>
                    <a href="#" class="action-link">preview</a>
                </div>
            </div>
            <!-- Course 5 -->
            <div class="course-card">
                <img src="https://images.unsplash.com/photo-1572044162444-ad60f128bdea?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Graphic Design Mastery">
                <h3>Graphic Design Mastery</h3>
                <p>Learn to create stunning designs using Adobe Photoshop and Illustrator.</p>
                <div class="price-preview">
                    <span class="price">$40</span>
                    <a href="#" class="action-link">preview</a>
                </div>
            </div>
            <!-- Course 6 -->
            <div class="course-card">
                <img src="https://images.unsplash.com/photo-1614064548237-096f735f344f?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Cybersecurity Basics">
                <h3>Cybersecurity Basics</h3>
                <p>Understand the essentials of cybersecurity and protect digital assets.</p>
                <div class="price-preview">
                    <span class="price">$55</span>
                    <a href="#" class="action-link">preview</a>
                </div>
            </div>
            <!-- Course 7 -->
            <div class="course-card">
                <img src="https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Cloud Computing Basics">
                <h3>Cloud Computing Basics</h3>
                <p>Explore the fundamentals of cloud computing with AWS and Azure.</p>
                <div class="price-preview">
                    <span class="price">$60</span>
                    <a href="#" class="action-link">preview</a>
                </div>
            </div>
            <!-- Course 8 -->
            <div class="course-card">
                <img src="https://images.unsplash.com/photo-1516321497487-e288fb19713f?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Mobile App Development">
                <h3>Mobile App Development</h3>
                <p>Build your first mobile app with Flutter and Dart.</p>
                <div class="price-preview">
                    <span class="price">$65</span>
                    <a href="#" class="action-link">preview</a>
                </div>
            </div>
        </div>
    </section>

    <!-- How It Works -->
    <section class="how-it-works">
        <h2>How it works</h2>
        <div class="steps">
            <!-- Step 1 -->
            <div class="step">
                <div class="step-circle">
                    <i class="fas fa-user-plus"></i>
                </div>
                <h3>Sign up</h3>
                <p>Create your account in minutes</p>
            </div>
            <!-- Step 2 -->
            <div class="step">
                <div class="step-circle">
                    <i class="fas fa-search"></i>
                </div>
                <h3>Browse</h3>
                <p>Explore our course catalog</p>
            </div>
            <!-- Step 3 -->
            <div class="step">
                <div class="step-circle">
                    <i class="fas fa-credit-card"></i>
                </div>
                <h3>Purchase</h3>
                <p>Buy your favorite courses</p>
            </div>
            <!-- Step 4 -->
            <div class="step">
                <div class="step-circle">
                    <i class="fas fa-graduation-cap"></i>
                </div>
                <h3>Learn</h3>
                <p>Start learning at your pace</p>
            </div>
        </div>
    </section>

    <!-- Why Choose Coursemera (Moved from courses.jsp) -->
    <section class="features">
        <div class="features-container">
            <div class="features-content">
                <h2>Why choose Coursemera?</h2>
                <p>We're committed to changing the future of learning for the better. Join millions of learners from around the world already learning on Coursemera.</p>
                <div class="feature-list">
                    <div class="feature-item">
                        <div class="feature-icon">✓</div>
                        <div class="feature-text">
                            <h4>Learn anything</h4>
                            <p>Whether you want to develop as a professional or discover a new hobby, we have the course for you.</p>
                        </div>
                    </div>
                    <div class="feature-item">
                        <div class="feature-icon">✓</div>
                        <div class="feature-text">
                            <h4>Learn together</h4>
                            <p>Join knowledge-sharing community of millions of learners and instructors.</p>
                        </div>
                    </div>
                    <div class="feature-item">
                        <div class="feature-icon">✓</div>
                        <div class="feature-text">
                            <h4>Learn with experts</h4>
                            <p>Meet instructors from top universities and companies who will share their experience.</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="features-image">
                <img src="https://images.unsplash.com/photo-1522202176988-66273c2fd55f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" alt="People learning together">
            </div>
        </div>
    </section>

    <!-- Testimonial Section -->
    <section class="testimonials">
        <h2>What Our Users Say</h2>
        <div class="testimonial-wrapper">
            <div class="testimonial-container">
                <div class="testimonial active">
                    <div class="user-info">
                        <img src="https://images.unsplash.com/photo-1505999407077-7937810b98ae?q=80&w=1630&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D/50" alt="User Avatar">
                        <div>
                            <div class="name">Sarah Jones</div>
                            <div class="title">Web Development Student</div>
                        </div>
                    </div>
                    <p>"Coursemera has transformed my learning experience! The Web Development course was comprehensive and easy to follow. I built my first website in just two weeks!"</p>
                </div>
                <div class="testimonial">
                    <div class="user-info">
                        <img src="https://plus.unsplash.com/premium_photo-1689530775582-83b8abdb5020?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D/50" alt="User Avatar">
                        <div>
                            <div class="name">Michael Lee</div>
                            <div class="title">Digital Marketing Enthusiast</div>
                        </div>
                    </div>
                    <p>"The Digital Marketing course on Coursemera gave me practical skills I could apply immediately. The instructors are top-notch and the content is engaging!"</p>
                </div>
                <div class="testimonial">
                    <div class="user-info">
                        <img src="https://images.unsplash.com/photo-1675469675830-11d9a6099ef4?q=80&w=1430&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D/50" alt="User Avatar">
                        <div>
                            <div class="name">Emily Chen</div>
                            <div class="title">Data Science Learner</div>
                        </div>
                    </div>
                    <p>"I never thought I could understand Data Science, but Coursemera made it so accessible. The lessons are well-structured, and I love the hands-on projects!"</p>
                </div>
            </div>
            <div class="testimonial-nav">
                <i class="fas fa-chevron-right"></i>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <div class="footer-sections">
            <div class="footer-section">
                <h3>CourseMera</h3>
                <p>Learn from the best instructors worldwide</p>
            </div>
            <div class="footer-section">
                <h3>Quick Links</h3>
                <p><a href="about.jsp" class="action-link">About us</a></p>
                <p><a href="#" class="action-link">Certified Instructors</a></p>
                <p><a href="#" class="action-link">Contact</a></p>
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
        // Pass authentication status to JavaScript
        const isAuthenticated = <%= isAuthenticated %>;

        // Redirect logic for unauthenticated users
        document.querySelectorAll('.action-link, [data-action]').forEach(element => {
            element.addEventListener('click', (e) => {
                e.preventDefault();
                const action = element.getAttribute('data-action');

                if (action === 'login') {
                    console.log('Redirecting to login.jsp');
                    window.location.href = 'login.jsp';
                } else if (action === 'publisher-login') {
                    console.log('Redirecting to publisher_login.jsp');
                    window.location.href = 'publisher_login.jsp';
                } else if (!isAuthenticated) {
                    console.log('Unauthenticated user, redirecting to login.jsp');
                    window.location.href = 'login.jsp';
                } else {
                    console.log('Authenticated user, no redirect needed');
                }
            });
        });

        // Highlight Home button as active (only for authenticated users)
        const homeButton = document.querySelector('.nav-home');
        if (homeButton && window.location.pathname.endsWith('index.jsp')) {
            homeButton.classList.add('active');
        }

        // Testimonial navigation
        const testimonials = document.querySelectorAll('.testimonial');
        const navButton = document.querySelector('.testimonial-nav');
        let currentIndex = 0;

        function showTestimonial(index) {
            testimonials.forEach((testimonial, i) => {
                testimonial.classList.remove('active');
                if (i === index) {
                    testimonial.classList.add('active');
                }
            });
        }

        navButton.addEventListener('click', () => {
            currentIndex = (currentIndex + 1) % testimonials.length;
            showTestimonial(currentIndex);
        });

        showTestimonial(currentIndex);
    </script>
</body>
</html>