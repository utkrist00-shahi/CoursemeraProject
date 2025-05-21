package dao;

import model.Publisher;
import util.DatabaseUtil;
import org.mindrot.jbcrypt.BCrypt;
import java.io.ByteArrayOutputStream;
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
            String hashedPassword = BCrypt.hashpw(publisher.getPassword(), BCrypt.gensalt());
            pstmt.setString(4, hashedPassword);
            byte[] resumeData = publisher.getResume();
            System.out.println("PublisherDAO: Preparing to save resume of size: " + (resumeData != null ? resumeData.length : 0) + " bytes for email: " + publisher.getEmail());
            pstmt.setBytes(5, resumeData);
            pstmt.setString(6, publisher.getResumeFilename());
            pstmt.setTimestamp(7, Timestamp.valueOf(publisher.getCreatedAt() != null ? publisher.getCreatedAt() : LocalDateTime.now()));
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
            System.err.println("PublisherDAO: Error saving pending publisher with email: " + publisher.getEmail() + 
                               ", SQLState: " + e.getSQLState() + 
                               ", ErrorCode: " + e.getErrorCode() + 
                               ", Message: " + e.getMessage());
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
                    publisher.setCreatedAt(rs.getTimestamp("publisher_created_at") != null ? rs.getTimestamp("publisher_created_at").toLocalDateTime() : LocalDateTime.now());
                    publisher.setProfilePicture(rs.getBytes("profile_picture"));
                    System.out.println("PublisherDAO: Found approved publisher with email: " + email);
                    return publisher;
                }
            }
        } catch (SQLException e) {
            System.err.println("PublisherDAO: Error fetching publisher by email: " + email + ", Message: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("PublisherDAO: No approved publisher found with email: " + email);
        return null;
    }

    public boolean validatePublisher(String email, String password) {
        Publisher publisher = getPublisherByEmail(email);
        if (publisher == null) {
            System.out.println("PublisherDAO: validatePublisher: No publisher with email: " + email);
            return false;
        }
        boolean valid = BCrypt.checkpw(password, publisher.getPassword());
        System.out.println("PublisherDAO: validatePublisher: Password for email " + email + ": " + (valid ? "valid" : "invalid"));
        return valid;
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
                publisher.setCreatedAt(rs.getTimestamp("pa_created_at") != null ? rs.getTimestamp("pa_created_at").toLocalDateTime() : LocalDateTime.now());
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
                    publisher.setCreatedAt(rs.getTimestamp("pa_created_at") != null ? rs.getTimestamp("pa_created_at").toLocalDateTime() : LocalDateTime.now());
                    System.out.println("PublisherDAO: Found pending publisher with ID: " + id);
                    return publisher;
                }
            }
        } catch (SQLException e) {
            System.err.println("PublisherDAO: Error fetching pending publisher by ID: " + id + ", Message: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("PublisherDAO: No pending publisher found with ID: " + id);
        return null;
    }

    public String moveToPublishers(int publisherId) {
        String selectSql = "SELECT * FROM publisher_approvals WHERE pa_id = ?";
        String insertSql = "INSERT INTO publishers (publisher_first_name, publisher_last_name, publisher_email, publisher_password, publisher_resume, publisher_resume_filename, publisher_created_at, profile_picture) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String deleteSql = "DELETE FROM publisher_approvals WHERE pa_id = ?";

        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false); // Start transaction

            // Fetch the publisher data
            Publisher publisher = null;
            try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
                selectStmt.setInt(1, publisherId);
                try (ResultSet rs = selectStmt.executeQuery()) {
                    if (rs.next()) {
                        publisher = new Publisher();
                        publisher.setId(rs.getInt("pa_id"));
                        publisher.setFirstName(rs.getString("pa_first_name"));
                        publisher.setLastName(rs.getString("pa_last_name"));
                        publisher.setEmail(rs.getString("pa_email"));
                        publisher.setPassword(rs.getString("pa_password"));
                        publisher.setResume(rs.getBytes("pa_resume"));
                        publisher.setResumeFilename(rs.getString("pa_resume_filename"));
                        publisher.setCreatedAt(rs.getTimestamp("pa_created_at") != null ? rs.getTimestamp("pa_created_at").toLocalDateTime() : LocalDateTime.now());
                    } else {
                        System.err.println("PublisherDAO: No publisher found with ID " + publisherId + " in publisher_approvals");
                        return "No publisher found with ID " + publisherId + " in publisher_approvals";
                    }
                }
            }

            // Log the data being transferred, including resume size
            int resumeSize = publisher.getResume() != null ? publisher.getResume().length : 0;
            System.out.println("PublisherDAO: Attempting to move publisher ID: " + publisherId +
                    ", First Name: " + (publisher.getFirstName() != null ? publisher.getFirstName() : "NULL") +
                    ", Last Name: " + (publisher.getLastName() != null ? publisher.getLastName() : "NULL") +
                    ", Email: " + (publisher.getEmail() != null ? publisher.getEmail() : "NULL") +
                    ", Password: " + (publisher.getPassword() != null ? "[HIDDEN] (Length: " + publisher.getPassword().length() + ")" : "NULL") +
                    ", Resume: " + resumeSize + " bytes" +
                    ", Resume Filename: " + (publisher.getResumeFilename() != null ? publisher.getResumeFilename() : "NULL") +
                    ", Created At: " + (publisher.getCreatedAt() != null ? publisher.getCreatedAt().toString() : "NULL"));

            // Insert into publishers
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                insertStmt.setString(1, publisher.getFirstName());
                insertStmt.setString(2, publisher.getLastName());
                insertStmt.setString(3, publisher.getEmail());
                insertStmt.setString(4, publisher.getPassword());
                insertStmt.setBytes(5, publisher.getResume());
                insertStmt.setString(6, publisher.getResumeFilename());
                insertStmt.setTimestamp(7, publisher.getCreatedAt() != null ? Timestamp.valueOf(publisher.getCreatedAt()) : null);
                insertStmt.setNull(8, Types.BLOB); // profile_picture
                int rowsInserted = insertStmt.executeUpdate();
                if (rowsInserted <= 0) {
                    System.err.println("PublisherDAO: Failed to insert publisher ID " + publisherId + " into publishers table, rows affected: " + rowsInserted);
                    conn.rollback();
                    return "Failed to insert publisher ID " + publisherId + " into publishers table";
                }
            }

            // Delete from publisher_approvals
            try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                deleteStmt.setInt(1, publisherId);
                int rowsDeleted = deleteStmt.executeUpdate();
                if (rowsDeleted <= 0) {
                    System.err.println("PublisherDAO: Failed to delete publisher ID " + publisherId + " from publisher_approvals, rows affected: " + rowsDeleted);
                    conn.rollback();
                    return "Failed to delete publisher ID " + publisherId + " from publisher_approvals";
                }
            }

            conn.commit();
            System.out.println("PublisherDAO: Successfully moved publisher ID " + publisherId + " to publishers");
            return "Success";
        } catch (SQLException e) {
            System.err.println("PublisherDAO: Error moving publisher ID " + publisherId + " to publishers: " +
                    "Message: " + e.getMessage() + ", SQLState: " + e.getSQLState() + ", ErrorCode: " + e.getErrorCode());
            e.printStackTrace();
            return "Database error: " + e.getMessage();
        }
    }

    public boolean deletePendingPublisher(int publisherId) {
        String sql = "DELETE FROM publisher_approvals WHERE pa_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, publisherId);
            int affectedRows = pstmt.executeUpdate();
            System.out.println("PublisherDAO: Deleted publisher ID: " + publisherId + " from publisher_approvals, rows affected: " + affectedRows);
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
                pstmt.setNull(4, Types.BLOB);
            }
            pstmt.setInt(5, publisher.getId());
            int affectedRows = pstmt.executeUpdate();
            System.out.println("PublisherDAO: Updated publisher ID: " + publisher.getId() + ", rows affected: " + affectedRows);
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("PublisherDAO: Error updating publisher ID " + publisher.getId() + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public static byte[] convertInputStreamToByteArray(InputStream inputStream) throws IOException {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        byte[] data = new byte[8192];
        int bytesRead;
        System.out.println("PublisherDAO: Starting to convert InputStream to byte array");
        while ((bytesRead = inputStream.read(data, 0, data.length)) != -1) {
            buffer.write(data, 0, bytesRead);
        }
        buffer.flush();
        byte[] result = buffer.toByteArray();
        System.out.println("PublisherDAO: Successfully converted InputStream to byte array, size: " + result.length + " bytes");
        return result;
    }
}