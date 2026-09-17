<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    boolean otpSent = Boolean.TRUE.equals(request.getAttribute("otpSent"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Forgot Password | Ambulance Management System</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

    <!-- Top bar -->
    <header class="topbar">
        <div class="brand">
            <span class="brand-badge">
                <svg viewBox="0 0 24 24" width="22" height="22" fill="none"><path d="M12 3v18M3 12h18" stroke="#fff" stroke-width="3.2" stroke-linecap="round"/></svg>
            </span>
            <div class="brand-text">
                <span class="brand-eyebrow">24 / 7 EMERGENCY RESPONSE</span>
                <span class="brand-title">Ambulance Management System</span>
            </div>
        </div>
        <div class="helpline">
            <span class="helpline-icon">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="none"><path d="M6.6 10.8c1.4 2.8 3.8 5.2 6.6 6.6l2.2-2.2c.3-.3.7-.4 1.1-.2 1.2.4 2.5.6 3.8.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1C10.9 21 3 13.1 3 3.7c0-.6.4-1 1-1h3.4c.6 0 1 .4 1 1 0 1.3.2 2.6.6 3.8.1.4 0 .8-.2 1.1L6.6 10.8Z" stroke="#e0342c" stroke-width="1.8" stroke-linejoin="round"/></svg>
            </span>
            <div class="helpline-text">
                <span class="helpline-label">Emergency Helpline</span>
                <span class="helpline-number">108</span>
            </div>
        </div>
    </header>

    <!-- Hero + reset card -->
    <main class="hero">
        <div class="hero-overlay"></div>

        <section class="login-card">
            <div class="card-icon">
                <svg viewBox="0 0 24 24" width="26" height="26" fill="none"><rect x="5" y="10.5" width="14" height="9.5" rx="2" stroke="#fff" stroke-width="1.8"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" stroke="#fff" stroke-width="1.8" stroke-linecap="round"/></svg>
            </div>

            <h1>Forgot Password</h1>
            <p class="subtitle">
                <% if (otpSent) { %>
                    Enter the OTP we emailed you and choose a new password
                <% } else { %>
                    We'll email a one-time code to the address on your account
                <% } %>
            </p>

            <% if (request.getAttribute("error") != null) { %>
                <div class="error-box"><%= request.getAttribute("error") %></div>
            <% } %>
            <% if (request.getAttribute("success") != null) { %>
                <div class="error-box" style="background:#e4f3ec; color:#2f7a5c; border-color:#bfe3cf;"><%= request.getAttribute("success") %></div>
            <% } %>

            <% if (!otpSent) { %>

                <!-- STEP 1: request an OTP -->
                <form action="forgot-password" method="post">
                    <input type="hidden" name="step" value="send">

                    <label for="role">Account Type</label>
                    <div class="field select-field">
                        <svg class="field-icon" viewBox="0 0 24 24" width="18" height="18" fill="none"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm-7 8a7 7 0 0 1 14 0" stroke="#9aa3b2" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        <select id="role" name="role">
                            <option value="ADMIN">Admin</option>
                            <option value="DISPATCHER">Dispatcher</option>
                            <option value="DRIVER">Driver</option>
                            <option value="HOSPITAL_STAFF">Hospital Staff</option>
                        </select>
                        <svg class="chevron" viewBox="0 0 24 24" width="16" height="16" fill="none"><path d="M6 9l6 6 6-6" stroke="#9aa3b2" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </div>

                    <label for="username">Username</label>
                    <div class="field">
                        <svg class="field-icon" viewBox="0 0 24 24" width="18" height="18" fill="none"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm-7 8a7 7 0 0 1 14 0" stroke="#9aa3b2" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        <input type="text" id="username" name="username" placeholder="Enter your username" required>
                    </div>

                    <button type="submit" class="btn-primary">
                        Send OTP
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="none"><path d="M5 12h14M13 6l6 6-6 6" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </button>
                </form>

            <% } else { %>

                <!-- STEP 2: enter OTP + new password -->
                <p class="subtitle" style="margin-top:-8px;">Code sent to <%= request.getAttribute("maskedEmail") != null ? request.getAttribute("maskedEmail") : "your email" %></p>

                <form action="forgot-password" method="post">
                    <input type="hidden" name="step" value="verify">

                    <label for="otp">OTP Code</label>
                    <div class="field">
                        <svg class="field-icon" viewBox="0 0 24 24" width="18" height="18" fill="none"><rect x="5" y="10.5" width="14" height="9.5" rx="2" stroke="#9aa3b2" stroke-width="1.8"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" stroke="#9aa3b2" stroke-width="1.8" stroke-linecap="round"/></svg>
                        <input type="text" id="otp" name="otp" placeholder="6-digit code" maxlength="6" inputmode="numeric" required>
                    </div>

                    <label for="newPassword">New Password</label>
                    <div class="field">
                        <svg class="field-icon" viewBox="0 0 24 24" width="18" height="18" fill="none"><rect x="5" y="10.5" width="14" height="9.5" rx="2" stroke="#9aa3b2" stroke-width="1.8"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" stroke="#9aa3b2" stroke-width="1.8" stroke-linecap="round"/></svg>
                        <input type="password" id="newPassword" name="newPassword" placeholder="Enter new password" required minlength="6">
                    </div>

                    <label for="confirmPassword">Confirm New Password</label>
                    <div class="field">
                        <svg class="field-icon" viewBox="0 0 24 24" width="18" height="18" fill="none"><rect x="5" y="10.5" width="14" height="9.5" rx="2" stroke="#9aa3b2" stroke-width="1.8"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" stroke="#9aa3b2" stroke-width="1.8" stroke-linecap="round"/></svg>
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-enter new password" required minlength="6">
                    </div>

                    <button type="submit" class="btn-primary">
                        Reset Password
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="none"><path d="M5 12h14M13 6l6 6-6 6" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </button>
                </form>

                <form action="forgot-password" method="get" style="margin-top:10px;">
                    <button type="submit" class="btn-secondary" style="width:100%;">Start over / resend</button>
                </form>

            <% } %>

            <p class="subtitle" style="margin-top:12px;">
                <a href="login.jsp" style="color:#e0342c; font-weight:600; text-decoration:none;">&larr; Back to Sign In</a>
            </p>
        </section>
    </main>
</body>
</html>
