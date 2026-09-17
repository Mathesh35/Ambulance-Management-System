package com.ambulance.servlet;

import com.ambulance.dao.AmbulanceDAO;
import com.ambulance.dao.DriverDAO;
import com.ambulance.dao.EmergencyRequestDAO;
import com.ambulance.model.Ambulance;
import com.ambulance.model.Driver;
import com.ambulance.model.EmergencyRequest;
import com.ambulance.model.User;
import com.ambulance.util.GeoUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Dispatcher-only "Assign Ambulance" screen (SRS FR5 - Nearest Ambulance
 * Allocation). For every PENDING request, ranks all AVAILABLE ambulances by
 * straight-line distance to the request's location (see GeoUtil) and lets
 * the dispatcher either one-click assign the nearest one or manually pick
 * a different available ambulance.
 */
@WebServlet("/dispatcher/allocate")
public class AllocationServlet extends HttpServlet {

    private final EmergencyRequestDAO requestDAO = new EmergencyRequestDAO();
    private final AmbulanceDAO ambulanceDAO = new AmbulanceDAO();
    private final DriverDAO driverDAO = new DriverDAO();

    /** One ranked candidate ambulance for a given request, for display only. */
    public static class AmbulanceOption {
        public final Ambulance ambulance;
        public final double distanceKm;
        public final int etaMinutes;

        public AmbulanceOption(Ambulance ambulance, double distanceKm, int etaMinutes) {
            this.ambulance = ambulance;
            this.distanceKm = distanceKm;
            this.etaMinutes = etaMinutes;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isDispatcher(request)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("auto".equals(action)) {
                int requestId = Integer.parseInt(request.getParameter("id"));
                assignNearest(requestId);
                response.sendRedirect("allocate");
                return;
            }

            List<EmergencyRequest> pendingRequests = requestDAO.getPendingRequests();
            List<Ambulance> availableAmbulances = ambulanceDAO.getAvailableAmbulances();

            // Rank available ambulances by distance for every pending request.
            Map<Integer, List<AmbulanceOption>> optionsByRequest = new HashMap<>();
            for (EmergencyRequest r : pendingRequests) {
                List<AmbulanceOption> options = new ArrayList<>();
                for (Ambulance a : availableAmbulances) {
                    double distance = GeoUtil.distanceKm(a.getCurrentLocation(), r.getLocation());
                    options.add(new AmbulanceOption(a, distance, GeoUtil.estimateEtaMinutes(distance)));
                }
                options.sort(Comparator.comparingDouble(o -> o.distanceKm));
                optionsByRequest.put(r.getId(), options);
            }

            request.setAttribute("pendingRequests", pendingRequests);
            request.setAttribute("optionsByRequest", optionsByRequest);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("/dispatcher/allocate.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isDispatcher(request)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        try {
            if ("assign".equals(request.getParameter("action"))) {
                int requestId = Integer.parseInt(request.getParameter("requestId"));
                int ambulanceId = Integer.parseInt(request.getParameter("ambulanceId"));
                assignAmbulanceToRequest(requestId, ambulanceId);
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Could not assign ambulance: " + e.getMessage());
        }
        response.sendRedirect("allocate");
    }

    /** Auto-assign: find the closest AVAILABLE ambulance and assign it (SRS FR5). */
    private void assignNearest(int requestId) throws SQLException {
        EmergencyRequest r = requestDAO.getRequestById(requestId);
        if (r == null || !"PENDING".equals(r.getStatus())) {
            return;
        }
        List<Ambulance> available = ambulanceDAO.getAvailableAmbulances();
        Ambulance nearest = null;
        double nearestDistance = Double.MAX_VALUE;
        for (Ambulance a : available) {
            double distance = GeoUtil.distanceKm(a.getCurrentLocation(), r.getLocation());
            if (distance < nearestDistance) {
                nearestDistance = distance;
                nearest = a;
            }
        }
        if (nearest != null) {
            assignAmbulanceToRequest(requestId, nearest.getId());
        }
    }

    /** Shared assignment logic: link ambulance+driver to the request and mark the ambulance ON_DUTY. */
    private void assignAmbulanceToRequest(int requestId, int ambulanceId) throws SQLException {
        Ambulance ambulance = ambulanceDAO.getAmbulanceById(ambulanceId);
        if (ambulance == null || !"AVAILABLE".equals(ambulance.getStatus())) {
            return; // already taken by another request - dispatcher should refresh and retry
        }

        int driverId = 0;
        for (Driver d : driverDAO.getAllDrivers()) {
            if (d.getAssignedAmbulanceId() == ambulanceId && "VERIFIED".equals(d.getStatus())) {
                driverId = d.getId();
                break;
            }
        }

        requestDAO.assignAmbulance(requestId, ambulanceId, driverId);
        ambulanceDAO.updateStatus(ambulanceId, "ON_DUTY");
    }

    private boolean isDispatcher(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && "DISPATCHER".equals(user.getRole());
    }
}
