package dao;

import model.User;
import util.DatabaseUtil;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;

public class UserDAO {
    // SQL Queries
    private static final String INSERT_SQL = "INSERT INTO users (user_username, user_email, user_password, user_created_at, user_role) VALUES (?, ?, ?, ?, ?)";
    private static final String SELECT_BY_USERNAME_SQL = "SELECT * FROM users WHERE user_username = ?";
    private static final String SELECT_BY_EMAIL_SQL = "SELECT * FROM users WHERE user_email = ?";
    private static final String SELECT_BY_ID_SQL = "SELECT * FROM users WHERE user_id = ?";

    // User Creation
    public boolean createUser(User user) {
        System.out.println("Attempting to create user: " + user.getUsername());
        
        // Set default role if not specified
        if (user.getRole() == null) {
            user.setRole(User.Role.USER);
        }

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {

            // Password hashing
            String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
            System.out.println("Hashed password length: " + hashedPassword.length());

            // Set parameters
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, hashedPassword);
            stmt.setTimestamp(4, Timestamp.valueOf(user.getCreatedAt()));
            stmt.setString(5, user.getRole().toString());

            // Execute and handle results
            System.out.println("Executing SQL: " + INSERT_SQL);
            int rowsAffected = stmt.executeUpdate();
            System.out.println("Rows affected: " + rowsAffected);

            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        user.setId(rs.getInt(1));
                        System.out.println("Generated ID: " + user.getId());
                    }
                }
                return true;
            }
            return false;

        } catch (SQLException e) {
            System.err.println("SQL Exception in createUser: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // User Retrieval by Username
    public User getUserByUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return null;
        }

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_USERNAME_SQL)) {

            stmt.setString(1, username.trim());
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
            return null;

        } catch (SQLException e) {
            System.err.println("SQL Error in getUserByUsername: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    // User Retrieval by Email
    public User getUserByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_EMAIL_SQL)) {

            stmt.setString(1, email.trim());
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
            return null;

        } catch (SQLException e) {
            System.err.println("SQL Error in getUserByEmail: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    // User Retrieval by ID
    public User getUserById(int userId) {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_ID_SQL)) {

            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
            return null;

        } catch (SQLException e) {
            System.err.println("SQL Error in getUserById: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    // User Validation
    public boolean validateUser(String username, String password) {
        User user = getUserByUsername(username);
        return user != null && BCrypt.checkpw(password, user.getPassword());
    }

    // Complete User Validation with Object Return
    public User validateAndGetUser(String username, String password) {
        User user = getUserByUsername(username);
        if (user == null || !BCrypt.checkpw(password, user.getPassword())) {
            return null;
        }
        return user;
    }

    // Helper method to map ResultSet to User object
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("user_id"));
        user.setUsername(rs.getString("user_username"));
        user.setEmail(rs.getString("user_email"));
        user.setPassword(rs.getString("user_password"));
        user.setCreatedAt(rs.getTimestamp("user_created_at").toLocalDateTime());
        user.setRole(User.Role.valueOf(rs.getString("user_role")));
        return user;
    }
}