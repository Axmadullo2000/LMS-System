<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create New Group • EDUCORE</title>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@700&family=Playfair+Display:wght@600&family=Roboto:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <style><%@include file="/css/teacher/group-form.css"%></style>
</head>
<body>
    <div class="topbar">
        <a href="${pageContext.request.contextPath}/teacher/dashboard" class="logo">EDUCORE</a>
        <div>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                Logout
            </a>
        </div>
    </div>
        <div class="container">
            <div class="card">
                <div class="card-header">
                    CREATE NEW GROUP
                </div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/teacher/groups/create" method="post">
                        <div class="form-group">
                            <label for="name">Group Name</label>
                            <input type="text" id="name" name="name" required placeholder="e.g. Advanced Java 2025" maxlength="100">
                        </div>

                       <div class="form-group">
                        <label for="description">Description (optional)</label>
                        <textarea id="description" name="description" placeholder="Brief description of the group, goals, schedule..."></textarea>
                    </div>

                        <div style="text-align: center;">
                        <button type="submit" class="btn-submit">
                            Create Group
                        </button>
                    </div>
                    </form>

                   <div style="text-align: center;">
                    <a href="${pageContext.request.contextPath}/teacher/groups" class="back-link">
                        ← Back to Groups
                    </a>
                </div>
                </div>
            </div>
        </div>
</body>
</html>