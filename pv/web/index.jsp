<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PeerVault - Connect & Exchange</title>

<style>
    /* CSS provided by the user, adapted for JSP/Web App */
    body {
        font-family: 'Segoe UI', sans-serif;
        margin: 0;
        background: #000;
        color: #f1f1f1;
        font-size: 16px;
    }

    header {
        background: #111;
        padding: 15px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: 0 2px 5px rgba(0,0,0,0.7);
    }

    header h1 { margin:0; color:#00cec9; font-size:30px; }
    .logo-img { background-color:#00cec9; max-height:50px; border-radius:10px; border:5px solid #0984e3; margin-right:15px; }

    .auth-buttons button {
        margin-left: 10px;
        padding: 10px 15px;
        font-weight: bold;
        border-radius: 6px;
        border: 3px solid #0984e3;
        background:#00cec9;
        color:#000;
        cursor:pointer;
        transition: background 0.2s;
    }

    .auth-buttons button:hover { background:#0984e3; color:#fff; }

    .container { padding: 20px; max-width:1200px; margin:auto; text-align:center; }
    
    .home-welcome {
        font-size:28px;
        color:#00cec9;
        text-align:center;
        margin-top:50px;
        margin-bottom:30px;
        padding:20px;
        background:#1e1e1e;
        border-radius:10px;
        border:1px solid #00cec9;
    }

    /* Form and Modal Styling */
    form input, form textarea, form select, form button {
        display:block;
        margin:10px 0;
        padding:15px;
        width:100%;
        max-width:450px;
        border-radius:6px;
        border:none;
        box-sizing:border-box;
    }

    form input, form textarea { background:#222; color:#f1f1f1; }
    form button { background:#00cec9; color:black; font-weight:bold; cursor:pointer; border:3px solid #0984e3; }
    form button:hover { background:#0984e3; color:#fff; }

    /* Modal Styling */
    .modal {
        display: none;
        position: fixed;
        z-index: 999;
        left: 0; top: 0;
        width: 100%; height: 100%;
        overflow: auto;
        background-color: rgba(0,0,0,0.7);
    }

    .modal-content {
        background-color: #1e1e1e;
        margin: 10% auto;
        padding: 30px;
        border: 1px solid #0984e3;
        width: 90%;
        max-width: 400px;
        border-radius: 12px;
    }
    
    .modal-content h2 { color:#00cec9; }

    .close {
        color: #fff;
        float: right;
        font-size: 28px;
        font-weight: bold;
        cursor: pointer;
    }
    
    .alert-box {
        padding: 10px 20px;
        border-radius: 6px;
        margin-bottom: 20px;
        color: #111;
        font-weight: bold;
        text-align: left;
    }
    .alert-success { background-color: #55efc4; border: 2px solid #00b894; }
    .alert-danger { background-color: #ff7675; border: 2px solid #d63031; }

    @media (max-width:768px){
        header { flex-direction:column; text-align:center; }
        .logo-img { max-height:40px; margin-bottom:10px; }
        header h1 { font-size:24px; }
        .home-welcome { font-size:20px; }
        .auth-buttons { margin-top:10px; }
    }
</style>
</head>
<body>

<% 
    // Check if the user is already logged in
    if (session.getAttribute("userId") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    // Check for status messages from Servlets
    String status = request.getParameter("status");
    String alertMessage = null;
    String alertClass = "alert-danger";

    if (status != null) {
        switch (status) {
            case "registered":
                alertMessage = "Registration successful! You can now sign in.";
                alertClass = "alert-success";
                break;
            case "login_fail":
                alertMessage = "Sign In failed. Check your email and password.";
                break;
            case "email_exists":
                alertMessage = "Registration failed. This email is already registered.";
                break;
            case "session_expired":
                alertMessage = "Your session has expired. Please sign in again.";
                break;
            case "logged_out":
                alertMessage = "You have been successfully logged out.";
                alertClass = "alert-success";
                break;
            default:
                alertMessage = "An unknown error occurred.";
        }
    }
%>

<header>
    <div style="display:flex; align-items:center;">
        <img class="logo-img" src="https://placehold.co/100x50/00cec9/111?text=PV" alt="Peervault Logo">
        <h1>PeerVault Exchange</h1>
    </div>
    <div class="auth-buttons">
        <button id="signInBtn">Sign In</button>
        <button id="signUpBtn">Sign Up</button>
    </div>
</header>

<div class="container">
    <h2 class="home-welcome">
        Your Student Exchange Hub: Share Notes, Books, and Equipment.
    </h2>
    
    <% if (alertMessage != null) { %>
        <div class="<%= alertClass %> alert-box" id="statusAlert">
            <%= alertMessage %>
        </div>
    <% } %>

    <div style="padding:20px; max-width:600px; margin:auto;">
        <p>This is the PeerVault, a collaborative platform for students in your college. Use the buttons above to sign in or register your account.</p>
    </div>
</div>

<!-- Sign In Modal -->
<div id="signInModal" class="modal">
    <div class="modal-content">
        <span class="close" id="closeSignIn">&times;</span>
        <h2>Sign In</h2>
        <!-- Form submits to LoginServlet -->
        <form action="LoginServlet" method="POST">
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Sign In</button>
        </form>
    </div>
</div>

<!-- Sign Up Modal -->
<div id="signUpModal" class="modal">
    <div class="modal-content">
        <span class="close" id="closeSignUp">&times;</span>
        <h2>Sign Up</h2>
        <!-- Form submits to RegisterServlet -->
        <form action="RegisterServlet" method="POST">
            <input type="text" name="name" placeholder="Full Name" required>
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password (Simple Text for now)" required>
            <button type="submit">Sign Up</button>
        </form>
    </div>
</div>

<script>
    // Modal Logic (Using standard JS for modals)
    const signInBtn = document.getElementById('signInBtn');
    const signUpBtn = document.getElementById('signUpBtn');
    const signInModal = document.getElementById('signInModal');
    const signUpModal = document.getElementById('signUpModal');
    const closeSignIn = document.getElementById('closeSignIn');
    const closeSignUp = document.getElementById('closeSignUp');

    // Display modals on button click
    if (signInBtn) signInBtn.onclick = () => signInModal.style.display = 'block';
    if (signUpBtn) signUpBtn.onclick = () => signUpModal.style.display = 'block';
    
    // Close modals on 'x' click
    if (closeSignIn) closeSignIn.onclick = () => signInModal.style.display = 'none';
    if (closeSignUp) closeSignUp.onclick = () => signUpModal.style.display = 'none';

    // Close modals when clicking outside
    window.onclick = function(event){
        if(event.target === signInModal) signInModal.style.display = 'none';
        if(event.target === signUpModal) signUpModal.style.display = 'none';
    };

    // If an alert is displayed, show the corresponding modal if login/reg failed
    const status = new URLSearchParams(window.location.search).get('status');
    if (status === 'login_fail' || status === 'session_expired') {
        signInModal.style.display = 'block';
    } else if (status === 'reg_fail' || status === 'email_exists') {
        signUpModal.style.display = 'block';
    }
</script>

</body>
</html>