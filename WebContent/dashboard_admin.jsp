<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%@ page import="com.ambulance.dao.UserDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
    if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Real counts pulled from the users table (no placeholder numbers)
    int totalUsers = 0, dispatchers = 0, drivers = 0, hospitalStaff = 0;
    try {
        List<User> allUsers = new UserDAO().getAllUsers();
        totalUsers = allUsers.size();
        for (User u : allUsers) {
            if ("DISPATCHER".equals(u.getRole())) dispatchers++;
            else if ("DRIVER".equals(u.getRole())) drivers++;
            else if ("HOSPITAL_STAFF".equals(u.getRole())) hospitalStaff++;
        }
    } catch (Exception e) {
        // stat cards will just show 0s if this fails; page still renders
    }

    String initials = "A";
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
    <title>Admin Dashboard | Ambulance Management System</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="admin-shell">

        <aside class="sidebar">
            <div class="sidebar-brand">
                <span class="crate"></span>
                <div class="sidebar-brand-text">
                    <strong>Ambulance Mgmt</strong>
                    <span>Admin Console</span>
                </div>
            </div>

            <nav class="sidebar-nav">
                <a class="nav-item active" href="dashboard_admin.jsp">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/><rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/></svg>
                    <span>Dashboard</span>
                </a>
                <a class="nav-item" href="admin/users">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    <span>Manage Users</span>
                </a>
                <a class="nav-item" href="admin/ambulances">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2"/><path d="M14 9h4l4 4v4a1 1 0 0 1-1 1h-2"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/></svg>
                    <span>Ambulance Management</span>
                </a>
                <a class="nav-item" href="admin/drivers">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 3.5-7 8-7s8 3 8 7"/></svg>
                    <span>Driver Management</span>
                </a>
                <a class="nav-item" href="change_password.jsp">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    <span>Change Password</span>
                </a>

            </nav>

            <div class="sidebar-foot">
                <div class="sidebar-avatar"><%= initials %></div>
                <div class="sidebar-foot-text">
                    <strong><%= currentUser.getFullName() %></strong>
                    <span>Administrator</span>
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

            <div class="stat-grid">
                <div class="stat-card">
                    <div class="stat-icon">
                        <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    </div>
                    <div>
                        <div class="stat-value"><%= totalUsers %></div>
                        <div class="stat-label">Total Accounts</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                    </div>
                    <div>
                        <div class="stat-value"><%= dispatchers %></div>
                        <div class="stat-label">Dispatchers</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 3.5-7 8-7s8 3 8 7"/></svg>
                    </div>
                    <div>
                        <div class="stat-value"><%= drivers %></div>
                        <div class="stat-label">Drivers</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21V5a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v16"/><path d="M9 9h1M9 13h1M14 9h1M14 13h1M9 21v-4h6v4"/></svg>
                    </div>
                    <div>
                        <div class="stat-value"><%= hospitalStaff %></div>
                        <div class="stat-label">Hospital Staff</div>
                    </div>
                </div>
            </div>

            <div class="quick-section">
                <span class="eyebrow">Quick Access</span>
                <div class="quick-list">
                    <a class="quick-card" href="admin/users">
                        <div class="quick-icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        </div>
                        <div class="quick-card-body">
                            <h4>Manage Users</h4>
                            <p>Add, edit, and remove accounts for Admins, Dispatchers, Drivers, and Hospital Staff.</p>
                        </div>
                        <svg class="quick-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>

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

                    <a class="quick-card" href="admin/ambulances">
                        <div class="quick-icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2"/><path d="M14 9h4l4 4v4a1 1 0 0 1-1 1h-2"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/></svg>
                        </div>
                        <div class="quick-card-body">
                            <h4>Ambulance Management</h4>
                            <p>Add, update, delete, and view ambulance status (FR2).</p>
                        </div>
                        <svg class="quick-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>

                    <a class="quick-card" href="admin/drivers">
                        <div class="quick-icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 3.5-7 8-7s8 3 8 7"/></svg>
                        </div>
                        <div class="quick-card-body">
                            <h4>Driver Management</h4>
                            <p>Register, verify, assign, and remove drivers (FR3).</p>
                        </div>
                        <svg class="quick-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
