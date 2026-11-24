package es.carlosgr.miter.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseManager {

    private static final String URL = "jdbc:mysql://localhost:3306/miter_bbdd?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Europe/Madrid";
    private static final String USER = System.getenv().getOrDefault("MITER_DB_USER", "miter");
    private static final String PASSWORD = System.getenv("MITER_DB_PASSWORD"); // definir como variable de entorno

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
