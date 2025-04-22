package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

//database connection

public class DatabaseUtil {
    private static final String URL = "jdbc:mariadb://localhost:3307/coursemeraproject"
        + "?useSSL=false"
        + "&allowPublicKeyRetrieval=true"
        + "&serverTimezone=UTC"
        + "&autoReconnect=true";

    private static final String USER = "root";
    private static final String PASSWORD = "";

    static {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            System.out.println("MariaDB JDBC driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("Failed to load MariaDB JDBC driver: " + e.getMessage());
            throw new RuntimeException("Failed to load MariaDB JDBC driver. Ensure mariadb-java-client.jar is in your classpath.", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Database connection established.");
            return conn;
        } catch (SQLException e) {
            System.err.println("Failed to connect to database: " + e.getMessage());
            throw new SQLException("Failed to connect to database. Verify credentials and that MariaDB is running.", e);
        }
    }
}