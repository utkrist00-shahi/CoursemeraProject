package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import dao.UserDAO;
import model.User;

@WebServlet("/user_dashboard")
@MultipartConfig(maxFileSize = 1024 * 1024 * 5) // 5MB max
public class UserDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDao;

    @Override
    public void init() throws ServletException {
        userDao = new UserDAO();
        System.out.println("UserDashboardServlet: Initialized with UserDAO.");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Prevent caching
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("UserDashboardServlet: No session or userId, redirecting to login.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        try {
            System.out.println("UserDashboardServlet: Fetching user with ID: " + userId);
            User user = userDao.getUserById(userId);
            if (user != null) {
                request.setAttribute("user", user);
                System.out.println("UserDashboardServlet: Forwarding to user_dashboard.jsp for user ID: " + userId);
                request.getRequestDispatcher("/user_dashboard.jsp").forward(request, response);
            } else {
                System.out.println("UserDashboardServlet: User not found for ID: " + userId + ", redirecting to login.");
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
            }
        } catch (Exception e) {
            System.out.println("UserDashboardServlet: Error in doGet - " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Prevent caching
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("UserDashboardServlet: No session or userId in doPost, redirecting to login.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        User user = userDao.getUserById(userId);
        if (user == null) {
            System.out.println("UserDashboardServlet: User not found for ID in doPost: " + userId + ", redirecting to login.");
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String action = request.getParameter("action");
            System.out.println("UserDashboardServlet: Processing POST action: " + action);

            if ("uploadImage".equals(action)) {
                Part filePart = request.getPart("profileImage");
                if (filePart != null && filePart.getSize() > 0) {
                    String contentType = filePart.getContentType();
                    if (!contentType.equals("image/jpeg") && !contentType.equals("image/png")) {
                        request.setAttribute("error", "Only PNG or JPEG images are allowed.");
                        System.out.println("UserDashboardServlet: Invalid file type: " + contentType);
                    } else if (filePart.getSize() > 5 * 1024 * 1024) {
                        request.setAttribute("error", "Image size exceeds 5MB limit.");
                        System.out.println("UserDashboardServlet: File too large: " + filePart.getSize() + " bytes");
                    } else {
                        try {
                            byte[] imageBytes = filePart.getInputStream().readAllBytes();
                            System.out.println("UserDashboardServlet: Image upload - File size: " + imageBytes.length + " bytes, Type: " + contentType);
                            if (userDao.updateUserImage(userId, imageBytes)) {
                                user.setImage(imageBytes);
                                request.setAttribute("success", "Profile image updated successfully.");
                                System.out.println("UserDashboardServlet: Image updated successfully for user ID: " + userId);
                            } else {
                                request.setAttribute("error", "Failed to update profile image in database.");
                                System.out.println("UserDashboardServlet: Failed to update image in database for user ID: " + userId);
                            }
                        } catch (IOException e) {
                            request.setAttribute("error", "Error reading image file: " + e.getMessage());
                            System.out.println("UserDashboardServlet: IOException reading image: " + e.getMessage());
                        }
                    }
                } else {
                    request.setAttribute("error", "No valid image selected.");
                    System.out.println("UserDashboardServlet: No valid image selected for upload.");
                }
            } else if ("updateCredentials".equals(action)) {
                String username = request.getParameter("username");
                String email = request.getParameter("email");
                String currentPassword = request.getParameter("currentPassword");
                String newPassword = request.getParameter("newPassword");
                String confirmNewPassword = request.getParameter("confirmNewPassword");

                System.out.println("UserDashboardServlet: Updating credentials - Username: " + username + ", Email: " + email);

                if (currentPassword == null || currentPassword.isEmpty()) {
                    request.setAttribute("error", "Current password is required.");
                } else if (!userDao.validateUser(user.getUsername(), currentPassword)) {
                    request.setAttribute("error", "Current password is incorrect.");
                } else {
                    if (userDao.updateUserCredentials(userId, username, email)) {
                        user.setUsername(username);
                        user.setEmail(email);
                        request.setAttribute("success", "Credentials updated successfully.");
                    } else {
                        request.setAttribute("error", "Failed to update credentials.");
                    }

                    if (newPassword != null && !newPassword.isEmpty()) {
                        if (!newPassword.equals(confirmNewPassword)) {
                            request.setAttribute("error", "New passwords do not match.");
                        } else if (userDao.updateUserPassword(userId, newPassword)) {
                            request.setAttribute("success", "Password updated successfully.");
                        } else {
                            request.setAttribute("error", "Failed to update password.");
                        }
                    }
                }
            } else {
                request.setAttribute("error", "Invalid action.");
            }

        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            System.out.println("UserDashboardServlet: POST Error - " + e.getMessage());
            e.printStackTrace();
        }

        request.setAttribute("user", user);
        System.out.println("UserDashboardServlet: Forwarding to user_dashboard.jsp after POST for user ID: " + userId);
        request.getRequestDispatcher("/user_dashboard.jsp").forward(request, response);
    }
}