<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Change Password | Ambulance Management System</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header class="topbar">
        <span class="brand-mark"><span class="crate"></span>Ambulance Management System</span>
        <div class="user-info">
            <span><%= currentUser != null ? currentUser.getFullName() : "" %></span>
            <span class="role-tag"><%= currentUser != null ? currentUser.getRole() : "" %></span>
            <a class="logout" href="logout">Log Out</a>
        </div>
    </header>

    <div class="container">
        <div class="section-heading">
            <span class="eyebrow">Account</span>
        </div>

        <section class="login-card" style="margin: 0 auto;">
            <h1>Change Password</h1>
            <p class="subtitle">Update your account password</p>

            <% if (request.getAttribute("error") != null) { %>
                <div class="error-box"><%= request.getAttribute("error") %></div>
            <% } %>
            <% if (request.getAttribute("success") != null) { %>
                <div class="error-box" style="background:#e4f3ec; color:#2f7a5c; border-color:#bfe3cf;"><%= request.getAttribute("success") %></div>
            <% } %>

            <form action="change-password" method="post">
                <label for="oldPassword">Current Password</label>
                <div class="field">
                    <svg class="field-icon" viewBox="0 0 24 24" width="18" height="18" fill="none"><rect x="5" y="10.5" width="14" height="9.5" rx="2" stroke="#9aa3b2" stroke-width="1.8"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" stroke="#9aa3b2" stroke-width="1.8" stroke-linecap="round"/></svg>
                    <input type="password" id="oldPassword" name="oldPassword" placeholder="Enter current password" required>
                    <button type="button" class="toggle-eye" data-target="oldPassword" aria-label="Show password">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="none"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" stroke="#9aa3b2" stroke-width="1.8" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="#9aa3b2" stroke-width="1.8"/></svg>
                    </button>
                </div>

                <label for="newPassword">New Password</label>
                <div class="field">
                    <svg class="field-icon" viewBox="0 0 24 24" width="18" height="18" fill="none"><rect x="5" y="10.5" width="14" height="9.5" rx="2" stroke="#9aa3b2" stroke-width="1.8"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" stroke="#9aa3b2" stroke-width="1.8" stroke-linecap="round"/></svg>
                    <input type="password" id="newPassword" name="newPassword" placeholder="Enter new password" required minlength="6">
                    <button type="button" class="toggle-eye" data-target="newPassword" aria-label="Show password">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="none"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" stroke="#9aa3b2" stroke-width="1.8" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="#9aa3b2" stroke-width="1.8"/></svg>
                    </button>
                </div>

                <label for="confirmPassword">Confirm New Password</label>
                <div class="field">
                    <svg class="field-icon" viewBox="0 0 24 24" width="18" height="18" fill="none"><rect x="5" y="10.5" width="14" height="9.5" rx="2" stroke="#9aa3b2" stroke-width="1.8"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" stroke="#9aa3b2" stroke-width="1.8" stroke-linecap="round"/></svg>
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-enter new password" required minlength="6">
                    <button type="button" class="toggle-eye" data-target="confirmPassword" aria-label="Show password">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="none"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" stroke="#9aa3b2" stroke-width="1.8" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="#9aa3b2" stroke-width="1.8"/></svg>
                    </button>
                </div>

                <button type="submit" class="btn-primary">
                    Update Password
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none"><path d="M5 12h14M13 6l6 6-6 6" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </button>
            </form>

            <p class="subtitle" style="margin-top:12px;"><a href="<%= dashboardPath(currentUser) %>" style="color:#e0342c; font-weight:600; text-decoration:none;">&larr; Back to Dashboard</a></p>
        </section>
    </div>
    <footer class="scms-footer">Ambulance Management System</footer>
    <script>
        document.querySelectorAll('.toggle-eye').forEach(function (btn) {
            btn.addEventListener('click', function () {
                var input = document.getElementById(this.getAttribute('data-target'));
                var isHidden = input.type === 'password';
                input.type = isHidden ? 'text' : 'password';
                this.setAttribute('aria-label', isHidden ? 'Hide password' : 'Show password');
            });
        });
    </script>
</body>
</html>
<%!
    private String dashboardPath(User user) {
        if (user == null) return "login.jsp";
        switch (user.getRole()) {
            case "ADMIN":          return "dashboard_admin.jsp";
            case "DISPATCHER":     return "dashboard_dispatcher.jsp";
            case "DRIVER":         return "dashboard_driver.jsp";
            case "HOSPITAL_STAFF": return "dashboard_hospital.jsp";
            default:               return "login.jsp";
        }
    }
%>
