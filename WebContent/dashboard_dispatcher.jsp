<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
    if (currentUser == null || !"DISPATCHER".equals(currentUser.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    String initials = "D";
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
    <title>Dispatcher Dashboard | Ambulance Management System</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="admin-shell">

        <aside class="sidebar">
            <div class="sidebar-brand">
                <span class="crate"></span>
                <div class="sidebar-brand-text">
                    <strong>Ambulance Mgmt</strong>
                    <span>Dispatch Console</span>
                </div>
            </div>

            <nav class="sidebar-nav">
                <a class="nav-item active" href="dashboard_dispatcher.jsp">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/><rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/></svg>
                    <span>Dashboard</span>
                </a>
                <a class="nav-item" href="change_password.jsp">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    <span>Change Password</span>
                </a>

                <a class="nav-item" href="dispatcher/requests">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                    <span>Emergency Requests</span>
                </a>

                <a class="nav-item" href="dispatcher/allocate">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2"/><path d="M14 9h4l4 4v4a1 1 0 0 1-1 1h-2"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/></svg>
                    <span>Assign Ambulance</span>
                </a>
                <a class="nav-item" href="dispatcher/track">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                    <span>Track Ambulance</span>
                </a>
            </nav>

            <div class="sidebar-foot">
                <div class="sidebar-avatar"><%= initials %></div>
                <div class="sidebar-foot-text">
                    <strong><%= currentUser.getFullName() %></strong>
                    <span>Dispatcher</span>
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

                    <a class="quick-card" href="dispatcher/requests">
                        <div class="quick-icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                        </div>
                        <div class="quick-card-body">
                            <h4>Emergency Requests</h4>
                            <p>Log and manage patient / emergency requests (FR4).</p>
                        </div>
                        <svg class="quick-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>

                    <a class="quick-card" href="dispatcher/allocate">
                        <div class="quick-icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2"/><path d="M14 9h4l4 4v4a1 1 0 0 1-1 1h-2"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/></svg>
                        </div>
                        <div class="quick-card-body">
                            <h4>Assign Ambulance</h4>
                            <p>Identify and assign the nearest available ambulance and driver (FR5).</p>
                        </div>
                        <svg class="quick-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>

                    <a class="quick-card" href="dispatcher/track">
                        <div class="quick-icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                        </div>
                        <div class="quick-card-body">
                            <h4>Track Ambulance</h4>
                            <p>Live progress and ETA tracking for ambulances en route (FR5).</p>
                        </div>
                        <svg class="quick-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
