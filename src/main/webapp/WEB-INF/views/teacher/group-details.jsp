<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${group.name} • EDUCORE</title>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@700&family=Playfair+Display:wght@600&family=Roboto:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <style><%@include file="/css/teacher/group-details.css"%></style>
</head>
<body>
<div class="topbar">
    <a href="${pageContext.request.contextPath}/teacher/dashboard" class="logo">EDUCORE</a>
    <a href="${pageContext.request.contextPath}/teacher/groups" class="back">
        Back to Groups
    </a>
</div>

<div class="container">

    <div class="page-header">
        <h1>${group.name}</h1>
        <p>Educore Academy</p>
    </div>

    <div class="group-info">
        <div class="desc">
            ${not empty group.description ? group.description : 'No description provided.'}
        </div>

        <div class="group-stats">
            <div class="stat-big">
                <div class="num">${studentSize}</div>
                <div class="label">ENROLLED STUDENTS</div>
            </div>
            <div class="stat-big">
                <div class="num">${assignments}</div>
                <div class="label">ACTIVE ASSIGNMENTS</div>
            </div>
        </div>

        <div style="margin-top: 40px; display: flex; gap: 20px; flex-wrap: wrap;">
            <a href="${pageContext.request.contextPath}/teacher/groups/edit?groupId=${group.id}" class="btn-luxury">
                Edit Group
            </a>
            <a href="${pageContext.request.contextPath}/teacher/assignments/create" class="btn-luxury">
                + New Assignment
            </a>
        </div>
    </div>

    <!-- === ФОРМА ДОБАВЛЕНИЯ СТУДЕНТА === -->
    <div class="section">
        <div class="section-header">
            Add Student to Group
        </div>
        <div class="section-body">
            <form action="${pageContext.request.contextPath}/teacher/groups/add-student" method="post" style="display:flex; gap:15px; margin-bottom:30px;">
                <input type="hidden" name="groupId" value="${group.id}">
                <input type="text" name="studentId" placeholder="Enter student email or ID" required
                       style="flex:1; min-width:300px; padding:16px; background:rgba(15,15,15,0.9); border:1px solid rgba(212,175,55,0.3); border-radius:12px; color:white; font-size:1.1rem;">
                <button type="submit" class="btn-luxury" style="padding:16px 32px;">
                    Add Student
                </button>
            </form>

            <c:if test="${param.success != null}">
                <div style="background:rgba(0,200,0,0.15); color:#0f0; padding:15px; border-radius:12px; text-align:center; border:1px solid rgba(0,255,0,0.3);">
                    Student successfully added!
                </div>
            </c:if>
        </div>
    </div>

    <!-- === СПИСОК СТУДЕНТОВ === -->
    <div class="section">
        <div class="section-header">
            Students in Group (${studentsByGroup.size()})
        </div>
        <div class="section-body">
            <c:choose>
                <c:when test="${empty studentsByGroup}">
                    <div class="no-data">
                        No students enrolled yet.<br><br>
                        Add students using the form above.
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                        <tr>
                            <th>#</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Joined</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="s" items="${studentsByGroup}" varStatus="status">
                            <tr>
                                <td>${status.index + 1}</td>
                                <td><strong>${s.fullName}</strong></td>
                                <td>${s.email}</td>
                                <td>${s.formattedCreatedAt}</td>  <!-- ИСПРАВЛЕНО: было student → стало s -->
                                <td>
                                    <form action="${pageContext.request.contextPath}/teacher/groups/remove-student" method="post" style="display: inline;">
                                        <input type="hidden" name="groupId" value="${group.id}">
                                        <input type="hidden" name="studentId" value="${s.id}">
                                        <button type="submit" class="remove-btn" title="Remove from group"
                                                onclick="return confirm('Remove ${s.fullName} from this group?')">
                                            Remove
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
</body>
</html>