package com.ambulance.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Provides a JDBC Connection to the H2 database used by the
 * Ambulance Management System.
 *
 * H2 stores the database as a file (ambulance_db.mv.db) in whatever
 * folder Tomcat is running from. AUTO_SERVER=TRUE lets you also open
 * the same file from the H2 console at the same time, for debugging.
 */
public class DBConnection {

    private static final String DB_URL =
            "jdbc:h2:./ambulance_db;AUTO_SERVER=TRUE";
    private static final String DB_USER = "sa";
    private static final String DB_PASSWORD = "";

    static {
        try {
            Class.forName("org.h2.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(
                "H2 JDBC Driver not found. Add h2-2.4.240.jar to WEB-INF/lib.", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
}
