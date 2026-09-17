package com.ambulance.model;

/**
 * Represents a row in the EMERGENCY_REQUESTS table (SRS FR4 - Patient/Emergency
 * Request Management). Captures patient details and the emergency itself.
 * Status values: PENDING, ASSIGNED, COMPLETED, CANCELLED.
 * (ASSIGNED is set later by Module 5 - Ambulance Allocation; this module only
 * creates/tracks the request and lets the dispatcher mark it COMPLETED/CANCELLED.)
 */
public class EmergencyRequest {
    private int id;
    private String patientName;
    private int patientAge;
    private String contactNumber;
    private String location;
    private String condition;
    private String priority;       // LOW, MEDIUM, HIGH, CRITICAL
    private String status;         // PENDING, ASSIGNED, COMPLETED, CANCELLED
    private String requestedBy;    // full name of the dispatcher who logged it
    private String createdAt;      // formatted timestamp, filled in by the DAO
    private String medicalHistory; // Module 4 / FR7 - maintained by hospital staff on the Patient Records screen

    // Module 5 (Nearest Ambulance Allocation & Tracking) - set once a request is ASSIGNED.
    private int assignedAmbulanceId;       // 0 = not yet assigned
    private String assignedVehicleNumber;  // not a DB column - filled in by the DAO via a join, for display only
    private int assignedDriverId;          // 0 = not yet assigned
    private String assignedDriverName;     // not a DB column - filled in by the DAO via a join, for display only
    private String assignedAt;             // formatted timestamp, filled in by the DAO

    public EmergencyRequest() {
    }

    public EmergencyRequest(int id, String patientName, int patientAge, String contactNumber,
                             String location, String condition, String priority, String status,
                             String requestedBy) {
        this.id = id;
        this.patientName = patientName;
        this.patientAge = patientAge;
        this.contactNumber = contactNumber;
        this.location = location;
        this.condition = condition;
        this.priority = priority;
        this.status = status;
        this.requestedBy = requestedBy;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public int getPatientAge() { return patientAge; }
    public void setPatientAge(int patientAge) { this.patientAge = patientAge; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getCondition() { return condition; }
    public void setCondition(String condition) { this.condition = condition; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getRequestedBy() { return requestedBy; }
    public void setRequestedBy(String requestedBy) { this.requestedBy = requestedBy; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getMedicalHistory() { return medicalHistory; }
    public void setMedicalHistory(String medicalHistory) { this.medicalHistory = medicalHistory; }

    public int getAssignedAmbulanceId() { return assignedAmbulanceId; }
    public void setAssignedAmbulanceId(int assignedAmbulanceId) { this.assignedAmbulanceId = assignedAmbulanceId; }

    public String getAssignedVehicleNumber() { return assignedVehicleNumber; }
    public void setAssignedVehicleNumber(String assignedVehicleNumber) { this.assignedVehicleNumber = assignedVehicleNumber; }

    public int getAssignedDriverId() { return assignedDriverId; }
    public void setAssignedDriverId(int assignedDriverId) { this.assignedDriverId = assignedDriverId; }

    public String getAssignedDriverName() { return assignedDriverName; }
    public void setAssignedDriverName(String assignedDriverName) { this.assignedDriverName = assignedDriverName; }

    public String getAssignedAt() { return assignedAt; }
    public void setAssignedAt(String assignedAt) { this.assignedAt = assignedAt; }
}
