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
import jakarta.servlet.http.HttpSession;

//@WebServlet("/AddItemServlet")
// ... imports

// @WebServlet("/AddItemServlet") // KEEP THIS COMMENTED OUT
public class AddItemServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp?status=session_expired");
            return;
        }
        
        Integer userId = (Integer) session.getAttribute("userId");
        
        // Get parameters
        String category = request.getParameter("category");
        String title = request.getParameter("name");
        String desc = request.getParameter("desc");
        String contactEmail = request.getParameter("contactEmail");

        // SAFETY CHECK: Prevent NullPointerException
        if (category == null) {
            response.sendRedirect("dashboard.jsp?status=invalid_category");
            return;
        }

        String sql = "";

        // Ensure these column names exist in your database exactly as written
        switch (category) {
            case "Note":
                sql = "INSERT INTO notes (user_id, title, description, contact_email) VALUES (?, ?, ?, ?)";
                break;
            case "Book":
                sql = "INSERT INTO books (user_id, title, description, contact_email) VALUES (?, ?, ?, ?)";
                break;
            case "Equipment":
                sql = "INSERT INTO equipment (user_id, title, description, contact_email) VALUES (?, ?, ?, ?)";
                break;
            default:
                response.sendRedirect("dashboard.jsp?status=invalid_category");
                return;
        }
        
        // Try-with-resources automatically closes Connection and PreparedStatement
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setString(2, title);
            ps.setString(3, desc);
            ps.setString(4, contactEmail);
            
            int rowCount = ps.executeUpdate();
            
            if (rowCount > 0) {
                response.sendRedirect("dashboard.jsp?status=item_posted&category=" + category.toLowerCase());
            } else {
                response.sendRedirect("dashboard.jsp?status=post_fail");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?status=error&message=" + e.getMessage());
        }
    }
}