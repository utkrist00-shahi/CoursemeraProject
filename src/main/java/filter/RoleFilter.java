package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin_panel.jsp", "/admin_panel_courses.jsp", "/admin_panel_users.jsp", "/user_dashboard.jsp", "/publisher_dashboard.jsp"})
public class RoleFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        // Determine the expected role based on the requested resource
        String expectedRole = null;
        String redirectPath = null;

        if (requestURI.endsWith("admin_panel.jsp") || requestURI.endsWith("admin_panel_courses.jsp") || requestURI.endsWith("admin_panel_users.jsp")) {
            expectedRole = "ADMIN";
            redirectPath = contextPath + "/login";
        } else if (requestURI.endsWith("user_dashboard.jsp")) {
            expectedRole = "USER";
            redirectPath = contextPath + "/login";
        } else if (requestURI.endsWith("publisher_dashboard.jsp")) {
            expectedRole = "PUBLISHER";
            redirectPath = contextPath + "/publisher_login.jsp";
        }

        // Check session and role
        boolean isAuthorized = false;
        if (session != null) {
            String role = (String) session.getAttribute("role");
            if (expectedRole != null && expectedRole.equals(role)) {
                // Additional checks for specific roles
                if ("PUBLISHER".equals(role) && session.getAttribute("publisherId") == null) {
                    System.out.println("RoleFilter: Missing publisherId for PUBLISHER role, redirecting to " + redirectPath);
                } else if ("USER".equals(role) && session.getAttribute("userId") == null) {
                    System.out.println("RoleFilter: Missing userId for USER role, redirecting to " + redirectPath);
                } else {
                    isAuthorized = true;
                }
            } else {
                System.out.println("RoleFilter: Role mismatch - expected: " + expectedRole + ", found: " + role + ", redirecting to " + redirectPath);
            }
        } else {
            System.out.println("RoleFilter: No session found, redirecting to " + redirectPath);
        }

        if (isAuthorized) {
            chain.doFilter(request, response); // Proceed to the requested resource
        } else {
            httpResponse.sendRedirect(redirectPath);
        }
    }

    @Override
    public void destroy() {
       
    	
    }
}