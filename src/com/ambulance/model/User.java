package com.ambulance.model;

/**
 * Represents a row in the USERS table.
 * Roles: ADMIN, DISPATCHER, DRIVER, HOSPITAL_STAFF (per SRS section 2.1/2.3).
 */
public class User {
    private int id;
    private String username;
    private String password; // TODO: store hashed password in production, not plain text
    private String role;
    private String fullName;
    private String email; // used for OTP-based password reset

    public User() {
    }

    public User(int id, String username, String password, String role, String fullName) {
        this(id, username, password, role, fullName, null);
    }

    public User(int id, String username, String password, String role, String fullName, String email) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.role = role;
        this.fullName = fullName;
        this.email = email;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
