package com.ambulance.listener;

import com.ambulance.db.DBConnection;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Runs once when Tomcat starts the app. Creates the USERS table in the H2
 * database if it doesn't exist yet, and seeds one test login per SRS role
 * so the app is usable immediately without running SQL by hand.
 */
@WebListener
public class DBInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try (Connection conn = DBConnection.getConnection()) {

            try (Statement st = conn.createStatement()) {
                st.execute(
                    "CREATE TABLE IF NOT EXISTS users (" +
                    "  id INT AUTO_INCREMENT PRIMARY KEY," +
                    "  username VARCHAR(50) NOT NULL UNIQUE," +
                    "  password VARCHAR(100) NOT NULL," +
                    "  role VARCHAR(20) NOT NULL," + // ADMIN, DISPATCHER, DRIVER, HOSPITAL_STAFF
                    "  full_name VARCHAR(100) NOT NULL," +
                    "  email VARCHAR(150)" +
                    ")"
                );
            }

            // For databases created before the email column existed (upgrade path).
            try (Statement st = conn.createStatement()) {
                st.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(150)");
            }

            // Seed default accounts only if the table is currently empty.
            try (PreparedStatement count = conn.prepareStatement("SELECT COUNT(*) FROM users");
                 ResultSet rs = count.executeQuery()) {
                rs.next();
                if (rs.getInt(1) == 0) {
                    seedUser(conn, "admin", "admin123", "ADMIN", "System Administrator", "admin@example.com");
                    seedUser(conn, "dispatcher", "dispatch123", "DISPATCHER", "Dispatch Operator", "dispatcher@example.com");
                    seedUser(conn, "driver", "driver123", "DRIVER", "Ambulance Driver", "driver@example.com");
                    seedUser(conn, "hospital", "hospital123", "HOSPITAL_STAFF", "Hospital Staff", "hospital@example.com");
                }
            }

            try (Statement st = conn.createStatement()) {
                st.execute(
                    "CREATE TABLE IF NOT EXISTS ambulances (" +
                    "  id INT AUTO_INCREMENT PRIMARY KEY," +
                    "  vehicle_number VARCHAR(20) NOT NULL UNIQUE," +
                    "  type VARCHAR(30) NOT NULL," + // BASIC, ADVANCED, PATIENT_TRANSPORT
                    "  status VARCHAR(20) NOT NULL," + // AVAILABLE, ON_DUTY, MAINTENANCE
                    "  current_location VARCHAR(150)" +
                    ")"
                );
            }

            // Seed a few sample ambulances only if the table is currently empty.
            try (PreparedStatement count = conn.prepareStatement("SELECT COUNT(*) FROM ambulances");
                 ResultSet rs = count.executeQuery()) {
                rs.next();
                if (rs.getInt(1) == 0) {
                    seedAmbulance(conn, "AMB-101", "ADVANCED", "AVAILABLE", "Central Station");
                    seedAmbulance(conn, "AMB-102", "BASIC", "ON_DUTY", "Downtown District");
                    seedAmbulance(conn, "AMB-103", "PATIENT_TRANSPORT", "MAINTENANCE", "Service Depot");
                }
            }

            try (Statement st = conn.createStatement()) {
                st.execute(
                    "CREATE TABLE IF NOT EXISTS drivers (" +
                    "  id INT AUTO_INCREMENT PRIMARY KEY," +
                    "  full_name VARCHAR(100) NOT NULL," +
                    "  license_number VARCHAR(30) NOT NULL UNIQUE," +
                    "  phone VARCHAR(20)," +
                    "  status VARCHAR(20) NOT NULL," + // PENDING, VERIFIED, REJECTED
                    "  assigned_ambulance_id INT," +
                    "  FOREIGN KEY (assigned_ambulance_id) REFERENCES ambulances(id) ON DELETE SET NULL" +
                    ")"
                );
            }

            // For databases created before drivers could be linked to a login account (upgrade path).
            try (Statement st = conn.createStatement()) {
                st.execute("ALTER TABLE drivers ADD COLUMN IF NOT EXISTS user_id INT");
            }

            // Seed a few sample drivers only if the table is currently empty.
            try (PreparedStatement count = conn.prepareStatement("SELECT COUNT(*) FROM drivers");
                 ResultSet rs = count.executeQuery()) {
                rs.next();
                if (rs.getInt(1) == 0) {
                    seedDriver(conn, "Ravi Kumar", "DL-TN-0192837", "9876543210", "VERIFIED", 1);
                    seedDriver(conn, "Suresh Babu", "DL-TN-0293845", "9876543211", "VERIFIED", 2);
                    seedDriver(conn, "Arun Prasad", "DL-TN-0394856", "9876543212", "PENDING", null);

                    // Link the first seeded driver to the seeded "driver" login so
                    // "My Assignments / Update Status" works out of the box.
                    try (PreparedStatement link = conn.prepareStatement(
                            "UPDATE drivers SET user_id = (SELECT id FROM users WHERE username = 'driver') " +
                            "WHERE license_number = 'DL-TN-0192837'")) {
                        link.executeUpdate();
                    }
                }
            }

            try (Statement st = conn.createStatement()) {
                st.execute(
                    "CREATE TABLE IF NOT EXISTS emergency_requests (" +
                    "  id INT AUTO_INCREMENT PRIMARY KEY," +
                    "  patient_name VARCHAR(100) NOT NULL," +
                    "  patient_age INT," +
                    "  contact_number VARCHAR(20)," +
                    "  location VARCHAR(200) NOT NULL," +
                    "  condition_notes VARCHAR(500)," +
                    "  priority VARCHAR(20) NOT NULL," + // LOW, MEDIUM, HIGH, CRITICAL
                    "  status VARCHAR(20) NOT NULL," +    // PENDING, ASSIGNED, COMPLETED, CANCELLED
                    "  requested_by VARCHAR(100)," +
                    "  created_at TIMESTAMP" +
                    ")"
                );
            }

            // For databases created before Module 5 (upgrade path), same pattern as users.email above.
            try (Statement st = conn.createStatement()) {
                st.execute("ALTER TABLE emergency_requests ADD COLUMN IF NOT EXISTS assigned_ambulance_id INT");
            }
            try (Statement st = conn.createStatement()) {
                st.execute("ALTER TABLE emergency_requests ADD COLUMN IF NOT EXISTS assigned_driver_id INT");
            }
            try (Statement st = conn.createStatement()) {
                st.execute("ALTER TABLE emergency_requests ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMP");
            }
            // For databases created before the Hospital "Patient Records" screen (FR7) existed.
            try (Statement st = conn.createStatement()) {
                st.execute("ALTER TABLE emergency_requests ADD COLUMN IF NOT EXISTS medical_history VARCHAR(1000)");
            }

            // Seed a few sample emergency requests only if the table is currently empty.
            try (PreparedStatement count = conn.prepareStatement("SELECT COUNT(*) FROM emergency_requests");
                 ResultSet rs = count.executeQuery()) {
                rs.next();
                if (rs.getInt(1) == 0) {
                    seedRequest(conn, "Meena Raj", 54, "9876500011", "12 Anna Nagar, Chennai",
                            "Chest pain, difficulty breathing", "CRITICAL", "PENDING", "Dispatch Operator");
                    seedRequest(conn, "Karthik S", 29, "9876500022", "MG Road bus stop, Chennai",
                            "Road traffic accident, leg injury", "HIGH", "PENDING", "Dispatch Operator");
                    seedRequest(conn, "Lakshmi N", 68, "9876500033", "7 Lake View Colony, Chennai",
                            "Routine transfer for dialysis", "LOW", "COMPLETED", "Dispatch Operator");
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to initialize the database", e);
        }
    }

    private void seedRequest(Connection conn, String patientName, int patientAge, String contactNumber,
                              String location, String conditionNotes, String priority, String status,
                              String requestedBy) throws SQLException {
        String sql = "INSERT INTO emergency_requests " +
                     "(patient_name, patient_age, contact_number, location, condition_notes, priority, status, requested_by, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patientName);
            ps.setInt(2, patientAge);
            ps.setString(3, contactNumber);
            ps.setString(4, location);
            ps.setString(5, conditionNotes);
            ps.setString(6, priority);
            ps.setString(7, status);
            ps.setString(8, requestedBy);
            ps.executeUpdate();
        }
    }

    private void seedDriver(Connection conn, String fullName, String licenseNumber, String phone,
                             String status, Integer assignedAmbulanceId) throws SQLException {
        String sql = "INSERT INTO drivers (full_name, license_number, phone, status, assigned_ambulance_id) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, licenseNumber);
            ps.setString(3, phone);
            ps.setString(4, status);
            if (assignedAmbulanceId == null) {
                ps.setNull(5, java.sql.Types.INTEGER);
            } else {
                ps.setInt(5, assignedAmbulanceId);
            }
            ps.executeUpdate();
        }
    }

    private void seedAmbulance(Connection conn, String vehicleNumber, String type, String status, String location)
            throws SQLException {
        String sql = "INSERT INTO ambulances (vehicle_number, type, status, current_location) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, vehicleNumber);
            ps.setString(2, type);
            ps.setString(3, status);
            ps.setString(4, location);
            ps.executeUpdate();
        }
    }

    private void seedUser(Connection conn, String username, String password, String role, String fullName, String email)
            throws SQLException {
        String sql = "INSERT INTO users (username, password, role, full_name, email) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password); // TODO: hash before storing (see UserDAO)
            ps.setString(3, role);
            ps.setString(4, fullName);
            ps.setString(5, email);
            ps.executeUpdate();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // no-op
    }
}
