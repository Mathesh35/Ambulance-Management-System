<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%@ page import="com.ambulance.model.EmergencyRequest" %>
<%@ page import="com.ambulance.servlet.AllocationServlet.AmbulanceOption" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
    if (currentUser == null || !"DISPATCHER".equals(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<EmergencyRequest> pendingRequests = (List<EmergencyRequest>) request.getAttribute("pendingRequests");
    Map<Integer, List<AmbulanceOption>> optionsByRequest = (Map<Integer, List<AmbulanceOption>>) request.getAttribute("optionsByRequest");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Assign Ambulance | Ambulance Management System</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        /* Page-specific styles only - reuses existing color palette (literal values from style.css), no global style.css edits, no new palette introduced */

        .page-head { display: flex; align-items: flex-end; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 18px; }
        .page-head h2 { font-size: 21px; font-weight: 700; color: #17213a; margin: 6px 0 0; }

        .toolbar { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 14px; }
        .search-box { position: relative; flex: 1; min-width: 220px; max-width: 340px; }
        .search-box svg { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #9aa2b1; }
        .search-box input { width: 100%; height: 38px; border: 1px solid #e2e5eb; border-radius: 10px; background: #fff; padding: 0 14px 0 36px; font-size: 13.5px; color: #1b2436; box-sizing: border-box; }

        table.alloc-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 6px 18px rgba(20,30,50,0.06); border: 1px solid #ebedf1; }
        table.alloc-table th, table.alloc-table td { padding: 12px 16px; text-align: left; font-size: 13px; border-bottom: 1px solid #ebedf1; vertical-align: middle; }
        table.alloc-table th { background: #f9fafb; text-transform: uppercase; letter-spacing: 0.04em; font-size: 11px; color: #5b6472; }
        table.alloc-table tbody tr:nth-child(even) { background: #fbfbfd; }
        table.alloc-table tbody tr:hover { background: #fef4f3; }
        table.alloc-table tr:last-child td { border-bottom: none; }

        .priority-pill { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; letter-spacing: 0.03em; text-transform: uppercase; }
        .priority-pill::before { content: ""; width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .priority-LOW { background: #eef1f6; color: #5b6472; }
        .priority-MEDIUM { background: #fff2df; color: #b3690a; }
        .priority-HIGH { background: #ffe6de; color: #d4531f; }
        .priority-CRITICAL { background: #fde8e7; color: #c62c26; }

        .nearest-badge { display: inline-flex; flex-direction: column; gap: 1px; }
        .nearest-badge strong { font-size: 13px; color: #17213a; }
        .nearest-badge span { font-size: 11.5px; color: #5b6472; }
        .no-ambulance { font-size: 12.5px; color: #c62c26; font-style: italic; }

        .assign-form { display: flex; align-items: center; gap: 6px; }
        .assign-select { height: 32px; border: 1px solid #e2e5eb; border-radius: 8px; background: #fff; padding: 0 8px; font-size: 12px; color: #2b3448; max-width: 190px; }
        .assign-select:disabled { background: #f4f5f7; color: #a7adb9; cursor: not-allowed; }

        .icon-btn { width: 30px; height: 30px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; border: 1px solid #e2e5eb; background: #fff; color: #5b6472; cursor: pointer; text-decoration: none; flex-shrink: 0; }
        .icon-btn:hover { background: #f4f5f7; }
        .icon-btn.verify:hover { color: #1c8a4c; border-color: #b9e6cb; }

        .empty-row td { text-align: center; padding: 26px; color: #9aa2b1; font-size: 13px; }
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
                <span class="eyebrow">Dispatcher &rsaquo; Assign Ambulance</span>
                <h2>Assign Ambulance</h2>
            </div>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-box" style="margin: 0 0 16px;"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (pendingRequests == null || pendingRequests.isEmpty()) { %>
            <div class="empty-state">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                <p>No pending requests right now - every logged emergency has an ambulance assigned.</p>
            </div>
        <% } else { %>

        <div class="toolbar">
            <div class="search-box">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" id="searchInput" placeholder="Search by patient or location">
            </div>
        </div>

        <table class="alloc-table" id="allocTable">
            <thead>
                <tr>
                    <th>Patient</th><th>Priority</th><th>Location</th><th>Nearest Ambulance</th><th>Assign</th>
                </tr>
            </thead>
            <tbody id="allocTableBody">
                <% for (EmergencyRequest r : pendingRequests) {
                    List<AmbulanceOption> options = optionsByRequest.get(r.getId());
                %>
                <tr data-search="<%= (r.getPatientName() + " " + r.getLocation()).toLowerCase() %>">
                    <td>
                        <div style="font-weight:600; color:#17213a;"><%= r.getPatientName() %></div>
                        <div style="font-size:11.5px; color:#8890a0;"><%= r.getCondition() != null ? r.getCondition() : "" %></div>
                    </td>
                    <td><span class="priority-pill priority-<%= r.getPriority() %>"><%= r.getPriority() %></span></td>
                    <td><%= r.getLocation() %></td>
                    <td>
                        <% if (options != null && !options.isEmpty()) {
                            AmbulanceOption nearest = options.get(0);
                        %>
                            <div class="nearest-badge">
                                <strong><%= nearest.ambulance.getVehicleNumber() %></strong>
                                <span><%= String.format("%.1f km", nearest.distanceKm) %> &middot; <%= nearest.etaMinutes %> min ETA</span>
                            </div>
                        <% } else { %>
                            <span class="no-ambulance">No ambulance available</span>
                        <% } %>
                    </td>
                    <td>
                        <% if (options != null && !options.isEmpty()) { %>
                            <form class="assign-form" action="allocate" method="post">
                                <input type="hidden" name="action" value="assign">
                                <input type="hidden" name="requestId" value="<%= r.getId() %>">
                                <select class="assign-select" name="ambulanceId">
                                    <% for (AmbulanceOption o : options) { %>
                                        <option value="<%= o.ambulance.getId() %>">
                                            <%= o.ambulance.getVehicleNumber() %> (<%= String.format("%.1f", o.distanceKm) %> km, <%= o.etaMinutes %> min)
                                        </option>
                                    <% } %>
                                </select>
                                <button type="submit" class="icon-btn verify" title="Assign selected ambulance">
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                </button>
                            </form>
                        <% } else { %>
                            <select class="assign-select" disabled><option>No ambulance</option></select>
                        <% } %>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>

        <p style="margin-top:20px;"><a href="../dashboard_dispatcher.jsp" style="color:#5b6472; font-size:13px;">&larr; Back to Dashboard</a></p>
    </div>
    <footer class="scms-footer">Ambulance Management System</footer>

    <script>
        // Search (client-side, works on the rows already rendered by the JSP)
        var allRows = Array.prototype.slice.call(document.querySelectorAll('#allocTableBody tr'));
        var searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', function () {
                var term = searchInput.value.trim().toLowerCase();
                allRows.forEach(function (row) {
                    var matches = !term || row.getAttribute('data-search').indexOf(term) !== -1;
                    row.style.display = matches ? '' : 'none';
                });
            });
        }
    </script>
</body>
</html>
