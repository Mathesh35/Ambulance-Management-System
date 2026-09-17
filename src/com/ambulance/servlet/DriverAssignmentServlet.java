package com.ambulance.servlet;

import com.ambulance.dao.AmbulanceDAO;
import com.ambulance.dao.DriverDAO;
import com.ambulance.dao.EmergencyRequestDAO;
import com.ambulance.model.Ambulance;
import com.ambulance.model.Driver;
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
import java.util.List;

/**
 * Driver-only "My Assignments" / "Update Status" screen (SRS FR4/FR5). Shows the
 * emergency requests assigned to the logged-in driver and lets them update their
 * ambulance's live location, or mark a run COMPLETED once they've reached the patient
 * (which also frees the ambulance back to AVAILABLE, same as the dispatcher's Track
 * Ambulance screen).
 */
@WebServlet("/driver/assignments")
public class DriverAssignmentServlet extends HttpServlet {

    private final DriverDAO driverDAO = new DriverDAO();
    private final EmergencyRequestDAO requestDAO = new EmergencyRequestDAO();
    private final AmbulanceDAO ambulanceDAO = new AmbulanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = requireDriver(request, response);
        if (currentUser == null) return;

        try {
            Driver driver = driverDAO.getDriverByUserId(currentUser.getId());
            request.setAttribute("driver", driver);

            if (driver == null) {
                request.setAttribute("error",
                    "Your login isn't linked to a driver profile yet. Ask an admin to link it under Driver Management.");
            } else {
                request.setAttribute("assignments", requestDAO.getRequestsForDriver(driver.getId()));
                if (driver.getAssignedAmbulanceId() > 0) {
                    request.setAttribute("ambulance", ambulanceDAO.getAmbulanceById(driver.getAssignedAmbulanceId()));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("/driver/assignments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = requireDriver(request, response);
        if (currentUser == null) return;

        String action = request.getParameter("action");
        try {
            Driver driver = driverDAO.getDriverByUserId(currentUser.getId());
            if (driver == null || driver.getAssignedAmbulanceId() <= 0) {
                response.sendRedirect("assignments");
                return;
            }

            if ("updateLocation".equals(action)) {
                String location = request.getParameter("location");
                if (location != null && !location.trim().isEmpty()) {
                    ambulanceDAO.updateLocation(driver.getAssignedAmbulanceId(), location.trim());
                }
            } else if ("complete".equals(action)) {
                int requestId = Integer.parseInt(request.getParameter("id"));
                EmergencyRequest r = requestDAO.getRequestById(requestId);
                if (r != null && "ASSIGNED".equals(r.getStatus()) && r.getAssignedDriverId() == driver.getId()) {
                    requestDAO.updateStatus(requestId, "COMPLETED");
                    ambulanceDAO.markArrivedAndFree(driver.getAssignedAmbulanceId(), r.getLocation());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        response.sendRedirect("assignments");
    }

    private User requireDriver(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !"DRIVER".equals(user.getRole())) {
            response.sendRedirect("../login.jsp");
            return null;
        }
        return user;
    }
}
