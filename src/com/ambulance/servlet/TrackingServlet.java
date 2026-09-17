package com.ambulance.servlet;

import com.ambulance.dao.AmbulanceDAO;
import com.ambulance.dao.EmergencyRequestDAO;
import com.ambulance.model.Ambulance;
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
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Dispatcher-only "Track Ambulance" screen (SRS FR5 - Nearest Ambulance
 * Allocation & Tracking). For every ASSIGNED request, estimates how far
 * along the ambulance is toward the patient's location based on elapsed
 * time since assignment vs. the estimated total travel time (see GeoUtil),
 * and lets the dispatcher mark the request COMPLETED once the ambulance
 * has arrived (which also frees the ambulance back to AVAILABLE).
 */
@WebServlet("/dispatcher/track")
public class TrackingServlet extends HttpServlet {

    private final EmergencyRequestDAO requestDAO = new EmergencyRequestDAO();
    private final AmbulanceDAO ambulanceDAO = new AmbulanceDAO();

    /** One in-progress ambulance run, pre-computed for the JSP/JS to render and animate. */
    public static class TrackingInfo {
        public final EmergencyRequest request;
        public final double distanceKm;
        public final int etaMinutes;
        public final long assignedAtMillis; // epoch ms - client JS ticks the countdown from this

        public TrackingInfo(EmergencyRequest request, double distanceKm, int etaMinutes, long assignedAtMillis) {
            this.request = request;
            this.distanceKm = distanceKm;
            this.etaMinutes = etaMinutes;
            this.assignedAtMillis = assignedAtMillis;
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
            if ("arrived".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                markArrived(id);
                response.sendRedirect("track");
                return;
            }

            List<EmergencyRequest> assignments = requestDAO.getActiveAssignments();
            List<TrackingInfo> trackingList = new ArrayList<>();
            for (EmergencyRequest r : assignments) {
                Ambulance ambulance = ambulanceDAO.getAmbulanceById(r.getAssignedAmbulanceId());
                if (ambulance == null) continue;
                double distance = GeoUtil.distanceKm(ambulance.getCurrentLocation(), r.getLocation());
                int eta = GeoUtil.estimateEtaMinutes(distance);
                long assignedAtMillis = parseMillis(r.getAssignedAt());
                trackingList.add(new TrackingInfo(r, distance, eta, assignedAtMillis));
            }
            request.setAttribute("trackingList", trackingList);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("/dispatcher/track.jsp").forward(request, response);
    }

    /** Mark a request COMPLETED and free its ambulance back to AVAILABLE at the patient's location. */
    private void markArrived(int requestId) throws SQLException {
        EmergencyRequest r = requestDAO.getRequestById(requestId);
        if (r == null || !"ASSIGNED".equals(r.getStatus())) {
            return;
        }
        requestDAO.updateStatus(requestId, "COMPLETED");
        if (r.getAssignedAmbulanceId() > 0) {
            ambulanceDAO.markArrivedAndFree(r.getAssignedAmbulanceId(), r.getLocation());
        }
    }

    /** H2's default timestamp string ("yyyy-MM-dd HH:mm:ss.S") parses straight into java.sql.Timestamp. */
    private long parseMillis(String timestampText) {
        if (timestampText == null) return System.currentTimeMillis();
        try {
            return Timestamp.valueOf(timestampText).getTime();
        } catch (IllegalArgumentException e) {
            return System.currentTimeMillis();
        }
    }

    private boolean isDispatcher(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && "DISPATCHER".equals(user.getRole());
    }
}
