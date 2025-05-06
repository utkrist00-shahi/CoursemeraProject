package dao;

import model.User;
import util.DatabaseUtil;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;

public class UserDAO {
    private static final String INSERT_SQL = "INSERT INTO users (user_username, user_email, user_password, user_created_at, user_role, user_image) VALUES (?, ?, ?, ?, ?, ?)";
    private static final String SELECT_BY_USERNAME_SQL = "SELECT * FROM users WHERE user_username = ?";
    private static final String SELECT_BY_EMAIL_SQL = "SELECT * FROM users WHERE user_email = ?";
    private static final String SELECT_BY_ID_SQL = "SELECT * FROM users WHERE user_id = ?";
    private static final String UPDATE_CREDENTIALS_SQL = "UPDATE users SET user_username = ?, user_email = ? WHERE user_id = ?";
    private static final String UPDATE_PASSWORD_SQL = "UPDATE users SET user_password = ? WHERE user_id = ?";
    private static final String UPDATE_IMAGE_SQL = "UPDATE users SET user_image = ? WHERE user_id = ?";

    public boolean createUser(User user) {
        System.out.println("Attempting to create user: " + user.getUsername());
        
        if (user.getRole() == null) {
            user.setRole(User.Role.USER);
        }

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {

            String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
            System.out.println("Hashed password length: " + hashedPassword.length());

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, hashedPassword);
            stmt.setTimestamp(4, Timestamp.valueOf(user.getCreatedAt()));
            stmt.setString(5, user.getRole().toString());
            if (user.getImage() != null && user.getImage().length > 0) {
                System.out.println("UserDAO: Setting image for new user, size: " + user.getImage().length + " bytes");
                stmt.setBytes(6, user.getImage());
            } else {
                System.out.println("UserDAO: No image provided for new user, setting to null");
                stmt.setNull(6, Types.BLOB);
            }

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

    public boolean validateUser(String username, String password) {
        User user = getUserByUsername(username);
        return user != null && BCrypt.checkpw(password, user.getPassword());
    }

    public User validateAndGetUser(String username, String password) {
        User user = getUserByUsername(username);
        if (user == null) {
            System.out.println("UserDAO: User not found for username: " + username);
            return null;
        }
        if (!BCrypt.checkpw(password, user.getPassword())) {
            System.out.println("UserDAO: Password validation failed for username: " + username);
            return null;
        }
        System.out.println("UserDAO: User validated successfully: " + username);
        return user;
    }

    public boolean updateUserCredentials(int userId, String username, String email) {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_CREDENTIALS_SQL)) {

            stmt.setString(1, username.trim());
            stmt.setString(2, email.trim());
            stmt.setInt(3, userId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("SQL Error in updateUserCredentials: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateUserPassword(int userId, String newPassword) {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_PASSWORD_SQL)) {

            String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            stmt.setString(1, hashedPassword);
            stmt.setInt(2, userId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("SQL Error in updateUserPassword: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateUserImage(int userId, byte[] image) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);
            System.out.println("UserDAO: Updating image for user ID " + userId + ", image size: " + (image != null ? image.length : "null") + " bytes");
            
            try (PreparedStatement stmt = conn.prepareStatement(UPDATE_IMAGE_SQL)) {
                if (image != null && image.length > 0) {
                    stmt.setBytes(1, image);
                } else {
                    stmt.setNull(1, Types.BLOB);
                }
                stmt.setInt(2, userId);
                
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    conn.commit();
                    System.out.println("UserDAO: Successfully updated image for user ID " + userId);
                    return true;
                } else {
                    conn.rollback();
                    System.out.println("UserDAO: No rows affected for user ID " + userId);
                    return false;
                }
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("UserDAO: SQLException in updateUserImage for user ID " + userId + ": " + e.getMessage());
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) {
            System.err.println("UserDAO: Connection error in updateUserImage: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                    System.out.println("UserDAO: Connection closed for user ID " + userId);
                } catch (SQLException e) {
                    System.err.println("UserDAO: Error closing connection: " + e.getMessage());
                }
            }
        }
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("user_id"));
        user.setUsername(rs.getString("user_username"));
        user.setEmail(rs.getString("user_email"));
        user.setPassword(rs.getString("user_password"));
        user.setCreatedAt(rs.getTimestamp("user_created_at") != null ? rs.getTimestamp("user_created_at").toLocalDateTime() : null);
        try {
            user.setRole(User.Role.valueOf(rs.getString("user_role")));
        } catch (IllegalArgumentException e) {
            user.setRole(User.Role.USER);
        }
        user.setImage(rs.getBytes("user_image"));
        System.out.println("UserDAO: Retrieved image for user ID " + user.getId() + ", size: " + (user.getImage() != null ? user.getImage().length : "null") + " bytes");
        return user;
    }
}