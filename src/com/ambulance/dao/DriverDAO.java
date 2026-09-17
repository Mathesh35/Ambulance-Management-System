package com.ambulance.dao;

import com.ambulance.db.DBConnection;
import com.ambulance.model.Driver;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Handles all SQL related to the DRIVERS table (SRS FR3 - Driver Management).
 * Covers registration, verification, and assignment to ambulances.
 */
public class DriverDAO {

    private static final String SELECT_BASE =
        "SELECT d.id, d.full_name, d.license_number, d.phone, d.status, d.assigned_ambulance_id, d.user_id, " +
        "       a.vehicle_number AS assigned_vehicle_number, u.username AS login_username " +
        "FROM drivers d " +
        "LEFT JOIN ambulances a ON d.assigned_ambulance_id = a.id " +
        "LEFT JOIN users u ON d.user_id = u.id ";

    /** Admin: list all drivers, with the vehicle number of whatever ambulance they're assigned to (if any). */
    public List<Driver> getAllDrivers() throws SQLException {
        List<Driver> drivers = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY d.id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                drivers.add(mapRow(rs));
            }
        }
        return drivers;
    }

    public Driver getDriverById(int id) throws SQLException {
        String sql = SELECT_BASE + "WHERE d.id = ?";
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

    /** Returns true if the license number is already registered. */
    public boolean licenseNumberExists(String licenseNumber) throws SQLException {
        String sql = "SELECT 1 FROM drivers WHERE license_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, licenseNumber);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Admin: register a new driver. New drivers always start out PENDING verification. */
    public void addDriver(Driver driver) throws SQLException {
        String sql = "INSERT INTO drivers (full_name, license_number, phone, status, assigned_ambulance_id) " +
                     "VALUES (?, ?, ?, 'PENDING', NULL)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, driver.getFullName());
            ps.setString(2, driver.getLicenseNumber());
            ps.setString(3, driver.getPhone());
            ps.executeUpdate();
        }
    }

    /** Admin: update a driver's basic details (name/license/phone). Status and assignment are changed separately. */
    public void updateDriver(Driver driver) throws SQLException {
        String sql = "UPDATE drivers SET full_name = ?, license_number = ?, phone = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, driver.getFullName());
            ps.setString(2, driver.getLicenseNumber());
            ps.setString(3, driver.getPhone());
            ps.setInt(4, driver.getId());
            ps.executeUpdate();
        }
    }

    /** Admin: verify or reject a driver's registration. */
    public void updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE drivers SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    /**
     * Admin: assign a driver to an ambulance (or unassign if ambulanceId is 0).
     * Only VERIFIED drivers should be assignable - enforced in the servlet.
     */
    public void assignAmbulance(int driverId, int ambulanceId) throws SQLException {
        String sql = "UPDATE drivers SET assigned_ambulance_id = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (ambulanceId <= 0) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, ambulanceId);
            }
            ps.setInt(2, driverId);
            ps.executeUpdate();
        }
    }

    /** Driver self-service: find the driver record linked to a given login account, if any. */
    public Driver getDriverByUserId(int userId) throws SQLException {
        String sql = SELECT_BASE + "WHERE d.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /** Admin: link (or unlink, if userId is 0) a driver record to a DRIVER-role login account. */
    public void linkUserAccount(int driverId, int userId) throws SQLException {
        String sql = "UPDATE drivers SET user_id = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId <= 0) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, userId);
            }
            ps.setInt(2, driverId);
            ps.executeUpdate();
        }
    }

    /** Admin: remove a driver record. Also frees up any ambulance they were assigned to. */
    public void deleteDriver(int id) throws SQLException {
        String sql = "DELETE FROM drivers WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private Driver mapRow(ResultSet rs) throws SQLException {
        Driver d = new Driver(
            rs.getInt("id"),
            rs.getString("full_name"),
            rs.getString("license_number"),
            rs.getString("phone"),
            rs.getString("status"),
            rs.getInt("assigned_ambulance_id")
        );
        d.setAssignedVehicleNumber(rs.getString("assigned_vehicle_number"));
        int userId = rs.getInt("user_id");
        if (!rs.wasNull()) {
            d.setUserId(userId);
            d.setLoginUsername(rs.getString("login_username"));
        }
        return d;
    }
}
