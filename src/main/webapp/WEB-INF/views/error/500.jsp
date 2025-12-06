<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>500 — Внутренняя ошибка сервера</title>
    <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet">
    <style>
        .error-container { text-align: center; margin-top: 80px; font-family: 'Segoe UI', sans-serif; }
        .error-code { font-size: 100px; color: #e74c3c; margin: 0; font-weight: bold; }
        .error-message { font-size: 28px; color: #2c3e50; margin: 20px 0; }
        .details { background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px auto; max-width: 700px; text-align: left; font-family: monospace; font-size: 13px; display: none; }
        .toggle-details { cursor: pointer; color: #3498db; text-decoration: underline; }
        .back-home a { padding: 12px 30px; background: #3498db; color: white; text-decoration: none; border-radius: 6px; font-size: 18px; }
        .back-home a:hover { background: #2980b9; }
    </style>
</head>
<body>
<div class="error-container">
    <h1 class="error-code">500</h1>
    <p class="error-message">Произошла внутренняя ошибка сервера</p>
    <p>Мы уже работаем над исправлением. Попробуйте позже.</p>

    <div class="back-home">
        <a href="${pageContext.request.contextPath}/">Вернуться на главную</a>
    </div>

    <br>
    <p class="toggle-details" onclick="document.getElementById('details').style.display = 'block'; this.style.display = 'none';">
        Показать технические детали (только для администраторов)
    </p>

    <div id="details" class="details">
        <strong>Исключение:</strong> <%= exception != null ? exception.getClass().getName() : "Неизвестно" %><br>
        <strong>Сообщение:</strong> <%= exception != null ? exception.getMessage() : "Нет данных" %><br><br>
        <strong>Stacktrace:</strong><br>
        <pre><%= exception != null ? java.util.Arrays.toString(exception.getStackTrace()) : "Нет" %></pre>
    </div>
</div>

<script>
    // В продакшене можно отключить показ деталей
    // Просто закомментируй строку выше с toggle-details
</script>
</body>
</html>