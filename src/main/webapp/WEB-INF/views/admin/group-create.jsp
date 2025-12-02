<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Создать группу — LMS Admin</title>

    <!-- Bootstrap 5 + Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style><%@include file="/css/admin/group-create.css"%></style>
</head>
<body>
    <!-- Sidebar Toggle -->
    <button class="sidebar-toggle" id="sidebarToggle">
        <i class="bi bi-list fs-4"></i>
    </button>

    <!-- Sidebar (тот же, что в groups.jsp) -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">LMS</div>
        <nav>
            <ul class="nav flex-column">
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link"><i class="bi bi-speedometer2"></i> <span>Dashboard</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users" class="nav-link"><i class="bi bi-people-fill"></i> <span>Пользователи</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/students" class="nav-link"><i class="bi bi-person-badge"></i> <span>Студенты</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/teachers" class="nav-link"><i class="bi bi-person-workspace"></i> <span>Преподаватели</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/admins" class="nav-link"><i class="bi bi-shield-fill-check"></i> <span>Админы</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/groups" class="nav-link active"><i class="bi bi-diagram-3-fill"></i> <span>Группы</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/assignments" class="nav-link"><i class="bi bi-journal-text"></i> <span>Задания</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/submissions" class="nav-link"><i class="bi bi-file-earmark-check"></i> <span>Сдачи</span></a></li>
            </ul>
        </nav>
    </aside>

    <!-- Main Content -->
    <div class="main-content">
        <div class="container-fluid">

            <!-- Page Header -->
            <div class="page-header mb-5">
                <h1>Создание новой группы</h1>
                <p class="text-muted">Заполните данные группы. Преподавателей и студентов можно добавить позже.</p>
            </div>

            <!-- Form Card -->
            <div class="card">
                <div class="card-header">
                    <h2>Новая группа</h2>
                </div>
                <div class="card-body p-5">

                    <!-- Error Message -->
                    <c:if test="${not empty param.error}">
                        <div class="alert alert-danger">
                            <c:choose>
                                <c:when test="${param.error == 'empty_name'}">Название группы не может быть пустым!</c:when>
                                <c:otherwise>Произошла ошибка. Попробуйте снова.</c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>

                    <!-- Success Message -->
                    <c:if test="${param.success == 'created'}">
                        <div class="alert alert-success">Группа успешно создана!</div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/admin/groups/create" method="post">
                        <div class="form-group">
                            <label for="name">
                                Название группы <span class="text-danger">*</span>
                            </label>
                            <input
                                    type="text"
                                    id="name"
                                    name="name"
                                    class="form-control form-control-lg"
                                    placeholder="Например: Java Advanced 2025"
                                    required
                                    autofocus
                                    value="${param.name}"
                            />
                        </div>

                        <div class="form-group">
                            <label for="description">Описание группы</label>
                            <textarea
                                    id="description"
                                    name="description"
                                    class="form-control"
                                    rows="4"
                                    placeholder="Краткое описание группы, цели курса, особенности...">${param.description}</textarea>
                        </div>

                        <div class="form-actions">
                            <a href="${pageContext.request.contextPath}/admin/groups" class="btn btn-secondary btn-lg">
                                Отмена
                            </a>
                            <button type="submit" class="btn btn-success btn-lg px-5">
                                Создать группу
                            </button>
                        </div>
                    </form>
                </div>
            </div>

        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Sidebar toggle (тот же код, что и в groups.jsp)
        const sidebarToggle = document.getElementById('sidebarToggle');
        const sidebar = document.getElementById('sidebar');

        const saved = localStorage.getItem('sidebarCollapsed');
        if (saved === 'true') {
            sidebar.classList.add('collapsed');
        }

        sidebarToggle.addEventListener('click', () => {
            sidebar.classList.toggle('collapsed');
            localStorage.setItem('sidebarCollapsed', sidebar.classList.contains('collapsed'));
        });
    </script>
</body>
</html>