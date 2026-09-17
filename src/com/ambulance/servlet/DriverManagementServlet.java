package com.ambulance.servlet;

import com.ambulance.dao.AmbulanceDAO;
import com.ambulance.dao.DriverDAO;
import com.ambulance.dao.UserDAO;
import com.ambulance.model.Ambulance;
import com.ambulance.model.Driver;
import com.ambulance.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Admin-only "Driver Management" screen (SRS FR3).
 * Actions: list (default), add, edit, update, delete, verify, reject, assign - all via the "action" parameter.
 */
@WebServlet("/admin/drivers")
public class DriverManagementServlet extends HttpServlet {

    private final DriverDAO driverDAO = new DriverDAO();
    private final AmbulanceDAO ambulanceDAO = new AmbulanceDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                driverDAO.deleteDriver(id);
                response.sendRedirect("drivers");
                return;
            }
            if ("verify".equals(action) || "reject".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                driverDAO.updateStatus(id, "verify".equals(action) ? "VERIFIED" : "REJECTED");
                response.sendRedirect("drivers");
                return;
            }
            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                request.setAttribute("editDriver", driverDAO.getDriverById(id));
            }
            request.setAttribute("drivers", driverDAO.getAllDrivers());
            request.setAttribute("ambulances", ambulanceDAO.getAllAmbulances());
            request.setAttribute("driverUsers", userDAO.getUsersByRole("DRIVER"));
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("/admin/drivers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("linkUser".equals(action)) {
                int driverId = Integer.parseInt(request.getParameter("id"));
                String userParam = request.getParameter("userId");
                int userId = (userParam == null || userParam.isEmpty()) ? 0 : Integer.parseInt(userParam);
                driverDAO.linkUserAccount(driverId, userId);
                response.sendRedirect("drivers");
                return;
            }
            if ("assign".equals(action)) {
                int driverId = Integer.parseInt(request.getParameter("id"));
                String ambulanceParam = request.getParameter("ambulanceId");
                int ambulanceId = (ambulanceParam == null || ambulanceParam.isEmpty())
                        ? 0 : Integer.parseInt(ambulanceParam);

                Driver driver = driverDAO.getDriverById(driverId);
                if (driver == null || !"VERIFIED".equals(driver.getStatus())) {
                    request.setAttribute("error", "Only verified drivers can be assigned to an ambulance.");
                    request.setAttribute("drivers", driverDAO.getAllDrivers());
                    request.setAttribute("ambulances", ambulanceDAO.getAllAmbulances());
                    request.getRequestDispatcher("/admin/drivers.jsp").forward(request, response);
                    return;
                }
                driverDAO.assignAmbulance(driverId, ambulanceId);
                response.sendRedirect("drivers");
                return;
            }

            String fullName = request.getParameter("fullName");
            String licenseNumber = request.getParameter("licenseNumber");
            String phone = request.getParameter("phone");

            if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Driver driver = new Driver(id, fullName, licenseNumber, phone, null, 0);
                driverDAO.updateDriver(driver);
            } else {
                if (driverDAO.licenseNumberExists(licenseNumber)) {
                    request.setAttribute("error", "License number already registered.");
                    request.setAttribute("drivers", driverDAO.getAllDrivers());
                    request.setAttribute("ambulances", ambulanceDAO.getAllAmbulances());
                    request.getRequestDispatcher("/admin/drivers.jsp").forward(request, response);
                    return;
                }
                Driver driver = new Driver(0, fullName, licenseNumber, phone, "PENDING", 0);
                driverDAO.addDriver(driver);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        response.sendRedirect("drivers");
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && "ADMIN".equals(user.getRole());
    }
}
