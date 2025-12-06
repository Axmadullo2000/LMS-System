<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <title>${assignment.title} - Assignment Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body>
    <jsp:include page="admin-layout.jsp">
        <jsp:param name="title" value="${assignment.title}"/>
        <jsp:param name="active" value="assignments"/>
    </jsp:include>

    <div class="container-fluid">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/admin/assignments">Assignments</a>
                </li>
                <li class="breadcrumb-item active">${assignment.title}</li>
            </ol>
        </nav>

        <!-- Assignment Header -->
        <div class="card mb-4">
            <div class="card-body">
                <div class="row">
                    <div class="col-md-8">
                        <h3 class="mb-2">
                            <i class="bi bi-journal-text text-warning"></i>
                            ${assignment.title}
                        </h3>
                        <div class="mb-3">
                            <c:choose>
                                <c:when test="${assignment.isOverdue()}">
                                        <span class="badge bg-danger fs-6">
                                            <i class="bi bi-exclamation-triangle"></i> Overdue
                                        </span>
                                </c:when>
                                <c:when test="${assignment.isActive()}">
                                        <span class="badge bg-success fs-6">
                                            <i class="bi bi-check-circle"></i> Active
                                        </span>
                                </c:when>
                            </c:choose>
                        </div>
                        <div class="text-muted">
                            <i class="bi bi-person"></i> Created by:
                            <strong>${assignment.creator.fullName}</strong>
                            <c:if test="${not empty assignment.creator.specialization}">
                                (${assignment.creator.specialization})
                            </c:if>
                        </div>
                        <div class="text-muted mt-2">
                            <i class="bi bi-calendar"></i>
                            Created: <fmt:formatDate value="${assignment.createdAt}" pattern="MMM dd, yyyy HH:mm" />
                            <span class="mx-2">|</span>
                            <i class="bi bi-clock"></i>
                            Updated: <fmt:formatDate value="${assignment.updatedAt}" pattern="MMM dd, yyyy HH:mm" />
                        </div>
                    </div>
                    <div class="col-md-4 text-end">
                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/assignments/delete"
                              onsubmit="return confirm('Are you sure you want to delete this assignment? This will also delete all submissions.');">
                            <input type="hidden" name="assignmentId" value="${assignment.id}">
                            <button type="submit" class="btn btn-danger">
                                <i class="bi bi-trash"></i> Delete Assignment
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Assignment Details -->
            <div class="col-lg-8 mb-4">
                <!-- Description Card -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-file-text text-primary"></i>
                            Assignment Details
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="text-muted small">Assignment ID</label>
                                <p><code>${assignment.id}</code></p>
                            </div>
                            <div class="col-md-6">
                                <label class="text-muted small">Max Score</label>
                                <p>
                                        <span class="badge bg-info fs-6">
                                            ${assignment.maxScore != null ? assignment.maxScore : 0} points
                                        </span>
                                </p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="text-muted small">Due Date</label>
                                <p>
                                    <c:choose>
                                        <c:when test="${not empty assignment.dueDate}">
                                            <i class="bi bi-calendar-event"></i>
                                            <fmt:formatDate value="${assignment.dueDate}" pattern="MMMM dd, yyyy 'at' HH:mm" />
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">No due date set</span>
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                            <div class="col-md-6">
                                <label class="text-muted small">Attached File</label>
                                <p>
                                    <c:choose>
                                        <c:when test="${assignment.hasFile()}">
                                            <i class="bi bi-paperclip text-info"></i>
                                            ${assignment.fileName}
                                            <br>
                                            <small class="text-muted">
                                                Size: ${assignment.fileSize / 1024} KB
                                            </small>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">No file attached</span>
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="text-muted small">Description</label>
                            <c:choose>
                                <c:when test="${not empty assignment.description}">
                                    <div class="border rounded p-3 bg-light">
                                            ${assignment.description}
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-muted">No description provided</p>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <label class="text-muted small">Reviewers</label>
                                <c:choose>
                                    <c:when test="${not empty assignment.reviewers}">
                                        <div class="d-flex flex-wrap gap-2">
                                            <c:forEach var="reviewer" items="${assignment.reviewers}">
                                                <span class="badge bg-success">${reviewer.fullName}</span>
                                            </c:forEach>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="text-muted mb-0">No additional reviewers</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Groups Card -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-diagram-3 text-primary"></i>
                            Assigned Groups
                            <span class="badge bg-primary rounded-pill">${assignment.groups.size()}</span>
                        </h5>
                    </div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty assignment.groups}">
                                <p class="text-muted mb-0">Not assigned to any groups</p>
                            </c:when>
                            <c:otherwise>
                                <div class="row g-3">
                                    <c:forEach var="group" items="${assignment.groups}">
                                        <div class="col-md-6">
                                            <div class="border rounded p-3">
                                                <h6 class="mb-2">
                                                    <i class="bi bi-diagram-3-fill text-primary"></i>
                                                        ${group.name}
                                                </h6>
                                                <div class="d-flex justify-content-between small text-muted">
                                                        <span>
                                                            <i class="bi bi-people"></i> ${group.students.size()} students
                                                        </span>
                                                    <span>
                                                            <i class="bi bi-person-workspace"></i> ${group.teachers.size()} teachers
                                                        </span>
                                                </div>
                                                <a href="${pageContext.request.contextPath}/admin/group/view?groupId=${group.id}"
                                                   class="btn btn-sm btn-outline-primary mt-2 w-100">
                                                    View Group <i class="bi bi-arrow-right"></i>
                                                </a>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Submissions List -->
                <div class="card">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-file-earmark-check text-success"></i>
                            Submissions
                            <span class="badge bg-secondary rounded-pill">${assignment.submissions.size()}</span>
                        </h5>
                    </div>
                    <div class="card-body p-0">
                        <c:choose>
                            <c:when test="${empty assignment.submissions}">
                                <div class="text-center py-5">
                                    <i class="bi bi-inbox fs-1 text-muted"></i>
                                    <p class="text-muted mt-3 mb-0">No submissions yet</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="table-light">
                                        <tr>
                                            <th>Student</th>
                                            <th>Submitted At</th>
                                            <th>Status</th>
                                            <th>Score</th>
                                            <th>Reviewer</th>
                                            <th>File</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="submission" items="${assignment.submissions}">
                                            <tr>
                                                <td>
                                                    <div class="d-flex align-items-center">
                                                        <div class="bg-primary bg-gradient text-white rounded-circle d-flex align-items-center justify-content-center me-2"
                                                             style="width: 30px; height: 30px; font-size: 0.8rem;">
                                                            <strong>${submission.student.fullName.substring(0,1).toUpperCase()}</strong>
                                                        </div>
                                                        <small>${submission.student.fullName}</small>
                                                    </div>
                                                </td>
                                                <td>
                                                    <small>
                                                        <fmt:formatDate value="${submission.submittedAt}"
                                                                        pattern="MMM dd, yyyy HH:mm" />
                                                    </small>
                                                </td>
                                                <td>
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
                                                        <c:when test="${submission.status == 'DRAFT'}">
                                                            <span class="badge bg-secondary">Draft</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-info">${submission.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty submission.score}">
                                                            <strong class="text-success">
                                                                    ${submission.score}/${assignment.maxScore}
                                                            </strong>
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
                                                    <c:if test="${not empty submission.fileName}">
                                                        <i class="bi bi-paperclip text-info"></i>
                                                        <small>${submission.fileName}</small>
                                                    </c:if>
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

            <!-- Statistics Sidebar -->
            <div class="col-lg-4">
                <!-- Quick Stats -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h6 class="mb-0">
                            <i class="bi bi-graph-up text-info"></i>
                            Quick Statistics
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="mb-3 pb-3 border-bottom">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted">Total Submissions</span>
                                <span class="badge bg-primary fs-6">${assignment.submissions.size()}</span>
                            </div>
                        </div>

                        <div class="mb-3 pb-3 border-bottom">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted">Graded</span>
                                <span class="badge bg-success fs-6">${assignment.gradedSubmissionCount}</span>
                            </div>
                        </div>

                        <div class="mb-3 pb-3 border-bottom">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted">Pending Review</span>
                                <span class="badge bg-warning text-dark fs-6">
                                    ${assignment.submissions.size() - assignment.gradedSubmissionCount}
                                </span>
                            </div>
                        </div>

                        <div class="mb-3 pb-3 border-bottom">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted">Assigned Groups</span>
                                <span class="badge bg-info fs-6">${assignment.groups.size()}</span>
                            </div>
                        </div>

                        <div>
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted">Total Students</span>
                                <span class="badge bg-secondary fs-6">
                                        <c:set var="totalStudents" value="0"/>
                                        <c:forEach var="group" items="${assignment.groups}">
                                            <c:set var="totalStudents" value="${totalStudents + group.students.size()}"/>
                                        </c:forEach>
                                        ${totalStudents}
                                    </span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Submission Progress -->
                <c:if test="${not empty assignment.submissions}">
                    <div class="card">
                        <div class="card-header bg-white">
                            <h6 class="mb-0">
                                <i class="bi bi-pie-chart text-warning"></i>
                                Grading Progress
                            </h6>
                        </div>
                        <div class="card-body">
                            <c:set var="gradingProgress"
                                   value="${assignment.submissions.size() > 0 ?
                                               (assignment.gradedSubmissionCount * 100 / assignment.submissions.size()) : 0}"/>
                            <div class="mb-2">
                                <div class="d-flex justify-content-between mb-1">
                                    <span class="text-muted small">Progress</span>
                                    <span class="text-muted small">${gradingProgress}%</span>
                                </div>
                                <div class="progress" style="height: 20px;">
                                    <div class="progress-bar bg-success"
                                         role="progressbar"
                                         style="width: ${gradingProgress}%">
                                            ${assignment.gradedSubmissionCount}/${assignment.submissions.size()}
                                    </div>
                                </div>
                            </div>
                            <p class="text-muted small mb-0 mt-3">
                                <c:choose>
                                    <c:when test="${gradingProgress == 100}">
                                        <i class="bi bi-check-circle text-success"></i>
                                        All submissions have been graded!
                                    </c:when>
                                    <c:otherwise>
                                        <i class="bi bi-hourglass-split text-warning"></i>
                                        ${assignment.submissions.size() - assignment.gradedSubmissionCount} submissions pending review
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>