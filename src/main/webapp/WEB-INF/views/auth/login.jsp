<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Moodle LMS</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <style><%@include file="/css/auth/login.css"%></style>
</head>
<body>
    <div class="login-container">
        <div class="logo">
            <i class="fas fa-graduation-cap"></i>
        </div>
        <h2>Welcome to Moodle LMS</h2>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error">
        <i class="fas fa-exclamation-triangle"></i> <%= request.getAttribute("error") %>
    </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/login" method="post">
        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email" required placeholder="admin@lms.com">
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required placeholder="••••••••">
        </div>
        <button type="submit">
            <i class="fas fa-sign-in-alt"></i> Login
        </button>
    </form>

    <div class="links">
        <p>Don't have an account? <a href="<%= request.getContextPath() %>/register">Register here</a></p>
    </div>
    </div>
</body>
</html>