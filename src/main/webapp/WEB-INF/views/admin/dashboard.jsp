<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - LMS Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style><%@include file="/css/admin/dashboard.css"%></style>
</head>
<body>
    <!-- HEADER -->
    <header class="main-header">
        <div class="header-left">
            <h1>LMS Admin Panel</h1>
            <p>Learning Management System Dashboard</p>
        </div>
        <div class="header-right">
            <form action="${pageContext.request.contextPath}/logout">
                <button type="submit" class="btn btn-danger btn-sm">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </button>
            </form>
        </div>
    </header>

    <!-- Sidebar Toggle -->
    <button class="sidebar-toggle" id="sidebarToggle">
        <i class="bi bi-list"></i>
    </button>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand"><i class="bi bi-mortarboard-fill"></i> LMS Dashboard</div>
        <nav>
            <ul class="nav flex-column">
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link active"><i class="bi bi-speedometer2"></i> <span>Dashboard</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users" class="nav-link"><i class="bi bi-people-fill"></i> <span>All users</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/students" class="nav-link"><i class="bi bi-person-badge"></i></i> <span>Students</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/teachers" class="nav-link"><i class="bi bi-person-workspace"></i> <span>Teachers</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/admins" class="nav-link"><i class="bi bi-shield-fill-check"></i> <span>Admins</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/groups" class="nav-link"><i class="bi bi-diagram-3-fill"></i> <span>Groups</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/assignments" class="nav-link"><i class="bi bi-journal-text"></i> <span>Assignments</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/submissions" class="nav-link"><i class="bi bi-file-earmark-check"></i> <span>Submissions</span></a></li>
            </ul>
        </nav>
    </aside>


    <div class="container">
            <!-- Header -->
            <div class="header">
                <div class="header-content">
                    <h1>Academic Administration Panel</h1>
                    <p>Learning Management System (LMS)</p>
                </div>
                <div class="header-actions">
                    <a href="${pageContext.request.contextPath}/admin/users/create" class="create_new_user">
                        Create New User
                    </a>
                </div>
            </div>

            <!-- Statistics Cards -->
            <div class="stats-grid">
                <!-- Students Card -->
                <a href="${pageContext.request.contextPath}/admin/users/students" style="text-decoration: none; color: inherit;">
                    <div class="stat-card students">
                        <div class="stat-header">
                            <div class="stat-icon">Student</div>
                        </div>
                        <div class="stat-label">Total Students</div>
                        <div class="stat-value">${totalStudents}</div>
                        <div class="stat-info">
                            Registered learners
                        </div>
                    </div>
                </a>

                <!-- Teachers Card -->
                <a href="${pageContext.request.contextPath}/admin/users/teachers" style="text-decoration: none; color: inherit;">
                    <div class="stat-card teachers">
                        <div class="stat-header">
                            <div class="stat-icon">Teacher</div>
                        </div>
                        <div class="stat-label">Teaching Staff</div>
                        <div class="stat-value">${totalTeachers}</div>
                        <div class="stat-info">
                            Active: <span class="stat-badge badge-success">${activeTeachers}</span>
                        </div>
                    </div>
                </a>

                <!-- Groups Card -->
                <a href="${pageContext.request.contextPath}/admin/groups" style="text-decoration: none; color: inherit;">
                    <div class="stat-card groups">
                        <div class="stat-header">
                            <div class="stat-icon">Group</div>
                        </div>
                        <div class="stat-label">Study Groups</div>
                        <div class="stat-value">${totalGroups}</div>
                        <div class="stat-info">
                            Courses and academic groups
                        </div>
                    </div>
                </a>

                <!-- Assignments Card -->
                <a href="${pageContext.request.contextPath}/admin/assignments" style="text-decoration: none; color: inherit;">
                    <div class="stat-card assignments">
                        <div class="stat-header">
                            <div class="stat-icon">Assignment</div>
                        </div>
                        <div class="stat-label">Assignments</div>
                        <div class="stat-value">${totalAssignments}</div>
                        <div class="stat-info">
                            Total created assignments
                        </div>
                    </div>
                </a>

                <!-- Submissions Card -->
                <a href="${pageContext.request.contextPath}/admin/submissions" style="text-decoration: none; color: inherit;">
                    <div class="stat-card submissions">
                        <div class="stat-header">
                            <div class="stat-icon">Submission</div>
                        </div>
                        <div class="stat-label">Submitted Works</div>
                        <div class="stat-value">${totalSubmissions}</div>
                        <div class="stat-info">
                            Total number of submissions
                        </div>
                    </div>
                </a>

                <!-- Pending Submissions Card -->
                <a href="${pageContext.request.contextPath}/admin/submissions" style="text-decoration: none; color: inherit;">
                    <div class="stat-card pending">
                        <div class="stat-header">
                            <div class="stat-icon">Pending</div>
                        </div>
                        <div class="stat-label">Pending Review</div>
                        <div class="stat-value">${pendingSubmissions}</div>
                        <div class="stat-info">
                            <c:if test="${pendingSubmissions > 0}">
                                <span class="stat-badge badge-warning">Require attention</span>
                            </c:if>
                            <c:if test="${pendingSubmissions == 0}">
                                All reviewed
                            </c:if>
                        </div>
                    </div>
                </a>
            </div>

            <!-- Quick Actions Section -->
            <div class="actions-section">
                <!-- User Management -->
                <div class="action-card">
                    <h2>User Management</h2>
                    <ul class="action-list">
                        <li class="action-item">
                            <a href="${pageContext.request.contextPath}/admin/users" class="action-link">
                                All Users
                            </a>
                        </li>
                        <li class="action-item">
                            <a href="${pageContext.request.contextPath}/admin/users/students" class="action-link">
                                Students
                            </a>
                        </li>
                        <li class="action-item">
                            <a href="${pageContext.request.contextPath}/admin/users/teachers" class="action-link">
                                Teachers
                            </a>
                        </li>
                        <li class="action-item">
                            <a href="${pageContext.request.contextPath}/admin/users/admins" class="action-link">
                                Administrators
                            </a>
                        </li>
                        <li class="action-item">
                            <a href="${pageContext.request.contextPath}/admin/users/create" class="action-link">
                                Create User
                            </a>
                        </li>
                    </ul>
                </div>

                <!-- Content Management -->
                <div class="action-card">
                    <h2>Content & Assessment</h2>
                    <ul class="action-list">
                        <li class="action-item">
                            <a href="${pageContext.request.contextPath}/admin/groups" class="action-link">
                                Study Groups
                            </a>
                        </li>
                        <li class="action-item">
                            <a href="${pageContext.request.contextPath}/admin/assignments" class="action-link">
                                All Assignments
                            </a>
                        </li>
                        <li class="action-item">
                            <a href="${pageContext.request.contextPath}/admin/assignments?filter=upcoming" class="action-link">
                                Upcoming Assignments
                            </a>
                        </li>
                        <li class="action-item">
                            <a href="${pageContext.request.contextPath}/admin/assignments?filter=expired" class="action-link">
                                Expired Assignments
                            </a>
                        </li>
                        <li class="action-item">
                            <a href="${pageContext.request.contextPath}/admin/submissions" class="action-link">
                                All Submissions
                            </a>
                        </li>
                    </ul>
                </div>
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