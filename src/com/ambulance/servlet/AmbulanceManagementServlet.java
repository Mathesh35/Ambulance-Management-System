package com.ambulance.servlet;

import com.ambulance.dao.AmbulanceDAO;
import com.ambulance.model.Ambulance;
import com.ambulance.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Admin-only "Ambulance Management" screen (SRS FR2).
 * Actions: list (default), add, edit, delete - all via the "action" parameter.
 */
@WebServlet("/admin/ambulances")
public class AmbulanceManagementServlet extends HttpServlet {

    private final AmbulanceDAO ambulanceDAO = new AmbulanceDAO();

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
                ambulanceDAO.deleteAmbulance(id);
                response.sendRedirect("ambulances");
                return;
            }
            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                request.setAttribute("editAmbulance", ambulanceDAO.getAmbulanceById(id));
            }
            request.setAttribute("ambulances", ambulanceDAO.getAllAmbulances());
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("/admin/ambulances.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String vehicleNumber = request.getParameter("vehicleNumber");
        String type = request.getParameter("type");
        String status = request.getParameter("status");
        String currentLocation = request.getParameter("currentLocation");

        try {
            if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Ambulance ambulance = new Ambulance(id, vehicleNumber, type, status, currentLocation);
                ambulanceDAO.updateAmbulance(ambulance);
            } else {
                if (ambulanceDAO.vehicleNumberExists(vehicleNumber)) {
                    request.setAttribute("error", "Vehicle number already registered.");
                    request.setAttribute("ambulances", ambulanceDAO.getAllAmbulances());
                    request.getRequestDispatcher("/admin/ambulances.jsp").forward(request, response);
                    return;
                }
                Ambulance ambulance = new Ambulance(0, vehicleNumber, type, status, currentLocation);
                ambulanceDAO.addAmbulance(ambulance);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        response.sendRedirect("ambulances");
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && "ADMIN".equals(user.getRole());
    }
}
