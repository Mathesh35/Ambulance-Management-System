<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%@ page import="com.ambulance.model.Driver" %>
<%@ page import="com.ambulance.model.Ambulance" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
    if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<Driver> drivers = (List<Driver>) request.getAttribute("drivers");
    List<Ambulance> ambulances = (List<Ambulance>) request.getAttribute("ambulances");
    List<com.ambulance.model.User> driverUsers = (List<com.ambulance.model.User>) request.getAttribute("driverUsers");
    Driver editDriver = (Driver) request.getAttribute("editDriver");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Driver Management | Ambulance Management System</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        /* Page-specific styles only - reuses existing color palette (literal values from style.css), no global style.css edits, no new palette introduced */

        .page-head { display: flex; align-items: flex-end; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 18px; }
        .page-head h2 { font-size: 21px; font-weight: 700; color: #17213a; margin: 6px 0 0; }
        .btn-add { display: inline-flex; align-items: center; gap: 8px; background: #e0342c; color: #fff; border: none; border-radius: 10px; padding: 11px 18px; font-size: 14px; font-weight: 600; cursor: pointer; box-shadow: 0 10px 20px rgba(224,52,44,0.28); text-decoration: none; }
        .btn-add:hover { transform: translateY(-1px); }

        .form-card { background: #fff; border: 1px solid #ebedf1; border-radius: 14px; padding: 22px 24px; margin-bottom: 20px; box-shadow: 0 6px 18px rgba(20,30,50,0.06); }
        .form-card.collapsed { display: none; }
        .form-card h4 { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; font-size: 16px; color:#17213a; }
        .form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; align-items: end; }
        .form-row .field { margin-top: 0; }
        .form-row label { display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #2b3448; margin-bottom: 5px; }
        .form-row select, .form-row input { width: 100%; height: 40px; border: 1px solid #e2e5eb; border-radius: 10px; background: #fafbfc; padding: 0 14px; font-size: 14px; color: #1b2436; box-sizing: border-box; }
        .form-row select:focus, .form-row input:focus { outline: none; border-color: #e0342c; background: #fff; }

        .toolbar { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 14px; }
        .search-box { position: relative; flex: 1; min-width: 220px; max-width: 340px; }
        .search-box svg { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #9aa2b1; }
        .search-box input { width: 100%; height: 38px; border: 1px solid #e2e5eb; border-radius: 10px; background: #fff; padding: 0 14px 0 36px; font-size: 13.5px; color: #1b2436; box-sizing: border-box; }
        .filter-group { display: flex; gap: 10px; }
        .filter-group select { height: 38px; border: 1px solid #e2e5eb; border-radius: 10px; background: #fff; padding: 0 12px; font-size: 13px; color: #2b3448; }

        table.drv-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 6px 18px rgba(20,30,50,0.06); border: 1px solid #ebedf1; }
        table.drv-table th, table.drv-table td { padding: 12px 16px; text-align: left; font-size: 13px; border-bottom: 1px solid #ebedf1; }
        table.drv-table th { background: #f9fafb; text-transform: uppercase; letter-spacing: 0.04em; font-size: 11px; color: #5b6472; }
        table.drv-table tbody tr:nth-child(even) { background: #fbfbfd; }
        table.drv-table tbody tr:hover { background: #fef4f3; }
        table.drv-table tr:last-child td { border-bottom: none; }

        .status-pill { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; letter-spacing: 0.03em; text-transform: uppercase; }
        .status-pill::before { content: ""; width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .status-PENDING { background: #fff2df; color: #b3690a; }
        .status-VERIFIED { background: #e5f7ec; color: #1c8a4c; }
        .status-REJECTED { background: #fde8e7; color: #c62c26; }

        .assign-select { height: 30px; border: 1px solid #e2e5eb; border-radius: 8px; background: #fff; padding: 0 8px; font-size: 12px; color: #2b3448; }
        .assign-select:disabled { background: #f4f5f7; color: #a7adb9; cursor: not-allowed; }

        .action-icons { display: flex; gap: 6px; align-items: center; }
        .icon-btn { width: 30px; height: 30px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; border: 1px solid #e2e5eb; background: #fff; color: #5b6472; cursor: pointer; text-decoration: none; }
        .icon-btn:hover { background: #f4f5f7; }
        .icon-btn.verify:hover { color: #1c8a4c; border-color: #b9e6cb; }
        .icon-btn.reject:hover { color: #c62c26; border-color: #f5c2bf; }
        .icon-btn.edit:hover { color: #b3690a; border-color: #f3d6a8; }
        .icon-btn.delete:hover { color: #c62c26; border-color: #f5c2bf; }

        .table-footer { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px; padding: 12px 4px 0; font-size: 12.5px; color: #5b6472; }
        .pagination { display: flex; align-items: center; gap: 6px; }
        .pagination button { min-width: 30px; height: 30px; border: 1px solid #e2e5eb; background: #fff; color: #2b3448; border-radius: 8px; cursor: pointer; font-size: 12.5px; }
        .pagination button.active { background: #e0342c; border-color: #e0342c; color: #fff; }
        .pagination button:disabled { opacity: 0.4; cursor: not-allowed; }

        .empty-row td { text-align: center; padding: 26px; color: #9aa2b1; font-size: 13px; }
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
        <div class="page-head">
            <div class="section-heading" style="margin-bottom:0;">
                <span class="eyebrow">Admin &rsaquo; Driver Management</span>
                <h2>Driver Management</h2>
            </div>
            <button type="button" class="btn-add" id="toggleFormBtn">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                Register New Driver
            </button>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-box" style="margin: 0 0 16px;"><%= request.getAttribute("error") %></div>
        <% } %>

        <div class="form-card <%= editDriver == null ? "collapsed" : "" %>" id="formCard">
            <h4>
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 3.5-7 8-7s8 3 8 7"/></svg>
                <%= editDriver != null ? "Edit Driver" : "Register New Driver" %>
            </h4>
            <form action="drivers" method="post">
                <% if (editDriver != null) { %>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= editDriver.getId() %>">
                <% } %>
                <div class="form-row">
                    <div class="field">
                        <label>Full Name</label>
                        <input type="text" name="fullName" placeholder="e.g. Ravi Kumar" required value="<%= editDriver != null ? editDriver.getFullName() : "" %>">
                    </div>
                    <div class="field">
                        <label>License Number</label>
                        <input type="text" name="licenseNumber" placeholder="e.g. DL-TN-0192837" required value="<%= editDriver != null ? editDriver.getLicenseNumber() : "" %>">
                    </div>
                    <div class="field">
                        <label>Phone</label>
                        <input type="text" name="phone" placeholder="e.g. 9876543210" value="<%= editDriver != null && editDriver.getPhone() != null ? editDriver.getPhone() : "" %>">
                    </div>
                    <div>
                        <button type="submit" class="btn-primary" style="margin-top:0;"><%= editDriver != null ? "Save Changes" : "Register Driver" %></button>
                    </div>
                </div>
            </form>
            <% if (editDriver != null) { %>
                <p style="margin-top:10px;"><a href="drivers" style="color:#5b6472; font-size:12.5px;">&larr; Cancel edit</a></p>
            <% } %>
        </div>

        <div class="toolbar">
            <div class="search-box">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" id="searchInput" placeholder="Search by name, license, or phone">
            </div>
            <div class="filter-group">
                <select id="statusFilter">
                    <option value="">All Status</option>
                    <option value="PENDING">Pending</option>
                    <option value="VERIFIED">Verified</option>
                    <option value="REJECTED">Rejected</option>
                </select>
            </div>
        </div>

        <table class="drv-table" id="drvTable">
            <thead>
                <tr>
                    <th>ID</th><th>Full Name</th><th>License No.</th><th>Phone</th><th>Status</th><th>Assigned Ambulance</th><th>Login Account</th><th>Actions</th>
                </tr>
            </thead>
            <tbody id="drvTableBody">
                <% if (drivers != null) { for (Driver d : drivers) {
                    String phone = d.getPhone() != null ? d.getPhone() : "-";
                    boolean verified = "VERIFIED".equals(d.getStatus());
                %>
                <tr data-status="<%= d.getStatus() %>" data-search="<%= (d.getFullName() + " " + d.getLicenseNumber() + " " + phone).toLowerCase() %>">
                    <td><%= d.getId() %></td>
                    <td><%= d.getFullName() %></td>
                    <td><%= d.getLicenseNumber() %></td>
                    <td><%= phone %></td>
                    <td><span class="status-pill status-<%= d.getStatus() %>"><%= d.getStatus() %></span></td>
                    <td>
                        <% if (verified) { %>
                            <form action="drivers" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="assign">
                                <input type="hidden" name="id" value="<%= d.getId() %>">
                                <select class="assign-select" name="ambulanceId" onchange="this.form.submit()">
                                    <option value="">Unassigned</option>
                                    <% if (ambulances != null) { for (Ambulance a : ambulances) { %>
                                        <option value="<%= a.getId() %>" <%= a.getId() == d.getAssignedAmbulanceId() ? "selected" : "" %>><%= a.getVehicleNumber() %></option>
                                    <% } } %>
                                </select>
                            </form>
                        <% } else { %>
                            <select class="assign-select" disabled><option>Not verified</option></select>
                        <% } %>
                    </td>
                    <td>
                        <form action="drivers" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="linkUser">
                            <input type="hidden" name="id" value="<%= d.getId() %>">
                            <select class="assign-select" name="userId" onchange="this.form.submit()">
                                <option value="">No login linked</option>
                                <% if (driverUsers != null) { for (com.ambulance.model.User du : driverUsers) { %>
                                    <option value="<%= du.getId() %>" <%= du.getId() == d.getUserId() ? "selected" : "" %>><%= du.getUsername() %> (<%= du.getFullName() %>)</option>
                                <% } } %>
                            </select>
                        </form>
                    </td>
                    <td>
                        <div class="action-icons">
                            <% if ("PENDING".equals(d.getStatus())) { %>
                                <a class="icon-btn verify" href="drivers?action=verify&id=<%= d.getId() %>" title="Verify">
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                </a>
                                <a class="icon-btn reject" href="drivers?action=reject&id=<%= d.getId() %>" title="Reject">
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                </a>
                            <% } %>
                            <a class="icon-btn edit" href="drivers?action=edit&id=<%= d.getId() %>" title="Edit">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                            </a>
                            <a class="icon-btn delete" href="drivers?action=delete&id=<%= d.getId() %>" title="Delete"
                               onclick="return confirm('Remove driver \'<%= d.getFullName() %>\'?');">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
                            </a>
                        </div>
                    </td>
                </tr>
                <% } } %>
            </tbody>
        </table>

        <div class="table-footer">
            <span id="resultCount"></span>
            <div class="pagination" id="pagination"></div>
        </div>

        <p style="margin-top:20px;"><a href="../dashboard_admin.jsp" style="color:#5b6472; font-size:13px;">&larr; Back to Dashboard</a></p>
    </div>
    <footer class="scms-footer">Ambulance Management System</footer>

    <script>
        // Toggle Add/Edit form
        var toggleBtn = document.getElementById('toggleFormBtn');
        var formCard = document.getElementById('formCard');
        toggleBtn.addEventListener('click', function () {
            formCard.classList.toggle('collapsed');
            if (!formCard.classList.contains('collapsed')) {
                formCard.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });

        // Search + status filter + pagination (client-side, works on the rows already rendered by the JSP)
        var allRows = Array.prototype.slice.call(document.querySelectorAll('#drvTableBody tr'));
        var searchInput = document.getElementById('searchInput');
        var statusFilter = document.getElementById('statusFilter');
        var resultCount = document.getElementById('resultCount');
        var paginationEl = document.getElementById('pagination');
        var pageSize = 5;
        var currentPage = 1;

        function getFilteredRows() {
            var term = searchInput.value.trim().toLowerCase();
            var status = statusFilter.value;
            return allRows.filter(function (row) {
                var matchesSearch = !term || row.getAttribute('data-search').indexOf(term) !== -1;
                var matchesStatus = !status || row.getAttribute('data-status') === status;
                return matchesSearch && matchesStatus;
            });
        }

        function renderTable() {
            var filtered = getFilteredRows();
            var totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));
            if (currentPage > totalPages) currentPage = totalPages;

            allRows.forEach(function (row) { row.style.display = 'none'; });

            var start = (currentPage - 1) * pageSize;
            var pageRows = filtered.slice(start, start + pageSize);
            pageRows.forEach(function (row) { row.style.display = ''; });

            var tbody = document.getElementById('drvTableBody');
            var existingEmpty = tbody.querySelector('.empty-row');
            if (existingEmpty) existingEmpty.remove();
            if (filtered.length === 0) {
                var tr = document.createElement('tr');
                tr.className = 'empty-row';
                tr.innerHTML = '<td colspan="8">No drivers match your search.</td>';
                tbody.appendChild(tr);
            }

            resultCount.textContent = filtered.length === 0
                ? 'Showing 0 of 0 entries'
                : 'Showing ' + (start + 1) + ' to ' + Math.min(start + pageSize, filtered.length) + ' of ' + filtered.length + ' entries';

            paginationEl.innerHTML = '';
            var prevBtn = document.createElement('button');
            prevBtn.textContent = 'Prev';
            prevBtn.disabled = currentPage === 1;
            prevBtn.addEventListener('click', function () { currentPage--; renderTable(); });
            paginationEl.appendChild(prevBtn);

            for (var p = 1; p <= totalPages; p++) {
                (function (pageNum) {
                    var btn = document.createElement('button');
                    btn.textContent = pageNum;
                    if (pageNum === currentPage) btn.classList.add('active');
                    btn.addEventListener('click', function () { currentPage = pageNum; renderTable(); });
                    paginationEl.appendChild(btn);
                })(p);
            }

            var nextBtn = document.createElement('button');
            nextBtn.textContent = 'Next';
            nextBtn.disabled = currentPage === totalPages;
            nextBtn.addEventListener('click', function () { currentPage++; renderTable(); });
            paginationEl.appendChild(nextBtn);
        }

        searchInput.addEventListener('input', function () { currentPage = 1; renderTable(); });
        statusFilter.addEventListener('change', function () { currentPage = 1; renderTable(); });
        renderTable();
    </script>
</body>
</html>
