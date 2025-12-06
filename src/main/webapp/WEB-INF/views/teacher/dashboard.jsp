<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Teacher Dashboard • EDUCORE</title>

    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@700&family=Playfair+Display:wght@600&family=Roboto:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <style><%@include file="/css/teacher/dashboard.css"%></style>
</head>
<body>
    <div class="topbar">
        <a href="${pageContext.request.contextPath}/teacher/dashboard" class="logo">EDUCORE</a>
        <div class="user-menu">
            <span><i class="bi bi-person-circle"></i> ${teacher.fullName}</span>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Logout</a>
        </div>
    </div>

    <div class="container">

        <header>
            <h1>WELCOME BACK, PROFESSOR</h1>
            <p>${teacher.fullName} • ${teacher.specialization}</p>
        </header>

        <!-- STAT CARDS -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="num">${studentsCount}</div>
                <div class="label">TOTAL STUDENTS</div>
            </div>
            <div class="stat-card">
                <div class="num">${groups.size()}</div>
                <div class="label">MY GROUPS</div>
            </div>
            <div class="stat-card">
                <div class="num">${totalAssignments}</div>
                <div class="label">ASSIGNMENTS CREATED</div>
            </div>
            <div class="stat-card">
                <div class="num">${pendingCount}</div>
                <div class="label">PENDING TO CHECK</div>
            </div>
        </div>

        <!-- MY GROUPS -->
        <div class="luxury-groups">
            <div class="section-header">
                <i class="bi bi-people-fill"></i> MY GROUPS
            </div>

            <div class="section-body">
                <c:choose>
                    <c:when test="${empty groups}">
                        <div class="empty-state">
                            <i class="bi bi-journal-plus" style="font-size:4rem; color:#444;"></i>
                            <h3 style="color:#999;">No groups created yet</h3>
                            <p style="color:#666;">
                                Begin your teaching legacy by creating the first elite group.
                            </p>
                            <a href="${pageContext.request.contextPath}/teacher/groups/create" class="btn-luxury">
                                Create First Group
                            </a>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="groups-table-wrapper">
                            <table class="luxury-table">
                                <thead>
                                <tr>
                                    <th>Group Name</th>
                                    <th>Students</th>
                                    <th>Assignments</th>
                                    <th style="text-align:center;">Actions</th>
                                </tr>
                                </thead>

                                <tbody>
                                <c:forEach var="g" items="${groups}">
                                    <tr class="group-row">
                                        <td>
                                            <div class="group-name-gold">${g.name}</div>
                                            <small style="color:#888;">
                                                <c:if test="${not empty g.description}">
                                                    ${fn:escapeXml(g.description.length() > 60 ?
                                                        g.description.substring(0,60).concat("...") : g.description)}
                                                </c:if>
                                            </small>
                                        </td>

                                        <td>
                                            <span class="stat-number">${g.students.size()}</span>
                                            <small>students</small>
                                        </td>

                                        <td>
                                            <span class="stat-number">${g.assignments.size()}</span>
                                            <small>tasks</small>
                                        </td>

                                        <td class="actions-cell">
                                            <a href="${pageContext.request.contextPath}/teacher/groups/view?groupId=${g.id}"
                                               class="action-btn view"><i class="bi bi-eye"></i></a>

                                            <a href="${pageContext.request.contextPath}/teacher/groups/edit?groupId=${g.id}"
                                               class="action-btn edit"><i class="bi bi-pencil-square"></i></a>

                                            <button type="button" class="action-btn delete"
                                                    onclick="showDeleteModal('${g.id}', '${fn:escapeXml(g.name)}')">
                                                <i class="bi bi-trash3"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <div style="text-align:center; margin-top:40px;">
                            <a href="${pageContext.request.contextPath}/teacher/groups/create" class="btn-luxury">
                                Create New Group
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- RECENT ASSIGNMENTS -->
        <div class="section">
            <div class="section-header">RECENT ASSIGNMENTS</div>
            <div class="section-body">

                <c:choose>
                    <c:when test="${empty formattedAssignments}">
                        <p style="color:#777; text-align:center; font-style:italic; padding:40px;">
                            No assignments created yet.
                            <a href="${pageContext.request.contextPath}/teacher/assignments/create"
                               style="color:var(--gold); text-decoration:underline;">
                                Create your first one →
                            </a>
                        </p>
                    </c:when>

                    <c:otherwise>
                        <table class="table">
                            <thead>
                            <tr>
                                <th>Title</th>
                                <th>Due Date</th>
                                <th>Groups</th>
                                <th>Submissions</th>
                                <th>Actions</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="a" items="${formattedAssignments}">
                                <tr>
                                    <td>${a.title}</td>
                                    <td>${a.dueDateFormatted}</td>
                                    <td>
                                        <c:forEach var="g" items="${a.groups}" varStatus="status">
                                            ${g.name}<c:if test="${!status.last}">, </c:if>
                                        </c:forEach>
                                    </td>
                                    <td>
                                        <!-- ✅ ПРАВИЛЬНО: используем submissionCounts из servlet -->
                                        <a href="${pageContext.request.contextPath}/teacher/submissions?assignmentId=${a.id}"
                                           class="btn" style="padding:8px 16px;">
                                            Check (${submissionCounts[a.id]})
                                        </a>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/teacher/assignments/edit?id=${a.id}">
                                            Edit
                                        </a>
                                        <a href="${pageContext.request.contextPath}/teacher/assignments/delete?id=${a.id}"
                                           onclick="return confirm('Delete this assignment?')">
                                            Delete
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                        <div style="text-align:right; margin-top:20px;">
                            <a href="${pageContext.request.contextPath}/teacher/assignments" style="color:var(--gold);">
                                View all assignments →
                            </a>
                        </div>

                    </c:otherwise>
                </c:choose>

            </div>
        </div>
    </div>

    <!-- DELETE MODAL (unchanged) -->
    <div id="deleteModal" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2>CONFIRM DELETION</h2>
                <span class="modal-close" onclick="closeDeleteModal()">×</span>
            </div>

            <div class="modal-body">
                <i class="bi bi-exclamation-triangle-fill warning-icon"></i>
                <h3>Permanently delete group</h3>

                <p id="groupNameDisplay"
                   style="font-size:1.4rem; color:var(--gold); margin:20px 0; font-weight:bold;"></p>

                <p style="color:#ccc; line-height:1.7;">
                    This action cannot be undone.
                </p>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-premium btn-secondary" onclick="closeDeleteModal()">
                    Cancel
                </button>

                <form id="deleteForm"
                      action="${pageContext.request.contextPath}/teacher/groups/delete"
                      method="post">
                    <input type="hidden" name="groupId" id="deleteGroupId">
                    <button type="submit" class="btn-premium btn-danger">
                        Yes, Delete Forever
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
    function showDeleteModal(id, name) {
        document.getElementById('deleteModal').style.display = 'flex';
        document.getElementById('groupNameDisplay').textContent = '«' + name + '»';
        document.getElementById('deleteGroupId').value = id;
    }

    function closeDeleteModal() {
        document.getElementById('deleteModal').style.display = 'none';
    }
</script>

</body>
</html>
