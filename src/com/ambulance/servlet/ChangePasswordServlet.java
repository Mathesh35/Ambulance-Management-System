package com.ambulance.servlet;

import com.ambulance.dao.UserDAO;
import com.ambulance.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("change_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New password and confirmation do not match.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        try {
            boolean success = userDAO.updatePassword(user.getId(), oldPassword, newPassword);
            if (success) {
                request.setAttribute("success", "Password updated successfully.");
            } else {
                request.setAttribute("error", "Current password is incorrect.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Could not update password: " + e.getMessage());
        }
        request.getRequestDispatcher("change_password.jsp").forward(request, response);
    }
}
