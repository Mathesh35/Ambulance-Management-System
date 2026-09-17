package com.ambulance.dao;

import com.ambulance.db.DBConnection;
import com.ambulance.model.EmergencyRequest;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Handles all SQL related to the EMERGENCY_REQUESTS table
 * (SRS FR4 - Patient/Emergency Request Management).
 */
public class EmergencyRequestDAO {

    private static final String SELECT_BASE =
        "SELECT r.id, r.patient_name, r.patient_age, r.contact_number, r.location, r.condition_notes, " +
        "       r.priority, r.status, r.requested_by, r.created_at, r.medical_history, " +
        "       r.assigned_ambulance_id, a.vehicle_number AS assigned_vehicle_number, " +
        "       r.assigned_driver_id, d.full_name AS assigned_driver_name, r.assigned_at " +
        "FROM emergency_requests r " +
        "LEFT JOIN ambulances a ON r.assigned_ambulance_id = a.id " +
        "LEFT JOIN drivers d ON r.assigned_driver_id = d.id ";

    /** Dispatcher: list all requests, most recent first. */
    public List<EmergencyRequest> getAllRequests() throws SQLException {
        List<EmergencyRequest> requests = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY r.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                requests.add(mapRow(rs));
            }
        }
        return requests;
    }

    /** Dispatcher: PENDING requests only, highest priority first - used by Module 5 (Allocation). */
    public List<EmergencyRequest> getPendingRequests() throws SQLException {
        List<EmergencyRequest> requests = new ArrayList<>();
        String sql = SELECT_BASE +
            "WHERE r.status = 'PENDING' " +
            "ORDER BY CASE r.priority " +
            "  WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 WHEN 'MEDIUM' THEN 3 ELSE 4 END, r.id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                requests.add(mapRow(rs));
            }
        }
        return requests;
    }

    /**
     * Driver self-service: every request ever assigned to this driver (ASSIGNED first, then
     * COMPLETED/CANCELLED history) - powers the "My Assignments" / "Update Status" screen.
     */
    public List<EmergencyRequest> getRequestsForDriver(int driverId) throws SQLException {
        List<EmergencyRequest> requests = new ArrayList<>();
        String sql = SELECT_BASE +
            "WHERE r.assigned_driver_id = ? " +
            "ORDER BY CASE r.status WHEN 'ASSIGNED' THEN 1 ELSE 2 END, r.assigned_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRow(rs));
                }
            }
        }
        return requests;
    }

    /** Dispatcher: ASSIGNED requests only (ambulance en route) - used by Module 5 (Tracking). */
    public List<EmergencyRequest> getActiveAssignments() throws SQLException {
        List<EmergencyRequest> requests = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE r.status = 'ASSIGNED' ORDER BY r.assigned_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                requests.add(mapRow(rs));
            }
        }
        return requests;
    }

    public EmergencyRequest getRequestById(int id) throws SQLException {
        String sql = SELECT_BASE + "WHERE r.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Dispatcher: assign the nearest (or manually chosen) ambulance + its driver to a
     * PENDING request. Moves the request to ASSIGNED and stamps assigned_at, which
     * Module 5's tracking screen uses to estimate progress/ETA.
     */
    public void assignAmbulance(int requestId, int ambulanceId, int driverId) throws SQLException {
        String sql = "UPDATE emergency_requests " +
                     "SET status = 'ASSIGNED', assigned_ambulance_id = ?, assigned_driver_id = ?, assigned_at = CURRENT_TIMESTAMP " +
                     "WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ambulanceId);
            if (driverId <= 0) {
                ps.setNull(2, java.sql.Types.INTEGER);
            } else {
                ps.setInt(2, driverId);
            }
            ps.setInt(3, requestId);
            ps.executeUpdate();
        }
    }

    /** Dispatcher: log a new emergency request. New requests always start out PENDING. */
    public void addRequest(EmergencyRequest r) throws SQLException {
        String sql = "INSERT INTO emergency_requests " +
                     "(patient_name, patient_age, contact_number, location, condition_notes, priority, status, requested_by, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 'PENDING', ?, CURRENT_TIMESTAMP)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, r.getPatientName());
            ps.setInt(2, r.getPatientAge());
            ps.setString(3, r.getContactNumber());
            ps.setString(4, r.getLocation());
            ps.setString(5, r.getCondition());
            ps.setString(6, r.getPriority());
            ps.setString(7, r.getRequestedBy());
            ps.executeUpdate();
        }
    }

    /** Dispatcher: update the patient/emergency details of an existing request. */
    public void updateRequest(EmergencyRequest r) throws SQLException {
        String sql = "UPDATE emergency_requests SET patient_name = ?, patient_age = ?, contact_number = ?, " +
                     "location = ?, condition_notes = ?, priority = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, r.getPatientName());
            ps.setInt(2, r.getPatientAge());
            ps.setString(3, r.getContactNumber());
            ps.setString(4, r.getLocation());
            ps.setString(5, r.getCondition());
            ps.setString(6, r.getPriority());
            ps.setInt(7, r.getId());
            ps.executeUpdate();
        }
    }

    /** Dispatcher: change a request's status (e.g. mark COMPLETED or CANCELLED). */
    public void updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE emergency_requests SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    /**
     * Hospital staff: view/search all patient records - same underlying rows as the
     * dispatcher's request log, but this is the read-oriented entry point for Module 4 / FR7.
     */
    public List<EmergencyRequest> getAllPatientRecords() throws SQLException {
        return getAllRequests();
    }

    /** Hospital staff: add or update a patient's medical history notes (FR7). */
    public void updateMedicalHistory(int id, String medicalHistory) throws SQLException {
        String sql = "UPDATE emergency_requests SET medical_history = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, medicalHistory);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    /** Dispatcher: remove a request record. */
    public void deleteRequest(int id) throws SQLException {
        String sql = "DELETE FROM emergency_requests WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private EmergencyRequest mapRow(ResultSet rs) throws SQLException {
        EmergencyRequest r = new EmergencyRequest(
            rs.getInt("id"),
            rs.getString("patient_name"),
            rs.getInt("patient_age"),
            rs.getString("contact_number"),
            rs.getString("location"),
            rs.getString("condition_notes"),
            rs.getString("priority"),
            rs.getString("status"),
            rs.getString("requested_by")
        );
        r.setCreatedAt(rs.getString("created_at"));
        r.setMedicalHistory(rs.getString("medical_history"));

        int assignedAmbulanceId = rs.getInt("assigned_ambulance_id");
        if (!rs.wasNull()) {
            r.setAssignedAmbulanceId(assignedAmbulanceId);
            r.setAssignedVehicleNumber(rs.getString("assigned_vehicle_number"));
        }
        int assignedDriverId = rs.getInt("assigned_driver_id");
        if (!rs.wasNull()) {
            r.setAssignedDriverId(assignedDriverId);
            r.setAssignedDriverName(rs.getString("assigned_driver_name"));
        }
        r.setAssignedAt(rs.getString("assigned_at"));
        return r;
    }
}
