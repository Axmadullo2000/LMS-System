<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<html>
<head>
    <title>Просмотр Submission</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <style>
        body { padding: 20px; }
        .submission-info { margin-bottom: 20px; }
        .file-link { margin-top: 10px; display: block; }
        .status { font-weight: bold; }
        .graded { color: green; }
        .pending { color: orange; }
        .rejected { color: red; }
    </style>
</head>
<body>
    <h2>Просмотр отправки</h2>

    <!-- Информация о задании -->
    <div class="submission-info">
        <h4>${assignment.title}</h4>
        <p>${assignment.description}</p>
        <p>Срок сдачи: ${assignment.formattedDueDate}</p>

        <c:if test="${assignment.fileName != null}">
            <a href="${pageContext.request.contextPath}/files/download?id=${assignment.id}&type=assignment"
               class="file-link">Скачать задание: ${assignment.fileName}</a>
        </c:if>
    </div>

    <!-- Информация о submission -->
    <div class="submission-info">
        <h5>Ваша отправка</h5>
        <p>Комментарий: <c:out value="${submission.comment}" default="Нет комментария"/></p>
        <c:if test="${submission.fileName != null}">
            <a href="${pageContext.request.contextPath}/files/download?id=${submission.id}&type=submission"
               class="file-link">Скачать файл: ${submission.fileName}</a>
        </c:if>

        <p>Статус:
            <span class="status ${submission.status.toString().toLowerCase()}">
                ${submission.status}
            </span>
        </p>

        <c:if test="${submission.score != null}">
            <p>Оценка: ${submission.score}</p>
        </c:if>

        <c:if test="${submission.reviewedAt != null}">
            <p>Проверено: <fmt:formatDate value="${submission.reviewedAt}" pattern="dd MMM yyyy HH:mm"/></p>
        </c:if>
    </div>

    <!-- Последняя отправка (если есть) -->
    <c:if test="${latestSubmission != null}">
        <div class="submission-info">
            <h5>Последняя отправка</h5>
            <p>Комментарий: <c:out value="${latestSubmission.comment}" default="Нет комментария"/></p>
            <c:if test="${latestSubmission.fileName != null}">
                <a href="${pageContext.request.contextPath}/student/download/submission?submissionId=${latestSubmission.id}"
                   class="file-link">Скачать файл: ${latestSubmission.fileName}</a>
            </c:if>
            <p>Статус:
                <span class="status ${latestSubmission.status.toString().toLowerCase()}">
                        ${latestSubmission.status}
                </span>
            </p>
            <c:if test="${latestSubmission.score != null}">
                <p>Оценка: ${latestSubmission.score}</p>
            </c:if>
            <c:if test="${latestSubmission.reviewedAt != null}">
                <p>Проверено: ${latestSubmission.submittedDate}</p>
            </c:if>
        </div>
    </c:if>

    <a href="${pageContext.request.contextPath}/files/download?type=submission&id=${submission.id}"
       class="file-link" target="_blank">
        Скачать ${submission.fileName}
    </a>

    <a href="${pageContext.request.contextPath}/student/submissions" class="btn btn-secondary">Назад к списку</a>
</body>
</html>
