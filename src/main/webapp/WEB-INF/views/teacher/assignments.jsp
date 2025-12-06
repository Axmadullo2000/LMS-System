<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.time.*, java.util.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Assignments • EDUCORE</title>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@700&family=Playfair+Display:wght@600&family=Roboto:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <style><%@include file="/css/teacher/assignments.css"%></style>
</head>
<body>

<div class="topbar">
    <a href="${pageContext.request.contextPath}/teacher/dashboard" class="logo">EDUCORE</a>
    <a href="${pageContext.request.contextPath}/teacher/dashboard" style="color:#aaa; text-decoration:none;">
        Back to Dashboard
    </a>
</div>

<div class="container">

    <div class="page-title">
        <h1>ASSIGNMENTS</h1>
    </div>

    <div style="text-align: center;">
        <a href="${pageContext.request.contextPath}/teacher/assignments/create" class="btn-create">
            + Create New Assignment
        </a>
    </div>

    <c:if test="${param.success != null}">
        <div class="success">Assignment successfully created!</div>
    </c:if>

    <c:choose>
        <c:when test="${empty assignments}">
            <div class="no-assignments">
                No assignments created yet.<br><br>
                Click the button above to create your first assignment.
            </div>
        </c:when>

        <c:otherwise>
            <div class="assignments-grid">

                <c:forEach var="assignment" items="${assignments}">

                    <%-- Конвертация даты внутри цикла --%>
                    <%
                        LocalDateTime dt = ((com.lms.system.model.Assignment) pageContext.getAttribute("assignment")).getDueDate();
                        Date dueDate = (dt == null) ? null : Date.from(dt.atZone(ZoneId.systemDefault()).toInstant());
                        pageContext.setAttribute("dueDateConverted", dueDate);

                        boolean active = (dt != null && dt.isAfter(LocalDateTime.now()));
                        pageContext.setAttribute("isActive", active);
                    %>

                    <div class="assignment-card">

                        <h3 class="assignment-title">${assignment.title}</h3>

                        <div class="assignment-meta">
                            <span>Max Score:
                                <strong>${assignment.maxScore}</strong>
                            </span>

                            <span>
                                Due:
                                <c:choose>
                                    <c:when test="${dueDateConverted != null}">
                                        <fmt:formatDate value="${dueDateConverted}" pattern="dd MMM yyyy, HH:mm" />
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:#999;">No due date</span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <c:choose>
                            <c:when test="${isActive}">
                                <div class="status status-active">ACTIVE</div>
                            </c:when>
                            <c:otherwise>
                                <div class="status status-past">PAST DUE</div>
                            </c:otherwise>
                        </c:choose>

                        <div class="groups-list">
                            Assigned to:
                            <c:forEach var="group" items="${assignment.groups}">
                                <span>${group.name}</span>
                            </c:forEach>
                        </div>

                        <c:if test="${not empty assignment.fileName}">
                            <div style="margin: 15px 0; color:#aaa;">
                                Attached: <strong>${assignment.fileName}</strong>
                            </div>
                        </c:if>

                        <div class="actions">
                            <a href="${pageContext.request.contextPath}/teacher/submissions?assignmentId=${assignment.id}" class="btn-sm btn-view">
                                View Submissions
                            </a>

                            <button class="btn-sm btn-delete"
                                    type="button"
                                    onclick="showDeleteModal('${assignment.id}', '${assignment.title}')">
                                Delete
                            </button>
                        </div>

                    </div>

                </c:forEach>

            </div>
        </c:otherwise>
    </c:choose>

</div>

<!-- DELETE ASSIGNMENT MODAL -->
<div id="deleteModal" class="modal-overlay" style="display:none;">
    <div class="modal-content">
        <div class="modal-header">
            <h2>CONFIRM DELETION</h2>
            <span class="modal-close" onclick="closeDeleteModal()">×</span>
        </div>

        <div class="modal-body">
            <i class="bi bi-exclamation-triangle-fill warning-icon"></i>
            <h3>Permanently delete assignment</h3>

            <p id="assignmentNameDisplay"
               style="font-size:1.4rem; color:var(--gold); margin:20px 0; font-weight:bold;">
            </p>

            <p style="color:#ccc; line-height:1.7;">
                This action cannot be undone.
            </p>
        </div>

        <div class="modal-footer">

            <button type="button" class="btn-premium btn-secondary" onclick="closeDeleteModal()">
                Cancel
            </button>

            <form id="deleteForm"
                  action="${pageContext.request.contextPath}/teacher/assignments/delete"
                  method="post">
                <input type="hidden" name="assignmentId" id="deleteAssignmentId">
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
        document.getElementById('assignmentNameDisplay').textContent = '«' + name + '»';
        document.getElementById('deleteAssignmentId').value = id;
    }

    function closeDeleteModal() {
        document.getElementById('deleteModal').style.display = 'none';
    }
</script>

</body>
</html>
