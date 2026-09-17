package com.ambulance.model;

/**
 * Represents a row in the AMBULANCES table (SRS FR2 - Ambulance Management).
 * Status values: AVAILABLE, ON_DUTY, MAINTENANCE.
 */
public class Ambulance {
    private int id;
    private String vehicleNumber;
    private String type;
    private String status;
    private String currentLocation;

    public Ambulance() {
    }

    public Ambulance(int id, String vehicleNumber, String type, String status, String currentLocation) {
        this.id = id;
        this.vehicleNumber = vehicleNumber;
        this.type = type;
        this.status = status;
        this.currentLocation = currentLocation;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getVehicleNumber() { return vehicleNumber; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCurrentLocation() { return currentLocation; }
    public void setCurrentLocation(String currentLocation) { this.currentLocation = currentLocation; }
}
