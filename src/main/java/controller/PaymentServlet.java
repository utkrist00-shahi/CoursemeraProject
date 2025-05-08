package controller;

import dao.CoursesDAO;
import model.Booking;
import model.Courses;
import model.Payment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CoursesDAO coursesDAO;

    @Override
    public void init() throws ServletException {
        coursesDAO = new CoursesDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"USER".equals(session.getAttribute("role"))) {
            System.out.println("PaymentServlet: Unauthorized access, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int courseId;
        try {
            courseId = Integer.parseInt(request.getParameter("courseId"));
        } catch (NumberFormatException e) {
            System.err.println("PaymentServlet: Invalid courseId format: " + request.getParameter("courseId"));
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid course ID");
            return;
        }

        Courses course = coursesDAO.getCourseById(courseId);
        if (course == null) {
            System.err.println("PaymentServlet: Course not found for ID: " + courseId);
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Course not found");
            return;
        }

        request.setAttribute("course", course);
        request.getRequestDispatcher("/payment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"USER".equals(session.getAttribute("role"))) {
            System.out.println("PaymentServlet: Unauthorized access on POST, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        int courseId;
        double amount;
        try {
            courseId = Integer.parseInt(request.getParameter("courseId"));
            amount = Double.parseDouble(request.getParameter("amount"));
        } catch (NumberFormatException e) {
            System.err.println("PaymentServlet: Invalid courseId or amount format - courseId: " + request.getParameter("courseId") + ", amount: " + request.getParameter("amount"));
            request.setAttribute("error", "Invalid course ID or amount");
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
            return;
        }

        // Simulate payment processing
        boolean paymentSuccess = simulatePaymentProcessing();

        if (paymentSuccess) {
            // Record payment
            Payment payment = new Payment(userId, courseId, amount, "SUCCESS");
            boolean paymentRecorded = coursesDAO.recordPayment(payment);
            if (!paymentRecorded) {
                System.err.println("PaymentServlet: Failed to record payment for userId: " + userId + ", courseId: " + courseId);
                request.setAttribute("error", "Failed to record payment. Please try again.");
                request.getRequestDispatcher("/payment.jsp").forward(request, response);
                return;
            }

            // Record booking
            Booking booking = new Booking(userId, courseId);
            boolean bookingRecorded = coursesDAO.recordBooking(booking);
            if (!bookingRecorded) {
                System.err.println("PaymentServlet: Failed to record booking for userId: " + userId + ", courseId: " + courseId);
                request.setAttribute("error", "Payment processed, but failed to enroll in the course. Please contact support.");
                request.getRequestDispatcher("/payment.jsp").forward(request, response);
                return;
            }

            System.out.println("PaymentServlet: Successfully processed payment and enrolled userId: " + userId + " in courseId: " + courseId);
            request.setAttribute("success", "Payment successful! You are now enrolled in the course.");
            response.sendRedirect(request.getContextPath() + "/user_dashboard");
        } else {
            System.err.println("PaymentServlet: Payment failed for userId: " + userId + ", courseId: " + courseId);
            request.setAttribute("error", "Payment failed. Please try again.");
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
        }
    }

    private boolean simulatePaymentProcessing() {
        // In a real application, integrate with a payment gateway (e.g., Stripe, PayPal).
        // For now, assume payment always succeeds.
        return true;
    }
}