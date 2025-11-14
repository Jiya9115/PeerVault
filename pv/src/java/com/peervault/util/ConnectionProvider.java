package com.peervault.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

// Utility class to provide a connection to the MySQL database
public class ConnectionProvider {
    private static final String URL = "jdbc:mysql://localhost:3306/peervault";
    private static final String USER = "root"; // XAMPP default MySQL username
    private static final String PASSWORD = ""; // XAMPP default MySQL password (usually blank)

    public static Connection getConnection() {
        Connection con = null;
        try {
            // Step 1: Load the MySQL JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Step 2: Establish the connection
            con = DriverManager.getConnection(URL, USER, PASSWORD);
            
            // Optional: for checking connection status
            System.out.println("--- DB Connected Successfully! ---"); 
            
        } catch (ClassNotFoundException e) {
            // Handle the case where the driver JAR is missing or path is wrong
            System.err.println("JDBC Driver not found. Ensure mysql-connector-java.jar is in Libraries: " + e.getMessage());
        } catch (SQLException e) {
            // Handle connection errors (e.g., XAMPP MySQL not running)
            System.err.println("Database connection failed. Check XAMPP/Tomcat setup: " + e.getMessage());
        }
        return con;
    }
}