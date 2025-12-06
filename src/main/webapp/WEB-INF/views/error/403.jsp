<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>403 — Доступ запрещён</title>
    <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet">
    <style>
        .error-container { text-align: center; margin-top: 100px; font-family: Arial, sans-serif; }
        .error-code { font-size: 120px; color: #e67e22; margin: 0; }
        .error-message { font-size: 28px; color: #2c3e50; }
        .back-home { margin-top: 30px; }
        .back-home a { padding: 12px 24px; background: #e67e22; color: white; text-decoration: none; border-radius: 6px; }
    </style>
</head>
<body>
<div class="error-container">
    <h1 class="error-code">403</h1>
    <p class="error-message">Доступ запрещён</p>
    <p>У вас нет прав для просмотра этой страницы.</p>
    <%
        String role = (String) session.getAttribute("role");
    %>

    <p>Ваша роль: <strong> <%= role %> + "</strong></p>
    <div class="back-home">
        <a href="<%= request.getContextPath() %>/">На главную</a>
        <a href="<%= request.getContextPath() %>/logout" style="margin-left: 15px; background: #95a5a6;">Выйти</a>
    </div>
</div>
</body>
</html>