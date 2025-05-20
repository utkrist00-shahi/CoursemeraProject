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
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f1f1f1;
            color: #333;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
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
            text-align: center;
        }
        .admin-container h2 {
            font-size: 28px;
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
        .admin-container .success {
            color: #2ecc71;
            font-size: 16px;
            margin-bottom: 20px;
        }
        .admin-container .error {
            color: #e74c3c;
            font-size: 16px;
            margin-bottom: 20px;
        }
        table {
            width: 80%;
            margin: 0 auto;
            border-collapse: collapse;
            background-color: #fff;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        table th, table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        table th {
            background-color: #3498db;
            color: #fff;
        }
        table td a {
            color: #3498db;
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
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        table td .delete-btn {
            background-color: #e74c3c;
            color: #fff;
        }
        table td .delete-btn:hover {
            background-color: #c0392b;
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
            <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel.jsp#courses-section'">Manage Courses</button>
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