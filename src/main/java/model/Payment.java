package model;

import java.sql.Timestamp;

public class Payment {
    private int id;
    private int userId;
    private int courseId;
    private double amount;
    private Timestamp paymentDate;
    private String status;

    public Payment() {}

    public Payment(int userId, int courseId, double amount, String status) {
        this.userId = userId;
        this.courseId = courseId;
        this.amount = amount;
        this.status = status;
        this.paymentDate = new Timestamp(System.currentTimeMillis());
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
    public Timestamp getPaymentDate() { return paymentDate; }
    public void setPaymentDate(Timestamp paymentDate) { this.paymentDate = paymentDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}