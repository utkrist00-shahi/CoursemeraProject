package dao;

import model.Courses;
import util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CoursesDAO {

    public boolean createCourse(Courses course) {
        String sql = "INSERT INTO courses (title, category, instructor, price, image_path, publisher_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, course.getTitle());
            stmt.setString(2, course.getCategory());
            stmt.setString(3, course.getInstructor());
            stmt.setDouble(4, course.getPrice());
            stmt.setString(5, course.getImagePath());
            stmt.setInt(6, course.getPublisherId());
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Courses> getCoursesByPublisher(int publisherId) {
        List<Courses> courses = new ArrayList<>();
        String sql = "SELECT * FROM courses WHERE publisher_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, publisherId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                int courseId = rs.getInt("id");
                if (rs.wasNull() || courseId <= 0) {
                    System.out.println("Warning: Skipping course with invalid or null ID: " + courseId + " for publisher: " + publisherId);
                    continue;
                }
                Courses course = new Courses();
                course.setId(courseId);
                course.setTitle(rs.getString("title"));
                course.setCategory(rs.getString("category"));
                course.setInstructor(rs.getString("instructor"));
                course.setPrice(rs.getDouble("price"));
                course.setImagePath(rs.getString("image_path"));
                course.setPublisherId(rs.getInt("publisher_id"));
                course.setCreatedAt(rs.getString("created_at"));
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
        String sql = "SELECT * FROM courses WHERE id = ? AND publisher_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, courseId);
            stmt.setInt(2, publisherId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Courses course = new Courses();
                course.setId(rs.getInt("id"));
                course.setTitle(rs.getString("title"));
                course.setCategory(rs.getString("category"));
                course.setInstructor(rs.getString("instructor"));
                course.setPrice(rs.getDouble("price"));
                course.setImagePath(rs.getString("image_path"));
                course.setPublisherId(rs.getInt("publisher_id"));
                course.setCreatedAt(rs.getString("created_at"));
                return course;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateCourse(Courses course) {
        String sql = "UPDATE courses SET title = ?, category = ?, instructor = ?, price = ?, image_path = ? WHERE id = ? AND publisher_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, course.getTitle());
            stmt.setString(2, course.getCategory());
            stmt.setString(3, course.getInstructor());
            stmt.setDouble(4, course.getPrice());
            stmt.setString(5, course.getImagePath());
            stmt.setInt(6, course.getId());
            stmt.setInt(7, course.getPublisherId());
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteCourse(int courseId, int publisherId) {
        String sql = "DELETE FROM courses WHERE id = ? AND publisher_id = ?";
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

    public List<Courses> getRecentlyAddedCourses() {
        List<Courses> courses = new ArrayList<>();
        String sql = "SELECT * FROM courses ORDER BY created_at DESC LIMIT 4";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Courses course = new Courses();
                course.setId(rs.getInt("id"));
                course.setTitle(rs.getString("title"));
                course.setCategory(rs.getString("category"));
                course.setInstructor(rs.getString("instructor"));
                course.setPrice(rs.getDouble("price"));
                course.setImagePath(rs.getString("image_path"));
                course.setPublisherId(rs.getInt("publisher_id"));
                course.setCreatedAt(rs.getString("created_at"));
                courses.add(course);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return courses;
    }
}