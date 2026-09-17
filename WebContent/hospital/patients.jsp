<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ambulance.model.User" %>
<%@ page import="com.ambulance.model.EmergencyRequest" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
    if (currentUser == null || !"HOSPITAL_STAFF".equals(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<EmergencyRequest> records = (List<EmergencyRequest>) request.getAttribute("records");
    EmergencyRequest editRecord = (EmergencyRequest) request.getAttribute("editRecord");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Patient Records | Ambulance Management System</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        /* Page-specific styles only - reuses existing color palette (literal values from style.css), no global style.css edits, no new palette introduced */

        .page-head { display: flex; align-items: flex-end; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 18px; }
        .page-head h2 { font-size: 21px; font-weight: 700; color: #17213a; margin: 6px 0 0; }

        .form-card { background: #fff; border: 1px solid #ebedf1; border-radius: 14px; padding: 22px 24px; margin-bottom: 20px; box-shadow: 0 6px 18px rgba(20,30,50,0.06); }
        .form-card h4 { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; font-size: 16px; color:#17213a; }
        .form-card .sub { font-size: 12.5px; color: #5b6472; margin-bottom: 16px; }
        .read-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; margin-bottom: 16px; }
        .read-grid .field label { display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em; color: #9aa2b1; margin-bottom: 4px; }
        .read-grid .field span { display: block; font-size: 14px; color: #1b2436; }
        .form-row { display: grid; grid-template-columns: 1fr; gap: 14px; align-items: end; }
        .form-row .field { margin-top: 0; }
        .form-row label { display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #2b3448; margin-bottom: 5px; }
        .form-row textarea { width: 100%; border: 1px solid #e2e5eb; border-radius: 10px; background: #fafbfc; padding: 10px 14px; font-size: 14px; color: #1b2436; box-sizing: border-box; height: 100px; resize: vertical; font-family: inherit; }
        .form-row textarea:focus { outline: none; border-color: #e0342c; background: #fff; }

        .toolbar { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 14px; }
        .search-box { position: relative; flex: 1; min-width: 220px; max-width: 340px; }
        .search-box svg { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #9aa2b1; }
        .search-box input { width: 100%; height: 38px; border: 1px solid #e2e5eb; border-radius: 10px; background: #fff; padding: 0 14px 0 36px; font-size: 13.5px; color: #1b2436; box-sizing: border-box; }

        table.req-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 6px 18px rgba(20,30,50,0.06); border: 1px solid #ebedf1; }
        table.req-table th, table.req-table td { padding: 12px 16px; text-align: left; font-size: 13px; border-bottom: 1px solid #ebedf1; }
        table.req-table th { background: #f9fafb; text-transform: uppercase; letter-spacing: 0.04em; font-size: 11px; color: #5b6472; }
        table.req-table tbody tr:nth-child(even) { background: #fbfbfd; }
        table.req-table tbody tr:hover { background: #fef4f3; }
        table.req-table tr:last-child td { border-bottom: none; }
        table.req-table td.notes-cell { max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

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

        .action-icons { display: flex; gap: 6px; align-items: center; }
        .icon-btn { width: 30px; height: 30px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; border: 1px solid #e2e5eb; background: #fff; color: #5b6472; cursor: pointer; text-decoration: none; }
        .icon-btn:hover { background: #f4f5f7; }
        .icon-btn.edit:hover { color: #b3690a; border-color: #f3d6a8; }

        .history-badge { display: inline-flex; align-items: center; gap: 5px; font-size: 11px; font-weight: 700; color: #1c8a4c; }
        .history-badge.empty { color: #9aa2b1; font-weight: 600; }

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
            <span class="role-tag">HOSPITAL STAFF</span>
            <a class="logout" href="../logout">Log Out</a>
        </div>
    </header>

    <div class="container">
        <div class="page-head">
            <div class="section-heading" style="margin-bottom:0;">
                <span class="eyebrow">Hospital &rsaquo; Patient Records</span>
                <h2>Patient Records</h2>
            </div>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-box" style="margin: 0 0 16px;"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (editRecord != null) { %>
        <div class="form-card" id="formCard">
            <h4>
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21V5a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v16"/><path d="M9 9h1M9 13h1M14 9h1M14 13h1M9 21v-4h6v4"/></svg>
                Patient / Emergency Details
            </h4>
            <p class="sub">Emergency details are logged by Dispatch and shown here read-only. Hospital staff can add or update the medical history below.</p>

            <div class="read-grid">
                <div class="field"><label>Patient Name</label><span><%= editRecord.getPatientName() %></span></div>
                <div class="field"><label>Age</label><span><%= editRecord.getPatientAge() > 0 ? editRecord.getPatientAge() : "-" %></span></div>
                <div class="field"><label>Contact Number</label><span><%= editRecord.getContactNumber() != null ? editRecord.getContactNumber() : "-" %></span></div>
                <div class="field"><label>Priority</label><span class="priority-pill priority-<%= editRecord.getPriority() %>"><%= editRecord.getPriority() %></span></div>
                <div class="field"><label>Status</label><span class="status-pill status-<%= editRecord.getStatus() %>"><%= editRecord.getStatus() %></span></div>
                <div class="field" style="grid-column: span 2;"><label>Location / Pickup Address</label><span><%= editRecord.getLocation() %></span></div>
                <div class="field" style="grid-column: span 2;"><label>Condition / Notes (from Dispatch)</label><span><%= editRecord.getCondition() != null && !editRecord.getCondition().isEmpty() ? editRecord.getCondition() : "-" %></span></div>
            </div>

            <form action="patients" method="post">
                <input type="hidden" name="id" value="<%= editRecord.getId() %>">
                <div class="form-row">
                    <div class="field">
                        <label>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                            Medical History (FR7)
                        </label>
                        <textarea name="medicalHistory" placeholder="e.g. Known hypertension, allergic to penicillin, prior cardiac surgery in 2019"><%= editRecord.getMedicalHistory() != null ? editRecord.getMedicalHistory() : "" %></textarea>
                    </div>
                    <div>
                        <button type="submit" class="btn-primary" style="margin-top:0;">Save Medical History</button>
                    </div>
                </div>
            </form>
            <p style="margin-top:10px;"><a href="patients" style="color:#5b6472; font-size:12.5px;">&larr; Back to all records</a></p>
        </div>
        <% } %>

        <div class="toolbar">
            <div class="search-box">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" id="searchInput" placeholder="Search by patient, location, or contact">
            </div>
        </div>

        <table class="req-table" id="recTable">
            <thead>
                <tr>
                    <th>ID</th><th>Patient</th><th>Age</th><th>Contact</th><th>Location</th><th>Condition</th><th>Priority</th><th>Status</th><th>Medical History</th><th>Actions</th>
                </tr>
            </thead>
            <tbody id="recTableBody">
                <% if (records != null) { for (EmergencyRequest r : records) {
                    String contact = r.getContactNumber() != null ? r.getContactNumber() : "-";
                    String cond = r.getCondition() != null && !r.getCondition().isEmpty() ? r.getCondition() : "-";
                    boolean hasHistory = r.getMedicalHistory() != null && !r.getMedicalHistory().trim().isEmpty();
                %>
                <tr data-search="<%= (r.getPatientName() + " " + r.getLocation() + " " + contact).toLowerCase() %>">
                    <td><%= r.getId() %></td>
                    <td><%= r.getPatientName() %></td>
                    <td><%= r.getPatientAge() > 0 ? r.getPatientAge() : "-" %></td>
                    <td><%= contact %></td>
                    <td><%= r.getLocation() %></td>
                    <td class="notes-cell" title="<%= cond %>"><%= cond %></td>
                    <td><span class="priority-pill priority-<%= r.getPriority() %>"><%= r.getPriority() %></span></td>
                    <td><span class="status-pill status-<%= r.getStatus() %>"><%= r.getStatus() %></span></td>
                    <td>
                        <% if (hasHistory) { %>
                            <span class="history-badge" title="<%= r.getMedicalHistory() %>">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                On file
                            </span>
                        <% } else { %>
                            <span class="history-badge empty">Not recorded</span>
                        <% } %>
                    </td>
                    <td>
                        <div class="action-icons">
                            <a class="icon-btn edit" href="patients?action=edit&id=<%= r.getId() %>" title="View / update medical history">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
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

        <p style="margin-top:20px;"><a href="../dashboard_hospital.jsp" style="color:#5b6472; font-size:13px;">&larr; Back to Dashboard</a></p>
    </div>
    <footer class="scms-footer">Ambulance Management System</footer>

    <script>
        // Search + pagination (client-side, works on the rows already rendered by the JSP)
        var allRows = Array.prototype.slice.call(document.querySelectorAll('#recTableBody tr'));
        var searchInput = document.getElementById('searchInput');
        var resultCount = document.getElementById('resultCount');
        var paginationEl = document.getElementById('pagination');
        var pageSize = 5;
        var currentPage = 1;

        function getFilteredRows() {
            var term = searchInput.value.trim().toLowerCase();
            return allRows.filter(function (row) {
                return !term || row.getAttribute('data-search').indexOf(term) !== -1;
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

            var tbody = document.getElementById('recTableBody');
            var existingEmpty = tbody.querySelector('.empty-row');
            if (existingEmpty) existingEmpty.remove();
            if (filtered.length === 0) {
                var tr = document.createElement('tr');
                tr.className = 'empty-row';
                tr.innerHTML = '<td colspan="10">No patient records match your search.</td>';
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
        renderTable();
    </script>
</body>
</html>
