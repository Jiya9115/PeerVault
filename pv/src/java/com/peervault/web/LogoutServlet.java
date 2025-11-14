package com.peervault.web;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

//@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false); // Do not create a new session if one doesn't exist
        
        if (session != null) {
            session.invalidate(); // Destroy the session
        }
        
        // Redirect to the login page with a logged_out status message
        response.sendRedirect("index.jsp?status=logged_out");
    }
}