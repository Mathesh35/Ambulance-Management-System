package com.ambulance.servlet;

import com.ambulance.dao.EmergencyRequestDAO;
import com.ambulance.model.EmergencyRequest;
import com.ambulance.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Dispatcher-only "Emergency Requests" screen (SRS FR4).
 * Actions: list (default), add, edit, update, delete, complete, cancel - all via the "action" parameter.
 */
@WebServlet("/dispatcher/requests")
public class EmergencyRequestServlet extends HttpServlet {

    private final EmergencyRequestDAO requestDAO = new EmergencyRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isDispatcher(request)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                requestDAO.deleteRequest(id);
                response.sendRedirect("requests");
                return;
            }
            if ("complete".equals(action) || "cancel".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                requestDAO.updateStatus(id, "complete".equals(action) ? "COMPLETED" : "CANCELLED");
                response.sendRedirect("requests");
                return;
            }
            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                request.setAttribute("editRequest", requestDAO.getRequestById(id));
            }
            request.setAttribute("requests", requestDAO.getAllRequests());
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("/dispatcher/requests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isDispatcher(request)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            String patientName = request.getParameter("patientName");
            String ageParam = request.getParameter("patientAge");
            int patientAge = (ageParam == null || ageParam.isEmpty()) ? 0 : Integer.parseInt(ageParam);
            String contactNumber = request.getParameter("contactNumber");
            String location = request.getParameter("location");
            String condition = request.getParameter("condition");
            String priority = request.getParameter("priority");

            if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                EmergencyRequest r = new EmergencyRequest(id, patientName, patientAge, contactNumber,
                        location, condition, priority, null, null);
                requestDAO.updateRequest(r);
            } else {
                HttpSession session = request.getSession(false);
                User currentUser = (User) session.getAttribute("user");
                EmergencyRequest r = new EmergencyRequest(0, patientName, patientAge, contactNumber,
                        location, condition, priority, "PENDING", currentUser.getFullName());
                requestDAO.addRequest(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        response.sendRedirect("requests");
    }

    private boolean isDispatcher(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && "DISPATCHER".equals(user.getRole());
    }
}
