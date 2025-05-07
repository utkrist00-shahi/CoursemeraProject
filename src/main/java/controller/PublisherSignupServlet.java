package controller;

import dao.PublisherDAO;
import model.Publisher;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet("/publisher_signup")
@MultipartConfig(maxFileSize = 20971520) // 20MB max file size
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

        System.out.println("Processing signup for email: " + email + ", resume file: " + resumeFilename + ", size: " + filePart.getSize() + " bytes");

        // Validation
        if (firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() || password.isEmpty() || filePart == null) {
            System.out.println("Validation failed: Missing required fields");
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
            return;
        }

        // Check file type
        if (!resumeFilename.toLowerCase().endsWith(".pdf")) {
            System.out.println("Invalid file type: " + resumeFilename);
            request.setAttribute("error", "Only PDF files are allowed");
            request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
            return;
        }

        // Check file size
        long fileSize = filePart.getSize();
        if (fileSize > 20971520) {
            System.out.println("File size exceeds limit: " + fileSize + " bytes");
            request.setAttribute("error", "File size exceeds 20MB limit");
            request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
            return;
        }

        // Convert resume to byte array
        byte[] resume;
        try {
            resume = PublisherDAO.convertInputStreamToByteArray(filePart.getInputStream());
            System.out.println("Resume converted to byte array successfully, size: " + resume.length + " bytes");
        } catch (IOException e) {
            System.out.println("Failed to convert resume to byte array for file: " + resumeFilename + ", error: " + e.getMessage());
            request.setAttribute("error", "Error processing resume file: " + e.getMessage());
            request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
            return;
        }

        // Create new publisher
        Publisher newPublisher = new Publisher(firstName, lastName, email, password, resume, resumeFilename);
        newPublisher.setCreatedAt(LocalDateTime.now());

        // Save to publisher_approvals table
        System.out.println("Attempting to save publisher with email: " + email + ", resume size: " + resume.length + " bytes");
        try {
            if (publisherDao.createPendingPublisher(newPublisher)) {
                System.out.println("Publisher registration successful for email: " + email);
                request.setAttribute("success", "Registration submitted successfully. Awaiting admin approval.");
                request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
            } else {
                System.out.println("Publisher registration failed for email: " + email + ". DAO returned false. Resume size: " + resume.length + " bytes");
                request.setAttribute("error", "Registration failed. Please check server logs for details or contact support.");
                request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.out.println("Database error during publisher signup for email: " + email + ", error: " + e.getMessage() + ", resume size: " + resume.length + " bytes");
            request.setAttribute("error", "Registration failed due to a database error: " + e.getMessage());
            request.getRequestDispatcher("/publisher_signup.jsp").forward(request, response);
        }
    }
}