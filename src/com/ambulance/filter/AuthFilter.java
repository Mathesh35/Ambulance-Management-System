package com.ambulance.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Blocks direct access to dashboards/admin pages unless the user has an
 * active session (SRS Non-Functional Requirement: Role-Based Access).
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final String[] PUBLIC_PATHS = {
        "/login.jsp", "/login", "/css/", "/images/",
        "/forgot_password.jsp", "/forgot-password"
    };

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String path = request.getRequestURI().substring(request.getContextPath().length());

        boolean isPublic = false;
        for (String p : PUBLIC_PATHS) {
            if (path.startsWith(p)) { isPublic = true; break; }
        }

        if (isPublic) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void init(FilterConfig filterConfig) { }

    @Override
    public void destroy() { }
}
