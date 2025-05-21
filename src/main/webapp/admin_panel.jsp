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

        .success {
            color: #065f46;
            font-size: 0.875rem;
            text-align: center;
            margin: 8px 0;
            padding: 8px;
            background: #ecfdf5;
            border: 1px solid #6ee7b7;
            border-radius: var(--border-radius);
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

        table {
            width: 100%;
            border-collapse: collapse;
            background: #ffffff;
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: var(--box-shadow);
        }

        table th, table td {
            padding: 12px;
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
            margin: 0 4px;
        }

        table td button {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 0.875rem;
            border: none;
            cursor: pointer;
            transition: var(--transition);
        }

        table td .approve-btn {
            background: var(--primary-color);
            color: #fff;
        }

        table td .approve-btn:hover {
            background: var(--secondary-color);
        }

        table td .reject-btn {
            background: #dc2626;
            color: #fff;
        }

        table td .reject-btn:hover {
            background: #b91c1c;
        }

        table td .view-resume-btn {
            background: var(--primary-color);
            color: #fff;
            margin-right: 4px;
        }

        table td .view-resume-btn:hover {
            background: var(--secondary-color);
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
        }

        .modal-content {
            background: #ffffff;
            margin: 5% auto;
            padding: 20px;
            border-radius: var(--border-radius);
            width: 90%;
            max-width: 800px;
            text-align: center;
            box-shadow: var(--box-shadow);
            position: relative;
        }

        .modal-content h3 {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--dark-color);
            margin: 0 0 12px;
        }

        .modal-content p {
            font-size: 0.875rem;
            color: var(--light-text);
            margin: 8px 0;
        }

        .modal-content object {
            width: 100%;
            height: 400px;
            border: 1px solid #e2e8f0;
            border-radius: var(--border-radius);
        }

        .modal-content .download-btn {
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 0.875rem;
            border: none;
            cursor: pointer;
            transition: var(--transition);
            background: var(--primary-color);
            color: #fff;
            margin-top: 12px;
        }

        .modal-content .download-btn:hover {
            background: var(--secondary-color);
        }

        .close {
            position: absolute;
            top: 10px;
            right: 15px;
            font-size: 1.5rem;
            cursor: pointer;
            color: var(--light-text);
        }

        .close:hover {
            color: var(--text-color);
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
            .admin-nav {
                flex-direction: column;
                gap: 8px;
            }
            table {
                font-size: 0.75rem;
            }
            table th, table td {
                padding: 8px;
            }
            .modal-content {
                width: 95%;
                margin: 10% auto;
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
            <section id="publishers-section">
                <div class="section-header">
                    <h2 class="section-title">Admin Panel</h2>
                </div>
                <div class="admin-nav">
                    <button class="active" onclick="showSection('publishers')">Manage Publishers</button>
                    <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel_courses.jsp'">Manage Courses</button>
                    <button onclick="window.location.href='${pageContext.request.contextPath}/admin_panel_users.jsp'">Manage Users</button>
                </div>
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
                    <p class="error">No pending publisher approvals.</p>
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
            </section>
        </div>

        <footer>
            <p>© 2025 CourseMera. All rights reserved.</p>
        </footer>

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
            window.currentPublisherId = publisherId;
        }

        function closeModal() {
            document.getElementById('resumeModal').style.display = 'none';
            const pdfPreview = document.getElementById('pdfPreview');
            pdfPreview.setAttribute('data', '');
        }

        function downloadResume() {
            if (window.currentPublisherId) {
                const form = document.createElement('form');
                form.method = 'GET';
                form.action = '${pageContext.request.contextPath}/admin_download_resume';
                form.target = '_blank';

                const input1 = document.createElement('input');
                input1.type = 'hidden';
                input1.name = 'publisherId';
                input1.value = window.currentPublisherId;

                const input2 = document.createElement('input');
                input2.type = 'hidden';
                input2.name = 'inline';
                input2.value = 'false';

                form.appendChild(input1);
                form.appendChild(input2);
                document.body.appendChild(form);
                form.submit();
                document.body.removeChild(form);

                closeModal();
            }
        }

        window.onclick = function(event) {
            const modal = document.getElementById('resumeModal');
            if (event.target == modal) {
                modal.style.display = 'none';
                const pdfPreview = document.getElementById('pdfPreview');
                pdfPreview.setAttribute('data', '');
            }
        }
    </script>
</body>
</html>