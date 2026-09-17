package com.ambulance.model;

/**
 * Represents a row in the DRIVERS table (SRS FR3 - Driver Management).
 * Status values: PENDING, VERIFIED, REJECTED.
 * assignedAmbulanceId is nullable (0 = not currently assigned to any ambulance).
 */
public class Driver {
    private int id;
    private String fullName;
    private String licenseNumber;
    private String phone;
    private String status;
    private int assignedAmbulanceId;

    // Module 4/5 (Driver self-service) - links this driver record to the DRIVER-role login
    // account that should see it under "My Assignments" / "Update Status". Nullable: 0 = not linked yet.
    private int userId;

    // Not a DB column - filled in by DriverDAO via a join, for display only.
    private String assignedVehicleNumber;
    private String loginUsername;

    public Driver() {
    }

    public Driver(int id, String fullName, String licenseNumber, String phone, String status, int assignedAmbulanceId) {
        this.id = id;
        this.fullName = fullName;
        this.licenseNumber = licenseNumber;
        this.phone = phone;
        this.status = status;
        this.assignedAmbulanceId = assignedAmbulanceId;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getLicenseNumber() { return licenseNumber; }
    public void setLicenseNumber(String licenseNumber) { this.licenseNumber = licenseNumber; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getAssignedAmbulanceId() { return assignedAmbulanceId; }
    public void setAssignedAmbulanceId(int assignedAmbulanceId) { this.assignedAmbulanceId = assignedAmbulanceId; }

    public String getAssignedVehicleNumber() { return assignedVehicleNumber; }
    public void setAssignedVehicleNumber(String assignedVehicleNumber) { this.assignedVehicleNumber = assignedVehicleNumber; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getLoginUsername() { return loginUsername; }
    public void setLoginUsername(String loginUsername) { this.loginUsername = loginUsername; }
}
