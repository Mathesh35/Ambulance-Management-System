<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%@ page import="com.ambulance.model.Ambulance" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
    if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<Ambulance> ambulances = (List<Ambulance>) request.getAttribute("ambulances");
    Ambulance editAmbulance = (Ambulance) request.getAttribute("editAmbulance");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Ambulance Management | Ambulance Management System</title>
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

        table.amb-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 6px 18px rgba(20,30,50,0.06); border: 1px solid #ebedf1; }
        table.amb-table th, table.amb-table td { padding: 12px 16px; text-align: left; font-size: 13px; border-bottom: 1px solid #ebedf1; }
        table.amb-table th { background: #f9fafb; text-transform: uppercase; letter-spacing: 0.04em; font-size: 11px; color: #5b6472; }
        table.amb-table tbody tr:nth-child(even) { background: #fbfbfd; }
        table.amb-table tbody tr:hover { background: #fef4f3; }
        table.amb-table tr:last-child td { border-bottom: none; }

        .status-pill { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; letter-spacing: 0.03em; text-transform: uppercase; }
        .status-pill::before { content: ""; width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .status-AVAILABLE { background: #e5f7ec; color: #1c8a4c; }
        .status-ON_DUTY { background: #fff2df; color: #b3690a; }
        .status-MAINTENANCE { background: #fde8e7; color: #c62c26; }

        .action-icons { display: flex; gap: 6px; }
        .icon-btn { width: 30px; height: 30px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; border: 1px solid #e2e5eb; background: #fff; color: #5b6472; cursor: pointer; text-decoration: none; }
        .icon-btn:hover { background: #f4f5f7; }
        .icon-btn.view:hover { color: #1b7fd1; border-color: #bcdcf5; }
        .icon-btn.edit:hover { color: #b3690a; border-color: #f3d6a8; }
        .icon-btn.delete:hover { color: #c62c26; border-color: #f5c2bf; }

        .table-footer { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px; padding: 12px 4px 0; font-size: 12.5px; color: #5b6472; }
        .pagination { display: flex; align-items: center; gap: 6px; }
        .pagination button { min-width: 30px; height: 30px; border: 1px solid #e2e5eb; background: #fff; color: #2b3448; border-radius: 8px; cursor: pointer; font-size: 12.5px; }
        .pagination button.active { background: #e0342c; border-color: #e0342c; color: #fff; }
        .pagination button:disabled { opacity: 0.4; cursor: not-allowed; }

        .empty-row td { text-align: center; padding: 26px; color: #9aa2b1; font-size: 13px; }

        /* View modal */
        .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(15,20,35,0.45); align-items: center; justify-content: center; z-index: 50; }
        .modal-overlay.open { display: flex; }
        .modal-box { background: #fff; border-radius: 14px; padding: 24px; width: 340px; box-shadow: 0 20px 50px rgba(0,0,0,0.25); }
        .modal-box h4 { margin: 0 0 14px; font-size: 16px; color: #17213a; }
        .modal-box dl { margin: 0; }
        .modal-box dt { font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; color: #9aa2b1; margin-top: 10px; }
        .modal-box dd { margin: 2px 0 0; font-size: 14px; color: #1b2436; }
        .modal-close { margin-top: 18px; width: 100%; height: 38px; border: 1px solid #e2e5eb; background: #f9fafb; border-radius: 10px; cursor: pointer; font-size: 13.5px; color: #2b3448; }
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
                <span class="eyebrow">Admin &rsaquo; Ambulance Management</span>
                <h2>Ambulance Management</h2>
            </div>
            <button type="button" class="btn-add" id="toggleFormBtn">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                Add New Ambulance
            </button>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-box" style="margin: 0 0 16px;"><%= request.getAttribute("error") %></div>
        <% } %>

        <div class="form-card <%= editAmbulance == null ? "collapsed" : "" %>" id="formCard">
            <h4>
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2"/><path d="M14 9h4l4 4v4a1 1 0 0 1-1 1h-2"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/></svg>
                <%= editAmbulance != null ? "Edit Ambulance" : "Add New Ambulance" %>
            </h4>
            <form action="ambulances" method="post">
                <% if (editAmbulance != null) { %>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= editAmbulance.getId() %>">
                <% } %>
                <div class="form-row">
                    <div class="field">
                        <label>Vehicle Number</label>
                        <input type="text" name="vehicleNumber" placeholder="e.g. AMB-104" required value="<%= editAmbulance != null ? editAmbulance.getVehicleNumber() : "" %>">
                    </div>
                    <div class="field">
                        <label>Type</label>
                        <select name="type" required>
                            <option value="">Select Type</option>
                            <%
                                String[] types = {"BASIC", "ADVANCED", "PATIENT_TRANSPORT"};
                                String currentType = editAmbulance != null ? editAmbulance.getType() : "";
                                for (String t : types) {
                            %>
                                <option value="<%= t %>" <%= t.equals(currentType) ? "selected" : "" %>><%= t %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="field">
                        <label>Status</label>
                        <select name="status" required>
                            <option value="">Select Status</option>
                            <%
                                String[] statuses = {"AVAILABLE", "ON_DUTY", "MAINTENANCE"};
                                String currentStatus = editAmbulance != null ? editAmbulance.getStatus() : "";
                                for (String s : statuses) {
                            %>
                                <option value="<%= s %>" <%= s.equals(currentStatus) ? "selected" : "" %>><%= s %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="field">
                        <label>Current Location</label>
                        <input type="text" name="currentLocation" placeholder="e.g. Central Station" value="<%= editAmbulance != null && editAmbulance.getCurrentLocation() != null ? editAmbulance.getCurrentLocation() : "" %>">
                    </div>
                    <div>
                        <button type="submit" class="btn-primary" style="margin-top:0;"><%= editAmbulance != null ? "Save Changes" : "Add Ambulance" %></button>
                    </div>
                </div>
            </form>
            <% if (editAmbulance != null) { %>
                <p style="margin-top:10px;"><a href="ambulances" style="color:#5b6472; font-size:12.5px;">&larr; Cancel edit</a></p>
            <% } %>
        </div>

        <div class="toolbar">
            <div class="search-box">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" id="searchInput" placeholder="Search by vehicle number, type, or location">
            </div>
            <div class="filter-group">
                <select id="statusFilter">
                    <option value="">All Status</option>
                    <option value="AVAILABLE">Available</option>
                    <option value="ON_DUTY">On Duty</option>
                    <option value="MAINTENANCE">Maintenance</option>
                </select>
            </div>
        </div>

        <table class="amb-table" id="ambTable">
            <thead>
                <tr>
                    <th>ID</th><th>Vehicle Number</th><th>Type</th><th>Status</th><th>Current Location</th><th>Actions</th>
                </tr>
            </thead>
            <tbody id="ambTableBody">
                <% if (ambulances != null) { for (Ambulance a : ambulances) {
                    String loc = a.getCurrentLocation() != null ? a.getCurrentLocation() : "-";
                %>
                <tr data-status="<%= a.getStatus() %>" data-search="<%= (a.getVehicleNumber() + " " + a.getType() + " " + loc).toLowerCase() %>">
                    <td><%= a.getId() %></td>
                    <td><%= a.getVehicleNumber() %></td>
                    <td><%= a.getType() %></td>
                    <td><span class="status-pill status-<%= a.getStatus() %>"><%= a.getStatus() %></span></td>
                    <td><%= loc %></td>
                    <td>
                        <div class="action-icons">
                            <button type="button" class="icon-btn view"
                                    data-vehicle="<%= a.getVehicleNumber() %>" data-type="<%= a.getType() %>"
                                    data-status="<%= a.getStatus() %>" data-location="<%= loc %>" title="View">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                            <a class="icon-btn edit" href="ambulances?action=edit&id=<%= a.getId() %>" title="Edit">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                            </a>
                            <a class="icon-btn delete" href="ambulances?action=delete&id=<%= a.getId() %>" title="Delete"
                               onclick="return confirm('Delete ambulance \'<%= a.getVehicleNumber() %>\'?');">
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

    <div class="modal-overlay" id="viewModal">
        <div class="modal-box">
            <h4>Ambulance Details</h4>
            <dl>
                <dt>Vehicle Number</dt><dd id="mVehicle"></dd>
                <dt>Type</dt><dd id="mType"></dd>
                <dt>Status</dt><dd id="mStatus"></dd>
                <dt>Current Location</dt><dd id="mLocation"></dd>
            </dl>
            <button type="button" class="modal-close" id="modalCloseBtn">Close</button>
        </div>
    </div>

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
        var allRows = Array.prototype.slice.call(document.querySelectorAll('#ambTableBody tr'));
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

            var tbody = document.getElementById('ambTableBody');
            var existingEmpty = tbody.querySelector('.empty-row');
            if (existingEmpty) existingEmpty.remove();
            if (filtered.length === 0) {
                var tr = document.createElement('tr');
                tr.className = 'empty-row';
                tr.innerHTML = '<td colspan="6">No ambulances match your search.</td>';
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

        // View modal
        var viewModal = document.getElementById('viewModal');
        document.querySelectorAll('.icon-btn.view').forEach(function (btn) {
            btn.addEventListener('click', function () {
                document.getElementById('mVehicle').textContent = btn.getAttribute('data-vehicle');
                document.getElementById('mType').textContent = btn.getAttribute('data-type');
                document.getElementById('mStatus').textContent = btn.getAttribute('data-status');
                document.getElementById('mLocation').textContent = btn.getAttribute('data-location');
                viewModal.classList.add('open');
            });
        });
        document.getElementById('modalCloseBtn').addEventListener('click', function () {
            viewModal.classList.remove('open');
        });
        viewModal.addEventListener('click', function (e) {
            if (e.target === viewModal) viewModal.classList.remove('open');
        });
    </script>
</body>
</html>
