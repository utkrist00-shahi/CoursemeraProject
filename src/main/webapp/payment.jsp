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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', Arial, sans-serif;
            background: linear-gradient(135deg, #e6f0fa 0%, #d1e8e2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }
        .payment-container {
            max-width: 600px;
            width: 100%;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .payment-title {
            text-align: center;
            font-size: 2rem;
            color: #1a3c34;
            margin-bottom: 20px;
        }
        .course-info {
            margin-bottom: 20px;
            padding: 15px;
            background: #f9fafb;
            border-radius: 8px;
        }
        .course-info h3 {
            font-size: 1.5rem;
            color: #1a3c34;
            margin-bottom: 10px;
        }
        .course-info p {
            margin: 5px 0;
            color: #555;
        }
        .payment-form label {
            display: block;
            font-weight: bold;
            margin-bottom: 5px;
            color: #333;
        }
        .payment-form input {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 1rem;
        }
        .payment-form input[readonly] {
            background: #f0f0f0;
        }
        .payment-form button {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #1a3c34 0%, #2c7a7b 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        .payment-form button:hover {
            background: linear-gradient(135deg, #15332d 0%, #226b6c 100%);
        }
        .message {
            margin-bottom: 15px;
            padding: 10px;
            border-radius: 4px;
            text-align: center;
        }
        .message.success {
            background-color: #d4edda;
            color: #155724;
        }
        .message.error {
            background-color: #f8d7da;
            color: #721c24;
        }
    </style>
</head>
<body>
    <div class="payment-container">
        <h2 class="payment-title">Payment for Course</h2>

        <% 
            String successMessage = (String) request.getAttribute("success");
            String errorMessage = (String) request.getAttribute("error");
        %>
        <% if (successMessage != null) { %>
            <div class="message success"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="message error"><%= errorMessage %></div>
        <% } %>

        <div class="course-info">
            <h3><%= course.getTitle() != null ? course.getTitle() : "Course Title" %></h3>
            <p>Instructor: <%= course.getInstructor() != null ? course.getInstructor() : "Unknown" %></p>
            <p>Price: $<%= String.format("%.2f", course.getPrice()) %></p>
        </div>

        <form class="payment-form" action="${pageContext.request.contextPath}/payment" method="post">
            <input type="hidden" name="courseId" value="<%= course.getId() %>">
            <input type="hidden" name="amount" value="<%= course.getPrice() %>">

            <label for="cardNumber">Card Number</label>
            <input type="text" id="cardNumber" name="cardNumber" placeholder="1234 5678 9012 3456" required>

            <label for="expiryDate">Expiry Date</label>
            <input type="text" id="expiryDate" name="expiryDate" placeholder="MM/YY" required>

            <label for="cvv">CVV</label>
            <input type="text" id="cvv" name="cvv" placeholder="123" required>

            <label for="amount">Amount ($)</label>
            <input type="text" id="amount" name="amountDisplay" value="<%= String.format("%.2f", course.getPrice()) %>" readonly>

            <button type="submit">Pay Now</button>
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