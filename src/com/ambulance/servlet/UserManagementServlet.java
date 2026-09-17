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

/**
 * Admin-only "Manage users" screen (SRS section 2.3).
 * Actions: list (default), add, edit, delete - all via the "action" parameter.
 */
@WebServlet("/admin/users")
public class UserManagementServlet extends HttpServlet {

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
                userDAO.deleteUser(id);
                response.sendRedirect("users");
                return;
            }
            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                request.setAttribute("editUser", userDAO.getUserById(id));
            }
            request.setAttribute("users", userDAO.getAllUsers());
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");

        try {
            if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                User user = new User(id, username, null, role, fullName, email);
                userDAO.updateUser(user);
            } else {
                if (userDAO.usernameExists(username)) {
                    request.setAttribute("error", "Username already exists.");
                    request.setAttribute("users", userDAO.getAllUsers());
                    request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
                    return;
                }
                User user = new User(0, username, password, role, fullName, email);
                userDAO.addUser(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        response.sendRedirect("users");
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && "ADMIN".equals(user.getRole());
    }
}
