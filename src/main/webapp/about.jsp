
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// caching prevention
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

// if logout occurred
String loggedOut = request.getParameter("loggedOut");
if ("true".equals(loggedOut)) {
    System.out.println("about.jsp: Logout detected via query parameter, ensuring unauthenticated state");
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
    <title>About Coursemera</title>
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
        header nav a.nav-link:hover {
            color: #3498db;
            background: linear-gradient(90deg, transparent, #3498db, transparent);
            background-size: 100% 2px;
            background-repeat: no-repeat;
            background-position: bottom;
        }
        header nav a.nav-link.active {
            color: #3498db;
            border-bottom: 2px solid #3498db;
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
        .hero p {
            font-size: 18px;
            margin: 0 auto 20px;
            max-width: 600px;
            position: relative;
            z-index: 1;
        }
        .hero img.team-image {
            width: 100%;
            max-width: 600px;
            height: auto;
            border-radius: 10px;
            margin-top: 20px;
            position: relative;
            z-index: 1;
        }

        /* Our Story Section */
        .our-story {
            padding: 60px 40px;
            text-align: center;
            background-color: #fff;
            margin-bottom: 40px;
        }
        .our-story h2 {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .our-story p {
            font-size: 16px;
            color: #666;
            max-width: 800px;
            margin: 0 auto;
            line-height: 1.6;
        }

        /* Core Values Section */
        .core-values {
            padding: 60px 40px;
            background-color: #f1f1f1;
            text-align: center;
            margin-bottom: 40px;
        }
        .core-values h2 {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 30px;
        }
        .values-grid {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .value-card {
            background-color: #fff;
            width: 300px;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s;
        }
        .value-card:hover {
            transform: scale(1.05);
        }
        .value-card i {
            font-size: 40px;
            color: #3498db;
            margin-bottom: 15px;
        }
        .value-card h3 {
            font-size: 18px;
            font-weight: bold;
            margin: 0 0 10px;
        }
        .value-card p {
            font-size: 14px;
            color: #666;
            margin: 0;
        }

        /* Our Journey Section */
        .our-journey {
            padding: 60px 40px;
            text-align: center;
            background-color: #fff;
            margin-bottom: 40px;
        }
        .our-journey h2 {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 30px;
        }
        .timeline {
            position: relative;
            max-width: 800px;
            margin: 0 auto;
        }
        .timeline::before {
            content: '';
            position: absolute;
            width: 4px;
            background-color: #3498db;
            top: 0;
            bottom: 0;
            left: 50%;
            margin-left: -2px;
        }
        .timeline-item {
            padding: 20px 40px;
            position: relative;
            width: 50%;
            box-sizing: border-box;
            display: flex;
            align-items: center;
        }
        .timeline-item:nth-child(odd) {
            left: 0;
            text-align: right;
            justify-content: flex-end;
        }
        .timeline-item:nth-child(even) {
            left: 50%;
            text-align: left;
            justify-content: flex-start;
        }
        .timeline-item::before {
            content: '';
            position: absolute;
            width: 20px;
            height: 20px;
            background-color: #3498db;
            border-radius: 50%;
            z-index: 1;
        }
        .timeline-item:nth-child(odd)::before {
            right: -10px;
        }
        .timeline-item:nth-child(even)::before {
            left: -10px;
        }
        .timeline-content {
            background-color: #f9f9f9;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            width: 90%;
        }
        .timeline-content h3 {
            font-size: 18px;
            font-weight: bold;
            margin: 0 0 10px;
        }
        .timeline-content .date {
            font-size: 14px;
            color: #3498db;
            margin-bottom: 10px;
        }
        .timeline-content p {
            font-size: 14px;
            color: #666;
            margin: 0;
        }

        /* Meet the Team Section */
        .team {
            padding: 60px 40px;
            text-align: center;
            background-color: #f1f1f1;
            margin-bottom: 40px;
        }
        .team h2 {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 30px;
        }
        .team-grid {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .team-member {
            background-color: #fff;
            width: 300px;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s;
        }
        .team-member:hover {
            transform: scale(1.05);
        }
        .team-member img {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 15px;
        }
        .team-member h3 {
            font-size: 18px;
            font-weight: bold;
            margin: 0 0 5px;
        }
        .team-member p {
            font-size: 14px;
            color: #666;
            margin: 0 0 10px;
        }
        .team-member .social-links {
            display: flex;
            gap: 10px;
            justify-content: center;
        }
        .team-member .social-links a {
            color: #3498db;
            font-size: 18px;
        }
        .team-member .social-links a:hover {
            color: #1e90ff;
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
                System.out.println("about.jsp: Session check - role: " + role + ", username: " + username + ", session ID: " + (session != null ? session.getId() : "null"));
                if (role == null || username == null) {
                    System.out.println("about.jsp: No session, displaying unauthenticated navbar without home, courses, and about");
            %>
                    <a href="#" class="login-button" data-action="login">login</a>
                    <a href="#" class="publisher-button" data-action="publisher-login">Become a Publisher</a>
            <%
                } else if ("USER".equals(role)) {
                    System.out.println("about.jsp: User session detected, displaying authenticated navbar for USER");
            %>
                    <a href="index.jsp" class="nav-home">Home</a>
                    <a href="courses.jsp" class="nav-link">courses</a>
                    <a href="about.jsp" class="nav-link active">about</a>
                    <a href="${pageContext.request.contextPath}/user_dashboard" class="user-info">
                        <i class="fas fa-user"></i>
                        <span><%= username %></span>
                    </a>
                    <a href="${pageContext.request.contextPath}/logout" class="logout-button">logout</a>
            <%
                } else if ("ADMIN".equals(role)) {
                    System.out.println("about.jsp: Role ADMIN detected, redirecting to admin_panel");
                    response.sendRedirect(request.getContextPath() + "/admin_panel");
                    return;
                } else {
                    System.out.println("about.jsp: Invalid or unsupported role (" + role + "), displaying unauthenticated navbar without home, courses, and about");
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
        <h2>About Coursemera<br><span>Empowering Learning</span></h2>
        <p>We are dedicated to providing accessible, high-quality education for everyone, everywhere.</p>
        <img src="https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Team Collaboration" class="team-image">
    </section>

    <!-- Our Story Section -->
    <section class="our-story">
        <h2>Our Story</h2>
        <p>Coursemera was founded with a mission to democratize education. We believe that learning should be a lifelong journey, accessible to all, regardless of location or background. Since our inception, we’ve connected millions of learners with expert instructors from around the globe, offering courses that inspire growth, creativity, and innovation.</p>
    </section>

    <!-- Core Values Section -->
    <section class="core-values">
        <h2>Our Core Values</h2>
        <div class="values-grid">
            <div class="value-card">
                <i class="fas fa-graduation-cap"></i>
                <h3>Education</h3>
                <p>We prioritize quality education that empowers individuals to achieve their goals.</p>
            </div>
            <div class="value-card">
                <i class="fas fa-users"></i>
                <h3>Inclusive Learning</h3>
                <p>We foster an environment where everyone has the opportunity to learn and grow.</p>
            </div>
            <div class="value-card">
                <i class="fas fa-lightbulb"></i>
                <h3>Innovation</h3>
                <p>We embrace new ideas and technologies to enhance the learning experience.</p>
            </div>
        </div>
    </section>

    <!-- Our Journey Section -->
    <section class="our-journey">
        <h2>Our Journey</h2>
        <div class="timeline">
            <div class="timeline-item">
                <div class="timeline-content">
                    <h3>Founded Coursemera</h3>
                    <div class="date">January 2018</div>
                    <p>Started with a vision to make education accessible to all.</p>
                </div>
            </div>
            <div class="timeline-item">
                <div class="timeline-content">
                    <h3>Reached 1M Users</h3>
                    <div class="date">March 2020</div>
                    <p>Celebrated our first major milestone with 1 million users.</p>
                </div>
            </div>
            <div class="timeline-item">
                <div class="timeline-content">
                    <h3>Expanded Course Library</h3>
                    <div class="date">June 2022</div>
                    <p>Introduced over 5,000 courses across various categories.</p>
                </div>
            </div>
            <div class="timeline-item">
                <div class="timeline-content">
                    <h3>Global Recognition</h3>
                    <div class="date">April 2024</div>
                    <p>Recognized as a leader in online education worldwide.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Meet the Team Section -->
    <section class="team">
        <h2>Meet the Team</h2>
        <div class="team-grid">
            <div class="team-member">
                <img src="https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D/300x200" alt="Michael Carter">
                <h3>Utkrist Shahi</h3>
                <p>Founder & CEO</p>
                <div class="social-links">
                    <a href="#"><i class="fab fa-linkedin"></i></a>
                    <a href="#"><i class="fab fa-twitter"></i></a>
                </div>
            </div>
            <div class="team-member">
                <img src="https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D/300x200" alt="Sarah Thompson">
                <h3>Deepika Bhujel</h3>
                <p>Chief Learning Officer</p>
                <div class="social-links">
                    <a href="#"><i class="fab fa-linkedin"></i></a>
                    <a href="#"><i class="fab fa-twitter"></i></a>
                </div>
            </div>
            <div class="team-member">
                <img src="https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D/300x200" alt="James Rodriguez">
                <h3>Bishal Khatri</h3>
                <p>Head of Technology</p>
                <div class="social-links">
                    <a href="#"><i class="fab fa-linkedin"></i></a>
                    <a href="#"><i class="fab fa-twitter"></i></a>
                </div>
            </div>
            <div class="team-member">
                <img src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D/300x200" alt="Emily Davis">
                <h3>Nisha Magar</h3>
                <p>Marketing Director</p>
                <div class="social-links">
                    <a href="#"><i class="fab fa-linkedin"></i></a>
                    <a href="#"><i class="fab fa-twitter"></i></a>
                </div>
            </div>
            <div class="team-member">
                <img src="https://images.unsplash.com/photo-1548372290-8d01b6c8e78c?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D/300x200" alt="David Kim">
                <h3>Prabesh Karki</h3>
                <p>Operations Manager</p>
                <div class="social-links">
                    <a href="#"><i class="fab fa-linkedin"></i></a>
                    <a href="#"><i class="fab fa-twitter"></i></a>
                </div>
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
        // passing authentication status to JavaScript
        const isAuthenticated = <%= isAuthenticated %>;

        // Redirecting logic for unauthenticated users
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

        // Highlight About button as active (only for authenticated users)
        const aboutButton = document.querySelector('.nav-link[href="about.jsp"]');
        if (aboutButton && window.location.pathname.endsWith('about.jsp')) {
            aboutButton.classList.add('active');
        }
    </script>
</body>
</html>
