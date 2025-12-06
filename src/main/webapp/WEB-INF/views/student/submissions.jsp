<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Submissions - LMS</title>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@700&family=Playfair+Display:wght@400;600&family=Roboto:wght@300;400&display=swap" rel="stylesheet">
    <style>
        :root {
            --gold: #D4AF37;
            --bg-dark: #0a0a0a;
            --bg-card: #1a1a1a;
        }

        .topbar {
            background: var(--bg-card);
            padding: 15px 0;
            border-bottom: 1px solid #333;
            margin-bottom: 30px;
        }

        .topbar .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .d-flex {
            display: flex;
        }

        .justify-content-between {
            justify-content: space-between;
        }

        .align-items-center {
            align-items: center;
        }

        .user-menu {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .logout-btn {
            color: var(--gold);
            text-decoration: none;
            padding: 8px 16px;
            border: 1px solid var(--gold);
            border-radius: 4px;
            transition: all 0.3s ease;
        }

        .logout-btn:hover {
            background: var(--gold);
            color: #000;
        }
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            color: #333;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        .header {
            background: #2c3e50;
            color: white;
            padding: 30px;
            border-radius: 8px;
            margin-bottom: 30px;
        }

        .header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
        }

        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #3498db;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #7f8c8d;
            font-size: 14px;
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }

        .alert-success {
            background: #d4edda;
            border-left: 4px solid #28a745;
            color: #155724;
        }

        .submissions-grid {
            display: grid;
            gap: 20px;
        }

        .submission-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
            transition: transform 0.2s ease;
        }

        .submission-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        .submission-header {
            padding: 20px;
            border-bottom: 1px solid #ecf0f1;
        }

        .submission-title {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 5px;
        }

        .submission-meta {
            display: flex;
            gap: 15px;
            font-size: 13px;
            color: #7f8c8d;
        }

        .submission-body {
            padding: 20px;
        }

        .submission-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 15px;
        }

        .info-item {
            display: flex;
            flex-direction: column;
        }

        .info-label {
            font-size: 12px;
            color: #7f8c8d;
            margin-bottom: 3px;
        }

        .info-value {
            font-size: 14px;
            font-weight: 600;
            color: #2c3e50;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        .status-submitted {
            background: #d1ecf1;
            color: #0c5460;
        }

        .status-graded {
            background: #d4edda;
            color: #155724;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
        }

        .score-display {
            font-size: 20px;
            font-weight: bold;
            color: #27ae60;
        }

        .feedback {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 4px;
            margin-top: 10px;
        }

        .feedback-label {
            font-weight: 600;
            margin-bottom: 8px;
            color: #2c3e50;
        }

        .feedback-text {
            color: #495057;
            line-height: 1.6;
        }

        .file-link {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            color: #3498db;
            text-decoration: none;
            font-size: 14px;
        }

        .file-link:hover {
            text-decoration: underline;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .empty-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }

        .empty-title {
            font-size: 24px;
            color: #2c3e50;
            margin-bottom: 10px;
        }

        .empty-text {
            color: #7f8c8d;
            margin-bottom: 20px;
        }

        .btn {
            display: inline-block;
            padding: 10px 20px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-weight: 600;
            transition: background 0.3s ease;
        }

        .btn:hover {
            background: #2980b9;
        }
    </style>
</head>
<body>
<header class="topbar">
    <div class="container d-flex justify-content-between align-items-center">
        <div>
            <a href="${pageContext.request.contextPath}/student/dashboard" style="text-decoration: none;">
                    <span style="font-family: 'Cinzel', serif; font-size: 1.8rem; color: var(--gold);">
                        EDUCORE
                    </span>
            </a>
        </div>
        <div class="user-menu">
            <a href="${pageContext.request.contextPath}/student/dashboard" style="margin-right: 20px; color: #aaa; text-decoration: none;">
                Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                Logout
            </a>
        </div>
    </div>
</header>

<div class="container">
    <div class="header">
        <h1>My Submissions</h1>
        <p>Track all your assignment submissions and grades</p>
    </div>

    <c:if test="${param.success == 'true'}">
        <div class="alert alert-success">
            ✓ Assignment submitted successfully!
        </div>
    </c:if>

    <div class="stats">
        <div class="stat-card">
            <div class="stat-number">${submissions.size()}</div>
            <div class="stat-label">Total Submissions</div>
        </div>
        <div class="stat-card">
            <%-- Count graded submissions --%>
            <c:set var="gradedCount" value="0"/>
            <c:forEach var="s" items="${submissions}">
                <c:if test="${s.status.name() == 'GRADED'}">
                    <c:set var="gradedCount" value="${gradedCount + 1}"/>
                </c:if>
            </c:forEach>
            <div class="stat-number">${gradedCount}</div>
            <div class="stat-label">Graded</div>
        </div>
        <div class="stat-card">
            <%-- Calculate average score --%>
            <c:set var="totalScore" value="0"/>
            <c:set var="scoreCount" value="0"/>
            <c:forEach var="s" items="${submissions}">
                <c:if test="${s.score != null}">
                    <c:set var="totalScore" value="${totalScore + s.score}"/>
                    <c:set var="scoreCount" value="${scoreCount + 1}"/>
                </c:if>
            </c:forEach>
            <div class="stat-number">
                <c:choose>
                    <c:when test="${scoreCount > 0}">
                        <fmt:formatNumber value="${totalScore / scoreCount}" maxFractionDigits="1"/>
                    </c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </div>
            <div class="stat-label">Average Score</div>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty submissions}">
            <div class="empty-state">
                <div class="empty-icon">📝</div>
                <div class="empty-title">No Submissions Yet</div>
                <div class="empty-text">You haven't submitted any assignments yet.</div>
                <a href="${pageContext.request.contextPath}/student/assignments" class="btn">View Assignments</a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="submissions-grid">
                <c:forEach var="submission" items="${submissions}">
                    <div class="submission-card">
                        <div class="submission-header">
                            <div class="submission-title">${submission.assignment.title}</div>
                            <div class="submission-meta">
                                <span>📅 Submitted: ${submission.submittedDate}</span>
                                <c:if test="${submission.reviewedAt != null}">
                                    <span>✓ Reviewed: ${submission.reviewedDate}</span>
                                </c:if>
                            </div>
                        </div>

                        <div class="submission-body">
                            <div class="submission-info">
                                <div class="info-item">
                                    <span class="info-label">Status</span>
                                    <span class="info-value">
                                            <span class="status-badge status-${submission.status.name().toLowerCase()}">${submission.status}</span>
                                        </span>
                                </div>

                                <c:if test="${submission.score != null}">
                                    <div class="info-item">
                                        <span class="info-label">Score</span>
                                        <span class="info-value score-display">
                                                ${submission.score} / ${submission.assignment.maxScore}
                                            </span>
                                    </div>
                                </c:if>

                                <c:if test="${submission.reviewer != null}">
                                    <div class="info-item">
                                        <span class="info-label">Reviewed By</span>
                                        <span class="info-value">${submission.reviewer.fullName}</span>
                                    </div>
                                </c:if>
                            </div>

                            <c:if test="${submission.comment != null && !submission.comment.isEmpty()}">
                                <div class="info-item">
                                    <span class="info-label">Your Comment</span>
                                    <span class="info-value">${submission.comment}</span>
                                </div>
                            </c:if>

                            <c:if test="${submission.filePath != null}">
                                <div class="info-item" style="margin-top: 10px;">
                                    <span class="info-label">Attached File</span>
                                    <!-- Скачать файл отправки -->
                                    <a href="${pageContext.request.contextPath}/files/download?id=${submission.id}&type=submission"
                                       class="file-link" target="_blank">
                                        Скачать ${submission.fileName}
                                    </a>
                                </div>
                            </c:if>

                            <c:if test="${submission.status.name() == 'GRADED'}">
                                <div class="feedback">
                                    <div class="feedback-label">Teacher Feedback</div>
                                    <div class="feedback-text">
                                            ${submission.reviewerComment != null ? submission.reviewerComment : 'No feedback provided'}
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>