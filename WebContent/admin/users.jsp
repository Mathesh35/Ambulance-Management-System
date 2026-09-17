<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
    if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<User> users = (List<User>) request.getAttribute("users");
    User editUser = (User) request.getAttribute("editUser");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Users | Ambulance Management System</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        /* Only page-specific layout additions - reuses existing color variables via literal values from style.css, no new palette introduced */
        table.users-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 6px 18px rgba(20,30,50,0.06); border: 1px solid #ebedf1; }
        table.users-table th, table.users-table td { padding: 12px 16px; text-align: left; font-size: 13px; border-bottom: 1px solid #ebedf1; }
        table.users-table th { background: #f9fafb; text-transform: uppercase; letter-spacing: 0.04em; font-size: 11px; color: #5b6472; }
        table.users-table tr:last-child td { border-bottom: none; }
        table.users-table a.action-link { color: #e0342c; font-weight: 600; text-decoration: none; margin-right: 12px; font-size: 12.5px; }
        .form-card { background: #fff; border: 1px solid #ebedf1; border-radius: 14px; padding: 22px 24px; margin-bottom: 24px; box-shadow: 0 6px 18px rgba(20,30,50,0.06); }
        .form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; align-items: end; }
        .form-row .field { margin-top: 0; }
        .form-row label { display: block; font-size: 12.5px; font-weight: 600; color: #2b3448; margin-bottom: 5px; }
        .form-row select { width: 100%; height: 38px; border: 1px solid #e2e5eb; border-radius: 10px; background: #fafbfc; padding: 0 14px; font-size: 14px; color: #1b2436; }
        .form-row input { width: 100%; height: 38px; border: 1px solid #e2e5eb; border-radius: 10px; background: #fafbfc; padding: 0 14px; font-size: 14px; color: #1b2436; }
    </style>
</head>
<body>
    <header class="topbar">
        <span class="brand-mark"><span class="crate"></span>Ambulance Management System</span>
        <div class="user-info">
            <span><%= currentUser.getFullName() %></span>
            <span class="role-tag">ADMIN</span>
            <a class="logout" href="../logout">Log Out</a>
        </div>
    </header>

    <div class="container">
        <div class="section-heading">
            <span class="eyebrow">Admin &rsaquo; Manage Users</span>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-box" style="margin: 0 0 16px;"><%= request.getAttribute("error") %></div>
        <% } %>

        <div class="form-card">
            <h4 style="margin-bottom: 14px; font-size: 16px; color:#17213a;">
                <%= editUser != null ? "Edit User" : "Add New User" %>
            </h4>
            <form action="users" method="post">
                <% if (editUser != null) { %>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= editUser.getId() %>">
                <% } %>
                <div class="form-row">
                    <div class="field">
                        <label>Full Name</label>
                        <input type="text" name="fullName" required value="<%= editUser != null ? editUser.getFullName() : "" %>">
                    </div>
                    <div class="field">
                        <label>Username</label>
                        <input type="text" name="username" required value="<%= editUser != null ? editUser.getUsername() : "" %>">
                    </div>
                    <div class="field">
                        <label>Email</label>
                        <input type="email" name="email" placeholder="for password reset OTPs" value="<%= editUser != null && editUser.getEmail() != null ? editUser.getEmail() : "" %>">
                    </div>
                    <% if (editUser == null) { %>
                    <div class="field">
                        <label>Password</label>
                        <input type="password" name="password" required>
                    </div>
                    <% } %>
                    <div class="field">
                        <label>Role</label>
                        <select name="role" required>
                            <%
                                String[] roles = {"ADMIN", "DISPATCHER", "DRIVER", "HOSPITAL_STAFF"};
                                String currentRole = editUser != null ? editUser.getRole() : "";
                                for (String r : roles) {
                            %>
                                <option value="<%= r %>" <%= r.equals(currentRole) ? "selected" : "" %>><%= r %></option>
                            <% } %>
                        </select>
                    </div>
                    <div>
                        <button type="submit" class="btn-primary" style="margin-top:0;"><%= editUser != null ? "Save Changes" : "Add User" %></button>
                    </div>
                </div>
            </form>
            <% if (editUser != null) { %>
                <p style="margin-top:10px;"><a href="users" style="color:#5b6472; font-size:12.5px;">&larr; Cancel edit</a></p>
            <% } %>
        </div>

        <table class="users-table">
            <thead>
                <tr>
                    <th>ID</th><th>Full Name</th><th>Username</th><th>Role</th><th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (users != null) { for (User u : users) { %>
                <tr>
                    <td><%= u.getId() %></td>
                    <td><%= u.getFullName() %></td>
                    <td><%= u.getUsername() %></td>
                    <td><span class="role-tag"><%= u.getRole() %></span></td>
                    <td>
                        <a class="action-link" href="users?action=edit&id=<%= u.getId() %>">Edit</a>
                        <a class="action-link" href="users?action=delete&id=<%= u.getId() %>"
                           onclick="return confirm('Delete user \'<%= u.getUsername() %>\'?');">Delete</a>
                    </td>
                </tr>
                <% } } %>
            </tbody>
        </table>

        <p style="margin-top:20px;"><a href="../dashboard_admin.jsp" style="color:#5b6472; font-size:13px;">&larr; Back to Dashboard</a></p>
    </div>
    <footer class="scms-footer">Ambulance Management System</footer>
</body>
</html>
