package controller;

import dao.CoursesDAO;
import model.Courses;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@WebServlet("/CourseManagementServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class CourseManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CoursesDAO coursesDAO;
    private static final String UPLOAD_DIR = "uploads";

    @Override
    public void init() {
        coursesDAO = new CoursesDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer publisherId = (Integer) session.getAttribute("publisherId");
        if (publisherId == null) {
            response.sendRedirect("publisher_login.jsp");
            return;
        }

        String action = request.getParameter("action");

        String appPath = request.getServletContext().getRealPath("");
        String uploadPath = appPath + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        if ("create".equals(action)) {
            String title = request.getParameter("title");
            String category = request.getParameter("category");
            String instructor = request.getParameter("instructor");
            double price = Double.parseDouble(request.getParameter("price"));

            Part filePart = request.getPart("image");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
            String filePath = UPLOAD_DIR + File.separator + uniqueFileName;
            String fullPath = uploadPath + File.separator + uniqueFileName;
            filePart.write(fullPath);

            Courses course = new Courses();
            course.setTitle(title);
            course.setCategory(category);
            course.setInstructor(instructor);
            course.setPrice(price);
            course.setImagePath(filePath);
            course.setPublisherId(publisherId);

            if (coursesDAO.createCourse(course)) {
                request.setAttribute("message", "Course created successfully!");
            } else {
                request.setAttribute("error", "Failed to create course.");
            }
            request.getRequestDispatcher("publisher_dashboard.jsp").forward(request, response);
        } else if ("update".equals(action)) {
            int courseId = Integer.parseInt(request.getParameter("courseId"));
            String title = request.getParameter("title");
            String category = request.getParameter("category");
            String instructor = request.getParameter("instructor");
            double price = Double.parseDouble(request.getParameter("price"));

            Courses course = new Courses();
            course.setId(courseId);
            course.setTitle(title);
            course.setCategory(category);
            course.setInstructor(instructor);
            course.setPrice(price);
            course.setPublisherId(publisherId);

            Part filePart = request.getPart("image");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
                String filePath = UPLOAD_DIR + File.separator + uniqueFileName;
                String fullPath = uploadPath + File.separator + uniqueFileName;
                filePart.write(fullPath);
                course.setImagePath(filePath);
            } else {
                List<Courses> courses = coursesDAO.getCoursesByPublisher(publisherId);
                for (Courses c : courses) {
                    if (c.getId() == courseId) {
                        course.setImagePath(c.getImagePath());
                        break;
                    }
                }
            }

            if (coursesDAO.updateCourse(course)) {
                request.setAttribute("message", "Course updated successfully!");
            } else {
                request.setAttribute("error", "Failed to update course.");
            }
            request.getRequestDispatcher("publisher_dashboard.jsp").forward(request, response);
        } else if ("delete".equals(action)) {
            int courseId = Integer.parseInt(request.getParameter("courseId"));
            if (coursesDAO.deleteCourse(courseId, publisherId)) {
                request.setAttribute("message", "Course deleted successfully!");
            } else {
                request.setAttribute("error", "Failed to delete course.");
            }
            request.getRequestDispatcher("publisher_dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer publisherId = (Integer) session.getAttribute("publisherId");
        if (publisherId == null) {
            response.sendRedirect("publisher_login.jsp");
            return;
        }

        request.setAttribute("courses", coursesDAO.getCoursesByPublisher(publisherId));
        request.getRequestDispatcher("publisher_dashboard.jsp").forward(request, response);
    }
}