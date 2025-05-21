package controller;

import dao.PublisherDAO;
import model.Publisher;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin_panel")
public class AdminApprovalServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PublisherDAO publisherDao;

    @Override
    public void init() throws ServletException {
        publisherDao = new PublisherDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"ADMIN".equals(session.getAttribute("role"))) {
            System.out.println("AdminApprovalServlet: Unauthorized access to admin_panel (GET), redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        System.out.println("AdminApprovalServlet: Authorized admin access (GET), username: " + session.getAttribute("username"));

        List<Publisher> pendingPublishers = publisherDao.getPendingPublishers();
        System.out.println("AdminApprovalServlet: Forwarding " + pendingPublishers.size() + " pending publishers to admin_panel.jsp");
        if (pendingPublishers.isEmpty()) {
            System.out.println("AdminApprovalServlet: No pending publishers found to display");
        } else {
            for (Publisher p : pendingPublishers) {
                System.out.println("AdminApprovalServlet: Publisher - ID: " + p.getId() + ", Name: " + p.getFirstName() + " " + p.getLastName() + ", Email: " + p.getEmail());
            }
        }
        request.setAttribute("pendingPublishers", pendingPublishers);
        request.getRequestDispatcher("/admin_panel.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"ADMIN".equals(session.getAttribute("role"))) {
            System.out.println("AdminApprovalServlet: Unauthorized access to admin_panel (POST), redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        System.out.println("AdminApprovalServlet: Authorized admin access (POST), username: " + session.getAttribute("username"));

        String action = request.getParameter("action");
        String publisherIdParam = request.getParameter("publisherId");
        System.out.println("AdminApprovalServlet: Received action: " + action + ", publisherId: " + publisherIdParam);

        int publisherId;
        try {
            publisherId = Integer.parseInt(publisherIdParam);
        } catch (NumberFormatException e) {
            System.err.println("AdminApprovalServlet: Invalid publisherId format: " + publisherIdParam);
            request.setAttribute("error", "Invalid publisher ID format.");
            List<Publisher> pendingPublishers = publisherDao.getPendingPublishers();
            request.setAttribute("pendingPublishers", pendingPublishers);
            request.getRequestDispatcher("/admin_panel.jsp").forward(request, response);
            return;
        }

        Publisher publisher = publisherDao.getPendingPublisherById(publisherId);
        if (publisher == null) {
            System.err.println("AdminApprovalServlet: Publisher with ID " + publisherId + " not found in publisher_approvals");
            request.setAttribute("error", "Publisher not found in pending approvals.");
            List<Publisher> pendingPublishers = publisherDao.getPendingPublishers();
            request.setAttribute("pendingPublishers", pendingPublishers);
            request.getRequestDispatcher("/admin_panel.jsp").forward(request, response);
            return;
        }

        try {
            if ("approve".equals(action)) {
                // Check for obvious issues before moving
                String errorMessage = null;
                if (publisher.getFirstName() == null || publisher.getFirstName().trim().isEmpty()) {
                    errorMessage = "First name is missing for publisher ID: " + publisherId;
                } else if (publisher.getEmail() == null || publisher.getEmail().trim().isEmpty()) {
                    errorMessage = "Email is missing for publisher ID: " + publisherId;
                } else if (publisher.getPassword() == null || publisher.getPassword().trim().isEmpty()) {
                    errorMessage = "Password is missing for publisher ID: " + publisherId;
                } else if (publisher.getCreatedAt() == null) {
                    errorMessage = "Created_at timestamp is missing for publisher ID: " + publisherId;
                } else if (publisherDao.getPublisherByEmail(publisher.getEmail()) != null) {
                    errorMessage = "Email " + publisher.getEmail() + " already exists in approved publishers.";
                }

                if (errorMessage != null) {
                    System.err.println("AdminApprovalServlet: Cannot approve publisher ID: " + publisherId + ". Reason: " + errorMessage);
                    request.setAttribute("error", errorMessage);
                } else {
                    String result = publisherDao.moveToPublishers(publisherId);
                    if ("Success".equals(result)) {
                        request.setAttribute("success", "Publisher approved successfully.");
                        System.out.println("AdminApprovalServlet: Approved publisher ID: " + publisherId);
                    } else {
                        request.setAttribute("error", "Failed to approve publisher ID: " + publisherId + ". Reason: " + result);
                        System.err.println("AdminApprovalServlet: Failed to approve publisher ID: " + publisherId +
                                ", Email: " + publisher.getEmail() + ", Reason: " + result);
                    }
                }
            } else if ("reject".equals(action)) {
                boolean actionSuccess = publisherDao.deletePendingPublisher(publisherId);
                if (actionSuccess) {
                    request.setAttribute("success", "Publisher rejected successfully.");
                    System.out.println("AdminApprovalServlet: Rejected publisher ID: " + publisherId);
                } else {
                    request.setAttribute("error", "Failed to reject publisher ID: " + publisherId + ". Check server logs.");
                    System.err.println("AdminApprovalServlet: Failed to reject publisher ID: " + publisherId);
                }
            } else {
                System.err.println("AdminApprovalServlet: Invalid action: " + action);
                request.setAttribute("error", "Invalid action specified.");
            }
        } catch (Exception e) {
            System.err.println("AdminApprovalServlet: Error processing action for publisher ID: " + publisherId + ": " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while processing the request: " + e.getMessage());
        }

        List<Publisher> pendingPublishers = publisherDao.getPendingPublishers();
        System.out.println("AdminApprovalServlet: After action, forwarding " + pendingPublishers.size() + " pending publishers to admin_panel.jsp");
        request.setAttribute("pendingPublishers", pendingPublishers);
        request.getRequestDispatcher("/admin_panel.jsp").forward(request, response);
    }
}