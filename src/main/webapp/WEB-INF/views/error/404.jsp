<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>404 — Page Not Found</title>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@700&family=Playfair+Display:wght@600&family=Roboto:wght@300&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <style><%@include file="/css/auth/404.css"%></style>
</head>
<body>
    <div class="error-container">
        <h1 class="error-code">404</h1>
        <h2 class="error-message">Lost in the Void</h2>
        <p class="error-desc">
            The page you seek has slipped into darkness.<br>
            Return before the shadows consume you.
        </p>
        <a href="${pageContext.request.contextPath}/" class="btn-home">
            ← Return to Light
        </a>
    </div>

    <script>
        function createSparkle() {
            const sparkle = document.createElement('div');
            sparkle.className = 'sparkle';
            sparkle.innerHTML = '✦';
            sparkle.style.left = Math.random() * 100 + 'vw';
            sparkle.style.animationDuration = (Math.random() * 3 + 2) + 's';
            sparkle.style.animationDelay = Math.random() * 2 + 's';
            document.body.appendChild(sparkle);

            setTimeout(() => {
                sparkle.remove();
            }, 6000);
        }

        setInterval(createSparkle, 400);
    </script>
</body>
</html>