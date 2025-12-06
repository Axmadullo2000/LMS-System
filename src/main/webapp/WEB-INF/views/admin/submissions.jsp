<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <title>Submissions - Admin Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style><%@include file="/css/admin/submissions.css"%></style>
</head>
<body>
    <!-- Sidebar Toggle Button -->
    <button class="sidebar-toggle" id="sidebarToggle">
        <i class="bi bi-list"></i>
    </button>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand"><i class="bi bi-mortarboard-fill"></i> LMS Groups</div>
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
                    <a href="${pageContext.request.contextPath}/admin/assignments" class="nav-link">
                        <i class="bi bi-journal-text"></i>
                        <span>Assignments</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/submissions" class="nav-link active">
                        <i class="bi bi-file-earmark-check"></i>
                        <span>Submissions</span>
                    </a>
                </li>
            </ul>
        </nav>
    </aside>

    <div class="container-fluid">
            <!-- Statistics Cards -->
            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <i class="bi bi-file-earmark-check fs-1 text-primary"></i>
                            <h3 class="mt-2">${submissions.size()}</h3>
                            <p class="text-muted mb-0">Total Submissions</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <i class="bi bi-check-circle fs-1 text-success"></i>
                            <h3 class="mt-2">
                                <c:set var="gradedCount" value="0"/>
                                <c:forEach var="sub" items="${submissions}">
                                    <c:if test="${sub.status == 'GRADED'}">
                                        <c:set var="gradedCount" value="${gradedCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${gradedCount}
                            </h3>
                            <p class="text-muted mb-0">Graded</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <i class="bi bi-hourglass-split fs-1 text-warning"></i>
                            <h3 class="mt-2">
                                <c:set var="pendingCount" value="0"/>
                                <c:forEach var="sub" items="${submissions}">
                                    <c:if test="${sub.status != 'GRADED' && sub.status != 'DRAFT'}">
                                        <c:set var="pendingCount" value="${pendingCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${pendingCount}
                            </h3>
                            <p class="text-muted mb-0">Pending Review</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <i class="bi bi-exclamation-triangle fs-1 text-danger"></i>
                            <h3 class="mt-2">
                                <c:set var="lateCount" value="0"/>
                                <c:forEach var="sub" items="${submissions}">
                                    <c:if test="${sub.status == 'LATE'}">
                                        <c:set var="lateCount" value="${lateCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${lateCount}
                            </h3>
                            <p class="text-muted mb-0">Late Submissions</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Submissions Table -->
            <div class="card">
                <div class="card-header bg-white">
                    <h5 class="mb-0">
                        <i class="bi bi-file-earmark-check text-success"></i>
                        All Submissions
                        <span class="badge bg-secondary rounded-pill">${submissions.size()}</span>
                    </h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${empty submissions}">
                            <div class="text-center py-5">
                                <i class="bi bi-inbox fs-1 text-muted"></i>
                                <p class="text-muted mt-3 mb-0">No submissions found in the system</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                    <tr>
                                        <th style="width: 5%">#</th>
                                        <th style="width: 15%">Student</th>
                                        <th style="width: 20%">Assignment</th>
                                        <th style="width: 12%">Submitted At</th>
                                        <th style="width: 10%">Status</th>
                                        <th style="width: 8%">Score</th>
                                        <th style="width: 12%">Reviewer</th>
                                        <th style="width: 10%">Reviewed At</th>
                                        <th style="width: 8%" class="text-center">Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="submission" items="${submissions}" varStatus="status">
                                        <tr>
                                            <td>${status.index + 1}</td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="bg-primary bg-gradient text-white rounded-circle d-flex align-items-center justify-content-center me-2"
                                                         style="width: 30px; height: 30px; font-size: 0.8rem;">
                                                        <strong>${submission.student.fullName.substring(0,1).toUpperCase()}</strong>
                                                    </div>
                                                    <div>
                                                        <small class="fw-bold">${submission.student.fullName}</small>
                                                        <br>
                                                        <small class="text-muted">${submission.student.email}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <strong>${submission.assignment.title}</strong>
                                                <br>
                                                <small class="text-muted">
                                                    by ${submission.assignment.creator.fullName}
                                                </small>
                                            </td>
                                            <td>
                                                <small>
                                                    <fmt:formatDate value="${submission.submittedAt}"
                                                                    pattern="MMM dd, yyyy" />
                                                    <br>
                                                    <fmt:formatDate value="${submission.submittedAt}"
                                                                    pattern="HH:mm" />
                                                </small>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${submission.status == 'GRADED'}">
                                                                <span class="badge bg-success">
                                                                    <i class="bi bi-check-circle"></i> Graded
                                                                </span>
                                                    </c:when>
                                                    <c:when test="${submission.status == 'SUBMITTED'}">
                                                                <span class="badge bg-primary">
                                                                    <i class="bi bi-send"></i> Submitted
                                                                </span>
                                                    </c:when>
                                                    <c:when test="${submission.status == 'UNDER_VIEW'}">
                                                                <span class="badge bg-warning text-dark">
                                                                    <i class="bi bi-eye"></i> Under Review
                                                                </span>
                                                    </c:when>
                                                    <c:when test="${submission.status == 'LATE'}">
                                                                <span class="badge bg-danger">
                                                                    <i class="bi bi-exclamation-triangle"></i> Late
                                                                </span>
                                                    </c:when>
                                                    <c:when test="${submission.status == 'DRAFT'}">
                                                                <span class="badge bg-secondary">
                                                                    <i class="bi bi-file-earmark"></i> Draft
                                                                </span>
                                                    </c:when>
                                                    <c:when test="${submission.status == 'PENDING'}">
                                                                <span class="badge bg-info">
                                                                    <i class="bi bi-hourglass"></i> Pending
                                                                </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">${submission.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty submission.score}">
                                                        <strong class="text-success">
                                                                ${submission.score}
                                                        </strong>
                                                        <c:if test="${not empty submission.assignment.maxScore}">
                                                            <span class="text-muted">/${submission.assignment.maxScore}</span>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty submission.reviewer}">
                                                        <small>${submission.reviewer.fullName}</small>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty submission.reviewedAt}">
                                                        <small>
                                                            <fmt:formatDate value="${submission.reviewedAt}"
                                                                            pattern="MMM dd, yyyy" />
                                                        </small>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <div class="btn-group btn-group-sm" role="group">
                                                    <button type="button"
                                                            class="btn btn-outline-primary"
                                                            data-bs-toggle="modal"
                                                            data-bs-target="#submissionModal${submission.id}"
                                                            title="View Details">
                                                        <i class="bi bi-eye"></i>
                                                    </button>
                                                    <button type="button"
                                                            class="btn btn-outline-danger"
                                                            onclick="deleteSubmission('${submission.id}')"
                                                            title="Delete">
                                                        <i class="bi bi-trash"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>

                                        <!-- Submission Details Modal -->
                                        <div class="modal fade" id="submissionModal${submission.id}" tabindex="-1">
                                            <div class="modal-dialog modal-lg">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">
                                                            <i class="bi bi-file-earmark-check text-success"></i>
                                                            Submission Details
                                                        </h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="row">
                                                            <div class="col-md-6 mb-3">
                                                                <label class="text-muted small">Student</label>
                                                                <p class="fw-bold">${submission.student.fullName}</p>
                                                                <small class="text-muted">${submission.student.email}</small>
                                                            </div>
                                                            <div class="col-md-6 mb-3">
                                                                <label class="text-muted small">Assignment</label>
                                                                <p class="fw-bold">${submission.assignment.title}</p>
                                                            </div>
                                                            <div class="col-md-6 mb-3">
                                                                <label class="text-muted small">Submission ID</label>
                                                                <p><code>${submission.id}</code></p>
                                                            </div>
                                                            <div class="col-md-6 mb-3">
                                                                <label class="text-muted small">Status</label>
                                                                <p>
                                                                    <c:choose>
                                                                        <c:when test="${submission.status == 'GRADED'}">
                                                                            <span class="badge bg-success">Graded</span>
                                                                        </c:when>
                                                                        <c:when test="${submission.status == 'SUBMITTED'}">
                                                                            <span class="badge bg-primary">Submitted</span>
                                                                        </c:when>
                                                                        <c:when test="${submission.status == 'UNDER_VIEW'}">
                                                                            <span class="badge bg-warning text-dark">Under Review</span>
                                                                        </c:when>
                                                                        <c:when test="${submission.status == 'LATE'}">
                                                                            <span class="badge bg-danger">Late</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="badge bg-secondary">${submission.status}</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </p>
                                                            </div>
                                                            <div class="col-md-6 mb-3">
                                                                <label class="text-muted small">Submitted At</label>
                                                                <p>
                                                                    <fmt:formatDate value="${submission.submittedAt}"
                                                                                    pattern="MMMM dd, yyyy 'at' HH:mm" />
                                                                </p>
                                                            </div>
                                                            <div class="col-md-6 mb-3">
                                                                <label class="text-muted small">Score</label>
                                                                <p>
                                                                    <c:choose>
                                                                        <c:when test="${not empty submission.score}">
                                                                            <strong class="text-success fs-5">
                                                                                    ${submission.score}/${submission.assignment.maxScore}
                                                                            </strong>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="text-muted">Not graded yet</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </p>
                                                            </div>
                                                            <c:if test="${not empty submission.reviewer}">
                                                                <div class="col-md-6 mb-3">
                                                                    <label class="text-muted small">Reviewer</label>
                                                                    <p class="fw-bold">${submission.reviewer.fullName}</p>
                                                                </div>
                                                                <div class="col-md-6 mb-3">
                                                                    <label class="text-muted small">Reviewed At</label>
                                                                    <p>
                                                                        <c:choose>
                                                                            <c:when test="${not empty submission.reviewedAt}">
                                                                                <fmt:formatDate value="${submission.reviewedAt}"
                                                                                                pattern="MMM dd, yyyy HH:mm" />
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="text-muted">-</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </p>
                                                                </div>
                                                            </c:if>
                                                            <c:if test="${not empty submission.fileName}">
                                                                <div class="col-12 mb-3">
                                                                    <label class="text-muted small">Attached File</label>
                                                                    <p>
                                                                        <i class="bi bi-paperclip text-info"></i>
                                                                            ${submission.fileName}
                                                                    </p>
                                                                </div>
                                                            </c:if>
                                                            <c:if test="${not empty submission.comment}">
                                                                <div class="col-12">
                                                                    <label class="text-muted small">Comment</label>
                                                                    <div class="border rounded p-3 bg-light">
                                                                            ${submission.comment}
                                                                    </div>
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

    <!-- Delete Confirmation Form (hidden) -->
    <form id="deleteSubmissionForm" method="post" action="${pageContext.request.contextPath}/admin/submissions/delete" style="display: none;">
        <input type="hidden" name="submissionId" id="deleteSubmissionId">
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function deleteSubmission(submissionId) {
            if (confirm('Are you sure you want to delete this submission? This action cannot be undone.')) {
                document.getElementById('deleteSubmissionId').value = submissionId;
                document.getElementById('deleteSubmissionForm').submit();
            }
        }
    </script>
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