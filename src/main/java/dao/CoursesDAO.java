package dao;

import model.Booking;
import model.Courses;
import model.Payment;
import util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CoursesDAO {

    public boolean createCourse(Courses course) {
        String sql = "INSERT INTO courses (course_title, course_category, course_instructor, course_price, course_image_path, publisher_id, course_book_pdf_filename) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, course.getTitle());
            stmt.setString(2, course.getCategory());
            stmt.setString(3, course.getInstructor());
            stmt.setDouble(4, course.getPrice());
            stmt.setString(5, course.getImagePath());
            stmt.setInt(6, course.getPublisherId());
            stmt.setString(7, course.getBookPdfFilename());
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    course.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
        return false;
    }

    public List<Courses> getCoursesByPublisher(int publisherId) {
        List<Courses> courses = new ArrayList<>();
        String sql = "SELECT * FROM courses WHERE publisher_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, publisherId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                int courseId = rs.getInt("course_id");
                if (rs.wasNull() || courseId <= 0) {
                    System.out.println("Warning: Skipping course with invalid or null ID: " + courseId + " for publisher: " + publisherId);
                    continue;
                }
                Courses course = new Courses();
                course.setId(courseId);
                course.setTitle(rs.getString("course_title"));
                course.setCategory(rs.getString("course_category"));
                course.setInstructor(rs.getString("course_instructor"));
                course.setPrice(rs.getDouble("course_price"));
                course.setImagePath(rs.getString("course_image_path"));
                course.setPublisherId(rs.getInt("publisher_id"));
                course.setCreatedAt(rs.getString("course_created_at"));
                course.setBookPdfFilename(rs.getString("course_book_pdf_filename"));
                courses.add(course);
                System.out.println("Retrieved course: ID=" + courseId + ", Title=" + course.getTitle());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("CoursesDAO: Retrieved " + courses.size() + " valid courses for publisher ID " + publisherId);
        return courses;
    }

    public Courses getCourseById(int courseId, int publisherId) {
        String sql = "SELECT * FROM courses WHERE course_id = ? AND publisher_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, courseId);
            stmt.setInt(2, publisherId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Courses course = new Courses();
                course.setId(rs.getInt("course_id"));
                course.setTitle(rs.getString("course_title"));
                course.setCategory(rs.getString("course_category"));
                course.setInstructor(rs.getString("course_instructor"));
                course.setPrice(rs.getDouble("course_price"));
                course.setImagePath(rs.getString("course_image_path"));
                course.setPublisherId(rs.getInt("publisher_id"));
                course.setCreatedAt(rs.getString("course_created_at"));
                course.setBookPdfFilename(rs.getString("course_book_pdf_filename"));
                return course;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Courses getCourseById(int courseId) {
        String sql = "SELECT * FROM courses WHERE course_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, courseId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Courses course = new Courses();
                course.setId(rs.getInt("course_id"));
                course.setTitle(rs.getString("course_title"));
                course.setCategory(rs.getString("course_category"));
                course.setInstructor(rs.getString("course_instructor"));
                course.setPrice(rs.getDouble("course_price"));
                course.setImagePath(rs.getString("course_image_path"));
                course.setPublisherId(rs.getInt("publisher_id"));
                course.setCreatedAt(rs.getString("course_created_at"));
                course.setBookPdfFilename(rs.getString("course_book_pdf_filename"));
                return course;
            }
        } catch (SQLException e) {
            System.err.println("CoursesDAO: Error fetching course by ID " + courseId + ": " + e.getMessage());
        }
        return null;
    }

    public boolean updateCourse(Courses course) {
        String sql = "UPDATE courses SET course_title = ?, course_category = ?, course_instructor = ?, course_price = ?, course_image_path = ?, course_book_pdf_filename = ? WHERE course_id = ? AND publisher_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, course.getTitle());
            stmt.setString(2, course.getCategory());
            stmt.setString(3, course.getInstructor());
            stmt.setDouble(4, course.getPrice());
            stmt.setString(5, course.getImagePath());
            stmt.setString(6, course.getBookPdfFilename());
            stmt.setInt(7, course.getId());
            stmt.setInt(8, course.getPublisherId());
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteCourse(int courseId, int publisherId) {
        String sql = "DELETE FROM courses WHERE course_id = ? AND publisher_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, courseId);
            stmt.setInt(2, publisherId);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteCourse(int courseId) {
        String sql = "DELETE FROM courses WHERE course_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, courseId);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("CoursesDAO: Error deleting course ID " + courseId + ": " + e.getMessage());
            return false;
        }
    }

    public List<Courses> getRecentlyAddedCourses(int limit) {
        List<Courses> courses = new ArrayList<>();
        String sql = "SELECT * FROM courses ORDER BY course_created_at DESC LIMIT ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Courses course = new Courses();
                course.setId(rs.getInt("course_id"));
                course.setTitle(rs.getString("course_title"));
                course.setCategory(rs.getString("course_category"));
                course.setInstructor(rs.getString("course_instructor"));
                course.setPrice(rs.getDouble("course_price"));
                course.setImagePath(rs.getString("course_image_path"));
                course.setPublisherId(rs.getInt("publisher_id"));
                course.setCreatedAt(rs.getString("course_created_at"));
                course.setBookPdfFilename(rs.getString("course_book_pdf_filename"));
                courses.add(course);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return courses;
    }

    public List<Courses> getRecentlyAddedCourses() {
        return getRecentlyAddedCourses(4); // Maintain backward compatibility
    }

    public List<Courses> getEnrolledCourses(int userId) {
        List<Courses> enrolledCourses = new ArrayList<>();
        String sql = "SELECT c.* FROM courses c JOIN bookings b ON c.course_id = b.booking_course_id WHERE b.booking_user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Courses course = new Courses();
                course.setId(rs.getInt("course_id"));
                course.setTitle(rs.getString("course_title"));
                course.setCategory(rs.getString("course_category"));
                course.setInstructor(rs.getString("course_instructor"));
                course.setPrice(rs.getDouble("course_price"));
                course.setImagePath(rs.getString("course_image_path"));
                course.setPublisherId(rs.getInt("publisher_id"));
                course.setCreatedAt(rs.getString("course_created_at"));
                course.setBookPdfFilename(rs.getString("course_book_pdf_filename"));
                enrolledCourses.add(course);
                System.out.println("CoursesDAO: Added enrolled course ID " + course.getId() + " for userId " + userId);
            }
        } catch (SQLException e) {
            System.err.println("CoursesDAO: Error fetching enrolled courses for userId " + userId + ": " + e.getMessage());
        }
        System.out.println("CoursesDAO: Retrieved " + enrolledCourses.size() + " enrolled courses for userId " + userId);
        return enrolledCourses;
    }

    public boolean recordPayment(Payment payment) {
        String sql = "INSERT INTO payments (payment_id, payment_user_id, payment_course_id, payment_amount, payment_date, payment_status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, payment.getId());
            stmt.setInt(2, payment.getUserId());
            stmt.setInt(3, payment.getCourseId());
            stmt.setDouble(4, payment.getAmount());
            stmt.setTimestamp(5, payment.getPaymentDate());
            stmt.setString(6, payment.getStatus());
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("CoursesDAO: Error recording payment: " + e.getMessage());
            return false;
        }
    }

    public boolean recordBooking(Booking booking) {
        String sql = "INSERT INTO bookings (booking_id, booking_user_id, booking_course_id, booking_date) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, booking.getId());
            stmt.setInt(2, booking.getUserId());
            stmt.setInt(3, booking.getCourseId());
            stmt.setTimestamp(4, booking.getBookingDate());
            int rowsAffected = stmt.executeUpdate();
            System.out.println("CoursesDAO: Recorded booking for userId " + booking.getUserId() + ", courseId " + booking.getCourseId() + ", rows affected: " + rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("CoursesDAO: Error recording booking for userId " + booking.getUserId() + ", courseId " + booking.getCourseId() + ": " + e.getMessage());
            return false;
        }
    }

    public boolean deleteBooking(Booking booking) {
        String sql = "DELETE FROM bookings WHERE booking_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, booking.getId());
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("CoursesDAO: Error deleting booking for bookingId: " + booking.getId() + ": " + e.getMessage());
            return false;
        }
    }

    public boolean deleteBookingByUserAndCourse(int userId, int courseId) {
        String sql = "DELETE FROM bookings WHERE booking_user_id = ? AND booking_course_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, courseId);
            System.out.println("CoursesDAO: Executing DELETE for userId=" + userId + ", courseId=" + courseId);
            int rowsAffected = stmt.executeUpdate();
            System.out.println("CoursesDAO: Rows affected: " + rowsAffected);
            if (rowsAffected > 0) {
                System.out.println("CoursesDAO: Successfully deleted booking for userId " + userId + " and courseId " + courseId);
                return true;
            } else {
                System.err.println("CoursesDAO: No booking found to delete for userId " + userId + " and courseId " + courseId);
                return false;
            }
        } catch (SQLException e) {
            System.err.println("CoursesDAO: Error deleting booking for userId " + userId + ", courseId " + courseId + ": " + e.getMessage());
            return false;
        }
    }

    public List<Courses> getAllCourses() {
        List<Courses> courses = new ArrayList<>();
        String sql = "SELECT * FROM courses";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                int courseId = rs.getInt("course_id");
                if (rs.wasNull() || courseId <= 0) {
                    System.out.println("Warning: Skipping course with invalid or null ID: " + courseId);
                    continue;
                }
                Courses course = new Courses();
                course.setId(courseId);
                course.setTitle(rs.getString("course_title"));
                course.setCategory(rs.getString("course_category"));
                course.setInstructor(rs.getString("course_instructor"));
                course.setPrice(rs.getDouble("course_price"));
                course.setImagePath(rs.getString("course_image_path"));
                course.setPublisherId(rs.getInt("publisher_id"));
                course.setCreatedAt(rs.getString("course_created_at"));
                course.setBookPdfFilename(rs.getString("course_book_pdf_filename"));
                courses.add(course);
                System.out.println("Retrieved course: ID=" + courseId + ", Title=" + course.getTitle());
            }
        } catch (SQLException e) {
            System.err.println("CoursesDAO: Error fetching all courses: " + e.getMessage());
        }
        System.out.println("CoursesDAO: Retrieved " + courses.size() + " valid courses");
        return courses;
    }
}