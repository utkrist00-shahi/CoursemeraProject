
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// Prevent caching of the page
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

// Check if logout occurred
String loggedOut = request.getParameter("loggedOut");
if ("true".equals(loggedOut)) {
    System.out.println("courses.jsp: Logout detected via query parameter, ensuring unauthenticated state");
    if (session != null) {
        session.invalidate();
    }
}

// Determine authentication status
String role = (String) session.getAttribute("role");
String username = (String) session.getAttribute("username");
boolean isAuthenticated = (role != null && username != null);
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
        }

        .container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 24px;
        }

        /* Header from index.jsp */
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

        /* Hero Section */
        .hero {
            padding: 80px 0;
            background: linear-gradient(135deg, #f6f7ff 0%, #f0f4ff 100%);
            text-align: center;
        }

        .hero h1 {
            font-size: 48px;
            font-weight: 800;
            margin-bottom: 16px;
            color: var(--dark-color);
        }

        .hero p {
            font-size: 18px;
            color: var(--light-text);
            max-width: 700px;
            margin: 0 auto 32px;
        }

        .hero-buttons {
            display: flex;
            justify-content: center;
            gap: 16px;
        }

        .primary-btn {
            background: var(--primary-color);
            color: white;
            padding: 14px 28px;
            border-radius: var(--border-radius);
            font-weight: 600;
            border: none;
            cursor: pointer;
            transition: var(--transition);
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
        }

        .primary-btn:hover {
            background: #3a5bef;
            transform: translateY(-2px);
        }

        .secondary-btn:hover {
            background: rgba(74, 107, 255, 0.1);
            transform: translateY(-2px);
        }

        /* Categories */
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

        /* Courses */
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
        }

        .enroll-btn:hover {
            background: #3a5bef;
            transform: translateY(-2px);
        }

        /* Testimonials */
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

        /* Footer from index.jsp */
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

        /* Responsive */
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
    <!-- Header from index.jsp -->
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
                    <a href="${pageContext.request.contextPath}/logout" class="logout-button">logout</a>
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

    <!-- Hero Section (Removed Join for Free) -->
    <section class="hero">
        <div class="container">
            <h1>Learn without limits</h1>
            <p>Start, switch, or advance your career with over 5,000 courses, Professional Certificates, and degrees from world-class universities and companies.</p>
            <div class="hero-buttons">
                <button class="secondary-btn">Explore Courses</button>
            </div>
        </div>
    </section>

    <!-- Categories -->
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
                <div class="category-card">
                    <div class="category-icon">🎭</div>
                    <h3>Arts & Humanities</h3>
                    <p>History, Music, Photography</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Popular Courses (Added Enroll Now buttons) -->
    <section class="courses-section">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Popular Courses</h2>
                <a href="#" class="view-all">View all →</a>
            </div>
            <div class="course-grid">
                <div class="course-card">
                    <img src="https://images.unsplash.com/photo-1555066931-4365d14bab8c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60" alt="Web Development" class="course-image">
                    <div class="course-content">
                        <div class="course-category">Technology</div>
                        <h3 class="course-title">Complete Web Development Bootcamp</h3>
                        <div class="course-instructor">Dr. Angela Yu</div>
                        <div class="course-meta">
                            <div class="course-price">$49.99</div>
                            <div class="course-rating">
                                <div class="stars">★★★★★</div>
                                <div class="rating-count">(4,287)</div>
                            </div>
                        </div>
                        <button class="enroll-btn">Enroll Now</button>
                    </div>
                </div>
                <div class="course-card">
                    <img src="https://images.unsplash.com/photo-1460925895917-afdab827c52f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60" alt="Data Science" class="course-image">
                    <div class="course-content">
                        <div class="course-category">Science</div>
                        <h3 class="course-title">Data Science A-Z</h3>
                        <div class="course-instructor">Kirill Eremenko</div>
                        <div class="course-meta">
                            <div class="course-price">$59.99</div>
                            <div class="course-rating">
                                <div class="stars">★★★★☆</div>
                                <div class="rating-count">(3,142)</div>
                            </div>
                        </div>
                        <button class="enroll-btn">Enroll Now</button>
                    </div>
                </div>
                <div class="course-card">
                    <img src="https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60" alt="Digital Marketing" class="course-image">
                    <div class="course-content">
                        <div class="course-category">Business</div>
                        <h3 class="course-title">Digital Marketing Masterclass</h3>
                        <div class="course-instructor">Paula Pant</div>
                        <div class="course-meta">
                            <div class="course-price">$39.99</div>
                            <div class="course-rating">
                                <div class="stars">★★★★★</div>
                                <div class="rating-count">(2,856)</div>
                            </div>
                        </div>
                        <button class="enroll-btn">Enroll Now</button>
                    </div>
                </div>
                <div class="course-card">
                   <img src="https://images.unsplash.com/photo-1542744173-8e7e53415bb0?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60" alt="Business" class="course-image"> <div class="course-content">
                        <div class="course-category">Business</div>
                        <h3 class="course-title">Business Fundamentals</h3>
                        <div class="course-instructor">Chris Haroun</div>
                        <div class="course-meta">
                            <div class="course-price">$29.99</div>
                            <div class="course-rating">
                                <div class="stars">★★★★☆</div>
                                <div class="rating-count">(1,943)</div>
                            </div>
                        </div>
                        <button class="enroll-btn">Enroll Now</button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- New Courses (Added Enroll Now buttons) -->
    <section class="courses-section">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">New & Noteworthy</h2>
                <a href="#" class="view-all">View all →</a>
            </div>
            <div class="course-grid">
                <div class="course-card">
                    <img src="https://images.unsplash.com/photo-1593642632823-8f785ba67e45?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60" alt="Python" class="course-image">
                    <div class="course-content">
                        <div class="course-category">Technology</div>
                        <h3 class="course-title">Python for Data Science</h3>
                        <div class="course-instructor">Jose Portilla</div>
                        <div class="course-meta">
                            <div class="course-price">$54.99</div>
                            <div class="course-rating">
                                <div class="stars">★★★★★</div>
                                <div class="rating-count">(876)</div>
                            </div>
                        </div>
                        <button class="enroll-btn">Enroll Now</button>
                    </div>
                </div>
                <div class="course-card">
                    <img src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60" alt="AI" class="course-image">
                    <div class="course-content">
                        <div class="course-category">Technology</div>
                        <h3 class="course-title">AI for Everyone</h3>
                        <div class="course-instructor">Andrew Ng</div>
                        <div class="course-meta">
                            <div class="course-price">$49.99</div>
                            <div class="course-rating">
                                <div class="stars">★★★★☆</div>
                                <div class="rating-count">(1,024)</div>
                            </div>
                        </div>
                        <button class="enroll-btn">Enroll Now</button>
                    </div>
                </div>
                <div class="course-card">
                    <img src="https://images.unsplash.com/photo-1542626991-cbc4e32524cc?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60" alt="Photography" class="course-image">
                    <div class="course-content">
                        <div class="course-category">Arts</div>
                        <h3 class="course-title">Photography Masterclass</h3>
                        <div class="course-instructor">Annie Leibovitz</div>
                        <div class="course-meta">
                            <div class="course-price">$34.99</div>
                            <div class="course-rating">
                                <div class="stars">★★★★★</div>
                                <div class="rating-count">(742)</div>
                            </div>
                        </div>
                        <button class="enroll-btn">Enroll Now</button>
                    </div>
                </div>
                <div class="course-card">
                    <img src="https://images.unsplash.com/photo-1450101499163-c8848c66ca85?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60" alt="Finance" class="course-image">
                    <div class="course-content">
                        <div class="course-category">Business</div>
                        <h3 class="course-title">Personal Finance Planning</h3>
                        <div class="course-instructor">Ramit Sethi</div>
                        <div class="course-meta">
                            <div class="course-price">$29.99</div>
                            <div class="course-rating">
                                <div class="stars">★★★★☆</div>
                                <div class="rating-count">(1,156)</div>
                            </div>
                        </div>
                        <button class="enroll-btn">Enroll Now</button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Testimonials -->
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

    <!-- CTA (Removed Get Started) -->
    <section class="hero" style="background: var(--primary-color); padding: 60px 0;">
        <div class="container" style="text-align: center;">
            <h1 style="color: white;">Start learning today</h1>
            <p style="color: rgba(255,255,255,0.8); margin-bottom: 32px;">Join over 10 million learners worldwide and gain new skills today.</p>
        </div>
    </section>

    <!-- Footer from index.jsp -->
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
        document.querySelectorAll('.action-link, [data-action], .enroll-btn').forEach(element => {
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
                    if (element.classList.contains('enroll-btn')) {
                        console.log('Enroll Now clicked for: ' + element.closest('.course-card').querySelector('.course-title').textContent);
                    }
                }
            });
        });

        // Simple script to toggle mobile menu (would be expanded in production)
        document.querySelectorAll('.course-card').forEach(card => {
            card.addEventListener('click', function(e) {
                if (!e.target.classList.contains('enroll-btn')) {
                    console.log('Course clicked: ' + this.querySelector('.course-title').textContent);
                }
            });
        });
    </script>
</body>
</html>
