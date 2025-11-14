package com.peervault.web;

import com.peervault.util.ConnectionProvider;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

//@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get user input from the Sign Up form
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password"); 
        
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = ConnectionProvider.getConnection();
            String sql = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";
            ps = con.prepareStatement(sql);
            
            // Set values in the prepared statement
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            
            // 2. Execute the statement
            int rowCount = ps.executeUpdate();
            
            // 3. Handle success/failure and redirect
            if (rowCount > 0) {
                // Registration successful, redirect to index.jsp with a success message
                response.sendRedirect("index.jsp?status=registered");
            } else {
                // Registration failed
                response.sendRedirect("index.jsp?status=reg_fail");
            }

        } catch (SQLException e) {
            // Handle unique constraint violation (email already exists) or other DB errors
            if (e.getSQLState().equals("23000")) { // MySQL Duplicate entry error code
                 response.sendRedirect("index.jsp?status=email_exists");
            } else {
                 e.printStackTrace();
                 response.sendRedirect("index.jsp?status=error&message=" + e.getMessage());
            }
        } finally {
            // 4. Close resources
            try { if (ps != null) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}