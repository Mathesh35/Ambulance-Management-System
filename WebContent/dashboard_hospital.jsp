<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
    if (currentUser == null || !"HOSPITAL_STAFF".equals(currentUser.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    String initials = "H";
    if (currentUser.getFullName() != null && currentUser.getFullName().length() > 0) {
        String[] parts = currentUser.getFullName().trim().split("\\s+");
        initials = parts.length > 1
            ? ("" + parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
            : ("" + parts[0].charAt(0)).toUpperCase();
    }
    String today = new SimpleDateFormat("EEEE, d MMMM yyyy").format(new Date());
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Hospital Staff Dashboard | Ambulance Management System</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="admin-shell">

        <aside class="sidebar">
            <div class="sidebar-brand">
                <span class="crate"></span>
                <div class="sidebar-brand-text">
                    <strong>Ambulance Mgmt</strong>
                    <span>Hospital Console</span>
                </div>
            </div>

            <nav class="sidebar-nav">
                <a class="nav-item active" href="dashboard_hospital.jsp">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/><rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/></svg>
                    <span>Dashboard</span>
                </a>
                <a class="nav-item" href="change_password.jsp">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    <span>Change Password</span>
                </a>

                <a class="nav-item" href="hospital/patients">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21V5a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v16"/><path d="M9 9h1M9 13h1M14 9h1M14 13h1M9 21v-4h6v4"/></svg>
                    <span>Patient Records</span>
                </a>
            </nav>

            <div class="sidebar-foot">
                <div class="sidebar-avatar"><%= initials %></div>
                <div class="sidebar-foot-text">
                    <strong><%= currentUser.getFullName() %></strong>
                    <span>Hospital Staff</span>
                </div>
                <a class="sidebar-logout" href="logout" title="Log out">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                </a>
            </div>
        </aside>

        <main class="admin-main">
            <div class="admin-topbar">
                <div>
                    <span class="eyebrow">Dashboard</span>
                    <h2>Welcome back, <%= currentUser.getFullName() %></h2>
                </div>
                <span class="admin-date"><%= today %></span>
            </div>

            <div class="quick-section" style="padding-top: 22px;">
                <span class="eyebrow">Quick Access</span>
                <div class="quick-list">
                    <a class="quick-card" href="change_password.jsp">
                        <div class="quick-icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </div>
                        <div class="quick-card-body">
                            <h4>Change Password</h4>
                            <p>Update your own account password.</p>
                        </div>
                        <svg class="quick-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>

                    <a class="quick-card" href="hospital/patients">
                        <div class="quick-icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21V5a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v16"/><path d="M9 9h1M9 13h1M14 9h1M14 13h1M9 21v-4h6v4"/></svg>
                        </div>
                        <div class="quick-card-body">
                            <h4>Patient Records</h4>
                            <p>View patient details and update medical history (FR7).</p>
                        </div>
                        <svg class="quick-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
