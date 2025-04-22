package controller;

import dao.PublisherDAO;
import model.Publisher;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet("/publisher_signup")
@MultipartConfig(maxFileSize = 10485760) // 10MB max file size
public class PublisherSignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PublisherDAO publisherDao;

    @Override
    public void init() throws ServletException {
        publisherDao = new PublisherDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String firstName = request.getParameter("firstName").trim();
        String lastName = request.getParameter("lastName").trim();
        String email = request.getParameter("email").trim();
        String password = request.getParameter("password");
        Part filePart = request.getPart("resume");
        String resumeFilename = filePart.getSubmittedFileName();

        // Validation
        if (firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() || password.isEmpty() || filePart == null) {
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
            return;
        }

        // Check file type
        if (!resumeFilename.toLowerCase().endsWith(".pdf")) {
            request.setAttribute("error", "Only PDF files are allowed");
            request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
            return;
        }

        // Convert resume to byte array
        byte[] resume = PublisherDAO.convertInputStreamToByteArray(filePart.getInputStream());

        // Create new publisher
        Publisher newPublisher = new Publisher(firstName, lastName, email, password, resume, resumeFilename);
        newPublisher.setCreatedAt(LocalDateTime.now());

        // Save to publisher_approvals table
        if (publisherDao.createPendingPublisher(newPublisher)) {
            request.setAttribute("success", "Registration submitted successfully. Awaiting admin approval.");
            request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Registration failed");
            request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
        }
    }
}