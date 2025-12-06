<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Groups — Admin Dashboard LMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style><%@include file="/css/admin/groups.css"%></style>
</head>
<body>
    <!-- Sidebar Toggle -->
    <button class="sidebar-toggle" id="sidebarToggle">
        <i class="bi bi-list"></i>
    </button>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand"><i class="bi bi-mortarboard-fill"></i> LMS Dashboard</div>
        <nav>
            <ul class="nav flex-column">
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link"><i class="bi bi-speedometer2"></i> <span>Dashboard</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users" class="nav-link"><i class="bi bi-people-fill"></i> <span>All users</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/students" class="nav-link"><i class="bi bi-person-badge"></i></i> <span>Students</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/teachers" class="nav-link"><i class="bi bi-person-workspace"></i> <span>Teachers</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/users/admins" class="nav-link"><i class="bi bi-shield-fill-check"></i> <span>Admins</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/groups" class="nav-link active"><i class="bi bi-diagram-3-fill"></i> <span>Groups</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/assignments" class="nav-link"><i class="bi bi-journal-text"></i> <span>Assignments</span></a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/submissions" class="nav-link"><i class="bi bi-file-earmark-check"></i> <span>Submissions</span></a></li>
            </ul>
        </nav>
    </aside>

    <div class="main-content">
            <div class="container-fluid">

                <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3 mb-5">
                    <div>
                        <h1 class="mb-1">
                            <i class="bi bi-diagram-3-fill text-primary"></i>
                            Groups
                        </h1>
                        <p class="text-muted mb-0">Management of Academic Groups, Students, and Faculty</p>
                    </div>

                    <a href="${pageContext.request.contextPath}/admin/group/create"
                       class="btn btn-success btn-lg d-flex align-items-center gap-2 shadow-sm px-4">
                        <i class="bi bi-plus-circle-fill fs-5"></i>
                        Create group
                    </a>
                </div>

                <c:if test="${param.success == 'created'}">
                    <div class="alert alert-success alert-dismissible fade show">
                        The group has been successfully created.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.success == 'deleted'}">
                    <div class="alert alert-warning alert-dismissible fade show">
                        The group has been deleted.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${empty groups}">
                        <div class="text-center py-5 my-5">
                            <div class="empty-icon mb-4">
                                <i class="bi bi-diagram-3" style="font-size: 6rem; opacity: 0.15;"></i>
                            </div>
                            <h3 class="text-muted mb-3">No groups available.</h3>
                            <p class="text-muted mb-4 col-lg-6 mx-auto">
                                Please create the first group to begin adding students and faculty, and subsequently to assign tasks.
                            </p>
                            <a href="${pageContext.request.contextPath}/admin/group/create"
                               class="btn btn-success btn-lg px-5 d-inline-flex align-items-center gap-2 shadow">
                                <i class="bi bi-plus-circle"></i>
                                Create the First Group
                            </a>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="row g-4 mb-5">
                            <c:forEach var="group" items="${groups}">
                                <c:set var="studentsSize" value="${fn:length(group.students)}" />
                                <c:set var="teachersSize" value="${fn:length(group.teachers)}" />
                                <c:set var="assignmentsSize" value="${fn:length(group.assignments)}" />

                                <div class="col-lg-4 col-md-6">
                                    <div class="card h-100 shadow-sm border-0 rounded-3 overflow-hidden">
                                        <div class="card-header bg-gradient bg-primary text-white">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <h5 class="mb-0">
                                                    <i class="bi bi-diagram-3-fill me-2"></i>
                                                    <c:out value="${group.name}" />
                                                </h5>
                                                <div class="dropdown">
                                                    <button class="btn btn-sm btn-light dropdown-toggle" data-bs-toggle="dropdown">
                                                        <i class="bi bi-three-dots-vertical"></i>
                                                    </button>
                                                    <ul class="dropdown-menu dropdown-menu-end">
                                                        <li>
                                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/groups/view?groupId=${group.id}">
                                                                <i class="bi bi-eye text-primary"></i> Подробно
                                                            </a>
                                                        </li>
                                                        <li><hr class="dropdown-divider"></li>
                                                        <li>
                                                            <form method="post" action="${pageContext.request.contextPath}/admin/groups/delete"
                                                                  onsubmit="return confirm('Удалить группу «${group.name}»?');">
                                                                <input type="hidden" name="groupId" value="${group.id}">
                                                                <button type="submit" class="dropdown-item text-danger">
                                                                    <i class="bi bi-trash"></i> Delete
                                                                </button>
                                                            </form>
                                                        </li>
                                                    </ul>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="card-body">
                                            <c:if test="${not empty group.description}">
                                                <p class="text-muted small mb-3">
                                                    <i class="bi bi-info-circle me-1"></i>
                                                    <c:out value="${group.description}" />
                                                </p>
                                            </c:if>

                                            <div class="row g-3 text-center">
                                                <div class="col-4">
                                                    <div class="stat-box">
                                                        <i class="bi bi-people-fill text-primary fs-4"></i>
                                                        <div class="count fs-3 fw-bold">${studentsSize}</div>
                                                        <div class="label">Students</div>
                                                    </div>
                                                </div>
                                                <div class="col-4">
                                                    <div class="stat-box">
                                                        <i class="bi bi-person-workspace text-success fs-4"></i>
                                                        <div class="count fs-3 fw-bold">${teachersSize}</div>
                                                        <div class="label">Teachers</div>
                                                    </div>
                                                </div>
                                                <div class="col-4">
                                                    <div class="stat-box">
                                                        <i class="bi bi-journal-text text-warning fs-4"></i>
                                                        <div class="count fs-3 fw-bold">${assignmentsSize}</div>
                                                        <div class="label">Assignments</div>
                                                    </div>
                                                </div>
                                            </div>

                                            <c:if test="${teachersSize > 0}">
                                                <div class="mt-3 text-center">
                                                    <small class="text-muted">Преподаватели:</small>
                                                    <div class="d-flex justify-content-center gap-1 mt-1">
                                                        <c:forEach var="t" items="${group.teachers}" varStatus="s">
                                                            <c:if test="${s.index < 4}">
                                                                    <span class="teacher-badge" title="${t.fullName}">
                                                                            ${fn:toUpperCase(fn:substring(t.fullName, 0, 1))}
                                                                    </span>
                                                            </c:if>
                                                        </c:forEach>
                                                        <c:if test="${teachersSize > 4}">
                                                            <span class="teacher-badge badge-more">+${teachersSize - 4}</span>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </div>

                                        <div class="card-footer bg-light">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <small class="text-muted">
                                                    <i class="bi bi-calendar-event me-1"></i> ${group.formattedCreatedAt}
                                                </small>
                                                <a href="${pageContext.request.contextPath}/admin/groups/view?groupId=${group.id}"
                                                   class="btn btn-primary btn-sm">
                                                    Open
                                                    <i class="bi bi-arrow-right ms-1"></i>
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <!-- Summary Card -->
                        <div class="summary-card p-4 rounded-3 bg-light border">
                            <div class="row text-center">
                                <div class="col-md-3 col-6 mb-3">
                                    <h4 class="text-primary fw-bold">${fn:length(groups)}</h4>
                                    <p class="mb-0">Total Groups</p>
                                </div>
                                <div class="col-md-3 col-6 mb-3">
                                    <h4 class="text-success fw-bold">
                                        <c:set var="totalStudents" value="0"/>
                                        <c:forEach var="g" items="${groups}">
                                            <c:set var="totalStudents" value="${totalStudents + fn:length(g.students)}"/>
                                        </c:forEach>
                                            ${totalStudents}
                                    </h4>
                                    <p class="mb-0">Students</p>
                                </div>
                                <div class="col-md-3 col-6 mb-3">
                                    <h4 class="text-info fw-bold">
                                        <c:set var="totalTeachers" value="0"/>
                                        <c:forEach var="g" items="${groups}">
                                            <c:set var="totalTeachers" value="${totalTeachers + fn:length(g.teachers)}"/>
                                        </c:forEach>
                                            ${totalTeachers}
                                    </h4>
                                    <p class="mb-0">Teachers</p>
                                </div>
                                <div class="col-md-3 col-6 mb-3">
                                    <h4 class="text-warning fw-bold">
                                        <c:set var="totalAssignments" value="0"/>
                                        <c:forEach var="g" items="${groups}">
                                            <c:set var="totalAssignments" value="${totalAssignments + fn:length(g.assignments)}"/>
                                        </c:forEach>
                                            ${totalAssignments}
                                    </h4>
                                    <p class="mb-0">Assignments</p>
                                </div>
                            </div>
                        </div>
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