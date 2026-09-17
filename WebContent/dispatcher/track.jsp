<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%@ page import="com.ambulance.model.EmergencyRequest" %>
<%@ page import="com.ambulance.servlet.TrackingServlet.TrackingInfo" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
    if (currentUser == null || !"DISPATCHER".equals(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<TrackingInfo> trackingList = (List<TrackingInfo>) request.getAttribute("trackingList");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Track Ambulance | Ambulance Management System</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        /* Page-specific styles only - reuses existing color palette (literal values from style.css), no global style.css edits, no new palette introduced */

        .page-head { display: flex; align-items: flex-end; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 18px; }
        .page-head h2 { font-size: 21px; font-weight: 700; color: #17213a; margin: 6px 0 0; }

        .track-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 18px; }

        .track-card { background: #fff; border: 1px solid #ebedf1; border-radius: 14px; padding: 20px 22px; box-shadow: 0 6px 18px rgba(20,30,50,0.06); }
        .track-card-head { display: flex; align-items: flex-start; justify-content: space-between; gap: 10px; margin-bottom: 14px; }
        .track-patient { font-size: 15px; font-weight: 700; color: #17213a; }
        .track-location { font-size: 12.5px; color: #5b6472; margin-top: 2px; }

        .priority-pill { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; letter-spacing: 0.03em; text-transform: uppercase; flex-shrink: 0; }
        .priority-pill::before { content: ""; width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .priority-LOW { background: #eef1f6; color: #5b6472; }
        .priority-MEDIUM { background: #fff2df; color: #b3690a; }
        .priority-HIGH { background: #ffe6de; color: #d4531f; }
        .priority-CRITICAL { background: #fde8e7; color: #c62c26; }

        .track-meta { display: flex; align-items: center; gap: 8px; font-size: 12.5px; color: #2b3448; margin-bottom: 4px; }
        .track-meta svg { color: #9aa2b1; flex-shrink: 0; }

        .track-progress-wrap { margin-top: 16px; }
        .track-progress-labels { display: flex; justify-content: space-between; font-size: 11.5px; color: #8890a0; margin-bottom: 6px; }
        .track-progress-labels .eta-remaining { font-weight: 700; color: #e0342c; }
        .track-progress-bar { height: 8px; background: #eef1f6; border-radius: 999px; overflow: hidden; }
        .track-progress-fill { height: 100%; background: linear-gradient(90deg, #e0342c, #ff6b5f); border-radius: 999px; width: 0%; transition: width 1s linear; }
        .track-progress-fill.arrived { background: #1c8a4c; }

        .track-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 16px; }
        .track-status { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em; color: #5b6472; }
        .btn-arrived { display: inline-flex; align-items: center; gap: 6px; background: #1c8a4c; color: #fff; border: none; border-radius: 9px; padding: 8px 14px; font-size: 12.5px; font-weight: 600; cursor: pointer; text-decoration: none; }
        .btn-arrived:hover { transform: translateY(-1px); }

        .empty-state { text-align: center; padding: 40px 20px; color: #8890a0; }
        .empty-state svg { color: #c3c8d1; margin-bottom: 10px; }
        .empty-state p { font-size: 13.5px; }
    </style>
</head>
<body>
    <header class="topbar">
        <span class="brand-mark"><span class="crate"></span>Ambulance Management System</span>
        <div class="user-info">
            <span><%= currentUser.getFullName() %></span>
            <span class="role-tag">DISPATCHER</span>
            <a class="logout" href="../logout">Log Out</a>
        </div>
    </header>

    <div class="container">
        <div class="page-head">
            <div class="section-heading" style="margin-bottom:0;">
                <span class="eyebrow">Dispatcher &rsaquo; Track Ambulance</span>
                <h2>Track Ambulance</h2>
            </div>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-box" style="margin: 0 0 16px;"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (trackingList == null || trackingList.isEmpty()) { %>
            <div class="empty-state">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                <p>No ambulances are currently en route. Assigned runs will show up here.</p>
            </div>
        <% } else { %>
        <div class="track-grid">
            <% for (TrackingInfo t : trackingList) {
                EmergencyRequest r = t.request;
            %>
            <div class="track-card" data-assigned-at="<%= t.assignedAtMillis %>" data-eta-ms="<%= t.etaMinutes * 60000L %>">
                <div class="track-card-head">
                    <div>
                        <div class="track-patient"><%= r.getPatientName() %></div>
                        <div class="track-location"><%= r.getLocation() %></div>
                    </div>
                    <span class="priority-pill priority-<%= r.getPriority() %>"><%= r.getPriority() %></span>
                </div>

                <div class="track-meta">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2"/><path d="M14 9h4l4 4v4a1 1 0 0 1-1 1h-2"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/></svg>
                    <span><%= r.getAssignedVehicleNumber() != null ? r.getAssignedVehicleNumber() : "Unassigned" %><%= r.getAssignedDriverName() != null ? " &middot; " + r.getAssignedDriverName() : "" %></span>
                </div>
                <div class="track-meta">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    <span><%= String.format("%.1f", t.distanceKm) %> km route &middot; <%= t.etaMinutes %> min estimated</span>
                </div>

                <div class="track-progress-wrap">
                    <div class="track-progress-labels">
                        <span>En route</span>
                        <span class="eta-remaining">Calculating...</span>
                    </div>
                    <div class="track-progress-bar">
                        <div class="track-progress-fill"></div>
                    </div>
                </div>

                <div class="track-footer">
                    <span class="track-status">Ambulance dispatched</span>
                    <a class="btn-arrived" href="track?action=arrived&id=<%= r.getId() %>">
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        Mark Arrived
                    </a>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>

        <p style="margin-top:20px;"><a href="../dashboard_dispatcher.jsp" style="color:#5b6472; font-size:13px;">&larr; Back to Dashboard</a></p>
    </div>
    <footer class="scms-footer">Ambulance Management System</footer>

    <script>
        // Live progress + ETA countdown per card, driven purely by client time vs. assigned-at timestamp.
        function formatRemaining(ms) {
            if (ms <= 0) return 'Arriving now';
            var totalSeconds = Math.floor(ms / 1000);
            var minutes = Math.floor(totalSeconds / 60);
            var seconds = totalSeconds % 60;
            return minutes + ':' + (seconds < 10 ? '0' : '') + seconds + ' remaining';
        }

        function tick() {
            document.querySelectorAll('.track-card').forEach(function (card) {
                var assignedAt = parseInt(card.getAttribute('data-assigned-at'), 10);
                var etaMs = parseInt(card.getAttribute('data-eta-ms'), 10);
                var elapsed = Date.now() - assignedAt;
                var remaining = etaMs - elapsed;
                var percent = Math.max(0, Math.min(100, (elapsed / etaMs) * 100));

                var fill = card.querySelector('.track-progress-fill');
                var label = card.querySelector('.eta-remaining');
                fill.style.width = percent + '%';
                label.textContent = formatRemaining(remaining);
                if (percent >= 100) {
                    fill.classList.add('arrived');
                    label.textContent = 'Arriving now';
                }
            });
        }

        tick();
        setInterval(tick, 1000);
    </script>
</body>
</html>
