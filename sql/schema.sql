-- Ambulance Management System — H2 schema reference for Module 1 (User Authentication)
--
-- NOTE: You do NOT need to run this by hand. DBInitializer.java (a
-- @WebListener) runs this automatically the first time Tomcat starts the
-- app, and seeds one login per role if the table is empty. This file is
-- just here for reference / if you want to inspect the schema in the H2
-- console (http://localhost:8082 if you run the H2 console tool, connecting
-- to jdbc:h2:./ambulance_db;AUTO_SERVER=TRUE from Tomcat's working directory).

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL, -- ADMIN, DISPATCHER, DRIVER, HOSPITAL_STAFF
    full_name VARCHAR(100) NOT NULL
);

-- Seeded automatically by DBInitializer on first run:
-- admin      / admin123    / ADMIN
-- dispatcher / dispatch123 / DISPATCHER
-- driver     / driver123   / DRIVER
-- hospital   / hospital123 / HOSPITAL_STAFF
--
-- NOTE: passwords are stored in plain text for now (see UserDAO TODOs) —
-- swap in hashing (e.g. BCrypt) before this goes anywhere near production.

-- H2 schema reference for Module 3 (Driver Management). Also created
-- automatically by DBInitializer.java.

CREATE TABLE IF NOT EXISTS drivers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(30) NOT NULL UNIQUE,
    phone VARCHAR(20),
    status VARCHAR(20) NOT NULL,        -- PENDING, VERIFIED, REJECTED
    assigned_ambulance_id INT,          -- FK -> ambulances.id, NULL if unassigned
    user_id INT,                        -- FK -> users.id (role DRIVER), links this record to a login for "My Assignments"
    FOREIGN KEY (assigned_ambulance_id) REFERENCES ambulances(id) ON DELETE SET NULL
);

-- Seeded automatically by DBInitializer on first run:
-- Ravi Kumar   / DL-TN-0192837 / VERIFIED / assigned to AMB-101
-- Suresh Babu  / DL-TN-0293845 / VERIFIED / assigned to AMB-102
-- Arun Prasad  / DL-TN-0394856 / PENDING  / unassigned

-- H2 schema reference for Module 4 (Patient/Emergency Request Management).
-- Also created automatically by DBInitializer.java.

CREATE TABLE IF NOT EXISTS emergency_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    patient_age INT,
    contact_number VARCHAR(20),
    location VARCHAR(200) NOT NULL,
    condition_notes VARCHAR(500),
    priority VARCHAR(20) NOT NULL,      -- LOW, MEDIUM, HIGH, CRITICAL
    status VARCHAR(20) NOT NULL,        -- PENDING, ASSIGNED, COMPLETED, CANCELLED
    requested_by VARCHAR(100),          -- dispatcher who logged the request
    created_at TIMESTAMP,
    assigned_ambulance_id INT,          -- FK -> ambulances.id, set by Module 5 (Allocation)
    assigned_driver_id INT,             -- FK -> drivers.id, set by Module 5 (Allocation)
    assigned_at TIMESTAMP,              -- when the ambulance was assigned, used for ETA/tracking
    medical_history VARCHAR(1000)       -- maintained by hospital staff on the Patient Records screen (FR7)
);

-- Seeded automatically by DBInitializer on first run:
-- Meena Raj  / CRITICAL / PENDING
-- Karthik S  / HIGH     / PENDING
-- Lakshmi N  / LOW      / COMPLETED
