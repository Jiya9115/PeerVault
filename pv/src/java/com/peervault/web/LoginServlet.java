package com.peervault.web;

import com.peervault.util.ConnectionProvider;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

//@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get user input
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = ConnectionProvider.getConnection();
            String sql = "SELECT user_id, name, email FROM users WHERE email = ? AND password = ?";
            ps = con.prepareStatement(sql);
            
            ps.setString(1, email);
            ps.setString(2, password);
            
            // 2. Execute query
            rs = ps.executeQuery();
            
            // 3. Check result
            if (rs.next()) {
                // Login successful: create a session and store user info
                HttpSession session = request.getSession();
                session.setAttribute("userId", rs.getInt("user_id"));
                session.setAttribute("userName", rs.getString("name"));
                session.setAttribute("userEmail", rs.getString("email"));
                
                // Redirect to the main dashboard
                response.sendRedirect("dashboard.jsp");
            } else {
                // Login failed: incorrect credentials
                response.sendRedirect("index.jsp?status=login_fail");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?status=error&message=" + e.getMessage());
        } finally {
            // 4. Close resources
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (ps != null) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}