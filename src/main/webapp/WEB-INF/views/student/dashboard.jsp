<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@700&family=Playfair+Display:wght@400;600&family=Roboto:wght@300;400&display=swap" rel="stylesheet">
    <style><%@include file="/css/student/dashboard.css"%></style>
</head>
<body>
    <header class="topbar">
        <div class="container d-flex justify-content-between align-items-center">
            <div>
                    <span style="font-family: 'Cinzel', serif; font-size: 1.8rem; color: var(--gold);">
                        EDUCORE
                    </span>
            </div>
            <nav class="main-nav">
                <a href="${pageContext.request.contextPath}/student/dashboard" class="nav-link active">Dashboard</a>
                <a href="${pageContext.request.contextPath}/student/assignments" class="nav-link">Assignments</a>
                <a href="${pageContext.request.contextPath}/student/submissions" class="nav-link">My Submissions</a>
                <a href="${pageContext.request.contextPath}/student/groups" class="nav-link">Groups</a>
            </nav>
            <div class="user-menu">
                    <span style="margin-right: 20px; color: #aaa;">
                        <i class="bi bi-person-circle"></i> ${student.fullName}
                    </span>
                <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </a>
            </div>
        </div>
    </header>

    <div class="container">

        <header>
            <h1>WELCOME BACK</h1>
            <p>${student.fullName} • Student email: ${student.email}</p>
        </header>

        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="num">${totalSubmissions}</div>
                <div class="label">SUBMITTED WORKS</div>
            </div>
            <div class="stat-card">
                <div class="num">${pendingCount}</div>
                <div class="label">PENDING REVIEW</div>
            </div>
            <div class="stat-card">
                <div class="num">${groupsCount}</div>
                <div class="label">MY GROUPS</div>
            </div>
            <div class="stat-card">
                <div class="num">${assignments.size()}</div>
                <div class="label">ACTIVE ASSIGNMENTS</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="section">
            <div class="section-header">QUICK ACTIONS</div>
            <div class="section-body">
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px;">
                    <a href="${pageContext.request.contextPath}/student/assignments" class="action-card">
                        <div style="font-size: 32px; margin-bottom: 10px;">📚</div>
                        <div style="font-weight: 600; margin-bottom: 5px;">View Assignments</div>
                        <div style="font-size: 13px; color: #999;">Browse all available assignments</div>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/submissions" class="action-card">
                        <div style="font-size: 32px; margin-bottom: 10px;">📝</div>
                        <div style="font-weight: 600; margin-bottom: 5px;">My Submissions</div>
                        <div style="font-size: 13px; color: #999;">Check your submitted work</div>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/groups" class="action-card">
                        <div style="font-size: 32px; margin-bottom: 10px;">👥</div>
                        <div style="font-weight: 600; margin-bottom: 5px;">My Groups</div>
                        <div style="font-size: 13px; color: #999;">View and manage your groups</div>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/profile" class="action-card">
                        <div style="font-size: 32px; margin-bottom: 10px;">⚙️</div>
                        <div style="font-weight: 600; margin-bottom: 5px;">Profile Settings</div>
                        <div style="font-size: 13px; color: #999;">Update your information</div>
                    </a>
                </div>
            </div>
        </div>

        <!-- My Groups -->
        <div class="section">
            <div class="section-header">
                <span>MY GROUPS</span>
                <a href="${pageContext.request.contextPath}/student/groups" style="font-size: 14px; color: var(--gold); text-decoration: none;">View All →</a>
            </div>
            <div class="section-body">
                <c:choose>
                    <c:when test="${empty groups}">
                        <div class="no-data">You are not a member of any group yet.</div>
                    </c:when>
                    <c:otherwise>
                        <ul>
                            <c:forEach var="g" items="${groups}" begin="0" end="4">
                                <li><strong>${g.name}</strong> — ${g.studentsCount} members</li>
                            </c:forEach>
                            <c:if test="${groups.size() > 5}">
                                <li style="color: var(--gold);">
                                    <a href="${pageContext.request.contextPath}/student/groups" style="color: var(--gold); text-decoration: none;">
                                        And ${groups.size() - 5} more groups...
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Active Assignments -->
        <div class="section">
            <div class="section-header">
                <span>ACTIVE ASSIGNMENTS</span>
                <a href="${pageContext.request.contextPath}/student/assignments" style="font-size: 14px; color: var(--gold); text-decoration: none;">View All →</a>
            </div>
            <div class="section-body">
                <c:choose>
                    <c:when test="${empty assignments}">
                        <div class="no-data">No active assignments at the moment.</div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <tr>
                                <th>Title</th>
                                <th>Due Date</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                            <c:forEach var="a" items="${assignments}" begin="0" end="4">
                                <%-- Find student's submission for this assignment --%>
                                <c:set var="mySubmission" value="${null}"/>
                                <c:forEach var="s" items="${submissions}">
                                    <c:if test="${s.assignment.id == a.id}">
                                        <c:set var="mySubmission" value="${s}"/>
                                    </c:if>
                                </c:forEach>

                                <tr>
                                    <td>
                                        <strong>${a.title}</strong>
                                    </td>
                                    <td>
                                        ${a.formattedDueDate}
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${mySubmission == null}">
                                                <span class="badge pending">NOT SUBMITTED</span>
                                            </c:when>
                                            <c:when test="${mySubmission.status.name() == 'PENDING' || mySubmission.status.name() == 'SUBMITTED'}">
                                                <span class="badge pending">PENDING REVIEW</span>
                                            </c:when>
                                            <c:when test="${mySubmission.status.name() == 'GRADED'}">
                                                <span class="badge submitted">GRADED: ${mySubmission.score}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge submitted">SUBMITTED</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/student/submit?assignmentId=${a.id}"
                                           style="color: var(--gold); text-decoration: none; font-weight: 600;">
                                                ${mySubmission == null ? 'Submit →' : 'Resubmit →'}
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </table>
                        <c:if test="${assignments.size() > 5}">
                            <div style="text-align: center; margin-top: 15px;">
                                <a href="${pageContext.request.contextPath}/student/assignments"
                                   style="color: var(--gold); text-decoration: none; font-weight: 600;">
                                    View all ${assignments.size()} assignments →
                                </a>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Recent Submissions -->
        <div class="section">
            <div class="section-header">
                <span>RECENT SUBMISSIONS</span>
                <a href="${pageContext.request.contextPath}/student/submissions" style="font-size: 14px; color: var(--gold); text-decoration: none;">View All →</a>
            </div>
            <div class="section-body">
                <c:choose>
                    <c:when test="${empty submissions}">
                        <div class="no-data">No submissions yet.</div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <tr>
                                <th>Assignment</th>
                                <th>Submitted</th>
                                <th>Status</th>
                                <th>Score</th>
                            </tr>
                            <c:forEach var="s" items="${submissions}" begin="0" end="4">
                                <tr>
                                    <td><strong>${s.assignment.title}</strong></td>
                                    <td>${s.submittedDate}</td>
                                    <td>
                                        <span class="badge ${s.status.name() == 'GRADED' ? 'submitted' : 'pending'}">
                                                ${s.status}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${s.score != null}">
                                                <strong style="color: var(--gold);">${s.score} / ${s.assignment.maxScore}</strong>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #666;">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</body>
</html>