package model;

public class Courses {
    private int id;
    private String title;
    private String category;
    private String instructor;
    private double price;
    private String imagePath;
    private int publisherId;
    private String createdAt;

    // Constructors
    public Courses() {}

    public Courses(int id, String title, String category, String instructor, double price, String imagePath, int publisherId, String createdAt) {
        this.id = id;
        this.title = title;
        this.category = category;
        this.instructor = instructor;
        this.price = price;
        this.imagePath = imagePath;
        this.publisherId = publisherId;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getInstructor() {
        return instructor;
    }

    public void setInstructor(String instructor) {
        this.instructor = instructor;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public int getPublisherId() {
        return publisherId;
    }

    public void setPublisherId(int publisherId) {
        this.publisherId = publisherId;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}