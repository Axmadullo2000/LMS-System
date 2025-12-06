<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admins - Admin Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style><%@include file="/css/admin/admins.css"%></style>
</head>
<body>
    <!-- Sidebar Toggle -->
    <button class="sidebar-toggle" id="sidebarToggle">
        <i class="bi bi-list"></i>
    </button>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand"><i class="bi bi-mortarboard-fill"></i> LMS Admins</div>
        <nav>
            <ul class="nav flex-column">
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link"><i class="bi bi-speedometer2"></i> <span>Dashboard</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users" class="nav-link"><i class="bi bi-people-fill"></i> <span>All users</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/students" class="nav-link"><i class="bi bi-person-badge"></i></i> <span>Students</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/teachers" class="nav-link"><i class="bi bi-person-workspace"></i> <span>Teachers</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/admins" class="nav-link active"><i class="bi bi-shield-fill-check"></i> <span>Admins</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/groups" class="nav-link"><i class="bi bi-diagram-3-fill"></i> <span>Groups</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/assignments" class="nav-link"><i class="bi bi-journal-text"></i> <span>Assignments</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/submissions" class="nav-link"><i class="bi bi-file-earmark-check"></i> <span>Submissions</span></a></li>
            </ul>
        </nav>
    </aside>


<div class="container">
        <!-- Header -->
        <div class="header">
            <div>
                <h1>🛡️ Admins (${admins.size()})</h1>
                <p class="info-text">Management of System Administrators and Their Privileges</p>
            </div>

            <a href="${pageContext.request.contextPath}/admin/users/create" class="btn btn-success">
                ➕ Add Administrator
            </a>
        </div>

        <!-- Admins Table -->
        <div class="table-card">
            <c:choose>
                <c:when test="${empty admins}">
                    <div class="empty-state">
                        <div class="empty-state-icon">📭</div>
                        <p>Нет администраторов. Создайте первого!</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                        <tr>
                            <th>Администратор</th>
                            <th>Email</th>
                            <th>Username</th>
                            <th>Department</th>
                            <th>Status</th>
                            <th>Created date</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="admin" items="${admins}">
                            <tr>
                                <td>
                                    <div class="user-info">
                                        <div class="avatar">
                                                ${admin.fullName.substring(0,1).toUpperCase()}
                                        </div>
                                        <strong>${admin.fullName}</strong>
                                    </div>
                                </td>
                                <td>${admin.email}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty admin.userName}">
                                            ${admin.userName}
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #999;">-</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty admin.department}">
                                            <span class="badge badge-secondary">${admin.department}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #999;">-</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${admin.active}">
                                            <span class="badge badge-success">✓ Active</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-danger">✗ Inactive</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${admin.formattedCreatedAt}</td>
                                <td>
                                    <div class="actions">
                                        <c:choose>
                                            <c:when test="${admin.active}">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/users/deactivate" style="display: inline;">
                                                    <input type="hidden" name="userId" value="${admin.id}">
                                                    <input type="hidden" name="userType" value="admin">
                                                    <button type="submit" class="btn btn-warning btn-sm"
                                                            onclick="return confirm('⚠️ Deactivate admin?')">
                                                        ⏸
                                                    </button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <form method="post" action="${pageContext.request.contextPath}/admin/users/activate" style="display: inline;">
                                                    <input type="hidden" name="userId" value="${admin.id}">
                                                    <input type="hidden" name="userType" value="admin">
                                                    <button type="submit" class="btn btn-success btn-sm">
                                                        ▶
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>

                                        <button class="btn btn-primary btn-sm" onclick="openModal('${admin.id}')">
                                            👁
                                        </button>
                                    </div>
                                </td>
                            </tr>

                            <!-- Modal for Admin Details -->
                            <div class="modal" id="modal-${admin.id}">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h3>🛡️ Детали администратора</h3>
                                        <button class="close-btn" onclick="closeModal('${admin.id}')">&times;</button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="warning-box">
                                            <strong>⚠️ Attention:</strong> This user possesses full system access.
                                        </div>

                                        <div class="info-row">
                                            <div class="info-item">
                                                <div class="info-label">Full Name</div>
                                                <div class="info-value">${admin.fullName}</div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label">Email</div>
                                                <div class="info-value">${admin.email}</div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label">Username</div>
                                                <div class="info-value">
                                                        ${not empty admin.userName ? admin.userName : '-'}
                                                </div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label">Department</div>
                                                <div class="info-value">
                                                        ${not empty admin.department ? admin.department : '-'}
                                                </div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label">ID</div>
                                                <div class="info-value"><code>${admin.id}</code></div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label">Status</div>
                                                <div class="info-value">
                                                    <c:choose>
                                                        <c:when test="${admin.active}">
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
                                                <div class="info-value">
                                                    <span class="badge badge-danger">${admin.role}</span>
                                                </div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label">Created</div>
                                                <div class="info-value">${admin.formattedCreatedAt}</div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label">Updated</div>
                                                <div class="info-value">${admin.formattedUpdatedAt}</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button class="btn btn-secondary" onclick="closeModal('${admin.id}')">Закрыть</button>
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