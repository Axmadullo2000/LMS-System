<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Submit Assignment - LMS</title>
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

        .main-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
        }

        .header {
            background: #2c3e50;
            color: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
        }

        .header h1 {
            font-size: 24px;
            margin-bottom: 10px;
        }

        .back-link {
            display: inline-block;
            color: #3498db;
            text-decoration: none;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        .assignment-info {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .assignment-info h2 {
            color: #2c3e50;
            margin-bottom: 15px;
            font-size: 20px;
        }

        .info-row {
            display: flex;
            margin-bottom: 10px;
            padding: 8px 0;
            border-bottom: 1px solid #ecf0f1;
        }

        .info-label {
            font-weight: 600;
            width: 150px;
            color: #7f8c8d;
        }

        .info-value {
            flex: 1;
            color: #2c3e50;
        }

        .overdue {
            color: #e74c3c;
            font-weight: bold;
        }

        .previous-submission {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }

        .previous-submission h3 {
            color: #856404;
            margin-bottom: 10px;
            font-size: 16px;
        }

        .submit-form {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #2c3e50;
        }

        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-family: inherit;
            font-size: 14px;
            resize: vertical;
            min-height: 120px;
        }

        .form-group input[type="file"] {
            width: 100%;
            padding: 10px;
            border: 2px dashed #ddd;
            border-radius: 4px;
            cursor: pointer;
        }

        .form-group input[type="file"]:hover {
            border-color: #3498db;
        }

        .file-info {
            margin-top: 8px;
            font-size: 13px;
            color: #7f8c8d;
        }

        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 30px;
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: #3498db;
            color: white;
        }

        .btn-primary:hover {
            background: #2980b9;
        }

        .btn-secondary {
            background: #95a5a6;
            color: white;
        }

        .btn-secondary:hover {
            background: #7f8c8d;
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }

        .alert-warning {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            color: #856404;
        }

        .alert-info {
            background: #d1ecf1;
            border-left: 4px solid #17a2b8;
            color: #0c5460;
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

<div class="main-container">
    <a href="${pageContext.request.contextPath}/student/dashboard" class="back-link">← Back to Dashboard</a>

    <div class="header">
        <h1>Submit Assignment</h1>
    </div>

    <%-- Create date object for overdue check ONCE --%>
    <jsp:useBean id="currentDate" class="java.util.Date"/>
    <c:set var="isOverdue" value="${assignment.dueDate.before(currentDate)}" />

    <div class="assignment-info">
        <h2>${assignment.title}</h2>
        <div class="info-row">
            <span class="info-label">Description:</span>
            <span class="info-value">${assignment.description}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Due Date:</span>
            <span class="info-value ${isOverdue ? 'overdue' : ''}">
                    <fmt:formatDate value="${assignment.dueDate}" pattern="dd MMM yyyy HH:mm"/>
                    <c:if test="${isOverdue}"> (OVERDUE)</c:if>
                </span>
        </div>
        <div class="info-row">
            <span class="info-label">Max Score:</span>
            <span class="info-value">${assignment.maxScore} points</span>
        </div>
    </div>

    <c:if test="${isOverdue}">
        <div class="alert alert-warning">
            ⚠️ This assignment is overdue. Late submissions may receive reduced credit.
        </div>
    </c:if>

    <c:if test="${latestSubmission != null}">
        <div class="previous-submission">
            <h3>📋 Previous Submission</h3>
            <div class="info-row">
                <span class="info-label">Submitted:</span>
                <span class="info-value">
                        <fmt:formatDate value="${latestSubmission.submittedAt}" pattern="dd MMM yyyy HH:mm"/>
                    </span>
            </div>
            <div class="info-row">
                <span class="info-label">Status:</span>
                <span class="info-value">${latestSubmission.status}</span>
            </div>
            <c:if test="${latestSubmission.score != null}">
                <div class="info-row">
                    <span class="info-label">Score:</span>
                    <span class="info-value">${latestSubmission.score} / ${assignment.maxScore}</span>
                </div>
            </c:if>
            <c:if test="${not empty latestSubmission.comment}">
                <div class="info-row">
                    <span class="info-label">Your Comment:</span>
                    <span class="info-value">${latestSubmission.comment}</span>
                </div>
            </c:if>
        </div>
    </c:if>

    <div class="submit-form">
        <form action="${pageContext.request.contextPath}/student/submit" method="post" enctype="multipart/form-data">
            <input type="hidden" name="assignmentId" value="${assignment.id}"/>

            <div class="form-group">
                <label for="content">Comments / Notes:</label>
                <textarea id="content" name="content" placeholder="Add any comments or notes about your submission...">${latestSubmission != null ? latestSubmission.comment : ''}</textarea>
            </div>

            <div class="form-group">
                <label for="file">Upload File:</label>
                <input type="file" id="file" name="file" accept=".pdf,.doc,.docx,.txt,.zip,.rar"/>
                <div class="file-info">Accepted formats: PDF, DOC, DOCX, TXT, ZIP, RAR (Max 10MB)</div>
                <c:if test="${latestSubmission != null && latestSubmission.filePath != null}">
                    <div class="file-info">
                        Previous file: <a href="${latestSubmission.filePath}" target="_blank">${latestSubmission.fileName}</a>
                    </div>
                </c:if>
            </div>

            <div class="button-group">
                <button type="submit" class="btn btn-primary">
                    ${latestSubmission != null ? 'Resubmit Assignment' : 'Submit Assignment'}
                </button>
                <a href="${pageContext.request.contextPath}/student/assignments" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>