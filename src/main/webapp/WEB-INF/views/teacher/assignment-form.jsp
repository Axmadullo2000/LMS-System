<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create Assignment • EDUCORE</title>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@700&family=Playfair+Display:wght@600&family=Roboto:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <style><%@include file="/css/teacher/assignment-form.css"%></style>
</head>
<body>

<div class="topbar">
    <a href="${pageContext.request.contextPath}/teacher/dashboard" class="logo">EDUCORE</a>
    <a href="${pageContext.request.contextPath}/teacher/assignments" style="color:#aaa; text-decoration:none; font-size:1.1rem;">
        Back to Assignments
    </a>
</div>

<div class="container">

    <div class="page-title">
        <h1>CREATE ASSIGNMENT</h1>
        <p>Craft the next challenge for your elite cohort</p>
    </div>

    <!-- Отображение ошибок -->
    <c:if test="${not empty error}">
        <div style="background:#ffebee; border-left:4px solid #f44336; padding:15px; margin-bottom:20px; color:#c62828;">
            <strong>⚠️ Error:</strong> ${error}
        </div>
    </c:if>

    <div class="form-card">
        <form action="${pageContext.request.contextPath}/teacher/assignments/create"
              method="post"
              enctype="multipart/form-data"
              onsubmit="return validateForm()">

            <div class="form-group">
                <label for="title">
                    <i class="bi bi-pencil-square"></i> Assignment Title
                </label>
                <input type="text"
                       id="title"
                       name="title"
                       required
                       value="${param.title}"
                       placeholder="e.g. Final Project: Neural Network Architecture"
                       maxlength="150">
            </div>

            <div class="form-group">
                <label for="description">
                    <i class="bi bi-card-text"></i> Description & Requirements
                </label>
                <textarea id="description"
                          name="description"
                          required
                          rows="6"
                          placeholder="Describe the task, expected deliverables, and evaluation criteria...">${param.description}</textarea>
            </div>

            <div class="form-group">
                <label for="assignmentFile">
                    <i class="bi bi-file-earmark-arrow-up"></i> Assignment Materials (Optional)
                </label>
                <div style="position:relative;">
                    <input type="file"
                           id="assignmentFile"
                           name="assignmentFile"
                           accept=".pdf,.doc,.docx,.zip,.pptx,.txt,.rar"
                           onchange="updateFileName(this)">
                    <div id="fileNameDisplay" style="margin-top:8px; color:#888; font-style:italic; display:none;">
                        Selected: <span id="fileName"></span>
                    </div>
                </div>
                <small style="color:#888; margin-top:8px; display:block;">
                    📎 Supported formats: PDF, DOC, DOCX, ZIP, PPTX, TXT, RAR (max 10MB)
                </small>
            </div>

            <div class="form-group">
                <label for="dueDateDate">
                    <i class="bi bi-calendar-event"></i> Deadline
                </label>
                <div class="datetime-wrapper">
                    <input type="date"
                           id="dueDateDate"
                           name="dueDateDate"
                           required
                           value="${param.dueDateDate}"
                           min="${java.time.LocalDate.now()}">
                    <input type="time"
                           id="dueDateTime"
                           name="dueDateTime"
                           required
                           value="${not empty param.dueDateTime ? param.dueDateTime : '23:59'}">
                </div>
                <small id="datetimePreview" style="color:#888; margin-top:8px; display:block;">
                    Students will see countdown in their dashboard
                </small>
            </div>

            <div class="form-group">
                <label for="maxScore">
                    <i class="bi bi-trophy-fill"></i> Maximum Score
                </label>
                <div class="score-input-wrapper">
                    <input type="number"
                           id="maxScore"
                           name="maxScore"
                           required
                           min="1"
                           max="10000"
                           value="${not empty param.maxScore ? param.maxScore : '100'}"
                           step="1">
                    <div class="score-badge">
                        <span id="scoreDisplay">${not empty param.maxScore ? param.maxScore : '100'}</span>
                        <span class="points">pts</span>
                    </div>
                </div>
                <small style="color:#888; margin-top:8px; display:block;">
                    Highest achievable score • will be displayed on leaderboard
                </small>
            </div>

            <div class="form-group">
                <label>
                    <i class="bi bi-people-fill"></i> Select Groups
                </label>
                <c:if test="${empty groups}">
                    <div style="background:#fff3cd; border-left:4px solid #ffc107; padding:15px; color:#856404;">
                        ⚠️ No groups available.
                        <a href="${pageContext.request.contextPath}/teacher/groups/create"
                           style="color:#d4af37; font-weight:bold;">
                            Create a group first →
                        </a>
                    </div>
                </c:if>
                <c:forEach var="group" items="${groups}">
                    <div class="checkbox-group">
                        <input type="checkbox"
                               id="group_${group.id}"
                               name="groupIds"
                               value="${group.id}"
                               class="group-checkbox">
                        <label for="group_${group.id}">
                                ${group.name}
                            <span style="color:#888;">
                                (${group.students.size()} student${group.students.size() != 1 ? 's' : ''})
                            </span>
                        </label>
                    </div>
                </c:forEach>
                <div id="groupError" style="color:#f44336; margin-top:8px; display:none;">
                    ⚠️ Please select at least one group
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn-submit">
                    <i class="bi bi-send-fill"></i> Publish Assignment
                </button>
                <a href="${pageContext.request.contextPath}/teacher/assignments"
                   class="btn-cancel">
                    Cancel
                </a>
            </div>

        </form>
    </div>

</div>

    <script>
    // Обновление отображения баллов
    document.getElementById('maxScore').addEventListener('input', function(e) {
        const val = e.target.value || '100';
        document.getElementById('scoreDisplay').textContent = val;
    });

    // Предпросмотр даты и времени
    function updateDateTimePreview() {
        const date = document.getElementById('dueDateDate').value;
        const time = document.getElementById('dueDateTime').value;
        const preview = document.getElementById('datetimePreview');

        if (date && time) {
            try {
                const dateObj = new Date(date + 'T' + time);
                const options = {
                    weekday: 'long',
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                };
                preview.textContent = '📅 Due: ' + dateObj.toLocaleDateString('en-US', options);
                preview.style.color = '#d4af37';
                preview.style.fontWeight = 'bold';
            } catch (e) {
                preview.textContent = 'Students will see countdown in their dashboard';
                preview.style.color = '#888';
            }
        }
    }

    document.getElementById('dueDateDate').addEventListener('change', updateDateTimePreview);
    document.getElementById('dueDateTime').addEventListener('change', updateDateTimePreview);

    // Отображение имени выбранного файла
    function updateFileName(input) {
        const display = document.getElementById('fileNameDisplay');
        const fileName = document.getElementById('fileName');

        if (input.files && input.files[0]) {
            const file = input.files[0];
            const size = (file.size / 1024 / 1024).toFixed(2);

            fileName.textContent = file.name + ' (' + size + ' MB)';
            display.style.display = 'block';
            display.style.color = '#4caf50';
        } else {
            display.style.display = 'none';
        }
    }

    // Валидация формы перед отправкой
    function validateForm() {
        const checkboxes = document.querySelectorAll('.group-checkbox');
        const checked = Array.from(checkboxes).some(cb => cb.checked);
        const groupError = document.getElementById('groupError');

        if (!checked) {
            groupError.style.display = 'block';
            groupError.scrollIntoView({ behavior: 'smooth', block: 'center' });
            return false;
        }

        groupError.style.display = 'none';

        // Проверка размера файла
        const fileInput = document.getElementById('assignmentFile');
        if (fileInput.files && fileInput.files[0]) {
            const fileSize = fileInput.files[0].size / 1024 / 1024; // MB
            if (fileSize > 10) {
                alert('⚠️ File size exceeds 10MB. Please choose a smaller file.');
                return false;
            }
        }

        // Показываем индикатор загрузки
        const submitBtn = document.querySelector('.btn-submit');
        submitBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> Publishing...';
        submitBtn.disabled = true;

        return true;
    }

    // Инициализация при загрузке
    document.addEventListener('DOMContentLoaded', function() {
        updateDateTimePreview();
    });
</script>

</body>
</html>