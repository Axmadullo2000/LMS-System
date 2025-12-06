<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Мои задания</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .card { transition: transform 0.2s; }
        .card:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
    </style>
</head>
<body class="bg-light">

<div class="container py-5">
    <h1 class="mb-4">Мои задания</h1>

    <!-- Фильтр по группе -->
    <c:if test="${not empty groups && groups.size() > 1}">
        <div class="card mb-4 border-0 shadow-sm">
            <div class="card-body">
                <form method="get" class="row g-3 align-items-center">
                    <div class="col-auto">
                        <label class="col-form-label fw-bold">Группа:</label>
                    </div>
                    <div class="col-auto">
                        <select name="groupId" class="form-select" onchange="this.form.submit()">
                            <option value="">Все задания</option>
                            <c:forEach var="group" items="${groups}">
                                <option value="${group.id}" ${param.groupId == group.id ? 'selected' : ''}>
                                        ${group.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </form>
            </div>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty assignments}">
            <div class="alert alert-info text-center p-5">
                <h4>Нет заданий</h4>
                <p>
                    <c:choose>
                        <c:when test="${not empty param.groupId}">В этой группе пока нет заданий.</c:when>
                        <c:otherwise>Преподаватель ещё не создал задания.</c:otherwise>
                    </c:choose>
                </p>
            </div>
        </c:when>

        <c:otherwise>
            <div class="row row-cols-1 row-cols-md-2 g-4">
                <c:forEach var="assignment" items="${assignments}">

                    <!-- Поиск своей отправки -->
                    <c:set var="mySubmission" value="${null}"/>
                    <c:forEach var="sub" items="${mySubmissions}">
                        <c:if test="${sub.assignment.id == assignment.id}">
                            <c:set var="mySubmission" value="${sub}"/>
                        </c:if>
                    </c:forEach>

                    <div class="col">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body d-flex flex-column">

                                <!-- Заголовок + просрочено -->
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <h5 class="card-title mb-0">${assignment.title}</h5>
                                    <c:if test="${assignment.dueDate != null && assignment.dueDate.isBefore(now)}">
                                        <span class="badge bg-danger">Просрочено</span>
                                    </c:if>
                                </div>

                                <!-- Срок сдачи -->
                                <p class="text-muted small mb-2">
                                    <strong>Сдать до:</strong>
                                    ${assignment.formattedDueDate}
<%--                                    <fmt:formatDate value="${assignment.dueDate}" pattern="dd MMMM yyyy, HH:mm"/>--%>

                                    <c:if test="${assignment.dueDate != null}">
                                        <br><small class="text-muted">
                                        <c:choose>
                                            <c:when test="${assignment.dueDate.isBefore(now)}">
                                                просрочено
                                            </c:when>
                                            <c:when test="${assignment.dueDate.toLocalDate().isEqual(now.toLocalDate())}">
                                                сегодня
                                            </c:when>
                                        </c:choose>
                                    </small>
                                    </c:if>
                                </p>

                                <!-- Максимальный балл -->
                                <c:if test="${assignment.maxScore != null}">
                                    <p class="mb-2">
                                        <span class="badge bg-info text-dark">Макс. балл: ${assignment.maxScore}</span>
                                    </p>
                                </c:if>

                                <!-- Описание -->
                                <div class="text-muted mb-3 flex-grow-1">
                                    <c:choose>
                                        <c:when test="${not empty assignment.description}">
                                            ${assignment.description}
                                        </c:when>
                                        <c:otherwise><em>Описание отсутствует</em></c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Прикреплённый файл — ИСПРАВЛЕНО! -->
                                <c:if test="${assignment.hasFile()}">
                                    <div class="alert alert-light border mb-3 p-3">
                                        <strong>Прикреплённый файл:</strong><br>
                                        <a href="${pageContext.request.contextPath}/files/download?id=${assignment.id}&type=assignment"
                                           class="link-primary text-decoration-none">
                                            Скачать ${assignment.fileName}
                                            <c:if test="${assignment.fileSize != null}">
                                                <small class="text-muted">(${assignment.fileSize / 1024} КБ)</small>
                                            </c:if>
                                        </a>
                                    </div>
                                </c:if>

                                <!-- Статус сдачи -->
                                <div class="mt-auto pt-3 border-top">
                                    <c:choose>
                                        <c:when test="${mySubmission == null}">
                                            <span class="badge bg-secondary fs-6">Не сдано</span>
                                        </c:when>
                                        <c:when test="${mySubmission.status == 'SUBMITTED'}">
                                            <span class="badge bg-primary fs-6">Ожидает проверки</span>
                                        </c:when>
                                        <c:when test="${mySubmission.status == 'GRADED'}">
                                            <span class="badge bg-success fs-6">
                                                Оценено: <strong>${mySubmission.score}</strong> / ${assignment.maxScore}
                                            </span>
                                        </c:when>
                                        <c:when test="${mySubmission.status == 'LATE'}">
                                            <span class="badge bg-warning text-dark fs-6">Сдано с опозданием</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-info fs-6">${mySubmission.status}</span>
                                        </c:otherwise>
                                    </c:choose>

                                    <!-- Кнопки -->
                                    <div class="mt-3">
                                        <c:choose>
                                            <c:when test="${mySubmission != null && mySubmission.status == 'GRADED'}">
                                                <a href="${pageContext.request.contextPath}/student/submission/view?id=${mySubmission.id}"
                                                   class="btn btn-success btn-sm">Посмотреть отзыв</a>
                                            </c:when>
                                            <c:when test="${mySubmission != null}">
                                                <a href="${pageContext.request.contextPath}/student/submission/view?submissionId=${mySubmission.id}"
                                                   class="btn btn-outline-primary btn-sm">Моя отправка</a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/student/submission/create?assignmentId=${assignment.id}"
                                                   class="btn btn-primary btn-sm">Сдать задание</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>