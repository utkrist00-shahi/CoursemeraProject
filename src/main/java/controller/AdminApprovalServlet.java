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
        // Check if user is logged in and has ADMIN role
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"ADMIN".equals(session.getAttribute("role"))) {
            System.out.println("AdminApprovalServlet: Unauthorized access to admin_panel (GET), redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        System.out.println("AdminApprovalServlet: Authorized admin access (GET), username: " + session.getAttribute("username"));

        // Fetch all pending publishers from publisher_approvals
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
        // Check if user is logged in and has ADMIN role
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"ADMIN".equals(session.getAttribute("role"))) {
            System.out.println("AdminApprovalServlet: Unauthorized access to admin_panel (POST), redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        System.out.println("AdminApprovalServlet: Authorized admin access (POST), username: " + session.getAttribute("username"));

        // Get form parameters
        String action = request.getParameter("action");
        String publisherIdParam = request.getParameter("publisherId");
        System.out.println("AdminApprovalServlet: Received action: " + action + ", publisherId: " + publisherIdParam);

        // Validate publisherId
        int publisherId;
        try {
            publisherId = Integer.parseInt(publisherIdParam);
        } catch (NumberFormatException e) {
            System.err.println("AdminApprovalServlet: Invalid publisherId format: " + publisherIdParam);
            request.setAttribute("error", "Invalid publisher ID.");
            List<Publisher> pendingPublishers = publisherDao.getPendingPublishers();
            request.setAttribute("pendingPublishers", pendingPublishers);
            request.getRequestDispatcher("/admin_panel.jsp").forward(request, response);
            return;
        }

        // Check if the publisher exists in publisher_approvals
        Publisher publisher = publisherDao.getPendingPublisherById(publisherId);
        if (publisher == null) {
            System.err.println("AdminApprovalServlet: Publisher with ID " + publisherId + " not found in publisher_approvals");
            request.setAttribute("error", "Publisher not found.");
            List<Publisher> pendingPublishers = publisherDao.getPendingPublishers();
            request.setAttribute("pendingPublishers", pendingPublishers);
            request.getRequestDispatcher("/admin_panel.jsp").forward(request, response);
            return;
        }

        // Process the action
        boolean actionSuccess = false;
        try {
            if ("approve".equals(action)) {
                // Move to publishers table and delete from publisher_approvals
                actionSuccess = publisherDao.moveToPublishers(publisherId);
                if (actionSuccess) {
                    request.setAttribute("success", "Publisher approved successfully.");
                    System.out.println("AdminApprovalServlet: Approved publisher ID: " + publisherId);
                } else {
                    // Enhanced error message to help diagnose the issue
                    String errorMessage = "Failed to approve publisher. Check server logs for details. " +
                            "Possible reasons: email already exists, required fields missing, or database error.";
                    request.setAttribute("error", errorMessage);
                    System.err.println("AdminApprovalServlet: Failed to approve publisher ID: " + publisherId +
                            ". Email: " + publisher.getEmail());
                }
            } else if ("reject".equals(action)) {
                // Delete from publisher_approvals
                actionSuccess = publisherDao.deletePendingPublisher(publisherId);
                if (actionSuccess) {
                    request.setAttribute("success", "Publisher rejected successfully.");
                    System.out.println("AdminApprovalServlet: Rejected publisher ID: " + publisherId);
                } else {
                    request.setAttribute("error", "Failed to reject publisher.");
                    System.err.println("AdminApprovalServlet: Failed to reject publisher ID: " + publisherId);
                }
            } else {
                System.err.println("AdminApprovalServlet: Invalid action: " + action);
                request.setAttribute("error", "Invalid action.");
            }
        } catch (Exception e) {
            System.err.println("AdminApprovalServlet: Error processing action: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while processing the request: " + e.getMessage());
        }

        // Refresh the list of pending publishers
        List<Publisher> pendingPublishers = publisherDao.getPendingPublishers();
        System.out.println("AdminApprovalServlet: After action, forwarding " + pendingPublishers.size() + " pending publishers to admin_panel.jsp");
        request.setAttribute("pendingPublishers", pendingPublishers);
        request.getRequestDispatcher("/admin_panel.jsp").forward(request, response);
    }
}