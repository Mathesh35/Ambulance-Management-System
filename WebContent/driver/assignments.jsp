<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%@ page import="com.ambulance.model.Driver" %>
<%@ page import="com.ambulance.model.Ambulance" %>
<%@ page import="com.ambulance.model.EmergencyRequest" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
    if (currentUser == null || !"DRIVER".equals(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    Driver driver = (Driver) request.getAttribute("driver");
    Ambulance ambulance = (Ambulance) request.getAttribute("ambulance");
    List<EmergencyRequest> assignments = (List<EmergencyRequest>) request.getAttribute("assignments");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Assignments | Ambulance Management System</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        /* Page-specific styles only - reuses existing color palette (literal values from style.css), no global style.css edits, no new palette introduced */

        .page-head { display: flex; align-items: flex-end; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 18px; }
        .page-head h2 { font-size: 21px; font-weight: 700; color: #17213a; margin: 6px 0 0; }

        .status-card { background: #fff; border: 1px solid #ebedf1; border-radius: 14px; padding: 22px 24px; margin-bottom: 20px; box-shadow: 0 6px 18px rgba(20,30,50,0.06); }
        .status-card h4 { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; font-size: 16px; color:#17213a; }
        .status-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 14px; margin-bottom: 16px; }
        .status-grid .field label { display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em; color: #9aa2b1; margin-bottom: 4px; }
        .status-grid .field span { display: block; font-size: 14px; color: #1b2436; }
        .form-row { display: grid; grid-template-columns: 2fr auto; gap: 14px; align-items: end; }
        .form-row .field { margin-top: 0; }
        .form-row label { display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #2b3448; margin-bottom: 5px; }
        .form-row input { width: 100%; height: 40px; border: 1px solid #e2e5eb; border-radius: 10px; background: #fafbfc; padding: 0 14px; font-size: 14px; color: #1b2436; box-sizing: border-box; }
        .form-row input:focus { outline: none; border-color: #e0342c; background: #fff; }

        table.asg-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 6px 18px rgba(20,30,50,0.06); border: 1px solid #ebedf1; }
        table.asg-table th, table.asg-table td { padding: 12px 16px; text-align: left; font-size: 13px; border-bottom: 1px solid #ebedf1; }
        table.asg-table th { background: #f9fafb; text-transform: uppercase; letter-spacing: 0.04em; font-size: 11px; color: #5b6472; }
        table.asg-table tbody tr:nth-child(even) { background: #fbfbfd; }
        table.asg-table tr:last-child td { border-bottom: none; }
        table.asg-table td.notes-cell { max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

        .status-pill { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; letter-spacing: 0.03em; text-transform: uppercase; }
        .status-pill::before { content: ""; width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .status-PENDING { background: #fff2df; color: #b3690a; }
        .status-ASSIGNED { background: #e6eefc; color: #1d5fd6; }
        .status-COMPLETED { background: #e5f7ec; color: #1c8a4c; }
        .status-CANCELLED { background: #fde8e7; color: #c62c26; }

        .priority-pill { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; letter-spacing: 0.03em; text-transform: uppercase; }
        .priority-pill::before { content: ""; width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .priority-LOW { background: #eef1f6; color: #5b6472; }
        .priority-MEDIUM { background: #fff2df; color: #b3690a; }
        .priority-HIGH { background: #ffe6de; color: #d4531f; }
        .priority-CRITICAL { background: #fde8e7; color: #c62c26; }

        .btn-complete { display: inline-flex; align-items: center; gap: 6px; background: #1c8a4c; color: #fff; border: none; border-radius: 8px; padding: 7px 12px; font-size: 12px; font-weight: 600; cursor: pointer; }
        .btn-complete:hover { opacity: 0.9; }

        .empty-row td { text-align: center; padding: 26px; color: #9aa2b1; font-size: 13px; }
    </style>
</head>
<body>
    <header class="topbar">
        <span class="brand-mark"><span class="crate"></span>Ambulance Management System</span>
        <div class="user-info">
            <span><%= currentUser.getFullName() %></span>
            <span class="role-tag">DRIVER</span>
            <a class="logout" href="../logout">Log Out</a>
        </div>
    </header>

    <div class="container">
        <div class="page-head">
            <div class="section-heading" style="margin-bottom:0;">
                <span class="eyebrow">Driver &rsaquo; My Assignments</span>
                <h2>My Assignments &amp; Status</h2>
            </div>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-box" style="margin: 0 0 16px;"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (driver != null) { %>
        <div class="status-card">
            <h4>
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                Update Status (FR5)
            </h4>

            <div class="status-grid">
                <div class="field"><label>Driver Status</label><span class="status-pill status-<%= driver.getStatus() %>"><%= driver.getStatus() %></span></div>
                <div class="field"><label>Assigned Ambulance</label><span><%= ambulance != null ? ambulance.getVehicleNumber() : "None yet - contact admin" %></span></div>
                <div class="field"><label>Ambulance Status</label><span><%= ambulance != null ? ambulance.getStatus() : "-" %></span></div>
                <div class="field"><label>Current Location</label><span><%= ambulance != null && ambulance.getCurrentLocation() != null ? ambulance.getCurrentLocation() : "-" %></span></div>
            </div>

            <% if (ambulance != null) { %>
            <form action="assignments" method="post">
                <input type="hidden" name="action" value="updateLocation">
                <div class="form-row">
                    <div class="field">
                        <label>Update Live Location</label>
                        <input type="text" name="location" placeholder="e.g. On MG Road, 2 km from patient" required>
                    </div>
                    <div>
                        <button type="submit" class="btn-primary" style="margin-top:0;">Update Location</button>
                    </div>
                </div>
            </form>
            <% } %>
        </div>
        <% } %>

        <h4 style="font-size:15px; color:#17213a; margin-bottom:10px;">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px; margin-right:4px;"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            Emergency Requests Assigned to Me (FR4)
        </h4>

        <table class="asg-table">
            <thead>
                <tr>
                    <th>ID</th><th>Patient</th><th>Location</th><th>Condition</th><th>Priority</th><th>Status</th><th>Assigned At</th><th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% if (assignments != null && !assignments.isEmpty()) { for (EmergencyRequest r : assignments) {
                    String cond = r.getCondition() != null && !r.getCondition().isEmpty() ? r.getCondition() : "-";
                    boolean active = "ASSIGNED".equals(r.getStatus());
                %>
                <tr>
                    <td><%= r.getId() %></td>
                    <td><%= r.getPatientName() %></td>
                    <td><%= r.getLocation() %></td>
                    <td class="notes-cell" title="<%= cond %>"><%= cond %></td>
                    <td><span class="priority-pill priority-<%= r.getPriority() %>"><%= r.getPriority() %></span></td>
                    <td><span class="status-pill status-<%= r.getStatus() %>"><%= r.getStatus() %></span></td>
                    <td><%= r.getAssignedAt() != null ? r.getAssignedAt() : "-" %></td>
                    <td>
                        <% if (active) { %>
                            <form action="assignments" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="complete">
                                <input type="hidden" name="id" value="<%= r.getId() %>">
                                <button type="submit" class="btn-complete"
                                        onclick="return confirm('Mark this run as completed? This frees your ambulance back to AVAILABLE.');">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                    Mark Completed
                                </button>
                            </form>
                        <% } else { %>
                            &mdash;
                        <% } %>
                    </td>
                </tr>
                <% } } else { %>
                <tr class="empty-row"><td colspan="8">No emergency requests have been assigned to you yet.</td></tr>
                <% } %>
            </tbody>
        </table>

        <p style="margin-top:20px;"><a href="../dashboard_driver.jsp" style="color:#5b6472; font-size:13px;">&larr; Back to Dashboard</a></p>
    </div>
    <footer class="scms-footer">Ambulance Management System</footer>
</body>
</html>
