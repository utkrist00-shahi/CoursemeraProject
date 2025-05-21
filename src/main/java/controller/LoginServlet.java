package controller;

import java.io.IOException;
import java.util.UUID;
import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import model.User;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDao;
    private static final String ADMIN_USERNAME = "utkrist";
    private static final String ADMIN_PASSWORD = "utkrist123";
    private static final String SECRET_KEY = "utkristhereforu";
    private static final String SESSION_TOKEN_COOKIE = "sessionToken";

    @Override
    public void init() throws ServletException {
        userDao = new UserDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // Check for session token cookie
        String sessionToken = getCookieValue(request, SESSION_TOKEN_COOKIE);
        if (sessionToken != null) {
            HttpSession session = request.getSession(false);
            if (session != null && sessionToken.equals(session.getAttribute("sessionToken"))) {
                String role = (String) session.getAttribute("role");
                if (role != null) {
                    if ("ADMIN".equals(role)) {
                        System.out.println("LoginServlet: Valid session token found, redirecting to admin_panel.jsp");
                        response.sendRedirect(request.getContextPath() + "/admin_panel");
                        return;
                    } else {
                        System.out.println("LoginServlet: Valid session token found, redirecting to index.jsp");
                        response.sendRedirect(request.getContextPath() + "/index.jsp");
                        return;
                    }
                }
            }
        }

        request.getSession().removeAttribute("successMessage");
        System.out.println("LoginServlet: Handling GET request, forwarding to login.jsp");
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String secretKey = request.getParameter("secretKey");

        HttpSession session = request.getSession(true); // Create a new session if none exists
        System.out.println("LoginServlet: Handling POST request, username: " + username);

        // Admin login flow
        if (ADMIN_USERNAME.equals(username) && ADMIN_PASSWORD.equals(password)) {
            if (session.getAttribute("awaitingSecret") != null && SECRET_KEY.equals(secretKey)) {
                // Final admin authentication
                session.removeAttribute("awaitingSecret");
                session.setAttribute("username", ADMIN_USERNAME);
                session.setAttribute("email", "utkristshahi56@gmail.com");
                session.setAttribute("role", "ADMIN");
                session.setAttribute("userId", 0);

                // Generate and store session token
                String sessionToken = UUID.randomUUID().toString();
                session.setAttribute("sessionToken", sessionToken);
                setSessionCookie(response, sessionToken);

                System.out.println("LoginServlet: Admin authenticated, session attributes set - username: " + ADMIN_USERNAME + ", role: ADMIN");
                System.out.println("LoginServlet: Redirecting to admin_panel.jsp");
                response.sendRedirect(request.getContextPath() + "/admin_panel");
            } else {
                // Store credentials in session for reuse
                session.setAttribute("tempUsername", username);
                session.setAttribute("tempPassword", password);
                session.setAttribute("awaitingSecret", true);
                System.out.println("LoginServlet: Admin credentials valid, awaiting secret key");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
            return;
        }

        // Regular user login
        User user = userDao.validateAndGetUser(username, password);
        if (user != null) {
            session.setAttribute("username", user.getUsername());
            session.setAttribute("email", user.getEmail());
            session.setAttribute("role", user.getRole().toString());
            session.setAttribute("userId", user.getId());

            // Generate and store session token
            String sessionToken = UUID.randomUUID().toString();
            session.setAttribute("sessionToken", sessionToken);
            setSessionCookie(response, sessionToken);

            System.out.println("LoginServlet: User authenticated, session attributes set - username: " + user.getUsername() + ", role: " + user.getRole());

            if (user.getRole() == User.Role.ADMIN) {
                System.out.println("LoginServlet: User is admin, redirecting to admin_panel.jsp");
                response.sendRedirect(request.getContextPath() + "/admin_panel");
            } else {
                System.out.println("LoginServlet: User is not admin, redirecting to index.jsp");
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            }
        } else {
            System.out.println("LoginServlet: Invalid username or password for user: " + username);
            request.setAttribute("error", "Invalid username or password");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    private void setSessionCookie(HttpServletResponse response, String sessionToken) {
        Cookie cookie = new Cookie(SESSION_TOKEN_COOKIE, sessionToken);
        cookie.setHttpOnly(true); // Prevent JavaScript access
        cookie.setSecure(true); // Requires HTTPS
        cookie.setPath("/"); // Cookie available across the application
        cookie.setMaxAge(24 * 60 * 60); // 1 day expiration
        response.addCookie(cookie);
        System.out.println("LoginServlet: Session token cookie set - " + sessionToken);
    }

    private String getCookieValue(HttpServletRequest request, String cookieName) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookieName.equals(cookie.getName())) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }
}