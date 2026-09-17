package com.ambulance.dao;

import com.ambulance.db.DBConnection;
import com.ambulance.model.Ambulance;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Handles all SQL related to the AMBULANCES table (SRS FR2 - Ambulance Management).
 */
public class AmbulanceDAO {

    /** Admin: list all ambulances. */
    public List<Ambulance> getAllAmbulances() throws SQLException {
        List<Ambulance> ambulances = new ArrayList<>();
        String sql = "SELECT id, vehicle_number, type, status, current_location FROM ambulances ORDER BY id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ambulances.add(mapRow(rs));
            }
        }
        return ambulances;
    }

    /** Module 5 (Allocation): only ambulances currently free to dispatch. */
    public List<Ambulance> getAvailableAmbulances() throws SQLException {
        List<Ambulance> ambulances = new ArrayList<>();
        String sql = "SELECT id, vehicle_number, type, status, current_location FROM ambulances " +
                     "WHERE status = 'AVAILABLE' ORDER BY id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ambulances.add(mapRow(rs));
            }
        }
        return ambulances;
    }

    public Ambulance getAmbulanceById(int id) throws SQLException {
        String sql = "SELECT id, vehicle_number, type, status, current_location FROM ambulances WHERE id = ?";
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

    /** Returns true if the vehicle number is already registered. */
    public boolean vehicleNumberExists(String vehicleNumber) throws SQLException {
        String sql = "SELECT 1 FROM ambulances WHERE vehicle_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, vehicleNumber);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Admin: register a new ambulance. */
    public void addAmbulance(Ambulance ambulance) throws SQLException {
        String sql = "INSERT INTO ambulances (vehicle_number, type, status, current_location) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ambulance.getVehicleNumber());
            ps.setString(2, ambulance.getType());
            ps.setString(3, ambulance.getStatus());
            ps.setString(4, ambulance.getCurrentLocation());
            ps.executeUpdate();
        }
    }

    /** Admin: update an existing ambulance's details/status. */
    public void updateAmbulance(Ambulance ambulance) throws SQLException {
        String sql = "UPDATE ambulances SET vehicle_number = ?, type = ?, status = ?, current_location = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ambulance.getVehicleNumber());
            ps.setString(2, ambulance.getType());
            ps.setString(3, ambulance.getStatus());
            ps.setString(4, ambulance.getCurrentLocation());
            ps.setInt(5, ambulance.getId());
            ps.executeUpdate();
        }
    }

    /** Module 5 (Allocation/Tracking): flip status only, e.g. AVAILABLE -&gt; ON_DUTY on assignment. */
    public void updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE ambulances SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    /** Module 5 (Tracking) / Driver self-service: update just the live location text, without changing status. */
    public void updateLocation(int id, String location) throws SQLException {
        String sql = "UPDATE ambulances SET current_location = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, location);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    /**
     * Module 5 (Tracking): once an ambulance reaches the patient, treat that location
     * as its new "current location" (also flips status back to AVAILABLE).
     */
    public void markArrivedAndFree(int id, String newLocation) throws SQLException {
        String sql = "UPDATE ambulances SET status = 'AVAILABLE', current_location = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newLocation);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    /** Admin: remove an ambulance from the fleet. */
    public void deleteAmbulance(int id) throws SQLException {
        String sql = "DELETE FROM ambulances WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private Ambulance mapRow(ResultSet rs) throws SQLException {
        return new Ambulance(
            rs.getInt("id"),
            rs.getString("vehicle_number"),
            rs.getString("type"),
            rs.getString("status"),
            rs.getString("current_location")
        );
    }
}
