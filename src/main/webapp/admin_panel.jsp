<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Publisher" %>
<%
// Session check before any output
if (session == null || session.getAttribute("role") == null || !"ADMIN".equals(session.getAttribute("role"))) {
    System.out.println("admin_panel.jsp: Unauthorized access, redirecting to login");
    response.sendRedirect(request.getContextPath() + "/login");
    return; // Stop further processing
}
System.out.println("admin_panel.jsp: Authorized access, username: " + session.getAttribute("username"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Coursemera</title>
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
        table td .approve-btn {
            background-color: #2ecc71;
            color: #fff;
        }
        table td .approve-btn:hover {
            background-color: #27ae60;
        }
        table td .reject-btn {
            background-color: #e74c3c;
            color: #fff;
        }
        table td .reject-btn:hover {
            background-color: #c0392b;
        }
        table td .delete-btn {
            background-color: #e74c3c;
            color: #fff;
        }
        table td .delete-btn:hover {
            background-color: #c0392b;
        }
        table td .view-resume-btn {
            background-color: #3498db;
            color: #fff;
            margin-right: 5px;
        }
        table td .view-resume-btn:hover {
            background-color: #1e90ff;
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

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1000;
        }
        .modal-content {
            background-color: #fff;
            margin: 5% auto;
            padding: 20px;
            border-radius: 10px;
            width: 90%;
            max-width: 800px;
            text-align: center;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            position: relative;
        }
        .modal-content h3 {
            margin: 0 0 15px;
            color: #333;
            font-size: 20px;
        }
        .modal-content p {
            margin: 10px 0;
            color: #666;
        }
        .modal-content object {
            width: 100%;
            height: 400px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .modal-content .download-btn {
            background-color: #8a2be2;
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 20px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 15px;
            transition: background-color 0.3s;
        }
        .modal-content .download-btn:hover {
            background-color: #6a1ab6;
        }
        .close {
            position: absolute;
            top: 10px;
            right: 15px;
            font-size: 24px;
            cursor: pointer;
            color: #888;
        }
        .close:hover {
            color: #555;
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
        <h2>Admin Panel</h2>
        <div class="admin-nav">
            <button class="active" onclick="showSection('publishers')">Manage Publishers</button>
            <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel_courses.jsp'">Manage Courses</button>
            <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel_users.jsp'">Manage Users</button>
        </div>
        <div id="publishers-section">
            <h3>Publisher Approvals</h3>
            <%
                String success = (String) request.getAttribute("success");
                if (success != null && !success.isEmpty()) {
                    System.out.println("admin_panel.jsp: Displaying success message: " + success);
            %>
                <p class="success"><%= success %></p>
            <%
                }
                String error = (String) request.getAttribute("error");
                if (error != null && !error.isEmpty()) {
                    System.err.println("admin_panel.jsp: Displaying error message: " + error);
            %>
                <p class="error"><%= error %></p>
            <%
                }
                List<Publisher> pendingPublishers = (List<Publisher>) request.getAttribute("pendingPublishers");
                System.out.println("admin_panel.jsp: Received " + (pendingPublishers != null ? pendingPublishers.size() : "null") + " pending publishers");
                if (pendingPublishers == null || pendingPublishers.isEmpty()) {
            %>
                <p>No pending publisher approvals.</p>
            <%
                } else {
            %>
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Resume</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (Publisher publisher : pendingPublishers) {
                                System.out.println("admin_panel.jsp: Rendering publisher - ID: " + publisher.getId() + ", Name: " + publisher.getFirstName() + " " + publisher.getLastName());
                        %>
                            <tr>
                                <td><%= publisher.getFirstName() != null ? publisher.getFirstName() : "" %> <%= publisher.getLastName() != null ? publisher.getLastName() : "" %></td>
                                <td><%= publisher.getEmail() != null ? publisher.getEmail() : "N/A" %></td>
                                <td>
                                    <% if (publisher.getResumeFilename() != null && publisher.getResume() != null) { %>
                                        <button class="view-resume-btn" onclick="openModal('<%= publisher.getId() %>', '<%= publisher.getResumeFilename() %>')">View Resume</button>
                                    <% } else { %>
                                        No resume
                                    <% } %>
                                </td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/admin_panel" method="post">
                                        <input type="hidden" name="publisherId" value="<%= publisher.getId() %>">
                                        <input type="hidden" name="action" value="approve">
                                        <button type="submit" class="approve-btn">Approve</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/admin_panel" method="post">
                                        <input type="hidden" name="publisherId" value="<%= publisher.getId() %>">
                                        <input type="hidden" name="action" value="reject">
                                        <button type="submit" class="reject-btn">Reject</button>
                                    </form>
                                </td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            <%
                }
            %>
        </div>
        </div>
        
      
    <!-- Footer -->
    <footer>
        <p>© 2025 CourseMera. All rights reserved.</p>
    </footer>

    <!-- Modal -->
    <div id="resumeModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">×</span>
            <h3>Resume Overview</h3>
            <p id="modalFilename"></p>
            <object id="pdfPreview" type="application/pdf" data="">
                <p>PDF preview not supported by your browser. Please download the file to view it.</p>
            </object>
            <button class="download-btn" onclick="downloadResume()">Download</button>
        </div>
    </div>

    <script>
        function showSection(sectionId) {
            document.getElementById('publishers-section').style.display = sectionId === 'publishers' ? 'block' : 'none';
         

            document.querySelectorAll('.admin-nav button').forEach(btn => {
                btn.classList.remove('active');
                if (btn.getAttribute('onclick').includes(sectionId)) {
                    btn.classList.add('active');
                }
            });
        }

        function openModal(publisherId, filename) {
            document.getElementById('modalFilename').innerText = filename;
            const pdfPreview = document.getElementById('pdfPreview');
            pdfPreview.setAttribute('data', '${pageContext.request.contextPath}/admin_download_resume?publisherId=' + publisherId + '&inline=true');
            document.getElementById('resumeModal').style.display = 'block';
            window.currentPublisherId = publisherId; // Store publisherId for download
        }

        function closeModal() {
            document.getElementById('resumeModal').style.display = 'none';
            const pdfPreview = document.getElementById('pdfPreview');
            pdfPreview.setAttribute('data', ''); // Clear PDF to prevent caching issues
        }

        function downloadResume() {
            if (window.currentPublisherId) {
                // Create a form to submit the download request
                const form = document.createElement('form');
                form.method = 'GET';
                form.action = '${pageContext.request.contextPath}/admin_download_resume';
                form.target = '_blank'; // Open in new tab to handle download

                const input1 = document.createElement('input');
                input1.type = 'hidden';
                input1.name = 'publisherId';
                input1.value = window.currentPublisherId;

                const input2 = document.createElement('input');
                input2.type = 'hidden';
                input2.name = 'inline';
                input2.value = 'false'; // Force download

                form.appendChild(input1);
                form.appendChild(input2);
                document.body.appendChild(form);
                form.submit();
                document.body.removeChild(form);

                closeModal(); // Close modal after initiating download
            }
        }

        // Close modal if user clicks outside
        window.onclick = function(event) {
            const modal = document.getElementById('resumeModal');
            if (event.target == modal) {
                modal.style.display = 'none';
                const pdfPreview = document.getElementById('pdfPreview');
                pdfPreview.setAttribute('data', ''); // Clear PDF to prevent caching issues
            }
        }
    </script>
</body>
</html>