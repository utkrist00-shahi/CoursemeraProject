package controller;

import dao.PublisherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.*; // Added to resolve IOException and OutputStream

@WebServlet("/admin_download_resume")
public class AdminDownloadResumeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PublisherDAO publisherDao;

    @Override
    public void init() throws ServletException {
        try {
            publisherDao = new PublisherDAO();
            System.out.println("AdminDownloadResumeServlet: Initialized successfully with PublisherDAO.");
        } catch (Exception e) {
            System.err.println("AdminDownloadResumeServlet: Initialization failed - " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Initialization failed due to: " + e.getMessage(), e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Session check
            if (request.getSession() == null || request.getSession().getAttribute("role") == null || !"ADMIN".equals(request.getSession().getAttribute("role"))) {
                System.out.println("AdminDownloadResumeServlet: Unauthorized access attempt for session: " + request.getSession());
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized access");
                return;
            }

            int publisherId;
            try {
                publisherId = Integer.parseInt(request.getParameter("publisherId"));
                System.out.println("AdminDownloadResumeServlet: Received publisherId: " + publisherId);
            } catch (NumberFormatException e) {
                System.err.println("AdminDownloadResumeServlet: Invalid publisherId parameter: " + request.getParameter("publisherId"));
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid publisher ID");
                return;
            }

            boolean inline = "true".equalsIgnoreCase(request.getParameter("inline"));

            // Fetch publisher from publisher_approvals
            model.Publisher publisher;
            try {
                publisher = publisherDao.getPendingPublisherById(publisherId);
                if (publisher == null) {
                    System.out.println("AdminDownloadResumeServlet: No publisher found for ID: " + publisherId);
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Publisher not found");
                    return;
                }
            } catch (Exception e) {
                System.err.println("AdminDownloadResumeServlet: Error fetching publisher ID " + publisherId + ": " + e.getMessage());
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error fetching publisher");
                return;
            }

            if (publisher.getResume() == null) {
                System.out.println("AdminDownloadResumeServlet: No resume found for publisherId: " + publisherId);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Resume not found");
                return;
            }

            // Set response headers
            String resumeFilename = publisher.getResumeFilename() != null ? publisher.getResumeFilename() : "resume.pdf";
            byte[] resumeData = publisher.getResume();

            if (inline) {
                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "inline; filename=\"" + resumeFilename + "\"");
            } else {
                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + resumeFilename + "\"");
            }

            // Write the PDF to the response
            try (OutputStream out = response.getOutputStream()) {
                out.write(resumeData);
                out.flush();
                System.out.println("AdminDownloadResumeServlet: Successfully served resume for publisherId: " + publisherId + ", inline: " + inline);
            } catch (IOException e) {
                System.err.println("AdminDownloadResumeServlet: Error writing resume data for publisherId " + publisherId + ": " + e.getMessage());
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing resume");
            }
        } catch (Exception e) {
            System.err.println("AdminDownloadResumeServlet: Unexpected error - " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unexpected server error");
        }
    }
}