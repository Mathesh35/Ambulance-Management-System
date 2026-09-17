package com.ambulance.servlet;

import com.ambulance.dao.UserDAO;
import com.ambulance.util.EmailService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;

/**
 * Forgot Password flow, done in two steps using an emailed OTP:
 *   Step 1 (action=send): user enters username + role. If that account has
 *     an email on file, a 6-digit OTP is generated, stored in their session
 *     (with a 10-minute expiry), and emailed to them via EmailService.
 *   Step 2 (action=verify): user enters the OTP + new password. If the OTP
 *     matches what's in their session and hasn't expired, the password is reset.
 */
@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private static final long OTP_VALID_MILLIS = 10 * 60 * 1000; // 10 minutes

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String step = request.getParameter("step");
        if ("verify".equals(step)) {
            handleVerifyAndReset(request, response);
        } else {
            handleSendOtp(request, response);
        }
    }

    /** Step 1: look up the account, generate an OTP, email it, and show the OTP entry form. */
    private void handleSendOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String role = request.getParameter("role");

        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("error", "Please enter your username.");
            request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
            return;
        }

        try {
            String email = userDAO.getEmailForUsernameAndRole(username, role);
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "No account with that username/role has an email on file. Contact an administrator.");
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
                return;
            }

            String otp = generateOtp();
            HttpSession session = request.getSession();
            session.setAttribute("resetOtp", otp);
            session.setAttribute("resetOtpExpiry", System.currentTimeMillis() + OTP_VALID_MILLIS);
            session.setAttribute("resetUsername", username);
            session.setAttribute("resetRole", role);

            boolean sent = EmailService.sendOtpEmail(email, otp);
            if (!sent) {
                request.setAttribute("error", "Could not send the OTP email. Check the EmailService configuration (Gmail address/App Password) and try again.");
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
                return;
            }

            request.setAttribute("otpSent", true);
            request.setAttribute("maskedEmail", maskEmail(email));
            request.setAttribute("username", username);
            request.setAttribute("role", role);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
    }

    /** Step 2: check the submitted OTP against the session, then reset the password. */
    private void handleVerifyAndReset(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String sessionOtp = (session != null) ? (String) session.getAttribute("resetOtp") : null;
        Long expiry = (session != null) ? (Long) session.getAttribute("resetOtpExpiry") : null;
        String username = (session != null) ? (String) session.getAttribute("resetUsername") : null;
        String role = (session != null) ? (String) session.getAttribute("resetRole") : null;

        String enteredOtp = request.getParameter("otp");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (sessionOtp == null || username == null) {
            request.setAttribute("error", "Your reset session expired. Please request a new OTP.");
            request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
            return;
        }

        // Keep showing the OTP step (not the initial form) if something below fails.
        request.setAttribute("otpSent", true);
        request.setAttribute("username", username);
        request.setAttribute("role", role);

        if (expiry == null || System.currentTimeMillis() > expiry) {
            clearOtpSession(session);
            request.setAttribute("otpSent", false);
            request.setAttribute("error", "That OTP has expired. Please request a new one.");
            request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
            return;
        }

        if (enteredOtp == null || !enteredOtp.trim().equals(sessionOtp)) {
            request.setAttribute("error", "Incorrect OTP. Please check your email and try again.");
            request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
            return;
        }

        if (newPassword == null || newPassword.length() < 6) {
            request.setAttribute("error", "New password must be at least 6 characters.");
            request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New password and confirmation do not match.");
            request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
            return;
        }

        try {
            boolean success = userDAO.resetPassword(username, role, newPassword);
            clearOtpSession(session);
            if (success) {
                request.setAttribute("otpSent", false);
                request.setAttribute("success", "Password reset successfully. You can now sign in with your new password.");
            } else {
                request.setAttribute("error", "No account found with that username and role.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Could not reset password: " + e.getMessage());
        }
        request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
    }

    private void clearOtpSession(HttpSession session) {
        if (session == null) return;
        session.removeAttribute("resetOtp");
        session.removeAttribute("resetOtpExpiry");
        session.removeAttribute("resetUsername");
        session.removeAttribute("resetRole");
    }

    private String generateOtp() {
        SecureRandom random = new SecureRandom();
        int code = 100000 + random.nextInt(900000); // always 6 digits
        return String.valueOf(code);
    }

    /** e.g. "admin@example.com" -> "ad***@example.com" */
    private String maskEmail(String email) {
        int at = email.indexOf('@');
        if (at <= 1) return email;
        String name = email.substring(0, at);
        String domain = email.substring(at);
        String visible = name.substring(0, Math.min(2, name.length()));
        return visible + "***" + domain;
    }
}
