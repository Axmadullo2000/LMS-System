<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
    <title>Assignments - Admin Panel</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style><%@include file="/css/admin/assignments.css"%></style>
</head>
<body>
    <!-- Sidebar Toggle Button -->
    <button class="sidebar-toggle" id="sidebarToggle">
        <i class="bi bi-list"></i>
    </button>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand"><i class="bi bi-mortarboard-fill"></i> LMS Assignments</div>
        <nav>
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link">
                        <i class="bi bi-speedometer2"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/users" class="nav-link">
                        <i class="bi bi-people-fill"></i>
                        <span>All Users</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/users/students" class="nav-link">
                        <i class="bi bi-person-badge"></i>
                        <span>Students</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/users/teachers" class="nav-link">
                        <i class="bi bi-person-workspace"></i>
                        <span>Teachers</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/users/admins" class="nav-link">
                        <i class="bi bi-shield-fill-check"></i>
                        <span>Admins</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/groups" class="nav-link">
                        <i class="bi bi-diagram-3-fill"></i>
                        <span>Groups</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/assignments" class="nav-link active">
                        <i class="bi bi-journal-text"></i>
                        <span>Assignments</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/submissions" class="nav-link">
                        <i class="bi bi-file-earmark-check"></i>
                        <span>Submissions</span>
                    </a>
                </li>
            </ul>
        </nav>
    </aside>

    <!-- Main Content -->
    <div class="container-fluid">
        <!-- Page Header -->
        <div class="page-header">
            <h1>
                <i class="bi bi-journal-text"></i>
                Assignments Management
            </h1>
        </div>

        <!-- Filter Bar -->
        <div class="card filter-bar">
            <div class="card-body">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <div class="btn-group" role="group">
                            <a href="${pageContext.request.contextPath}/admin/assignments"
                               class="btn ${empty filter ? 'btn-primary' : 'btn-outline-primary'}">
                                <i class="bi bi-list-ul"></i> All Assignments
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/assignments?filter=upcoming"
                               class="btn ${filter == 'upcoming' ? 'btn-warning' : 'btn-outline-warning'}">
                                <i class="bi bi-calendar-event"></i> Upcoming (7 days)
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/assignments?filter=expired"
                               class="btn ${filter == 'expired' ? 'btn-danger' : 'btn-outline-danger'}">
                                <i class="bi bi-clock-history"></i> Expired
                            </a>
                        </div>
                    </div>
                    <div class="col-md-4 text-end">
                        <span class="text-muted">
                            <i class="bi bi-journal-text"></i>
                            Total: <strong>${fn:length(assignments)}</strong>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Assignments Table -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="bi bi-journal-text text-warning"></i>
                    <c:choose>
                        <c:when test="${filter == 'upcoming'}">Upcoming Assignments</c:when>
                        <c:when test="${filter == 'expired'}">Expired Assignments</c:when>
                        <c:otherwise>All Assignments</c:otherwise>
                    </c:choose>
                    <span class="badge bg-warning text-dark rounded-pill ms-2">${fn:length(assignments)}</span>
                </h5>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty assignments}">
                        <!-- Empty State -->
                        <div class="empty-state">
                            <i class="bi bi-inbox"></i>
                            <h5>No Assignments Found</h5>
                            <p>
                                <c:choose>
                                    <c:when test="${filter == 'upcoming'}">No upcoming assignments in the next 7 days</c:when>
                                    <c:when test="${filter == 'expired'}">No expired assignments found</c:when>
                                    <c:otherwise>No assignments found in the system</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <!-- Assignments Table -->
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                <tr>
                                    <th style="width: 5%">#</th>
                                    <th style="width: 25%">Title</th>
                                    <th style="width: 15%">Creator</th>
                                    <th style="width: 12%">Due Date</th>
                                    <th style="width: 8%">Score</th>
                                    <th style="width: 10%">Groups</th>
                                    <th style="width: 10%">Submissions</th>
                                    <th style="width: 10%">Status</th>
                                    <th style="width: 5%" class="text-center">Actions</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="assignment" items="${assignments}" varStatus="status">
                                    <c:set var="groupsSize" value="${fn:length(assignment.groups)}" />
                                    <c:set var="submissionsSize" value="${fn:length(assignment.submissions)}" />

                                    <tr>
                                        <td><strong>${status.index + 1}</strong></td>
                                        <td>
                                            <div>
                                                <strong><c:out value="${assignment.title}" /></strong>
                                                <c:if test="${not empty assignment.description}">
                                                    <br>
                                                    <small class="text-muted">
                                                        <c:choose>
                                                            <c:when test="${fn:length(assignment.description) > 50}">
                                                                <c:out value="${fn:substring(assignment.description, 0, 50)}" />...
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:out value="${assignment.description}" />
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </small>
                                                </c:if>
                                                <c:if test="${assignment.hasFile()}">
                                                    <br>
                                                    <small class="text-info">
                                                        <i class="bi bi-paperclip"></i>
                                                        <c:out value="${assignment.fileName}" />
                                                    </small>
                                                </c:if>
                                            </div>
                                        </td>
                                        <td>
                                            <c:if test="${not empty assignment.creator}">
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="avatar">
                                                        <c:set var="creatorName" value="${assignment.creator.fullName}" />
                                                            ${fn:toUpperCase(fn:substring(creatorName, 0, 1))}
                                                    </div>
                                                    <small><c:out value="${assignment.creator.fullName}" /></small>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty assignment.dueDate}">
                                                    <fmt:formatDate value="${assignment.dueDate}" pattern="MMM dd, yyyy" />
                                                    <br>
                                                    <small class="text-muted">
                                                        <fmt:formatDate value="${assignment.dueDate}" pattern="HH:mm" />
                                                    </small>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">No deadline</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge bg-info">
                                                ${not empty assignment.maxScore ? assignment.maxScore : 0} pts
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${groupsSize > 0}">
                                                    <span class="badge bg-primary">
                                                        ${groupsSize} ${groupsSize == 1 ? 'group' : 'groups'}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">No groups</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge bg-secondary">${submissionsSize}</span>
                                            <c:if test="${submissionsSize > 0}">
                                                <br>
                                                <small class="text-success">
                                                        ${assignment.gradedSubmissionCount} graded
                                                </small>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${assignment.isOverdue()}">
                                                    <span class="badge bg-danger">
                                                        <i class="bi bi-exclamation-triangle"></i> Overdue
                                                    </span>
                                                </c:when>
                                                <c:when test="${assignment.isActive()}">
                                                    <span class="badge bg-success">
                                                        <i class="bi bi-check-circle"></i> Active
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">
                                                        <i class="bi bi-question-circle"></i> No deadline
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <div class="btn-group btn-group-sm" role="group">
                                                <a href="${pageContext.request.contextPath}/admin/assignment/view?assignmentId=${assignment.id}"
                                                   class="btn btn-outline-primary"
                                                   title="View Details">
                                                    <i class="bi bi-eye"></i>
                                                </a>
                                                <button type="button"
                                                        class="btn btn-outline-danger"
                                                        onclick="deleteAssignment('${assignment.id}', '${fn:escapeXml(assignment.title)}')"
                                                        title="Delete">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </div>
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

        <!-- Statistics Summary -->
        <c:if test="${not empty assignments}">
            <div class="card mt-4">
                <div class="card-body">
                    <h6 class="mb-4">
                        <i class="bi bi-graph-up text-info"></i> Statistics Summary
                    </h6>
                    <div class="row">
                        <div class="col-md-3 col-sm-6 mb-3 mb-md-0">
                            <div class="stat-item">
                                <i class="bi bi-journal-text text-primary"></i>
                                <h4>${fn:length(assignments)}</h4>
                                <p>Total Assignments</p>
                            </div>
                        </div>
                        <div class="col-md-3 col-sm-6 mb-3 mb-md-0">
                            <div class="stat-item">
                                <i class="bi bi-check-circle text-success"></i>
                                <c:set var="activeCount" value="0"/>
                                <c:forEach var="a" items="${assignments}">
                                    <c:if test="${a.isActive()}">
                                        <c:set var="activeCount" value="${activeCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                <h4>${activeCount}</h4>
                                <p>Active</p>
                            </div>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <div class="stat-item">
                                <i class="bi bi-exclamation-triangle text-danger"></i>
                                <c:set var="overdueCount" value="0"/>
                                <c:forEach var="a" items="${assignments}">
                                    <c:if test="${a.isOverdue()}">
                                        <c:set var="overdueCount" value="${overdueCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                <h4>${overdueCount}</h4>
                                <p>Overdue</p>
                            </div>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <div class="stat-item">
                                <i class="bi bi-file-earmark-check text-info"></i>
                                <c:set var="totalSubmissions" value="0"/>
                                <c:forEach var="a" items="${assignments}">
                                    <c:set var="totalSubmissions" value="${totalSubmissions + fn:length(a.submissions)}"/>
                                </c:forEach>
                                <h4>${totalSubmissions}</h4>
                                <p>Total Submissions</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>
    </div>

    <!-- Delete Confirmation Form (hidden) -->
    <form id="deleteAssignmentForm" method="post"
          action="${pageContext.request.contextPath}/admin/assignments/delete"
          style="display: none;">
        <input type="hidden" name="assignmentId" id="deleteAssignmentId">
    </form>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Sidebar Toggle Functionality
        const sidebarToggle = document.getElementById('sidebarToggle');
        const sidebar = document.getElementById('sidebar');
        const body = document.body;

        // Load saved state
        const sidebarState = localStorage.getItem('sidebarCollapsed');
        if (sidebarState === 'true') {
            sidebar.classList.add('collapsed');
            body.classList.add('sidebar-collapsed');
        }

        sidebarToggle.addEventListener('click', function() {
            sidebar.classList.toggle('collapsed');
            body.classList.toggle('sidebar-collapsed');

            // Save state
            const isCollapsed = sidebar.classList.contains('collapsed');
            localStorage.setItem('sidebarCollapsed', isCollapsed);
        });

        // Mobile sidebar toggle
        if (window.innerWidth <= 992) {
            sidebarToggle.addEventListener('click', function() {
                sidebar.classList.toggle('show');
            });

            // Close sidebar when clicking outside on mobile
            document.addEventListener('click', function(event) {
                if (window.innerWidth <= 992) {
                    if (!sidebar.contains(event.target) && !sidebarToggle.contains(event.target)) {
                        sidebar.classList.remove('show');
                    }
                }
            });
        }

        // Delete Assignment Function
        function deleteAssignment(assignmentId, assignmentTitle) {
            const message = 'Are you sure you want to delete "' + assignmentTitle + '"?\n\n' +
                'This will also delete all associated submissions. This action cannot be undone.';

            if (confirm(message)) {
                document.getElementById('deleteAssignmentId').value = assignmentId;
                document.getElementById('deleteAssignmentForm').submit();
            }
        }
    </script>
</body>
</html>