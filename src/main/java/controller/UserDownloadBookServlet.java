package controller;

import dao.CoursesDAO;
import model.Courses;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Paths;

@WebServlet("/user_download_book")
public class UserDownloadBookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CoursesDAO coursesDAO;
    private static final String UPLOAD_DIR = "Uploads";

    @Override
    public void init() throws ServletException {
        try {
            coursesDAO = new CoursesDAO();
            System.out.println("UserDownloadBookServlet: Initialized successfully with CoursesDAO.");
        } catch (Exception e) {
            System.err.println("UserDownloadBookServlet: Initialization failed - " + e.getMessage());
            throw new ServletException("Initialization failed due to: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Validate user session and role
            if (request.getSession() == null || request.getSession().getAttribute("role") == null || !"USER".equals(request.getSession().getAttribute("role"))) {
                System.out.println("UserDownloadBookServlet: Unauthorized access attempt for session: " + (request.getSession() != null ? request.getSession().getId() : "null"));
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized access");
                return;
            }

            // Parse courseId parameter
            int courseId;
            try {
                courseId = Integer.parseInt(request.getParameter("courseId"));
                System.out.println("UserDownloadBookServlet: Received courseId: " + courseId);
            } catch (NumberFormatException e) {
                System.err.println("UserDownloadBookServlet: Invalid courseId parameter: " + request.getParameter("courseId"));
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid course ID");
                return;
            }

            // Determine if the PDF should be displayed inline or downloaded
            boolean inline = "true".equalsIgnoreCase(request.getParameter("inline"));

            // Fetch the course
            Courses course = coursesDAO.getCourseById(courseId);
            if (course == null) {
                System.out.println("UserDownloadBookServlet: No course found for ID: " + courseId);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Course not found");
                return;
            }

            // Check if the PDF file path exists
            String pdfFilePath = course.getBookPdfFilename();
            if (pdfFilePath == null || pdfFilePath.isEmpty()) {
                System.out.println("UserDownloadBookServlet: No book PDF found for courseId: " + courseId);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Book PDF not found");
                return;
            }

            // Construct the full file path
            String fullPdfPath = request.getServletContext().getRealPath("") + File.separator + pdfFilePath;
            File pdfFile = new File(fullPdfPath);
            if (!pdfFile.exists()) {
                System.out.println("UserDownloadBookServlet: PDF file not found at: " + fullPdfPath);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Book PDF file not found on server");
                return;
            }

            // Set response headers
            String pdfFileName = Paths.get(pdfFilePath).getFileName().toString();
            response.setContentType("application/pdf");
            if (inline) {
                response.setHeader("Content-Disposition", "inline; filename=\"" + pdfFileName + "\"");
            } else {
                response.setHeader("Content-Disposition", "attachment; filename=\"" + pdfFileName + "\"");
            }

            // Serve the PDF file
            try (FileInputStream fileInputStream = new FileInputStream(pdfFile);
                 OutputStream out = response.getOutputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
                out.flush();
                System.out.println("UserDownloadBookServlet: Successfully served book for courseId: " + courseId + ", inline: " + inline);
            } catch (IOException e) {
                System.err.println("UserDownloadBookServlet: Error writing book data for courseId " + courseId + ": " + e.getMessage());
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing book");
            }
        } catch (Exception e) {
            System.err.println("UserDownloadBookServlet: Unexpected error - " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unexpected server error");
        }
    }
}