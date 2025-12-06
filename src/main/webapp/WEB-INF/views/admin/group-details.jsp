<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${group.name} - Детали группы</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
        }
        .breadcrumb {
            background: white;
            padding: 15px 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .breadcrumb-item a {
            color: #667eea;
            text-decoration: none;
        }
        .header-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .header-card h1 {
            color: #333;
            margin-bottom: 10px;
        }
        .header-actions {
            display: flex;
            gap: 15px;
            margin-top: 20px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        .stat-value {
            font-size: 2.5rem;
            font-weight: bold;
            color: #333;
        }
        .stat-label {
            color: #666;
            font-size: 0.9rem;
        }
        .card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            overflow: hidden;
        }
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .card-title {
            font-size: 1.3rem;
            font-weight: 600;
            margin: 0;
        }
        .list-item {
            padding: 20px 30px;
            border-bottom: 1px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .list-item:last-child {
            border-bottom: none;
        }
        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 1.2rem;
            color: white;
        }
        .avatar-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .avatar-success {
            background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
        }
        .user-name {
            font-weight: 600;
            color: #333;
            font-size: 1.1rem;
        }
        .user-email {
            color: #666;
            font-size: 0.9rem;
        }
        .empty-state {
            padding: 60px 30px;
            text-align: center;
            color: #999;
        }
        .empty-state i {
            font-size: 4rem;
            color: #ddd;
            margin-bottom: 20px;
        }
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        .modal.show {
            display: flex;
        }
        .modal-content {
            background: white;
            border-radius: 15px;
            width: 90%;
            max-width: 600px;
            max-height: 90vh;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }
        .modal-header {
            padding: 20px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .modal-header h3 {
            margin: 0;
        }
        .close-btn {
            background: none;
            border: none;
            color: white;
            font-size: 2rem;
            cursor: pointer;
            line-height: 1;
        }
        .modal-body {
            padding: 30px;
            overflow-y: auto;
            flex: 1;
        }
        .modal-footer {
            padding: 20px 30px;
            border-top: 1px solid #eee;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        .student-list {
            max-height: 400px;
            overflow-y: auto;
        }
        .student-item {
            padding: 15px;
            border: 2px solid #f0f0f0;
            border-radius: 10px;
            margin-bottom: 10px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 15px;
            transition: all 0.3s;
        }
        .student-item:hover {
            border-color: #667eea;
            background: #f8f9ff;
        }
        .student-item input[type="checkbox"] {
            width: 20px;
            height: 20px;
            cursor: pointer;
        }
        .search-box {
            position: relative;
            margin-bottom: 20px;
        }
        .search-box input {
            width: 100%;
            padding: 12px 15px 12px 45px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 1rem;
        }
        .search-box i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
        }
        .badge {
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        .badge-primary {
            background: #e3f2fd;
            color: #2196f3;
        }
        .badge-success {
            background: #e8f5e9;
            color: #4caf50;
        }
        .badge-danger {
            background: #ffebee;
            color: #f44336;
        }
        .badge-secondary {
            background: #f5f5f5;
            color: #666;
        }
        .table {
            width: 100%;
            margin-top: 20px;
        }
        .table th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #666;
        }
        .table td {
            padding: 15px;
            border-bottom: 1px solid #f0f0f0;
        }
        .progress {
            height: 8px;
            background: #f0f0f0;
            border-radius: 10px;
            overflow: hidden;
        }
        .progress-bar {
            height: 100%;
            transition: width 0.3s;
        }
        .bg-success {
            background: linear-gradient(90deg, #4caf50 0%, #45a049 100%);
        }
        .bg-warning {
            background: linear-gradient(90deg, #ff9800 0%, #f57c00 100%);
        }
        .bg-danger {
            background: linear-gradient(90deg, #f44336 0%, #d32f2f 100%);
        }
        .selected-count {
            background: white;
            color: #667eea;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
        }
    </style>
</head>
<body>
<div class="container">
    <!-- Alerts -->
    <c:if test="${param.success == 'teacher_added'}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle me-2"></i>
            Преподаватель успешно добавлен в группу!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${param.success == 'teacher_removed'}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle me-2"></i>
            Преподаватель удалён из группы.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${param.success == 'students_added'}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle me-2"></i>
            Студенты успешно добавлены в группу!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${param.error != null}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-x-circle me-2"></i>
            Ошибка: ${param.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Главная</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/groups">Группы</a></li>
            <li class="breadcrumb-item active">${group.name}</li>
        </ol>
    </nav>

    <!-- Header -->
    <div class="header-card">
        <h1><i class="bi bi-people-fill me-2"></i>${group.name}</h1>
        <c:if test="${not empty group.description}">
            <p class="text-muted">${group.description}</p>
        </c:if>
        <div class="text-muted small">
            <i class="bi bi-calendar3"></i> Создано: ${group.formattedCreatedAt}
            <span class="ms-3"><i class="bi bi-key"></i> ID: <code>${group.id}</code></span>
        </div>
        <div class="header-actions">
            <a href="${pageContext.request.contextPath}/teacher/assignment/create?groupId=${group.id}"
               class="btn btn-success">
                <i class="bi bi-plus-circle me-2"></i>Создать задание
            </a>
            <form method="post" action="${pageContext.request.contextPath}/admin/groups/delete"
                  onsubmit="return confirm('Удалить группу «${group.name}»?')">
                <input type="hidden" name="groupId" value="${group.id}">
                <button type="submit" class="btn btn-danger">
                    <i class="bi bi-trash3 me-2"></i>Удалить группу
                </button>
            </form>
        </div>
    </div>

    <!-- Statistics -->
    <div class="stats-grid">
        <div class="stat-card">
            <i class="bi bi-person-fill stat-icon text-primary"></i>
            <div class="stat-value">${studentSize}</div>
            <div class="stat-label">Студентов</div>
        </div>
        <div class="stat-card">
            <i class="bi bi-person-badge stat-icon text-success"></i>
            <div class="stat-value">${teacherSize}</div>
            <div class="stat-label">Преподавателей</div>
        </div>
        <div class="stat-card">
            <i class="bi bi-journal-text stat-icon text-warning"></i>
            <div class="stat-value">${assignmentSize}</div>
            <div class="stat-label">Заданий</div>
        </div>
    </div>

    <!-- Teachers -->
    <div class="card">
        <div class="card-header">
            <div class="card-title">
                <i class="bi bi-person-badge me-2"></i>Преподаватели
            </div>
            <button class="btn btn-light btn-sm" onclick="openTeacherModal()">
                <i class="bi bi-plus-lg me-1"></i>Добавить
            </button>
        </div>
        <c:choose>
            <c:when test="${teacherSize == 0}">
                <div class="empty-state">
                    <i class="bi bi-person-x"></i>
                    <p>Нет преподавателей в группе</p>
                    <button class="btn btn-primary mt-3" onclick="openTeacherModal()">
                        <i class="bi bi-plus-circle me-2"></i>Добавить преподавателя
                    </button>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="teacher" items="${group.teachers}">
                    <div class="list-item">
                        <div class="user-info">
                            <div class="avatar avatar-success">${fn:substring(teacher.fullName, 0, 1)}</div>
                            <div>
                                <div class="user-name">${teacher.fullName}</div>
                                <div class="user-email">
                                    <i class="bi bi-envelope me-1"></i>${teacher.email}
                                </div>
                                <c:if test="${not empty teacher.specialization}">
                                    <span class="badge badge-secondary mt-1">
                                        <i class="bi bi-award me-1"></i>${teacher.specialization}
                                    </span>
                                </c:if>
                            </div>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/admin/groups/remove-teacher">
                            <input type="hidden" name="groupId" value="${group.id}">
                            <input type="hidden" name="teacherId" value="${teacher.id}">
                            <button type="submit" class="btn btn-outline-danger btn-sm"
                                    onclick="return confirm('Удалить ${teacher.fullName} из группы?')">
                                <i class="bi bi-trash3"></i> Удалить
                            </button>
                        </form>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Students -->
    <div class="card">
        <div class="card-header">
            <div class="card-title">
                <i class="bi bi-people me-2"></i>Студенты
            </div>
            <div>
                <span class="badge badge-primary me-2">${studentSize}</span>
                <button class="btn btn-light btn-sm" onclick="openStudentModal()">
                    <i class="bi bi-plus-lg me-1"></i>Добавить
                </button>
            </div>
        </div>
        <c:choose>
            <c:when test="${studentSize == 0}">
                <div class="empty-state">
                    <i class="bi bi-people"></i>
                    <p>В группе пока нет студентов</p>
                    <button class="btn btn-primary mt-3" onclick="openStudentModal()">
                        <i class="bi bi-plus-circle me-2"></i>Добавить студентов
                    </button>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="student" items="${group.students}" varStatus="status">
                    <div class="list-item">
                        <div class="user-info">
                            <span class="text-muted me-3">#${status.index + 1}</span>
                            <div class="avatar avatar-primary">${fn:substring(student.fullName, 0, 1)}</div>
                            <div>
                                <div class="user-name">${student.fullName}</div>
                                <div class="user-email">
                                    <i class="bi bi-envelope me-1"></i>${student.email}
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Assignments -->
    <div class="card">
        <div class="card-header">
            <div class="card-title">
                <i class="bi bi-journal-text me-2"></i>Задания группы
            </div>
            <a href="${pageContext.request.contextPath}/teacher/assignment/create?groupId=${group.id}"
               class="btn btn-light btn-sm">
                <i class="bi bi-plus-circle me-1"></i>Создать
            </a>
        </div>
        <div class="p-4">
            <c:choose>
                <c:when test="${assignmentSize == 0}">
                    <div class="empty-state">
                        <i class="bi bi-journal-x"></i>
                        <p>Пока нет заданий</p>
                        <a href="${pageContext.request.contextPath}/teacher/assignment/create?groupId=${group.id}"
                           class="btn btn-primary mt-3">
                            <i class="bi bi-plus-circle me-2"></i>Создать первое задание
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>Задание</th>
                                <th>Создатель</th>
                                <th>Сдано</th>
                                <th>Статус</th>
                                <th>Срок</th>
                                <th>Действия</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="assignment" items="${assignments}">
                                <tr>
                                    <td>
                                        <strong>${assignment.title}</strong>
                                        <br>
                                        <small class="text-muted">${fn:substring(assignment.description, 0, 100)}${fn:length(assignment.description) > 100 ? '...' : ''}</small>
                                    </td>
                                    <td>${assignment.creator.fullName}</td>
                                    <td>
                                        <c:set var="submCount" value="${submissionCounts[assignment.id]}" />
                                        <c:set var="studCount" value="${totalStudents}" />

                                        <strong>${submCount}</strong> / ${studCount}

                                        <c:if test="${studCount > 0}">
                                            <c:set var="percentage" value="${completionRates[assignment.id]}" />
                                            <div class="progress mt-1" style="height: 6px;">
                                                <div class="progress-bar ${percentage >= 100 ? 'bg-success' : percentage >= 50 ? 'bg-warning' : 'bg-danger'}"
                                                     role="progressbar"
                                                     style="width: ${percentage}%"
                                                     aria-valuenow="${percentage}"
                                                     aria-valuemin="0"
                                                     aria-valuemax="100">
                                                </div>
                                            </div>
                                            <small class="text-muted">${String.format("%.0f", percentage)}%</small>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:set var="gradedCount" value="${gradedCounts[assignment.id]}" />
                                        <span class="badge ${gradedCount == submCount && submCount > 0 ? 'badge-success' : 'badge-secondary'}">
                                            ${gradedCount} / ${submCount} проверено
                                        </span>
                                    </td>
                                    <td>
                                            ${assignment.formattedDueDate}
                                        <c:if test="${assignment.overdue}">
                                            <br><span class="badge badge-danger">Просрочено</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/teacher/submissions?assignmentId=${assignment.id}"
                                           class="btn btn-sm btn-primary">
                                            <i class="bi bi-eye me-1"></i>Просмотр
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Teacher Modal -->
<div class="modal" id="teacherModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="bi bi-person-plus me-2"></i>Добавить преподавателя</h3>
            <button class="close-btn" onclick="closeTeacherModal()">×</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/admin/groups/add-teacher">
            <input type="hidden" name="groupId" value="${group.id}">
            <div class="modal-body">
                <c:choose>
                    <c:when test="${empty allTeachers}">
                        <div class="text-center text-muted">
                            <i class="bi bi-info-circle" style="font-size: 3rem;"></i>
                            <p class="mt-3">Все преподаватели уже добавлены</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <label class="form-label">Выберите преподавателя:</label>
                        <select name="teacherId" class="form-select form-select-lg" required>
                            <option value="">— Выберите —</option>
                            <c:forEach var="teacher" items="${allTeachers}">
                                <option value="${teacher.id}">
                                        ${teacher.fullName}
                                    <c:if test="${not empty teacher.specialization}">
                                        — ${teacher.specialization}
                                    </c:if>
                                </option>
                            </c:forEach>
                        </select>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeTeacherModal()">Отмена</button>
                <c:if test="${not empty allTeachers}">
                    <button type="submit" class="btn btn-success">
                        <i class="bi bi-plus-circle me-2"></i>Добавить
                    </button>
                </c:if>
            </div>
        </form>
    </div>
</div>

<!-- Student Modal -->
<div class="modal" id="studentModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="bi bi-people-fill me-2"></i>Добавить студентов</h3>
            <span class="selected-count" id="selectedCount">Выбрано: 0</span>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/admin/groups/add-students">
            <input type="hidden" name="groupId" value="${group.id}">
            <div class="modal-body">
                <div class="search-box">
                    <i class="bi bi-search"></i>
                    <input type="text" id="studentSearch" placeholder="Поиск по имени или email...">
                </div>
                <div class="student-list">
                    <c:choose>
                        <c:when test="${empty availableStudents}">
                            <div class="text-center text-muted">
                                <i class="bi bi-info-circle" style="font-size: 3rem;"></i>
                                <p class="mt-3">Все студенты уже добавлены</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="student" items="${availableStudents}">
                                <label class="student-item" data-name="${fn:toLowerCase(student.fullName)}"
                                       data-email="${fn:toLowerCase(student.email)}">
                                    <input type="checkbox" name="studentIds" value="${student.id}">
                                    <div class="user-info">
                                        <div class="avatar avatar-primary">
                                                ${fn:substring(student.fullName, 0, 1)}
                                        </div>
                                        <div>
                                            <div class="user-name">${student.fullName}</div>
                                            <div class="user-email">${student.email}</div>
                                        </div>
                                    </div>
                                </label>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeStudentModal()">Отмена</button>
                <c:if test="${not empty availableStudents}">
                    <button type="submit" class="btn btn-success" id="submitStudentsBtn" disabled>
                        <i class="bi bi-plus-circle me-2"></i>Добавить
                    </button>
                </c:if>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Modal functions
    function openTeacherModal() {
        document.getElementById('teacherModal').classList.add('show');
    }

    function closeTeacherModal() {
        document.getElementById('teacherModal').classList.remove('show');
    }

    function openStudentModal() {
        document.getElementById('studentModal').classList.add('show');
        updateSelectedCount();
    }

    function closeStudentModal() {
        document.getElementById('studentModal').classList.remove('show');
        document.getElementById('studentSearch').value = '';
        filterStudents('');
    }

    // Close modal on outside click
    document.querySelectorAll('.modal').forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === this) {
                this.classList.remove('show');
            }
        });
    });

    // Close modal on Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeTeacherModal();
            closeStudentModal();
        }
    });

    // Student search functionality
    const studentSearchInput = document.getElementById('studentSearch');
    if (studentSearchInput) {
        studentSearchInput.addEventListener('input', function() {
            filterStudents(this.value.toLowerCase());
        });
    }

    function filterStudents(query) {
        const studentItems = document.querySelectorAll('.student-item');
        studentItems.forEach(item => {
            const name = item.getAttribute('data-name') || '';
            const email = item.getAttribute('data-email') || '';
            if (name.includes(query) || email.includes(query)) {
                item.style.display = '';
            } else {
                item.style.display = 'none';
            }
        });
    }

    // Update selected students count
    function updateSelectedCount() {
        const checkboxes = document.querySelectorAll('input[name="studentIds"]');
        const submitBtn = document.getElementById('submitStudentsBtn');
        const counter = document.getElementById('selectedCount');

        if (!checkboxes.length || !submitBtn || !counter) return;

        let count = 0;
        checkboxes.forEach(cb => {
            if (cb.checked) count++;
        });

        counter.textContent = `Выбрано: ${count}`;
        submitBtn.disabled = count === 0;

        if (count === 0) {
            submitBtn.innerHTML = '<i class="bi bi-exclamation-circle me-2"></i>Выберите студентов';
        } else if (count === 1) {
            submitBtn.innerHTML = '<i class="bi bi-plus-circle me-2"></i>Добавить 1 студента';
        } else {
            submitBtn.innerHTML = `<i class="bi bi-plus-circle me-2"></i>Добавить студентов (${count})`;
        }
    }

    // Add event listeners to checkboxes
    document.querySelectorAll('input[name="studentIds"]').forEach(checkbox => {
        checkbox.addEventListener('change', updateSelectedCount);
    });

    // Auto-dismiss alerts after 5 seconds
    document.querySelectorAll('.alert').forEach(alert => {
        setTimeout(() => {
            const bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }, 5000);
    });

    // Select all / Deselect all functionality
    function createSelectAllButton() {
        const studentList = document.querySelector('.student-list');
        const availableStudents = document.querySelectorAll('input[name="studentIds"]');

        if (studentList && availableStudents.length > 0) {
            const selectAllBtn = document.createElement('button');
            selectAllBtn.type = 'button';
            selectAllBtn.className = 'btn btn-outline-primary btn-sm mb-3';
            selectAllBtn.innerHTML = '<i class="bi bi-check-all me-1"></i>Выбрать всех';
            selectAllBtn.id = 'selectAllBtn';

            selectAllBtn.addEventListener('click', function() {
                const visibleCheckboxes = Array.from(availableStudents).filter(cb => {
                    return cb.closest('.student-item').style.display !== 'none';
                });

                const allChecked = visibleCheckboxes.every(cb => cb.checked);

                visibleCheckboxes.forEach(cb => {
                    cb.checked = !allChecked;
                });

                if (allChecked) {
                    this.innerHTML = '<i class="bi bi-check-all me-1"></i>Выбрать всех';
                } else {
                    this.innerHTML = '<i class="bi bi-x-circle me-1"></i>Снять выбор';
                }

                updateSelectedCount();
            });

            const searchBox = document.querySelector('.search-box');
            if (searchBox) {
                searchBox.after(selectAllBtn);
            }
        }
    }

    // Initialize select all button
    createSelectAllButton();

    // Update select all button state when filtering
    const originalFilterStudents = filterStudents;
    filterStudents = function(query) {
        originalFilterStudents(query);

        const selectAllBtn = document.getElementById('selectAllBtn');
        if (selectAllBtn) {
            const visibleCheckboxes = Array.from(document.querySelectorAll('input[name="studentIds"]')).filter(cb => {
                return cb.closest('.student-item').style.display !== 'none';
            });

            if (visibleCheckboxes.length === 0) {
                selectAllBtn.disabled = true;
            } else {
                selectAllBtn.disabled = false;
                const allChecked = visibleCheckboxes.every(cb => cb.checked);
                if (allChecked) {
                    selectAllBtn.innerHTML = '<i class="bi bi-x-circle me-1"></i>Снять выбор';
                } else {
                    selectAllBtn.innerHTML = '<i class="bi bi-check-all me-1"></i>Выбрать всех';
                }
            }
        }
    };

    // Smooth scroll to top when alerts appear
    if (document.querySelector('.alert')) {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // Confirm before deleting group
    document.querySelectorAll('form[action*="delete"]').forEach(form => {
        form.addEventListener('submit', function(e) {
            if (!this.hasAttribute('data-confirmed')) {
                e.preventDefault();
                if (confirm(this.getAttribute('onsubmit')?.replace('return confirm(', '').replace(')', '') || 'Вы уверены?')) {
                    this.setAttribute('data-confirmed', 'true');
                    this.submit();
                }
            }
        });
    });
</script>
</body>
</html>