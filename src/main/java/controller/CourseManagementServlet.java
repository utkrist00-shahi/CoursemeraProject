package controller;

import dao.CoursesDAO;
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
import model.Courses;

@WebServlet({"/CourseManagementServlet"})
@MultipartConfig(
   fileSizeThreshold = 2097152,
   maxFileSize = 10485760L,
   maxRequestSize = 52428800L
)
public class CourseManagementServlet extends HttpServlet {
   private static final long serialVersionUID = 1L;
   private CoursesDAO coursesDAO;
   private static final String UPLOAD_DIR = "uploads";

   public CourseManagementServlet() {
   }

   public void init() {
      this.coursesDAO = new CoursesDAO();
      System.out.println("CourseManagementServlet: Initialized");
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      String role = (String) session.getAttribute("role");

      // Handle admin delete action
      if ("ADMIN".equals(role)) {
         String action = request.getParameter("action");
         if ("delete".equals(action)) {
            int courseId = Integer.parseInt(request.getParameter("courseId"));
            if (this.coursesDAO.deleteCourse(courseId)) {
               request.setAttribute("message", "Course deleted successfully!");
            } else {
               request.setAttribute("error", "Failed to delete course.");
            }
            // Fetch all courses again and forward to admin panel
            request.setAttribute("courses", this.coursesDAO.getAllCourses());
            request.getRequestDispatcher("/admin_panel_courses.jsp").forward(request, response);
            return;
         }
      }

      // Original publisher logic
      Integer publisherId = (Integer) session.getAttribute("publisherId");
      if (publisherId == null) {
         response.sendRedirect("publisher_login.jsp");
         return;
      }

      String action = request.getParameter("action");
      String appPath = request.getServletContext().getRealPath("");
      String uploadPath = appPath + File.separator + "uploads";
      File uploadDir = new File(uploadPath);
      if (!uploadDir.exists()) {
         uploadDir.mkdirs();
      }

      if ("create".equals(action)) {
         String title = request.getParameter("title");
         String category = request.getParameter("category");
         String instructor = request.getParameter("instructor");
         double price = Double.parseDouble(request.getParameter("price"));
         Part imagePart = request.getPart("image");
         Part bookPdfPart = request.getPart("bookPdf");

         if (title != null && category != null && instructor != null && imagePart != null && imagePart.getSize() > 0) {
            String fileName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
            String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
            String filePath = "uploads" + File.separator + uniqueFileName;
            String fullPath = uploadPath + File.separator + uniqueFileName;
            imagePart.write(fullPath);

            String pdfFileName = null;
            if (bookPdfPart != null && bookPdfPart.getSize() > 0) {
               pdfFileName = bookPdfPart.getSubmittedFileName();
               String uniquePdfFileName = UUID.randomUUID().toString() + "_" + pdfFileName;
               String pdfFilePath = "uploads" + File.separator + uniquePdfFileName;
               String fullPdfPath = uploadPath + File.separator + uniquePdfFileName;
               bookPdfPart.write(fullPdfPath);
            }

            Courses course = new Courses();
            course.setTitle(title);
            course.setCategory(category);
            course.setInstructor(instructor);
            course.setPrice(price);
            course.setImagePath(filePath);
            course.setPublisherId(publisherId);
            course.setBookPdfFilename(pdfFileName);

            if (this.coursesDAO.createCourse(course)) {
               request.setAttribute("message", "Course created successfully!");
            } else {
               request.setAttribute("error", "Failed to create course.");
            }
         } else {
            request.setAttribute("error", "All fields, including an image, are required.");
         }

         request.getRequestDispatcher("publisher_dashboard.jsp").forward(request, response);
      } else if ("update".equals(action)) {
         int courseId = Integer.parseInt(request.getParameter("courseId"));
         String title = request.getParameter("title");
         String category = request.getParameter("category");
         String instructor = request.getParameter("instructor");
         double price = Double.parseDouble(request.getParameter("price"));
         Part imagePart = request.getPart("image");
         Part bookPdfPart = request.getPart("bookPdf");

         Courses course = new Courses();
         course.setId(courseId);
         course.setTitle(title);
         course.setCategory(category);
         course.setInstructor(instructor);
         course.setPrice(price);
         course.setPublisherId(publisherId);

         if (imagePart != null && imagePart.getSize() > 0) {
            String fileName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
            String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
            String filePath = "uploads" + File.separator + uniqueFileName;
            String fullPath = uploadPath + File.separator + uniqueFileName;
            imagePart.write(fullPath);
            course.setImagePath(filePath);
         } else {
            Courses existingCourse = this.coursesDAO.getCourseById(courseId, publisherId);
            if (existingCourse != null) {
               course.setImagePath(existingCourse.getImagePath());
            }
         }

         if (bookPdfPart != null && bookPdfPart.getSize() > 0) {
            String pdfFileName = bookPdfPart.getSubmittedFileName();
            String uniquePdfFileName = UUID.randomUUID().toString() + "_" + pdfFileName;
            String pdfFilePath = "uploads" + File.separator + uniquePdfFileName;
            String fullPdfPath = uploadPath + File.separator + uniquePdfFileName;
            bookPdfPart.write(fullPdfPath);
            course.setBookPdfFilename(pdfFileName);
         } else {
            Courses existingCourse = this.coursesDAO.getCourseById(courseId, publisherId);
            if (existingCourse != null) {
               course.setBookPdfFilename(existingCourse.getBookPdfFilename());
            }
         }

         if (this.coursesDAO.updateCourse(course)) {
            request.setAttribute("message", "Course updated successfully!");
         } else {
            request.setAttribute("error", "Failed to update course.");
         }

         request.getRequestDispatcher("publisher_dashboard.jsp").forward(request, response);
      } else if ("delete".equals(action)) {
         int courseId = Integer.parseInt(request.getParameter("courseId"));
         if (this.coursesDAO.deleteCourse(courseId, publisherId)) {
            request.setAttribute("message", "Course deleted successfully!");
         } else {
            request.setAttribute("error", "Failed to delete course.");
         }

         request.getRequestDispatcher("publisher_dashboard.jsp").forward(request, response);
      }
   }

   protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      String role = (String) session.getAttribute("role");

      if ("ADMIN".equals(role)) {
         List<Courses> courses = this.coursesDAO.getAllCourses();
         System.out.println("CourseManagementServlet: Fetched " + courses.size() + " courses for admin");
         request.setAttribute("courses", courses);
         request.getRequestDispatcher("/admin_panel_courses.jsp").forward(request, response);
         return;
      }

      Integer publisherId = (Integer) session.getAttribute("publisherId");
      if (publisherId == null) {
         response.sendRedirect("publisher_login.jsp");
         return;
      }

      request.setAttribute("courses", this.coursesDAO.getCoursesByPublisher(publisherId));
      request.getRequestDispatcher("publisher_dashboard.jsp").forward(request, response);
   }
}