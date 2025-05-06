package dao;

import model.Publisher;
import util.DatabaseUtil;
import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class PublisherDAO {

    public boolean createPendingPublisher(Publisher publisher) {
        String sql = "INSERT INTO publisher_approvals (pa_first_name, pa_last_name, pa_email, pa_password, pa_resume, pa_resume_filename, pa_created_at) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, publisher.getFirstName());
            pstmt.setString(2, publisher.getLastName());
            pstmt.setString(3, publisher.getEmail());
            pstmt.setString(4, publisher.getPassword());
            pstmt.setBytes(5, publisher.getResume());
            pstmt.setString(6, publisher.getResumeFilename());
            pstmt.setTimestamp(7, Timestamp.valueOf(publisher.getCreatedAt()));
            int affectedRows = pstmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        publisher.setId(rs.getInt(1));
                    }
                }
                System.out.println("PublisherDAO: Successfully saved pending publisher with email: " + publisher.getEmail());
                return true;
            } else {
                System.err.println("PublisherDAO: No rows affected while saving pending publisher with email: " + publisher.getEmail());
                return false;
            }
        } catch (SQLException e) {
            System.err.println("PublisherDAO: Error saving pending publisher: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public Publisher getPublisherByEmail(String email) {
        String sql = "SELECT * FROM publishers WHERE publisher_email = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Publisher publisher = new Publisher();
                    publisher.setId(rs.getInt("publisher_id"));
                    publisher.setFirstName(rs.getString("publisher_first_name"));
                    publisher.setLastName(rs.getString("publisher_last_name"));
                    publisher.setEmail(rs.getString("publisher_email"));
                    publisher.setPassword(rs.getString("publisher_password"));
                    publisher.setResume(rs.getBytes("publisher_resume"));
                    publisher.setResumeFilename(rs.getString("publisher_resume_filename"));
                    publisher.setCreatedAt(rs.getTimestamp("publisher_created_at").toLocalDateTime());
                    publisher.setProfilePicture(rs.getBytes("profile_picture"));
                    System.out.println("PublisherDAO: Found approved publisher with email: " + email);
                    return publisher;
                }
            }
        } catch (SQLException e) {
            System.err.println("PublisherDAO: Error fetching publisher by email: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("PublisherDAO: No approved publisher found with email: " + email);
        return null;
    }

    public List<Publisher> getPendingPublishers() {
        List<Publisher> pendingPublishers = new ArrayList<>();
        String sql = "SELECT * FROM publisher_approvals";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Publisher publisher = new Publisher();
                publisher.setId(rs.getInt("pa_id"));
                publisher.setFirstName(rs.getString("pa_first_name"));
                publisher.setLastName(rs.getString("pa_last_name"));
                publisher.setEmail(rs.getString("pa_email"));
                publisher.setPassword(rs.getString("pa_password"));
                publisher.setResume(rs.getBytes("pa_resume"));
                publisher.setResumeFilename(rs.getString("pa_resume_filename"));
                publisher.setCreatedAt(rs.getTimestamp("pa_created_at").toLocalDateTime());
                pendingPublishers.add(publisher);
            }
            System.out.println("PublisherDAO: Fetched " + pendingPublishers.size() + " pending publishers from publisher_approvals");
        } catch (SQLException e) {
            System.err.println("PublisherDAO: Error fetching pending publishers: " + e.getMessage());
            e.printStackTrace();
        }
        return pendingPublishers;
    }

    public Publisher getPendingPublisherById(int id) {
        String sql = "SELECT * FROM publisher_approvals WHERE pa_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Publisher publisher = new Publisher();
                    publisher.setId(rs.getInt("pa_id"));
                    publisher.setFirstName(rs.getString("pa_first_name"));
                    publisher.setLastName(rs.getString("pa_last_name"));
                    publisher.setEmail(rs.getString("pa_email"));
                    publisher.setPassword(rs.getString("pa_password"));
                    publisher.setResume(rs.getBytes("pa_resume"));
                    publisher.setResumeFilename(rs.getString("pa_resume_filename"));
                    publisher.setCreatedAt(rs.getTimestamp("pa_created_at").toLocalDateTime());
                    System.out.println("PublisherDAO: Found pending publisher with ID: " + id);
                    return publisher;
                }
            }
        } catch (SQLException e) {
            System.err.println("PublisherDAO: Error fetching pending publisher by ID: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("PublisherDAO: No pending publisher found with ID: " + id);
        return null;
    }

    public boolean moveToPublishers(int publisherId) {
        String insertSql = "INSERT INTO publishers (publisher_first_name, publisher_last_name, publisher_email, publisher_password, publisher_resume, publisher_resume_filename, publisher_created_at, profile_picture) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String deleteSql = "DELETE FROM publisher_approvals WHERE pa_id = ?";
        Connection conn = null;
        PreparedStatement insertStmt = null;
        PreparedStatement deleteStmt = null;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            Publisher publisher = getPendingPublisherById(publisherId);
            if (publisher == null) {
                System.err.println("PublisherDAO: No publisher found with ID " + publisherId + " in publisher_approvals");
                return false;
            }

            System.out.println("PublisherDAO: Attempting to move publisher ID: " + publisherId +
                    ", First Name: " + publisher.getFirstName() +
                    ", Last Name: " + (publisher.getLastName() != null ? publisher.getLastName() : "NULL") +
                    ", Email: " + publisher.getEmail() +
                    ", Password: " + (publisher.getPassword() != null ? publisher.getPassword() : "NULL") +
                    ", Resume: " + (publisher.getResume() != null ? publisher.getResume().length + " bytes" : "NULL") +
                    ", Resume Filename: " + (publisher.getResumeFilename() != null ? publisher.getResumeFilename() : "NULL") +
                    ", Created At: " + publisher.getCreatedAt());

            if (publisher.getFirstName() == null || publisher.getFirstName().trim().isEmpty()) {
                System.err.println("PublisherDAO: First name is missing for publisher ID " + publisherId);
                return false;
            }
            if (publisher.getEmail() == null || publisher.getEmail().trim().isEmpty()) {
                System.err.println("PublisherDAO: Email is missing for publisher ID " + publisherId);
                return false;
            }
            if (publisher.getCreatedAt() == null) {
                System.err.println("PublisherDAO: Created_at is missing for publisher ID " + publisherId);
                return false;
            }

            insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, publisher.getFirstName());
            insertStmt.setString(2, publisher.getLastName());
            insertStmt.setString(3, publisher.getEmail());
            insertStmt.setString(4, publisher.getPassword());
            insertStmt.setBytes(5, publisher.getResume());
            insertStmt.setString(6, publisher.getResumeFilename());
            insertStmt.setTimestamp(7, Timestamp.valueOf(publisher.getCreatedAt()));
            insertStmt.setNull(8, java.sql.Types.BLOB); // profile_picture is null initially
            int rowsInserted = insertStmt.executeUpdate();
            if (rowsInserted != 1) {
                System.err.println("PublisherDAO: Failed to insert publisher ID " + publisherId + " into publishers table, rows affected: " + rowsInserted);
                conn.rollback();
                return false;
            }
            System.out.println("PublisherDAO: Successfully inserted publisher ID " + publisherId + " into publishers table");

            deleteStmt = conn.prepareStatement(deleteSql);
            deleteStmt.setInt(1, publisherId);
            int rowsDeleted = deleteStmt.executeUpdate();
            if (rowsDeleted != 1) {
                System.err.println("PublisherDAO: Failed to delete publisher ID " + publisherId + " from publisher_approvals, rows affected: " + rowsDeleted);
                conn.rollback();
                return false;
            }
            System.out.println("PublisherDAO: Successfully deleted publisher ID " + publisherId + " from publisher_approvals");

            conn.commit();
            System.out.println("PublisherDAO: Successfully moved publisher ID " + publisherId + " to publishers");
            return true;
        } catch (SQLException e) {
            System.err.println("PublisherDAO: General SQL error in moveToPublishers for ID " + publisherId + ": " +
                    e.getMessage() + ", SQLState: " + e.getSQLState() + ", ErrorCode: " + e.getErrorCode());
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException rollbackEx) {
                System.err.println("PublisherDAO: Rollback error in moveToPublishers: " + rollbackEx.getMessage());
            }
            return false;
        } finally {
            try {
                if (insertStmt != null) insertStmt.close();
                if (deleteStmt != null) deleteStmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("PublisherDAO: Error closing resources in moveToPublishers: " + e.getMessage());
            }
        }
    }

    public boolean deletePendingPublisher(int publisherId) {
        String sql = "DELETE FROM publisher_approvals WHERE pa_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, publisherId);
            int affectedRows = pstmt.executeUpdate();
            System.out.println("PublisherDAO: Deleted publisher ID: " + publisherId + " from publisher_approvals (rejection), affected rows: " + affectedRows);
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("PublisherDAO: Error deleting pending publisher ID: " + publisherId + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePublisher(Publisher publisher) {
        String sql = "UPDATE publishers SET publisher_first_name = ?, publisher_last_name = ?, publisher_email = ?, profile_picture = COALESCE(?, profile_picture) WHERE publisher_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, publisher.getFirstName());
            pstmt.setString(2, publisher.getLastName());
            pstmt.setString(3, publisher.getEmail());
            if (publisher.getProfilePicture() != null) {
                pstmt.setBytes(4, publisher.getProfilePicture());
            } else {
                pstmt.setNull(4, java.sql.Types.BLOB);
            }
            pstmt.setInt(5, publisher.getId());
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("PublisherDAO: Error updating publisher ID " + publisher.getId() + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public static byte[] convertInputStreamToByteArray(InputStream inputStream) throws IOException {
        return inputStream.readAllBytes();
    }
}