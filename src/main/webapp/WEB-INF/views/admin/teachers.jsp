<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teachers - Admin Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style><%@include file="/css/admin/teachers.css"%></style>
</head>
<body>
    <!-- Sidebar Toggle -->
    <button class="sidebar-toggle" id="sidebarToggle">
        <i class="bi bi-list"></i>
    </button>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand"><i class="bi bi-mortarboard-fill"></i> LMS Teachers</div>
        <nav>
            <ul class="nav flex-column">
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link"><i class="bi bi-speedometer2"></i> <span>Dashboard</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users" class="nav-link"><i class="bi bi-people-fill"></i> <span>All Users</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/students" class="nav-link"><i class="bi bi-person-badge"></i></i> <span>Students</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/teachers" class="nav-link active"><i class="bi bi-person-workspace"></i> <span>Teachers</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/admins" class="nav-link"><i class="bi bi-shield-fill-check"></i> <span>Admins</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/groups" class="nav-link"><i class="bi bi-diagram-3-fill"></i> <span>Groups</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/assignments" class="nav-link"><i class="bi bi-journal-text"></i> <span>Assignments</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/submissions" class="nav-link"><i class="bi bi-file-earmark-check"></i> <span>Submissions</span></a></li>
            </ul>
        </nav>
    </aside>

    <div class="container">
        <!-- Header with Search -->
            <div class="header">
                <h1>👨‍🏫 Teachers (${teachers.size()})</h1>

                <form method="get" action="${pageContext.request.contextPath}/admin/users/teachers" class="search-form">
                    <input type="text" name="search" placeholder="Поиск по имени..." value="${searchQuery}">
                    <button type="submit" class="btn btn-primary">Search</button>
                    <c:if test="${not empty searchQuery}">
                        <a href="${pageContext.request.contextPath}/admin/users/teachers" class="btn btn-secondary">Reset</a>
                    </c:if>
                </form>

                <a href="${pageContext.request.contextPath}/admin/users/create" class="btn btn-success">
                    ➕ Add teacher
                </a>
            </div>

            <!-- Teachers Table -->
            <div class="table-card">
                <c:choose>
                    <c:when test="${empty teachers}">
                        <div class="empty-state">
                            <div class="empty-state-icon">📭</div>
                            <c:choose>
                                <c:when test="${not empty searchQuery}">
                                    <p>Teacher with name "${searchQuery}" is not found</p>
                                </c:when>
                                <c:otherwise>
                                    <p>No teachers available. Please create the first one!</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <thead>
                            <tr>
                                <th>Teacher</th>
                                <th>Email</th>
                                <th>Speciality</th>
                                <th>Status</th>
                                <th>Group</th>
                                <th>Assignment</th>
                                <th>Created date</th>
                                <th>Actions</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="teacher" items="${teachers}">
                                <tr>
                                    <td>
                                        <div class="user-info">
                                            <div class="avatar">
                                                    ${teacher.fullName.substring(0,1).toUpperCase()}
                                            </div>
                                            <strong>${teacher.fullName}</strong>
                                        </div>
                                    </td>
                                    <td>${teacher.email}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty teacher.specialization}">
                                                <span class="badge badge-secondary">${teacher.specialization}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #999;">-</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${teacher.active}">
                                                <span class="badge badge-success">✓ Активен</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-danger">✗ Неактивен</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge badge-info">${teacher.groups.size()} групп</span>
                                    </td>
                                    <td>
                                        <span class="badge badge-secondary">${teacher.createdAssignments.size()}</span>
                                    </td>
                                    <td>${teacher.formattedCreatedAt}</td>
                                    <td>
                                        <div class="actions">
                                            <c:choose>
                                                <c:when test="${teacher.active}">
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/users/deactivate" style="display: inline;">
                                                        <input type="hidden" name="userId" value="${teacher.id}">
                                                        <input type="hidden" name="userType" value="teacher">
                                                        <button type="submit" class="btn btn-warning btn-sm"
                                                                onclick="return confirm('Деактивировать преподавателя?')">
                                                            ⏸
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/users/activate" style="display: inline;">
                                                        <input type="hidden" name="userId" value="${teacher.id}">
                                                        <input type="hidden" name="userType" value="teacher">
                                                        <button type="submit" class="btn btn-success btn-sm">
                                                            ▶
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>

                                            <button class="btn btn-primary btn-sm" onclick="openModal('${teacher.id}')">
                                                👁
                                            </button>
                                        </div>
                                    </td>
                                </tr>

                                <!-- Modal for Teacher Details -->
                                <div class="modal" id="modal-${teacher.id}">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h3>👨‍🏫 Teacher details</h3>
                                            <button class="close-btn" onclick="closeModal('${teacher.id}')">&times;</button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="info-row">
                                                <div class="info-item">
                                                    <div class="info-label">Full Name</div>
                                                    <div class="info-value">${teacher.fullName}</div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">Email</div>
                                                    <div class="info-value">${teacher.email}</div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">Speciality</div>
                                                    <div class="info-value">
                                                            ${not empty teacher.specialization ? teacher.specialization : '-'}
                                                    </div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">ID</div>
                                                    <div class="info-value"><code>${teacher.id}</code></div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">Статус</div>
                                                    <div class="info-value">
                                                        <c:choose>
                                                            <c:when test="${teacher.active}">
                                                                <span class="badge badge-success">Active</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-danger">Inactive</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">Role</div>
                                                    <div class="info-value"><span class="badge badge-success">${teacher.role}</span></div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">Created</div>
                                                    <div class="info-value">${teacher.formattedCreatedAt}</div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">Updated</div>
                                                    <div class="info-value">${teacher.formattedUpdatedAt}</div>
                                                </div>
                                            </div>

                                            <div class="info-item">
                                                <div class="info-label">Groups</div>
                                                <c:choose>
                                                    <c:when test="${empty teacher.groups}">
                                                        <p style="color: #999;">Not assigned to any group.</p>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div style="display: flex; flex-wrap: wrap; gap: 5px; margin-top: 5px;">
                                                            <c:forEach var="group" items="${teacher.groups}">
                                                                <a href="${pageContext.request.contextPath}/admin/group/view?groupId=${group.id}"
                                                                   class="badge badge-info" style="text-decoration: none;">
                                                                        ${group.name}
                                                                </a>
                                                            </c:forEach>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="info-item">
                                                <div class="info-label">Statistics</div>
                                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 5px;">
                                                    <div>
                                                        📝 <strong>${teacher.createdAssignments.size()}</strong> Assignments Created
                                                    </div>
                                                    <div>
                                                        👁 <strong>${teacher.reviewingAssignments.size()}</strong> Under Review
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button class="btn btn-secondary" onclick="closeModal('${teacher.id}')">Close</button>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const sidebarToggle = document.getElementById('sidebarToggle');
        const sidebar = document.getElementById('sidebar');
        const body = document.body;

        const savedState = localStorage.getItem('sidebarCollapsed');
        if (savedState === 'true') {
            sidebar.classList.add('collapsed');
            body.classList.add('sidebar-collapsed');
        }

        sidebarToggle.addEventListener('click', () => {
            sidebar.classList.toggle('collapsed');
            body.classList.toggle('sidebar-collapsed');
            localStorage.setItem('sidebarCollapsed', sidebar.classList.contains('collapsed'));
        });
    </script>
</body>
</html>