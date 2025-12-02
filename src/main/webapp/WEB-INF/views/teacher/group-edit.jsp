<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Group • EDUCORE</title>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@700&family=Roboto:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <style><%@include file="/css/teacher/group-edit.css"%></style>
</head>
<body>
    <div class="topbar">
        <a href="${pageContext.request.contextPath}/teacher/dashboard" class="logo">EDUCORE</a>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Logout</a>
    </div>

    <div class="container">
        <div class="card">
            <div class="card-header">EDIT GROUP</div>
                <div class="card-body">

                    <form action="${pageContext.request.contextPath}/teacher/groups/update" method="post">
                        <input type="hidden" name="groupId" value="${group.id}">

                        <div class="form-group">
                            <label>Group Name</label>
                            <input type="text" name="name" value="${group.name}" required maxlength="100">
                        </div>

                        <div class="form-group">
                            <label>Description</label>
                            <textarea required name="description">${group.description}</textarea>
                        </div>

                        <div style="text-align:center;">
                            <button type="submit" class="btn-submit">Save Changes</button>
                        </div>
                    </form>

                    <div style="text-align:center; margin-top:20px;">
                        <a href="${pageContext.request.contextPath}/teacher/groups" class="back-link">Back to Groups</a>
                    </div>
                </div>
            </div>
        </div>
</body>
</html>