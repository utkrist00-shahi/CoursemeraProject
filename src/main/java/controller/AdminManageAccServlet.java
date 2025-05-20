package controller;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/adminmanageacc")
public class AdminManageAccServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        System.out.println("AdminManageAccServlet: Initialized");
      
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        System.out.println("AdminManageAccServlet: Handling GET request");
        if (session == null || session.getAttribute("role") == null || !"ADMIN".equals(session.getAttribute("role"))) {
            System.out.println("AdminManageAccServlet: Unauthorized (GET), redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        System.out.println("AdminManageAccServlet: Authorized (GET), username: " + session.getAttribute("username"));

        List<User> users = userDAO.getAllUsers();
        System.out.println("AdminManageAccServlet: Fetched " + users.size() + " users");
        if (users.isEmpty()) {
            System.err.println("AdminManageAccServlet: No users found");
            request.setAttribute("error", "No users found. Check logs.");
        } else {
            for (User user : users) {
                System.out.println("AdminManageAccServlet: User - ID: " + user.getId() + ", Username: " + user.getUsername() + ", Email: " + user.getEmail() + ", Role: " + user.getRole());
            }
        }
        request.setAttribute("users", users);
        System.out.println("AdminManageAccServlet: Forwarding to admin_panel.jsp with " + users.size() + " users");
        request.getRequestDispatcher("/admin_panel_users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        System.out.println("AdminManageAccServlet: Handling POST request");
        if (session == null || session.getAttribute("role") == null || !"ADMIN".equals(session.getAttribute("role"))) {
            System.out.println("AdminManageAccServlet: Unauthorized (POST), redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        System.out.println("AdminManageAccServlet: Authorized (POST), username: " + session.getAttribute("username"));

        String action = request.getParameter("action");
        String userIdParam = request.getParameter("userId");
        System.out.println("AdminManageAccServlet: Action: " + action + ", userId: " + userIdParam);

        int userId;
        try {
            userId = Integer.parseInt(userIdParam);
        } catch (NumberFormatException e) {
            System.err.println("AdminManageAccServlet: Invalid userId: " + userIdParam);
            request.setAttribute("error", "Invalid user ID.");
            List<User> users = userDAO.getAllUsers();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/admin_panel_users.jsp").forward(request, response);
            return;
        }

        User user = userDAO.getUserById(userId);
        if (user == null) {
            System.err.println("AdminManageAccServlet: User ID " + userId + " not found");
            request.setAttribute("error", "User not found.");
            List<User> users = userDAO.getAllUsers();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/admin_panel_users.jsp").forward(request, response);
            return;
        }

        try {
            if ("delete".equals(action)) {
                if (userDAO.deleteUser(userId)) {
                    request.setAttribute("success", "User deleted.");
                    System.out.println("AdminManageAccServlet: Deleted user ID: " + userId);
                } else {
                    request.setAttribute("error", "Failed to delete user.");
                    System.err.println("AdminManageAccServlet: Delete failed for ID: " + userId);
                }
            } else {
                System.err.println("AdminManageAccServlet: Invalid action: " + action);
                request.setAttribute("error", "Invalid action.");
            }
        } catch (Exception e) {
            System.err.println("AdminManageAccServlet: Action error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        List<User> users = userDAO.getAllUsers();
        System.out.println("AdminManageAccServlet: After action, forwarding " + users.size() + " users");
        request.setAttribute("users", users);
        request.getRequestDispatcher("/admin_panel_users.jsp").forward(request, response);
    }
}