package model;

import java.sql.Timestamp;

public class Booking {
    private int id;
    private int userId;
    private int courseId;
    private Timestamp bookingDate;

    public Booking() {}

    public Booking(int userId, int courseId) {
        this.userId = userId;
        this.courseId = courseId;
        this.bookingDate = new Timestamp(System.currentTimeMillis());
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }
    public Timestamp getBookingDate() { return bookingDate; }
    public void setBookingDate(Timestamp bookingDate) { this.bookingDate = bookingDate; }
}