package com.ambulance.dao;

import com.ambulance.db.DBConnection;
import com.ambulance.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Handles all SQL related to the USERS table.
 * Covers SRS FR1 (User Login), and the Admin "Manage users" characteristic (2.3).
 */
public class UserDAO {

    /** Looks up a user by username/password/role. Returns the User if credentials match, else null. */
    public User validateLogin(String username, String password, String role) throws SQLException {
        String sql = "SELECT id, username, password, role, full_name, email FROM users " +
                     "WHERE username = ? AND password = ? AND role = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password); // TODO: compare hashed password instead of plain text
            ps.setString(3, role);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /** Returns true if the username is already taken. */
    public boolean usernameExists(String username) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Admin: list all users. */
    public List<User> getAllUsers() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, username, password, role, full_name, email FROM users ORDER BY id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(mapRow(rs));
            }
        }
        return users;
    }

    /** Admin (Driver Management): list login accounts for a given role, e.g. DRIVER, so one can be linked to a driver record. */
    public List<User> getUsersByRole(String role) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, username, password, role, full_name, email FROM users WHERE role = ? ORDER BY full_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapRow(rs));
                }
            }
        }
        return users;
    }

    public User getUserById(int id) throws SQLException {
        String sql = "SELECT id, username, password, role, full_name, email FROM users WHERE id = ?";
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
     * Forgot Password (OTP) step 1: looks up the account by username + role and
     * returns its email address, or null if no such account exists / it has no
     * email on file. The caller uses this address to send the OTP.
     */
    public String getEmailForUsernameAndRole(String username, String role) throws SQLException {
        String sql = "SELECT email FROM users WHERE username = ? AND role = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, role);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("email");
                }
            }
        }
        return null;
    }

    /** Admin: add a new user (login credentials for a Dispatcher, Driver, Hospital Staff, or Admin). */
    public void addUser(User user) throws SQLException {
        String sql = "INSERT INTO users (username, password, role, full_name, email) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword()); // TODO: hash before storing
            ps.setString(3, user.getRole());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getEmail());
            ps.executeUpdate();
        }
    }

    /** Admin: update an existing user's username/role/full name/email. */
    public void updateUser(User user) throws SQLException {
        String sql = "UPDATE users SET username = ?, role = ?, full_name = ?, email = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getRole());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setInt(5, user.getId());
            ps.executeUpdate();
        }
    }

    /** Admin: delete a user account. */
    public void deleteUser(int id) throws SQLException {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    /** Change Password feature (SRS product function, section 2.2). Returns true if the old password matched. */
    public boolean updatePassword(int userId, String oldPassword, String newPassword) throws SQLException {
        String checkSql = "SELECT id FROM users WHERE id = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setInt(1, userId);
                check.setString(2, oldPassword); // TODO: compare hashed password
                try (ResultSet rs = check.executeQuery()) {
                    if (!rs.next()) {
                        return false;
                    }
                }
            }
            String updateSql = "UPDATE users SET password = ? WHERE id = ?";
            try (PreparedStatement update = conn.prepareStatement(updateSql)) {
                update.setString(1, newPassword); // TODO: hash before storing
                update.setInt(2, userId);
                update.executeUpdate();
            }
        }
        return true;
    }

    /**
     * Forgot Password (OTP) step 2: after the OTP the user typed has already
     * been verified by ForgotPasswordServlet against the session, this sets
     * the new password. Returns true if a matching account was found and updated.
     */
    public boolean resetPassword(String username, String role, String newPassword) throws SQLException {
        String sql = "UPDATE users SET password = ? WHERE username = ? AND role = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword); // TODO: hash before storing
            ps.setString(2, username);
            ps.setString(3, role);
            int rowsUpdated = ps.executeUpdate();
            return rowsUpdated > 0;
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        return new User(
            rs.getInt("id"),
            rs.getString("username"),
            rs.getString("password"),
            rs.getString("role"),
            rs.getString("full_name"),
            rs.getString("email")
        );
    }
}
