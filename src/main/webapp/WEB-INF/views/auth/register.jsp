<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register Moodle LMS</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <style><%@include file="/css/auth/register.css"%></style>
</head>
<body>
    <div class="register-container">
        <div class="logo">
            <i class="fas fa-user-plus"></i>
        </div>

        <h2>Create Your Account</h2>

        <% if (request.getAttribute("error") != null) { %>
        <div class="error">
            <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
        </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/register" method="post">
            <div class="form-group">
                <label for="fullName">Full Name</label>
                <input type="text" id="fullName" name="fullName" required placeholder="John Doe">
            </div>

            <div class="form-group">
                <label for="username">User Name</label>
                <input type="text" id="username" name="username" required placeholder="@John_Doe">
            </div>

            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" required placeholder="john@example.com">
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required minlength="6">
            </div>

            <div class="form-group">
                <label for="role">I am a...</label>
                <select id="role" name="role" required onchange="toggleSpecialization()">
                    <option value="">Choose your role</option>
                    <option value="TEACHER">Teacher</option>
                    <option value="STUDENT">Student</option>
                </select>
            </div>

            <div class="form-group" id="specializationField" onchange="toggleSpecialization()">
                <label for="specializationInput">Specialization (e.g. Mathematics, Physics)</label>
                <input type="text" id="specializationInput" name="specialization" placeholder="Mathematics">
            </div>

            <button type="submit">
                <i class="fas fa-user-plus"></i> Create Account
            </button>
        </form>

        <div class="back-link">
            <p>Already have an account? <a href="<%= request.getContextPath() %>/login">Login here</a></p>
        </div>
    </div>

    <script>
        function toggleSpecialization() {
            let role = document.getElementById("role").value;
            let specializationField = document.getElementById("specializationField");
            let specializationInput = document.getElementById("specializationInput");

            if (role === "TEACHER") {
                specializationField.style.display = "block";
                specializationInput.required = true;
            }else {
                specializationField.style.display = "none";
                specializationInput.required = false;
            }
        }
    </script>
</body>
</html>
