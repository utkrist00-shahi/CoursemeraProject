package controller;

import dao.PublisherDAO;
import model.Publisher;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.UUID;

@WebServlet({"/publisher_login", "/download_resume"})
public class PublisherLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PublisherDAO publisherDao;
    private static final String SESSION_TOKEN_COOKIE = "sessionToken";

    @Override
    public void init() throws ServletException {
        publisherDao = new PublisherDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // Check for session token cookie
        if ("/publisher_login".equals(path)) {
            String sessionToken = getCookieValue(request, SESSION_TOKEN_COOKIE);
            if (sessionToken != null) {
                HttpSession session = request.getSession(false);
                if (session != null && sessionToken.equals(session.getAttribute("sessionToken"))) {
                    String role = (String) session.getAttribute("role");
                    if ("PUBLISHER".equals(role)) {
                        System.out.println("PublisherLoginServlet: Valid session token found, redirecting to publisher_dashboard.jsp");
                        response.sendRedirect(request.getContextPath() + "/publisher_dashboard.jsp");
                        return;
                    }
                }
            }
        }

        if ("/download_resume".equals(path)) {
            // Handle resume download
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("resume") != null && session.getAttribute("resumeFilename") != null) {
                byte[] resume = (byte[]) session.getAttribute("resume");
                String resumeFilename = (String) session.getAttribute("resumeFilename");

                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + resumeFilename + "\"");
                response.setContentLength(resume.length);
                response.getOutputStream().write(resume);
                response.getOutputStream().flush();
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Resume not found");
            }
        } else {
            // Handle login page display
            request.getRequestDispatcher("/publisher_login.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email").trim();
        String password = request.getParameter("password");

        // Validation
        if (email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Email and password are required");
            request.getRequestDispatcher("/publisher_login.jsp").forward(request, response);
            return;
        }

        // Authenticate publisher using BCrypt validation
        if (!publisherDao.validatePublisher(email, password)) {
            request.setAttribute("error", "Invalid email or password");
            request.getRequestDispatcher("/publisher_login.jsp").forward(request, response);
            return;
        }

        // Retrieve publisher details for session
        Publisher publisher = publisherDao.getPublisherByEmail(email);
        if (publisher == null) {
            request.setAttribute("error", "Invalid email or password");
            request.getRequestDispatcher("/publisher_login.jsp").forward(request, response);
            return;
        }

        // If authentication successful, proceed to dashboard
        HttpSession session = request.getSession();
        session.setAttribute("firstName", publisher.getFirstName());
        session.setAttribute("lastName", publisher.getLastName());
        session.setAttribute("email", publisher.getEmail());
        session.setAttribute("publisherId", publisher.getId());
        session.setAttribute("resume", publisher.getResume());
        session.setAttribute("resumeFilename", publisher.getResumeFilename());
        session.setAttribute("role", "PUBLISHER");

        // Generate and store session token
        String sessionToken = UUID.randomUUID().toString();
        session.setAttribute("sessionToken", sessionToken);
        setSessionCookie(response, sessionToken);

        request.getRequestDispatcher("/publisher_dashboard.jsp").forward(request, response);
    }

    private void setSessionCookie(HttpServletResponse response, String sessionToken) {
        Cookie cookie = new Cookie(SESSION_TOKEN_COOKIE, sessionToken);
        cookie.setHttpOnly(true);
        cookie.setSecure(true);
        cookie.setPath("/");
        cookie.setMaxAge(24 * 60 * 60); // 1 day expiration
        response.addCookie(cookie);
        System.out.println("PublisherLoginServlet: Session token cookie set - " + sessionToken);
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