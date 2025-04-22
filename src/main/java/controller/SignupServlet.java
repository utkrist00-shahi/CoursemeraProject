package controller;

import dao.UserDAO;
import model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDao;

    @Override
    public void init() throws ServletException {
        userDao = new UserDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/signup.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username").trim();
        String email = request.getParameter("email").trim();
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validation
        if (username.isEmpty() || email.isEmpty() || password.isEmpty() || !password.equals(confirmPassword)) {
            request.setAttribute("error", "Invalid input");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
            return;
        }
        
        // Restrict admin username
        if (username.equalsIgnoreCase("utkrist")) {
            request.setAttribute("error", "This username is reserved");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
            return;
        }

        // Check for existing user
        if (userDao.getUserByUsername(username) != null || userDao.getUserByEmail(email) != null) {
            request.setAttribute("error", "Username or email already exists");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
            return;
        }

        // Creating new user
        User newUser = new User(username, email, password);
        newUser.setCreatedAt(LocalDateTime.now());
        
        if (userDao.createUser(newUser)) {
            User createdUser = userDao.getUserByUsername(username);
            HttpSession session = request.getSession();
            session.setAttribute("username", createdUser.getUsername());
            session.setAttribute("email", createdUser.getEmail());
            session.setAttribute("role", createdUser.getRole().toString());
            session.setAttribute("userId", createdUser.getId());
            response.sendRedirect("login.jsp?success=Registration+successful");
        } else {
            request.setAttribute("error", "Registration failed");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
        }
    }
}