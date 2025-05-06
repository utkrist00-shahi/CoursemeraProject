package controller;

import dao.PublisherDAO;
import model.Publisher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;

@WebServlet("/ProfileManagementServlet")
@MultipartConfig(maxFileSize = 2 * 1024 * 1024) // 2MB limit
public class ProfileManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PublisherDAO publisherDAO;

    @Override
    public void init() throws ServletException {
        publisherDAO = new PublisherDAO();
        System.out.println("ProfileManagementServlet: Initialized successfully at " + new java.util.Date());
        try {
            if (publisherDAO == null) {
                throw new ServletException("ProfileManagementServlet: PublisherDAO failed to initialize.");
            }
            System.out.println("ProfileManagementServlet: PublisherDAO instantiated successfully.");
        } catch (Exception e) {
            System.err.println("ProfileManagementServlet: Error during initialization - " + e.getMessage());
            throw new ServletException("ProfileManagementServlet: Initialization failed.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("ProfileManagementServlet: Received POST request at " + new java.util.Date());
        HttpSession session = request.getSession();
        Integer publisherId = (Integer) session.getAttribute("publisherId");
        System.out.println("ProfileManagementServlet: publisherId from session - " + publisherId);

        if (publisherId == null) {
            System.out.println("ProfileManagementServlet: publisherId is null, redirecting to login.");
            response.sendRedirect("publisher_login.jsp");
            return;
        }

        String action = request.getParameter("action");
        System.out.println("ProfileManagementServlet: Action received - " + action);

        if ("update".equals(action)) {
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            Part filePart = request.getPart("profilePicture");
            byte[] profilePicture = null;

            // Handle profile picture upload
            if (filePart != null && filePart.getSize() > 0) {
                String contentType = filePart.getContentType();
                if (contentType != null && contentType.startsWith("image/")) {
                    try (InputStream input = filePart.getInputStream()) {
                        profilePicture = input.readAllBytes();
                        System.out.println("ProfileManagementServlet: Profile picture uploaded, size: " + profilePicture.length + " bytes");
                    } catch (IOException e) {
                        System.err.println("ProfileManagementServlet: Error reading profile picture - " + e.getMessage());
                        session.setAttribute("error", "Failed to upload profile picture: " + e.getMessage());
                        response.sendRedirect("publisher_dashboard.jsp");
                        return;
                    }
                } else {
                    System.out.println("ProfileManagementServlet: Invalid file type for profile picture - " + contentType);
                    session.setAttribute("error", "Profile picture must be an image.");
                    response.sendRedirect("publisher_dashboard.jsp");
                    return;
                }
            }

            System.out.println("ProfileManagementServlet: Updating profile - FirstName: " + firstName + ", LastName: " + lastName + ", Email: " + email);

            Publisher publisher = new Publisher();
            publisher.setId(publisherId);
            publisher.setFirstName(firstName);
            publisher.setLastName(lastName);
            publisher.setEmail(email);
            if (profilePicture != null) {
                publisher.setProfilePicture(profilePicture);
            }

            try {
                if (publisherDAO.updatePublisher(publisher)) {
                    session.setAttribute("firstName", firstName);
                    session.setAttribute("lastName", lastName);
                    session.setAttribute("email", email);
                    session.setAttribute("message", "Profile updated successfully!");
                    System.out.println("ProfileManagementServlet: Profile updated successfully.");
                } else {
                    session.setAttribute("error", "Failed to update profile.");
                    System.out.println("ProfileManagementServlet: Failed to update profile.");
                }
            } catch (Exception e) {
                System.err.println("ProfileManagementServlet: Error during profile update - " + e.getMessage());
                session.setAttribute("error", "Failed to update profile due to server error: " + e.getMessage());
            }
            response.sendRedirect("publisher_dashboard.jsp");
        } else {
            System.out.println("ProfileManagementServlet: Invalid action received - " + action);
            session.setAttribute("error", "Invalid action.");
            response.sendRedirect("publisher_dashboard.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("ProfileManagementServlet: Received GET request at " + new java.util.Date());
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "GET method not supported.");
    }
}