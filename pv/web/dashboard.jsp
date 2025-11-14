<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.peervault.util.ConnectionProvider" %>
<%@ page import="jakarta.servlet.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    // 1. Check if user is logged in, redirect if not
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("index.jsp?status=session_expired");
        return;
    }
    
    // 2. Define the current page/category
    String currentCategory = request.getParameter("category");
    if (currentCategory == null || currentCategory.isEmpty()) {
        currentCategory = "dashboard"; 
    }
    
    String tableFilter = "";
    String pageTitle = "";
    
    switch (currentCategory) {
        case "notes":
            tableFilter = "notes";
            pageTitle = "Notes & Study Material";
            break;
        case "books":
            tableFilter = "books";
            pageTitle = "Books & Textbooks";
            break;
        case "lab":
            tableFilter = "equipment";
            pageTitle = "Lab Equipment";
            break;
        case "dashboard":
        default:
            tableFilter = "all"; 
            pageTitle = "Dashboard - All Items";
            break;
    }
    
    // 3. DECLARE VARIABLES OUTSIDE THE TRY BLOCK (Scope Fix)
    Connection con = null;
    Statement stmt = null;
    ResultSet rsNotes = null;
    ResultSet rsBooks = null;
    ResultSet rsEquipment = null;

    try {
        con = ConnectionProvider.getConnection();
        
        if ("all".equals(tableFilter) || "notes".equals(tableFilter)) {
            stmt = con.createStatement();
            rsNotes = stmt.executeQuery("SELECT 'Note' AS type, title, description, contact_email, post_date FROM notes ORDER BY post_date DESC");
            request.setAttribute("notesList", rsNotes);
        }
        
        if ("all".equals(tableFilter) || "books".equals(tableFilter)) {
            stmt = con.createStatement();
            rsBooks = stmt.executeQuery("SELECT 'Book' AS type, title, description, contact_email, post_date FROM books ORDER BY post_date DESC");
            request.setAttribute("booksList", rsBooks);
        }
        
        if ("all".equals(tableFilter) || "equipment".equals(tableFilter)) {
            stmt = con.createStatement();
            rsEquipment = stmt.executeQuery("SELECT 'Equipment' AS type, title, description, contact_email, post_date FROM equipment ORDER BY post_date DESC");
            request.setAttribute("equipmentList", rsEquipment);
        }

    } catch (SQLException e) {
        e.printStackTrace();
        request.setAttribute("queryError", "Failed to load items: " + e.getMessage());
    }
    
    request.setAttribute("currentPage", currentCategory);
    request.setAttribute("pageTitle", pageTitle);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PeerVault - <%= pageTitle %></title>

<style>
    body { font-family: 'Segoe UI', sans-serif; margin: 0; background: #000; color: #f1f1f1; font-size: 16px; }
    header { background: #111; padding: 15px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 5px rgba(0,0,0,0.7); }
    header h1 { margin:0; color:#00cec9; font-size:30px; }
    .logo-img { background-color:#00cec9; max-height:50px; border-radius:10px; border:5px solid #0984e3; margin-right:15px; }
    .auth-buttons button { margin-left: 10px; padding: 10px 15px; font-weight: bold; border-radius: 6px; border: 3px solid #0984e3; background:#00cec9; color:#000; cursor:pointer; transition: background 0.2s; }
    .auth-buttons button:hover { background:#0984e3; color:#fff; }
    nav { background: rgb(59,57,57); padding: 10px; text-align: center; display: flex; flex-wrap: wrap; justify-content: center; }
    nav a { margin: 5px; padding: 10px 18px; height: 50px; line-height: 30px; font-size: 15px; width: 170px; border: none; border-radius: 8px; background: #00cec9; border: 3px solid #0984e3; cursor: pointer; font-weight: bold; color: #000; text-decoration: none; display: inline-block; transition: background 0.2s; text-align:center; }
    nav a.active, nav a:hover { background:#0984e3; color:#fff !important; }
    .container { padding: 20px; max-width:1200px; margin:auto; }
    .card { background:#1e1e1e; padding:20px; margin:15px 0; border-radius:12px; box-shadow:0 3px 7px rgba(0,0,0,0.6); border-left:5px solid #00cec9; transition:border-color 0.3s; }
    .card:hover { border-left-color:#0984e3; }
    .card h3 { margin-top:0; color:#55efc4; font-size:24px; }
    .card p { margin:8px 0; font-size:16px; }
    .card a { color:#00cec9; text-decoration:none; }
    .card a:hover { color:#0984e3; text-decoration:underline; }
    .list-grid { display:grid; grid-template-columns: repeat(auto-fit, minmax(300px,1fr)); gap:20px; }
    .home-welcome { font-size:28px; color:#00cec9; text-align:center; margin-bottom:30px; padding:20px; background:#1e1e1e; border-radius:10px; border:1px solid #00cec9; }
    form input, form textarea, form select, form button { display:block; margin:10px 0; padding:15px; width:100%; max-width:450px; border-radius:6px; border:none; box-sizing:border-box; }
    form input, form textarea { background:#222; color:#f1f1f1; }
    form select { background:#111; color:#00cec9; border:1px solid #0984e3; }
    form button { background:#00cec9; color:black; font-weight:bold; cursor:pointer; border:3px solid #0984e3; }
    form button:hover { background:#0984e3; color:#fff; }
    .status-message { padding: 15px; margin-bottom: 20px; border-radius: 8px; font-weight: bold; text-align: center; }
    .status-success { background-color: #55efc4; color: #111; border: 2px solid #00b894; }
    .status-fail { background-color: #ff7675; color: #111; border: 2px solid #d63031; }
    @media (max-width:768px){ header { flex-direction:column; text-align:center; } nav a { width:150px; font-size:13px; padding:8px; } .logo-img { max-height:40px; margin-bottom:10px; } header h1 { font-size:24px; } .home-welcome { font-size:20px; } .auth-buttons { margin-top:10px; } }
</style>
</head>
<body>

<header>
    <div style="display:flex; align-items:center;">
        <img class="logo-img" src="https://placehold.co/100x50/00cec9/111?text=PV" alt="Peervault Logo">
        <h1>PeerVault Exchange</h1>
    </div>
    <div class="auth-buttons">
        <span style="margin-right:10px; color:#55efc4;">Hello, <%= session.getAttribute("userName") %></span>
        <button onclick="window.location.href='LogoutServlet'">Sign Out</button>
    </div>
</header>

<nav id="menuLinks">
    <a href="dashboard.jsp?category=dashboard" class="<%= "dashboard".equals(request.getAttribute("currentPage")) ? "active" : "" %>" data-target="dashboard">Dashboard</a>
    <a href="dashboard.jsp?category=notes" class="<%= "notes".equals(request.getAttribute("currentPage")) ? "active" : "" %>" data-target="notes">Notes & Study</a>
    <a href="dashboard.jsp?category=books" class="<%= "books".equals(request.getAttribute("currentPage")) ? "active" : "" %>" data-target="books">Books & Textbooks</a>
    <a href="dashboard.jsp?category=lab" class="<%= "lab".equals(request.getAttribute("currentPage")) ? "active" : "" %>" data-target="lab">Lab Equipment</a>
    <a href="#" id="addItemNav" data-target="add">Add Item</a>
</nav>

<div class="container">
    <h2 class="home-welcome" id="pageTitle"><%= request.getAttribute("pageTitle") %></h2>

    <%
        String status = request.getParameter("status");
        if (status != null) {
            String msg = "";
            String cssClass = "status-fail";
            if ("item_posted".equals(status)) {
                msg = "Successfully posted your " + request.getParameter("category") + " item!";
                cssClass = "status-success";
            } else if ("post_fail".equals(status)) {
                msg = "Failed to post item. Please try again.";
            } else if ("invalid_category".equals(status)) {
                msg = "Invalid category selected for posting.";
            } else if (request.getAttribute("queryError") != null) {
                msg = (String) request.getAttribute("queryError");
            } else {
                 msg = "An error occurred.";
            }
    %>
        <div class="<%= cssClass %> status-message"><%= msg %></div>
    <%
        }
    %>

    <div id="itemListDisplay" class="list-grid" style="display: <%= "add".equals(request.getAttribute("currentPage")) ? "none" : "grid" %>;">
        
        <%
            boolean hasItems = false;
            
            if (request.getAttribute("notesList") != null) {
                ResultSet rsn = (ResultSet) request.getAttribute("notesList");
                while (rsn.next()) {
                    hasItems = true;
        %>
            <div class="card">
                <h3><%= rsn.getString("title") %></h3>
                <p><strong>Type:</strong> Note</p>
                <p><%= rsn.getString("description") %></p>
                <p><strong>Contact:</strong> <a href="mailto:<%= rsn.getString("contact_email") %>"><%= rsn.getString("contact_email") %></a></p>
                <p style="font-size:13px; color:#aaa;">Posted: <%= rsn.getTimestamp("post_date") %></p>
            </div>
        <%       
                }
            }
            if (request.getAttribute("booksList") != null) {
                ResultSet rsb = (ResultSet) request.getAttribute("booksList");
                while (rsb.next()) {
                    hasItems = true;
        %>
            <div class="card">
                <h3><%= rsb.getString("title") %></h3>
                <p><strong>Type:</strong> Book</p>
                <p><%= rsb.getString("description") %></p>
                <p><strong>Contact:</strong> <a href="mailto:<%= rsb.getString("contact_email") %>"><%= rsb.getString("contact_email") %></a></p>
                <p style="font-size:13px; color:#aaa;">Posted: <%= rsb.getTimestamp("post_date") %></p>
            </div>
        <%
                }
            }
            if (request.getAttribute("equipmentList") != null) {
                ResultSet rse = (ResultSet) request.getAttribute("equipmentList");
                while (rse.next()) {
                    hasItems = true;
        %>
            <div class="card">
                <h3><%= rse.getString("title") %></h3>
                <p><strong>Type:</strong> Lab Equipment</p>
                <p><%= rse.getString("description") %></p>
                <p><strong>Contact:</strong> <a href="mailto:<%= rse.getString("contact_email") %>"><%= rse.getString("contact_email") %></a></p>
                <p style="font-size:13px; color:#aaa;">Posted: <%= rse.getTimestamp("post_date") %></p>
            </div>
        <%
                }
            }
            
            if (!hasItems) {
        %>
            <div style="grid-column: 1 / -1; text-align: center; color: #aaa; padding: 50px;">
                No items found in the <%= request.getAttribute("pageTitle") %> category. Be the first to post!
            </div>
        <%
            }
            
            // CRITICAL FIX: CLEANUP RESOURCES
            // We removed the 'finally' block because the try-block closed at the top of the file.
            try { if (rsNotes != null) rsNotes.close(); } catch (SQLException e) { }
            try { if (rsBooks != null) rsBooks.close(); } catch (SQLException e) { }
            try { if (rsEquipment != null) rsEquipment.close(); } catch (SQLException e) { }
            try { if (stmt != null) stmt.close(); } catch (SQLException e) { }
            try { if (con != null) con.close(); } catch (SQLException e) { }
        %>
    </div>

    <div id="addPage" style="max-width:500px; margin:30px auto; background:#1e1e1e; padding:30px; border-radius:12px; display: none;">
        <h3>Post a New Item for Exchange/Sale</h3>
        <form action="AddItemServlet" method="POST">
            <label for="category">Category</label>
            <select id="category" name="category" required>
                <option value="Note">Note</option>
                <option value="Book">Book</option>
                <option value="Equipment">Lab Equipment</option>
            </select>

            <label for="title">Item Title</label>
            <input type="text" id="title" name="name" placeholder="E.g., Microprocessor Notes or Python Textbook" required>
            
            <label for="desc">Description</label>
            <textarea id="desc" name="desc" placeholder="Condition, price, or exchange terms..." rows="4"></textarea>

            <label for="email">Contact Email</label>
            <input type="email" id="email" name="contactEmail" placeholder="Your College Email" required value="<%= session.getAttribute("userEmail") %>" readonly>
            
            <button type="submit">Post Item</button>
        </form>
    </div>
</div>

<script>
    const navLinks = document.querySelectorAll('nav a');
    const addItemNav = document.getElementById('addItemNav');
    const itemListDisplay = document.getElementById('itemListDisplay');
    const addPage = document.getElementById('addPage');
    const pageTitleElement = document.getElementById('pageTitle');
    
    const currentPage = "<%= request.getAttribute("currentPage") %>";
    if (currentPage === "add") {
        itemListDisplay.style.display = 'none';
        addPage.style.display = 'block';
    }

    addItemNav.addEventListener('click', e => {
        e.preventDefault();
        navLinks.forEach(l => l.classList.remove('active'));
        addItemNav.classList.add('active');
        itemListDisplay.style.display = 'none';
        addPage.style.display = 'block';
        pageTitleElement.textContent = 'Add New Item';
    });
    
    navLinks.forEach(link => {
        if(link.getAttribute('data-target') !== 'add') {
             link.addEventListener('click', e => {
                 navLinks.forEach(l => l.classList.remove('active'));
                 link.classList.add('active');
             });
        }
    });
</script>

</body>
</html>