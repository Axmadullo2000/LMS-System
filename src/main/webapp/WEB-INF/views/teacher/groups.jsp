<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Groups • EDUCORE</title>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@700&family=Playfair+Display:wght@600&family=Roboto:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/teacher/groups.css">
    <style><%@include file="/css/teacher/groups.css"%></style>
</head>
<body>

    <div class="topbar">
        <a href="${pageContext.request.contextPath}/teacher/dashboard" class="logo">EDUCORE</a>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Logout</a>
    </div>

    <div class="actions-sidebar">
        <a href="${pageContext.request.contextPath}/teacher/dashboard" class="btn-premium btn-secondary-sm">
            Back to Dashboard
        </a>

        <a href="${pageContext.request.contextPath}/teacher/groups/create" class="btn-premium btn-create-sm">
            Create Group
        </a>
    </div>

    <div class="container">
        <div class="page-header">
            <h1>MY GROUPS</h1>
            <p>Command your academic realms</p>
        </div>

        <c:choose>
            <c:when test="${empty groups}">
                <div class="empty-state" onclick="window.location.href='${pageContext.request.contextPath}/teacher/groups/create'">
                    <i class="bi bi-journal-plus empty-icon"></i>
                    <h2>No groups created yet</h2>
                    <p>Your empire awaits its first cohort</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="groups-grid">
                    <c:forEach var="group" items="${groups}">
                        <div class="group-card">
                            <div class="group-header">${group.name}</div>
                            <div class="group-body">
                                <div class="group-desc">
                                    <c:choose>
                                        <c:when test="${not empty group.description}">${group.description}</c:when>
                                        <c:otherwise><em>No description provided.</em></c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="group-stats">
                                    <div class="stat">
                                        <div class="num">${group.students.size()}</div>
                                        <div class="label">Students</div>
                                    </div>
                                    <div class="stat">
                                        <div class="num">${group.assignments.size()}</div>
                                        <div class="label">Assignments</div>
                                    </div>
                                </div>

                                <div class="group-actions">
                                    <a href="${pageContext.request.contextPath}/teacher/groups/view?groupId=${group.id}"
                                       class="btn-premium btn-view">Open</a>

                                    <a href="${pageContext.request.contextPath}/teacher/groups/edit?groupId=${group.id}"
                                       class="btn-premium btn-edit">Edit</a>

                                    <form action="${pageContext.request.contextPath}/teacher/groups/delete" method="post"
                                          class="delete-form" style="display:inline;">
                                        <input type="hidden" name="groupId" value="${group.id}">
                                        <button type="button" class="btn-premium btn-delete"
                                                onclick="showDeleteModal('${group.id}', '${group.name}')">
                                            Delete
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

    </div>
    <!-- PREMIUM DELETE CONFIRMATION MODAL -->
    <div id="deleteModal" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2>CONFIRM DELETION</h2>
                <span class="modal-close" onclick="closeDeleteModal()">×</span>
            </div>
            <div class="modal-body">
                <i class="bi bi-exclamation-triangle-fill warning-icon"></i>
                <h3>Permanently delete group</h3>
                <p id="groupNameDisplay" style="font-size:1.4rem; color:var(--gold); margin:20px 0; font-weight:bold;"></p>
                <p style="color:#ccc; line-height:1.7;">
                    This action <strong>cannot be undone</strong>. All students will be removed from the group,<br>
                    and all assignments associated with this cohort will be deleted.
                </p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-premium btn-secondary" onclick="closeDeleteModal()">
                    Cancel
                </button>
                <form id="actualDeleteForm" action="${pageContext.request.contextPath}/teacher/groups/delete" method="post" style="display:inline;">
                    <input type="hidden" name="groupId" id="deleteGroupId">
                    <button type="submit" class="btn-premium btn-danger">
                        Yes, Delete Forever
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
        function showDeleteModal(groupId, groupName) {
            document.getElementById('deleteModal').style.display = 'flex';
            document.getElementById('groupNameDisplay').textContent = '«' + groupName + '»';
            document.getElementById('deleteGroupId').value = groupId;
        }

        function closeDeleteModal() {
            document.getElementById('deleteModal').style.display = 'none';
        }

        // Закрытие по клику на фон
        document.getElementById('deleteModal').addEventListener('click', function(e) {
            if (e.target === this) closeDeleteModal();
        });
    </script>
</body>
</html>