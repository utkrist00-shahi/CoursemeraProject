package model;

import java.time.LocalDateTime;

public class User {
    private int id;
    private String username;
    private String email;
    private String password;
    private LocalDateTime createdAt;
    private Role role;
    private byte[] image;

    public enum Role {
        USER, ADMIN, PUBLISHER
    }

    public User() {}

    public User(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.createdAt = LocalDateTime.now();
        this.role = Role.USER;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { 
        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("Username cannot be null or empty");
        }
        this.username = username.trim();
    }
    public String getEmail() { return email; }
    public void setEmail(String email) { 
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email cannot be null or empty");
        }
        this.email = email.trim();
    }
    public String getPassword() { return password; }
    public void setPassword(String password) { 
        if (password == null || password.trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty");
        }
        this.password = password;
    }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }
    public byte[] getImage() { return image; }
    public void setImage(byte[] image) { this.image = image; }
}