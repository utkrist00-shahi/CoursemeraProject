package controller;

import dao.PublisherDAO;
import model.Publisher;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet({"/publisher_login", "/download_resume"})
public class PublisherLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PublisherDAO publisherDao;

    @Override
    public void init() throws ServletException {
        publisherDao = new PublisherDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        
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
        session.setAttribute("role", "PUBLISHER"); // Set role dynamically
        request.getRequestDispatcher("/publisher_dashboard.jsp").forward(request, response);
    }
}