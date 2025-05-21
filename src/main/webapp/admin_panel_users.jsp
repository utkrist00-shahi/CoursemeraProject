<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.User" %>
<%
// Session check before any output
if (session == null || session.getAttribute("role") == null || !"ADMIN".equals(session.getAttribute("role"))) {
    System.out.println("admin_panel_users.jsp: Unauthorized access, redirecting to login");
    response.sendRedirect(request.getContextPath() + "/login");
    return; // Stop further processing
}
System.out.println("admin_panel_users.jsp: Authorized access, username: " + session.getAttribute("username"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Manage Users - Coursemera</title>
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

        .admin-container {
            flex: 1;
            padding: 40px 20px;
            text-align: center;
            background: #ffffff;
        }

        header {
            background: #ffffff;
            padding: 20px 40px;
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
            width: 80px;
            height: 80px;
        }

        header h1 {
            font-size: 24px;
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
            gap: 20px;
        }

        header nav .admin-info {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 16px;
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

        header nav .admin-info i {
            color: #fff;
        }

        header nav a.logout-button {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 600;
            font-size: 16px;
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

        .admin-container h2 {
            font-size: 28px;
            font-weight: 600;
            color: var(--dark-color);
            margin: 0 0 20px;
            padding-bottom: 8px;
            position: relative;
        }

        .admin-container h2::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 40px;
            height: 3px;
            background: var(--primary-color);
        }

        .admin-container h3 {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--dark-color);
            margin: 0 0 20px;
        }

        .admin-nav {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-bottom: 30px;
        }

        .admin-nav button {
            padding: 12px 24px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 16px;
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

        .success {
            color: #065f46;
            font-size: 16px;
            text-align: center;
            margin: 0 0 20px;
            padding: 8px;
            background: #ecfdf5;
            border: 1px solid #6ee7b7;
            border-radius: var(--border-radius);
        }

        .error {
            color: #dc2626;
            font-size: 16px;
            text-align: center;
            margin: 0 0 20px;
            padding: 8px;
            background: #fef2f2;
            border: 1px solid #f87171;
            border-radius: var(--border-radius);
        }

        table {
            width: 80%;
            margin: 0 auto;
            border-collapse: collapse;
            background: #ffffff;
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: var(--box-shadow);
        }

        table th, table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        table th {
            background: var(--primary-color);
            color: #fff;
            font-weight: 600;
            font-size: 0.875rem;
        }

        table td {
            font-size: 0.875rem;
        }

        table td a {
            color: var(--primary-color);
            text-decoration: none;
        }

        table td a:hover {
            text-decoration: underline;
        }

        table td form {
            display: inline;
            margin: 0 5px;
        }

        table td button {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 14px;
            border: none;
            cursor: pointer;
            transition: var(--transition);
        }

        table td .delete-btn {
            background: #dc2626;
            color: #fff;
        }

        table td .delete-btn:hover {
            background: #b91c1c;
        }

        footer {
            background: var(--dark-color);
            color: var(--light-color);
            padding: 20px 40px;
            text-align: center;
        }

        footer p {
            margin: 0;
            font-size: 14px;
            color: var(--light-text);
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
            .admin-container {
                padding: 20px 16px;
            }
            .admin-nav {
                flex-direction: column;
                gap: 8px;
            }
            table {
                width: 100%;
                font-size: 0.75rem;
            }
            table th, table td {
                padding: 8px;
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
        <h2>Admin Panel - Manage Users</h2>
        <div class="admin-nav">
            <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel'">Manage Publishers</button>
            <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel_courses.jsp'">Manage Courses</button>
            <button class="active">Manage Users</button>
        </div>
        <div id="users-section">
            <h3>Manage Users</h3>
            <%
                List<User> users = (List<User>) request.getAttribute("users");
                if (users == null) {
                    System.out.println("admin_panel_users.jsp: users null, redirecting to /adminmanageacc");
                    response.sendRedirect(request.getContextPath() + "/adminmanageacc");
                    return;
                }
                System.out.println("admin_panel_users.jsp: Received " + (users != null ? users.size() : "null") + " users");
            %>
            <% if (users.isEmpty()) { %>
                <p>No users found.</p>
            <% } else { %>
                <table border="1">
                    <thead>
                        <tr>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (User user : users) { %>
                        <tr>
                            <td><%= user.getUsername() != null ? user.getUsername() : "N/A" %></td>
                            <td><%= user.getEmail() != null ? user.getEmail() : "N/A" %></td>
                            <td>
                                <form action="${pageContext.request.contextPath}/adminmanageacc" method="post" onsubmit="return confirm('Delete user <%= user.getUsername() %>?');">
                                    <input type="hidden" name="userId" value="<%= user.getId() %>">
                                    <input type="hidden" name="action" value="delete">
                                    <button type="submit" class="delete-btn">Delete</button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
            <% String error = (String) request.getAttribute("error");
               if (error != null && !error.isEmpty()) { %>
                <p class="error"><%= error %></p>
            <% }
               String success = (String) request.getAttribute("success");
               if (success != null && !success.isEmpty()) { %>
                <p class="success"><%= success %></p>
            <% } %>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        <p>© 2025 CourseMera. All rights reserved.</p>
    </footer>
</body>
</html>