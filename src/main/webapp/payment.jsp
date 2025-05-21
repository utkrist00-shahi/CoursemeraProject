<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Courses" %>
<%
// Prevent caching
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

Courses course = (Courses) request.getAttribute("course");
if (course == null) {
    response.sendRedirect(request.getContextPath() + "/courses.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - Coursemera</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Roboto', sans-serif;
            background: linear-gradient(145deg, #1e1b4b 0%, #4c1d95 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            color: #f1f5f9;
        }
        .payment-container {
            max-width: 650px;
            width: 100%;
            background: #ffffff;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.2);
            animation: slideIn 0.6s ease-out;
            position: relative;
            overflow: hidden;
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .payment-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 5px;
            background: linear-gradient(90deg, #7c3aed, #3b82f6);
        }
        .payment-title {
            font-size: 2.5rem;
            font-weight: 700;
            color: #1e1b4b;
            text-align: center;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
        }
        .payment-title i {
            color: #7c3aed;
            font-size: 2rem;
        }
        .course-info {
            background: #f8fafc;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 30px;
            border-left: 5px solid #7c3aed;
            transition: all 0.3s ease;
        }
        .course-info:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        .course-info h3 {
            font-size: 1.8rem;
            font-weight: 600;
            color: #1e1b4b;
            margin-bottom: 15px;
        }
        .course-info p {
            font-size: 1.1rem;
            color: #475569;
            margin: 10px 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .course-info p i {
            color: #7c3aed;
            font-size: 1.2rem;
        }
        .payment-form .form-group {
            position: relative;
            margin-bottom: 25px;
        }
        .payment-form label {
            font-weight: 500;
            color: #1e1b4b;
            font-size: 1rem;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .payment-form label i {
            color: #7c3aed;
        }
        .payment-form input {
            width: 100%;
            padding: 14px 16px;
            padding-left: 40px;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        .payment-form input:focus {
            outline: none;
            border-color: #7c3aed;
            box-shadow: 0 0 10px rgba(124, 58, 237, 0.2);
        }
        .payment-form input[readonly] {
            background: #f3f4f6;
            cursor: not-allowed;
        }
        .payment-form .form-group i {
            position: absolute;
            left: 12px;
            top: 42px;
            color: #7c3aed;
            font-size: 1.2rem;
        }
        .payment-form button {
            width: 100%;
            padding: 16px;
            background: linear-gradient(90deg, #7c3aed, #3b82f6);
            color: #ffffff;
            border: none;
            border-radius: 10px;
            font-size: 1.2rem;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.3s ease;
        }
        .payment-form button:hover {
            background: linear-gradient(90deg, #6d28d9, #2563eb);
            transform: translateY(-3px);
        }
        .payment-form button:active {
            transform: translateY(0);
        }
        .message {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.3s ease;
        }
        .message.success {
            background: #dcfce7;
            color: #166534;
        }
        .message.success i {
            color: #16a34a;
        }
        .message.error {
            background: #fee2e2;
            color: #991b1b;
        }
        .message.error i {
            color: #dc2626;
        }
        .error-text {
            color: #dc2626;
            font-size: 0.9rem;
            margin-top: -15px;
            margin-bottom: 15px;
            display: none;
        }
        .error-input {
            border-color: #dc2626 !important;
        }
        @media (max-width: 480px) {
            .payment-container {
                padding: 25px;
            }
            .payment-title {
                font-size: 2rem;
            }
            .course-info h3 {
                font-size: 1.5rem;
            }
            .payment-form input {
                padding: 12px 16px;
                padding-left: 40px;
            }
        }
    </style>
</head>
<body>
    <div class="payment-container">
        <h2 class="payment-title"><i class="fas fa-credit-card"></i> Payment for Course</h2>

        <% 
            String successMessage = (String) request.getAttribute("success");
            String errorMessage = (String) request.getAttribute("error");
        %>
        <% if (successMessage != null) { %>
            <div class="message success"><i class="fas fa-check-circle"></i> <%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="message error"><i class="fas fa-exclamation-circle"></i> <%= errorMessage %></div>
        <% } %>

        <div class="course-info">
            <h3><%= course.getTitle() != null ? course.getTitle() : "Course Title" %></h3>
            <p><i class="fas fa-chalkboard-teacher"></i> Instructor: <%= course.getInstructor() != null ? course.getInstructor() : "Unknown" %></p>
            <p><i class="fas fa-dollar-sign"></i> Price: $<%= String.format("%.2f", course.getPrice()) %></p>
        </div>

        <form class="payment-form" action="${pageContext.request.contextPath}/payment" method="post">
            <input type="hidden" name="courseId" value="<%= course.getId() %>">
            <input type="hidden" name="amount" value="<%= course.getPrice() %>">

            <div class="form-group">
                <label for="cardNumber"><i class="fas fa-credit-card"></i> Card Number</label>
                <input type="text" id="cardNumber" name="cardNumber" placeholder="1234 5678 9012 3456" required>
                <i class="fas fa-credit-card"></i>
            </div>

            <div class="form-group">
                <label for="expiryDate"><i class="fas fa-calendar-alt"></i> Expiry Date</label>
                <input type="text" id="expiryDate" name="expiryDate" placeholder="MM/YY" required>
                <i class="fas fa-calendar-alt"></i>
            </div>

            <div class="form-group">
                <label for="cvv"><i class="fas fa-lock"></i> CVV</label>
                <input type="text" id="cvv" name="cvv" placeholder="123" required>
                <i class="fas fa-lock"></i>
            </div>

            <div class="form-group">
                <label for="amount"><i class="fas fa-dollar-sign"></i> Amount ($)</label>
                <input type="text" id="amount" name="amountDisplay" value="<%= String.format("%.2f", course.getPrice()) %>" readonly>
                <i class="fas fa-dollar-sign"></i>
            </div>

            <button type="submit"><i class="fas fa-arrow-right"></i> Pay Now</button>
        </form>
    </div>

    <script>
        // Basic client-side validation
        document.querySelector('.payment-form').addEventListener('submit', function(e) {
            const cardNumber = document.getElementById('cardNumber').value;
            const expiryDate = document.getElementById('expiryDate').value;
            const cvv = document.getElementById('cvv').value;

            if (!/^\d{16}$/.test(cardNumber.replace(/\s/g, ''))) {
                e.preventDefault();
                alert('Please enter a valid 16-digit card number.');
                return;
            }

            if (!/^\d{2}\/\d{2}$/.test(expiryDate)) {
                e.preventDefault();
                alert('Please enter a valid expiry date in MM/YY format.');
                return;
            }

            if (!/^\d{3}$/.test(cvv)) {
                e.preventDefault();
                alert('Please enter a valid 3-digit CVV.');
                return;
            }
        });
    </script>
</body>
</html>