package dao;

import model.User;
import util.DatabaseUtil;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    private static final String INSERT_SQL = "INSERT INTO users (user_username, user_email, user_password, user_created_at, user_role, user_image) VALUES (?, ?, ?, ?, ?, ?)";
    private static final String SELECT_BY_USERNAME_SQL = "SELECT * FROM users WHERE user_username = ?";
    private static final String SELECT_BY_EMAIL_SQL = "SELECT * FROM users WHERE user_email = ?";
    private static final String SELECT_BY_ID_SQL = "SELECT * FROM users WHERE user_id = ?";
    private static final String UPDATE_CREDENTIALS_SQL = "UPDATE users SET user_username = ?, user_email = ? WHERE user_id = ?";
    private static final String UPDATE_PASSWORD_SQL = "UPDATE users SET user_password = ? WHERE user_id = ?";
    private static final String UPDATE_IMAGE_SQL = "UPDATE users SET user_image = ? WHERE user_id = ?";
    private static final String SELECT_ALL_USERS_SQL = "SELECT user_id, user_username, user_email, user_role FROM users";
    private static final String DELETE_USER_SQL = "DELETE FROM users WHERE user_id = ?";
    private static final String COUNT_USERS_SQL = "SELECT COUNT(*) AS user_count FROM users";

    public boolean createUser(User user) {
        System.out.println("UserDAO: Creating user: " + user.getUsername());
        if (user.getRole() == null) user.setRole(User.Role.USER);
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, hashedPassword);
            stmt.setTimestamp(4, Timestamp.valueOf(user.getCreatedAt()));
            stmt.setString(5, user.getRole().toString());
            stmt.setBytes(6, user.getImage() != null && user.getImage().length > 0 ? user.getImage() : null);
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) user.setId(rs.getInt(1));
                }
                System.out.println("UserDAO: Created user ID: " + user.getId());
                return true;
            }
            System.out.println("UserDAO: Create failed, no rows affected");
            return false;
        } catch (SQLException e) {
            System.err.println("UserDAO: createUser error: " + e.getMessage() + ", Code: " + e.getErrorCode() + ", State: " + e.getSQLState());
            e.printStackTrace();
            return false;
        }
    }

    public User getUserByUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            System.out.println("UserDAO: Invalid username: null or empty");
            return null;
        }
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_USERNAME_SQL)) {
            stmt.setString(1, username.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    System.out.println("UserDAO: Found username: " + username);
                    return mapResultSetToUser(rs);
                }
                System.out.println("UserDAO: Username not found: " + username);
                return null;
            }
        } catch (SQLException e) {
            System.err.println("UserDAO: getUserByUsername error: " + e.getMessage() + ", Code: " + e.getErrorCode() + ", State: " + e.getSQLState());
            e.printStackTrace();
            return null;
        }
    }

    public User getUserByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            System.out.println("UserDAO: Invalid email: null or empty");
            return null;
        }
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_EMAIL_SQL)) {
            stmt.setString(1, email.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    System.out.println("UserDAO: Found email: " + email);
                    return mapResultSetToUser(rs);
                }
                System.out.println("UserDAO: Email not found: " + email);
                return null;
            }
        } catch (SQLException e) {
            System.err.println("UserDAO: getUserByEmail error: " + e.getMessage() + ", Code: " + e.getErrorCode() + ", State: " + e.getSQLState());
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
                    System.out.println("UserDAO: Found user ID: " + userId);
                    return mapResultSetToUser(rs);
                }
                System.out.println("UserDAO: User ID not found: " + userId);
                return null;
            }
        } catch (SQLException e) {
            System.err.println("UserDAO: getUserById error: " + e.getMessage() + ", Code: " + e.getErrorCode() + ", State: " + e.getSQLState());
            e.printStackTrace();
            return null;
        }
    }

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        System.out.println("UserDAO: Running: " + SELECT_ALL_USERS_SQL);
        try (Connection conn = DatabaseUtil.getConnection()) {
            System.out.println("UserDAO: Connected, URL: " + conn.getMetaData().getURL());
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT DATABASE()")) {
                if (rs.next()) System.out.println("UserDAO: Database: " + rs.getString(1));
                else System.out.println("UserDAO: No database info");
            }
            try (PreparedStatement stmt = conn.prepareStatement(SELECT_ALL_USERS_SQL);
                 ResultSet rs = stmt.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("user_username"));
                    user.setEmail(rs.getString("user_email"));
                    String role = rs.getString("user_role");
                    try {
                        user.setRole(role != null ? User.Role.valueOf(role) : User.Role.USER);
                    } catch (IllegalArgumentException e) {
                        user.setRole(User.Role.USER);
                        System.out.println("UserDAO: Invalid role for ID " + user.getId() + ": " + role);
                    }
                    users.add(user);
                    count++;
                    System.out.println("UserDAO: User " + count + " - ID: " + user.getId() + ", Username: " + user.getUsername() + ", Email: " + user.getEmail() + ", Role: " + user.getRole());
                }
                System.out.println("UserDAO: Fetched " + count + " users");
                if (count == 0) {
                    System.out.println("UserDAO: No users, trying fallback: SELECT * FROM users");
                    try (PreparedStatement fallback = conn.prepareStatement("SELECT * FROM users");
                         ResultSet frs = fallback.executeQuery()) {
                        int fcount = 0;
                        while (frs.next()) {
                            fcount++;
                            StringBuilder cols = new StringBuilder();
                            for (int i = 1; i <= frs.getMetaData().getColumnCount(); i++) {
                                cols.append(frs.getMetaData().getColumnName(i)).append(": ").append(frs.getObject(i)).append(", ");
                            }
                            System.out.println("UserDAO: Fallback user " + fcount + " - " + cols);
                        }
                        System.out.println("UserDAO: Fallback fetched " + fcount + " users");
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("UserDAO: getAllUsers error: " + e.getMessage() + ", Code: " + e.getErrorCode() + ", State: " + e.getSQLState());
            e.printStackTrace();
        }
        System.out.println("UserDAO: Returning " + users.size() + " users");
        return users;
    }

    public boolean deleteUser(int userId) {
        System.out.println("UserDAO: Deleting user ID: " + userId);
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(DELETE_USER_SQL)) {
            stmt.setInt(1, userId);
            int rows = stmt.executeUpdate();
            System.out.println("UserDAO: Deleted user ID: " + userId + ", rows: " + rows);
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("UserDAO: deleteUser error: " + e.getMessage() + ", Code: " + e.getErrorCode() + ", State: " + e.getSQLState());
            e.printStackTrace();
            return false;
        }
    }

    public boolean validateUser(String username, String password) {
        User user = getUserByUsername(username);
        if (user == null) {
            System.out.println("UserDAO: validateUser: No user: " + username);
            return false;
        }
        boolean valid = BCrypt.checkpw(password, user.getPassword());
        System.out.println("UserDAO: validateUser: Password for " + username + ": " + (valid ? "valid" : "invalid"));
        return valid;
    }

    public User validateAndGetUser(String username, String password) {
        User user = getUserByUsername(username);
        if (user == null || !BCrypt.checkpw(password, user.getPassword())) {
            System.out.println("UserDAO: validateAndGetUser: Invalid credentials for " + username);
            return null;
        }
        System.out.println("UserDAO: validateAndGetUser: Validated: " + username);
        return user;
    }

    public boolean updateUserCredentials(int userId, String username, String email) {
        System.out.println("UserDAO: Updating credentials for ID: " + userId);
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_CREDENTIALS_SQL)) {
            stmt.setString(1, username.trim());
            stmt.setString(2, email.trim());
            stmt.setInt(3, userId);
            int rows = stmt.executeUpdate();
            System.out.println("UserDAO: Updated credentials for ID: " + userId + ", rows: " + rows);
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("UserDAO: updateUserCredentials error: " + e.getMessage() + ", Code: " + e.getErrorCode() + ", State: " + e.getSQLState());
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateUserPassword(int userId, String newPassword) {
        System.out.println("UserDAO: Updating password for ID: " + userId);
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_PASSWORD_SQL)) {
            String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            stmt.setString(1, hashedPassword);
            stmt.setInt(2, userId);
            int rows = stmt.executeUpdate();
            System.out.println("UserDAO: Updated password for ID: " + userId + ", rows: " + rows);
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("UserDAO: updateUserPassword error: " + e.getMessage() + ", Code: " + e.getErrorCode() + ", State: " + e.getSQLState());
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateUserImage(int userId, byte[] image) {
        System.out.println("UserDAO: Updating image for ID: " + userId);
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement stmt = conn.prepareStatement(UPDATE_IMAGE_SQL)) {
                stmt.setBytes(1, image != null && image.length > 0 ? image : null);
                stmt.setInt(2, userId);
                int rows = stmt.executeUpdate();
                if (rows > 0) {
                    conn.commit();
                    System.out.println("UserDAO: Updated image for ID: " + userId);
                    return true;
                }
                conn.rollback();
                System.out.println("UserDAO: Image update failed for ID: " + userId);
                return false;
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("UserDAO: updateUserImage error: " + e.getMessage() + ", Code: " + e.getErrorCode() + ", State: " + e.getSQLState());
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) {
            System.err.println("UserDAO: updateUserImage conn error: " + e.getMessage() + ", Code: " + e.getErrorCode() + ", State: " + e.getSQLState());
            e.printStackTrace();
            return false;
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
            String role = rs.getString("user_role");
            user.setRole(role != null ? User.Role.valueOf(role) : User.Role.USER);
        } catch (IllegalArgumentException e) {
            user.setRole(User.Role.USER);
            System.out.println("UserDAO: Invalid role for ID " + user.getId());
        }
        user.setImage(rs.getBytes("user_image"));
        System.out.println("UserDAO: Mapped user - ID: " + user.getId() + ", Username: " + user.getUsername());
        return user;
    }
}