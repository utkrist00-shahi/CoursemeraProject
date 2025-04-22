package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import dao.UserDAO;
import model.User;

@WebServlet("/user_dashboard")
public class UserDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDao;

    @Override
    public void init() throws ServletException {
        userDao = new UserDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Prevent caching
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int userId = (int) session.getAttribute("userId");
            User user = userDao.getUserById(userId);
            
            if (user != null) {
                request.setAttribute("user", user);
                System.out.println("UserDashboardServlet: Displaying dashboard for user ID: " + userId);
                request.getRequestDispatcher("/user_dashboard.jsp").forward(request, response);
            } else {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
            }
        } catch (Exception e) {
            System.out.println("UserDashboardServlet: Error - " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }
}