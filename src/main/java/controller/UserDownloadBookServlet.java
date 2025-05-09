package controller;

import dao.CoursesDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Courses;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

@WebServlet({"/user_download_book"})
public class UserDownloadBookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CoursesDAO coursesDAO;

    public UserDownloadBookServlet() {
    }

    public void init() {
        this.coursesDAO = new CoursesDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");

        if (userId == null || !"USER".equals(role)) {
            System.err.println("UserDownloadBookServlet: Unauthorized access - userId: " + userId + ", role: " + role);
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized access");
            return;
        }

        String courseIdStr = request.getParameter("courseId");
        boolean download = Boolean.parseBoolean(request.getParameter("download"));
        boolean fallback = Boolean.parseBoolean(request.getParameter("fallback"));

        int courseId;
        try {
            courseId = Integer.parseInt(courseIdStr);
        } catch (NumberFormatException e) {
            System.err.println("UserDownloadBookServlet: Invalid courseId: " + courseIdStr);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid course ID");
            return;
        }

        Courses course = coursesDAO.getCourseById(courseId);
        if (course == null || course.getBookPdfFilename() == null) {
            System.err.println("UserDownloadBookServlet: No PDF found for courseId: " + courseId);
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "PDF not found for course ID: " + courseId);
            return;
        }

        String filename = course.getBookPdfFilename();
        String basePath = request.getServletContext().getRealPath("") + File.separator;
        String[] possiblePaths = new String[] {
            filename, // e.g., Uploads/document.pdf or Uploads/UUID_document.pdf
            "Uploads" + File.separator + filename // e.g., Uploads/originalFilename
        };

        if (fallback) {
            // Try to find UUID-prefixed file
            File uploadDir = new File(basePath + "Uploads");
            String originalName = filename.contains("/") ? filename.substring(filename.lastIndexOf("/") + 1) : filename;
            File[] matchingFiles = uploadDir.listFiles((dir, name) -> name.endsWith(originalName) && name.contains("_"));
            if (matchingFiles != null && matchingFiles.length > 0) {
                possiblePaths = new String[] { "Uploads" + File.separator + matchingFiles[0].getName() };
                System.out.println("UserDownloadBookServlet: Using fallback path: " + possiblePaths[0]);
            }
        }

        File pdfFile = null;
        for (String path : possiblePaths) {
            File file = new File(basePath + path);
            if (file.exists()) {
                pdfFile = file;
                System.out.println("UserDownloadBookServlet: Found PDF at " + file.getAbsolutePath());
                break;
            }
        }

        if (pdfFile == null) {
            System.err.println("UserDownloadBookServlet: PDF file not found for courseId: " + courseId + ", filename: " + filename);
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "PDF file not found");
            return;
        }

        response.setContentType("application/pdf");
        if (download) {
            response.setHeader("Content-Disposition", "attachment; filename=\"" + pdfFile.getName() + "\"");
        } else {
            response.setHeader("Content-Disposition", "inline");
        }

        Files.copy(pdfFile.toPath(), response.getOutputStream());
        response.getOutputStream().flush();
        System.out.println("UserDownloadBookServlet: Served PDF " + pdfFile.getAbsolutePath() + " for courseId: " + courseId + ", download: " + download);
    }
}