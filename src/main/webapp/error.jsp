<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Coursemera</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f1f1f1;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            text-align: center;
        }
        .error-container {
            background-color: #fff;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            max-width: 500px;
            width: 100%;
        }
        .error-container h2 {
            font-size: 24px;
            color: #e74c3c;
            margin: 0 0 20px;
        }
        .error-container p {
            font-size: 16px;
            color: #666;
            margin: 0 0 20px;
        }
        .error-container a {
            display: inline-block;
            background-color: #3498db;
            color: #fff;
            padding: 10px 20px;
            border-radius: 20px;
            text-decoration: none;
            font-size: 16px;
        }
        .error-container a:hover {
            background-color: #2980b9;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <h2>An Error Occurred</h2>
        <p>
            <%
                //  HTTP status code if available 
                Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
                if (statusCode != null) {
                    out.println("Error Code: " + statusCode + "<br>");
                }
                
                // Display error message 
                String errorMessage = (String) request.getAttribute("jakarta.servlet.error.message");
                if (errorMessage != null && !errorMessage.isEmpty()) {
                    out.println("Message: " + errorMessage);
                } else if (statusCode != null && statusCode == 404) {
                    out.println("The page you are looking for could not be found.");
                } else {
                    out.println("An unexpected error occurred. Please try again later.");
                }
            %>
        </p>
        <a href="index.jsp">Back to Home</a>
    </div>
</body>
</html>