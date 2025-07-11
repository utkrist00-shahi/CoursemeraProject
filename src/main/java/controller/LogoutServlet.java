package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SESSION_TOKEN_COOKIE = "sessionToken";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Prevent caching of secure pages
        setNoCacheHeaders(response);
        
        // Clear session token cookie
        clearSessionCookie(response);
        
        // Invalidate session and clear all attributes
        invalidateSession(request);
        
        // Redirect to application root
        String redirectUrl = request.getContextPath() + "/";
        
        System.out.println("LogoutServlet: Redirecting to: " + redirectUrl);
        response.sendRedirect(redirectUrl);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void setNoCacheHeaders(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }

    private void clearSessionCookie(HttpServletResponse response) {
        Cookie cookie = new Cookie(SESSION_TOKEN_COOKIE, "");
        cookie.setHttpOnly(true);
        cookie.setSecure(true);
        cookie.setPath("/");
        cookie.setMaxAge(0); // Expire the cookie immediately
        response.addCookie(cookie);
        System.out.println("LogoutServlet: Session token cookie cleared");
    }

    private void invalidateSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            try {
                // Clear all session attributes used in LoginServlet
                session.removeAttribute("username");
                session.removeAttribute("email");
                session.removeAttribute("role");
                session.removeAttribute("userId");
                session.removeAttribute("tempUsername");
                session.removeAttribute("tempPassword");
                session.removeAttribute("awaitingSecret");
                session.removeAttribute("successMessage");
                session.removeAttribute("sessionToken");
                
                // Clear all session attributes used in PublisherLoginServlet
                session.removeAttribute("firstName");
                session.removeAttribute("lastName");
                session.removeAttribute("publisherId");
                session.removeAttribute("resume");
                session.removeAttribute("resumeFilename");
                
                // Invalidate the session
                session.invalidate();
                
                System.out.println("LogoutServlet: Session invalidated successfully with all attributes cleared");
            } catch (IllegalStateException e) {
                System.out.println("LogoutServlet: Session already invalidated - " + e.getMessage());
            }
        } else {
            System.out.println("LogoutServlet: No active session found");
        }
    }
}