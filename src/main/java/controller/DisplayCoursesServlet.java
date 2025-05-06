package controller;

import dao.CoursesDAO;
import model.Courses;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/DisplayCoursesServlet")
public class DisplayCoursesServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private CoursesDAO coursesDAO;

    @Override
    public void init() {
        coursesDAO = new CoursesDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Courses> recentCourses = coursesDAO.getRecentlyAddedCourses();
        if (recentCourses == null) {
            recentCourses = java.util.Collections.emptyList();
        }
        request.setAttribute("recentCourses", recentCourses);
        System.out.println("DisplayCoursesServlet: Setting recentCourses with size: " + (recentCourses != null ? recentCourses.size() : 0));
        request.getRequestDispatcher("courses.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}