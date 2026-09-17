package com.ambulance.servlet;

import com.ambulance.dao.EmergencyRequestDAO;
import com.ambulance.model.EmergencyRequest;
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
 * Hospital Staff-only "Patient Records" screen (SRS FR7, part of Module 4 -
 * Patient/Emergency Request Management). Lets hospital staff view every
 * patient/emergency record logged by dispatch and add/update the patient's
 * medical history notes. Read-only on everything else - hospital staff
 * cannot edit the emergency details themselves, only the medical history.
 */
@WebServlet("/hospital/patients")
public class PatientRecordsServlet extends HttpServlet {

    private final EmergencyRequestDAO requestDAO = new EmergencyRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isHospitalStaff(request)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                request.setAttribute("editRecord", requestDAO.getRequestById(id));
            }
            request.setAttribute("records", requestDAO.getAllPatientRecords());
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("/hospital/patients.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isHospitalStaff(request)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String medicalHistory = request.getParameter("medicalHistory");
            requestDAO.updateMedicalHistory(id, medicalHistory);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        response.sendRedirect("patients");
    }

    private boolean isHospitalStaff(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && "HOSPITAL_STAFF".equals(user.getRole());
    }
}
