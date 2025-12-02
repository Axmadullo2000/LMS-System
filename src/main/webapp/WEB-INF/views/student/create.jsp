<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Сдать задание</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .file-upload-area {
            border: 2px dashed #ccc;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            background: #f9f9f9;
            transition: all 0.3s;
        }
        .file-upload-area:hover {
            border-color: #0d6efd;
            background: #f0f4ff;
        }
        .file-upload-area.dragover {
            border-color: #0d6efd;
            background: #e7f0ff;
        }
    </style>
</head>
<body class="bg-light">

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">

            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0">
                        Сдать задание: <strong>${assignment.title}</strong>
                    </h4>
                </div>
                <div class="card-body">

                    <!-- Информация о задании -->
                    <div class="alert alert-info">
                        <strong>Срок сдачи:</strong>
                        ${assignment.formattedDueDate}
                        <c:if test="${assignment.dueDate.isBefore(now)}">
                            <span class="badge bg-danger ms-2">Просрочено</span>
                        </c:if>
                        <br>
                        <strong>Макс. балл:</strong> ${assignment.maxScore}
                    </div>

                    <!-- Предыдущая отправка (если есть) -->
                    <c:if test="${latestSubmission != null}">
                        <div class="alert alert-warning">
                            <strong>Вы уже сдавали это задание!</strong><br>
                            Отправлено: <fmt:formatDate value="${latestSubmission.submittedAt}" pattern="d MMM yyyy, HH:mm"/><br>
                            Статус: <span class="badge bg-${latestSubmission.status == 'GRADED' ? 'success' : 'primary'}">
                                ${latestSubmission.status.displayName}
                        </span>
                            <c:if test="${latestSubmission.score != null}">
                                → Оценка: <strong>${latestSubmission.score}</strong> из ${assignment.maxScore}
                            </c:if>
                            <hr>
                            <small class="text-muted">Вы можете сдать повторно — последняя отправка будет учтена.</small>
                        </div>
                    </c:if>

                    <!-- Форма отправки -->
                    <form action="${pageContext.request.contextPath}/student/submission/create"
                          method="post"
                          enctype="multipart/form-data">

                        <input type="hidden" name="assignmentId" value="${assignment.id}">

                        <div class="mb-4">
                            <label for="comment" class="form-label">Комментарий (необязательно)</label>
                            <textarea name="content" id="comment" rows="4" class="form-control"
                                      placeholder="Например: всё сделал, проверьте п.5, использовал другой подход..."></textarea>
                        </div>

                        <div class="mb-4">
                            <label class="form-label">Прикрепить файл</label>
                            <div class="file-upload-area" id="dropArea">
                                <p class="text-muted mb-2">
                                    Перетащите файл сюда или нажмите для выбора
                                </p>
                                <input type="file" name="file" id="fileInput" class="d-none">
                                <button type="button" class="btn btn-outline-primary" onclick="document.getElementById('fileInput').click()">
                                    Выбрать файл
                                </button>
                                <div id="fileName" class="mt-3 text-primary fw-bold"></div>
                            </div>
                            <small class="text-muted">Поддерживаются: .pdf, .docx, .zip, .jpg и др.</small>
                        </div>

                        <div class="d-flex gap-3">
                            <button type="submit" class="btn btn-success btn-lg">
                                Отправить задание
                            </button>
                            <a href="${pageContext.request.contextPath}/student/assignments"
                               class="btn btn-secondary btn-lg">
                                Назад к заданиям
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Drag & Drop + отображение имени файла
    const dropArea = document.getElementById('dropArea');
    const fileInput = document.getElementById('fileInput');
    const fileNameDiv = document.getElementById('fileName');

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    ['dragenter', 'dragover'].forEach(eventName => {
        dropArea.addEventListener(eventName, () => dropArea.classList.add('dragover'), false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, () => dropArea.classList.remove('dragover'), false);
    });

    dropArea.addEventListener('drop', handleDrop, false);
    fileInput.addEventListener('change', () => {
        if (fileInput.files.length) {
            fileNameDiv.textContent = fileInput.files[0].name;
        }
    });

    function handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        if (files.length) {
            fileInput.files = files;
            fileNameDiv.textContent = files[0].name;
        }
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>