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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role"); // from the "Login As" dropdown

        try {
            User user = userDAO.validateLogin(username, password, role);

            if (user != null) {
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                response.sendRedirect(dashboardFor(user.getRole()));
            } else {
                request.setAttribute("error", "Invalid username or password.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Could not connect to the database: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private String dashboardFor(String role) {
        switch (role) {
            case "ADMIN":          return "dashboard_admin.jsp";
            case "DISPATCHER":     return "dashboard_dispatcher.jsp";
            case "DRIVER":         return "dashboard_driver.jsp";
            case "HOSPITAL_STAFF": return "dashboard_hospital.jsp";
            default:               return "login.jsp";
        }
    }
}
