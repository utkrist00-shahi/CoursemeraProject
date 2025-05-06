package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import dao.UserDAO;
import model.User;

@WebServlet("/signup")
@MultipartConfig(maxFileSize = 1024 * 1024 * 5) // 5MB max
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDao;

    @Override
    public void init() throws ServletException {
        userDao = new UserDAO();
        System.out.println("SignupServlet: Initialized with UserDAO.");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        System.out.println("SignupServlet: Forwarding to signup.jsp for GET request.");
        request.getRequestDispatcher("/signup.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (username == null || email == null || password == null || 
            username.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "All fields (except profile image) are required.");
            System.out.println("SignupServlet: Validation failed - missing required fields.");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
            return;
        }

        User user = new User(username.trim(), email.trim(), password.trim());
        user.setCreatedAt(java.time.LocalDateTime.now());

        // Check if this is a multipart request
        boolean isMultipart = request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/");
        System.out.println("SignupServlet: Request is multipart: " + isMultipart);

        if (isMultipart) {
            try {
                Part filePart = request.getPart("profileImage");
                if (filePart != null && filePart.getSize() > 0) {
                    String contentType = filePart.getContentType();
                    if (!contentType.equals("image/jpeg") && !contentType.equals("image/png")) {
                        request.setAttribute("error", "Only PNG or JPEG images are allowed.");
                        System.out.println("SignupServlet: Invalid file type: " + contentType);
                        request.getRequestDispatcher("/signup.jsp").forward(request, response);
                        return;
                    }
                    if (filePart.getSize() > 5 * 1024 * 1024) {
                        request.setAttribute("error", "Image size exceeds 5MB limit.");
                        System.out.println("SignupServlet: File too large: " + filePart.getSize() + " bytes");
                        request.getRequestDispatcher("/signup.jsp").forward(request, response);
                        return;
                    }
                    byte[] imageBytes = filePart.getInputStream().readAllBytes();
                    System.out.println("SignupServlet: Image uploaded - File size: " + imageBytes.length + " bytes, Type: " + contentType);
                    user.setImage(imageBytes);
                } else {
                    System.out.println("SignupServlet: No profile image provided in multipart request.");
                }
            } catch (Exception e) {
                System.err.println("SignupServlet: Exception processing multipart - " + e.getMessage());
                e.printStackTrace();
                request.setAttribute("error", "An error occurred processing the image: " + e.getMessage());
                request.getRequestDispatcher("/signup.jsp").forward(request, response);
                return;
            }
        } else {
            System.out.println("SignupServlet: Non-multipart request, no image processed.");
        }

        try {
            if (userDao.createUser(user)) {
                System.out.println("SignupServlet: User created successfully: " + username);
                request.setAttribute("success", "Signup successful! Please log in.");
                response.sendRedirect(request.getContextPath() + "/login");
            } else {
                System.out.println("SignupServlet: User creation failed for username: " + username);
                request.setAttribute("error", "Signup failed. Username or email may already exist.");
                request.getRequestDispatcher("/signup.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.err.println("SignupServlet: Exception during signup - " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
        }
    }
}