<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
    <title>Grade Submission</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .container { max-width: 650px; margin: auto; }
        .card { padding: 20px; border: 1px solid #ccc; border-radius: 6px; }
        label { font-weight: bold; margin-top: 15px; display: block; }
        input, textarea { width: 100%; padding: 8px; margin-top: 5px; box-sizing: border-box; }
        button {
            margin-top: 20px; padding: 10px 20px;
            background: #4CAF50; color: white; border: none; border-radius: 4px;
            cursor: pointer;
        }
        button:hover { background: #45a049; }
        a { color: #0056d6; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .info-section { margin-bottom: 20px; padding: 15px; background: #f5f5f5; border-radius: 4px; }
        .error { color: red; padding: 10px; background: #fee; border-radius: 4px; margin-bottom: 15px; }
        .already-graded { padding: 10px; background: #e7f3ff; border-left: 3px solid #2196F3; margin-bottom: 15px; }
    </style>
</head>
<body>

<div class="container">

    <h2>Grade Submission</h2>

    <c:if test="${not empty error}">
        <div class="error">
            ⚠️ ${error}
        </div>
    </c:if>

    <div class="card">

        <div class="info-section">
            <p><b>Student:</b> ${submission.student.fullName}</p>
            <p><b>Assignment:</b> ${submission.assignment.title}</p>
            <p><b>Max Score:</b> ${submission.assignment.maxScore}</p>
            <p><b>Submitted:</b> ${submission.submittedDate}</p>
            <p><b>Status:</b>
                <span style="color: ${submission.status == 'GRADED' ? 'green' : 'orange'};">
                    ${submission.status}
                </span>
            </p>

            <!-- Показываем если уже оценено -->
            <c:if test="${submission.status == 'GRADED'}">
                <div class="already-graded">
                    <b>Previously Graded:</b><br>
                    Score: ${submission.score} / ${submission.assignment.maxScore}<br>
                    <c:if test="${not empty submission.reviewerComment}">
                        Feedback: ${submission.reviewerComment}
                    </c:if>
                    <c:if test="${not empty submission.reviewedDate}">
                        <br>Graded on: ${submission.reviewedDate}
                    </c:if>
                </div>
            </c:if>
        </div>

        <!-- Файл студента -->
        <c:if test="${not empty submission.filePath}">
            <div style="margin-bottom: 15px;">
                <b>Submitted File:</b><br>
                <a href="${pageContext.request.contextPath}/files/download?type=submission&id=${submission.id}"
                   class="file-link" target="_blank">
                    Скачать ${submission.fileName}
                </a>
            </div>
        </c:if>

        <!-- Комментарий студента -->
        <c:if test="${not empty submission.comment}">
            <div style="margin-bottom: 15px;">
                <b>Student's Comment:</b>
                <div style="padding: 10px; background: #f9f9f9; border-left: 3px solid #2196F3; margin-top: 5px;">
                        ${submission.comment}
                </div>
            </div>
        </c:if>

        <!-- Форма оценки -->
        <form action="${pageContext.request.contextPath}/teacher/submissions/grade" method="post" onsubmit="return validateForm()">

            <input type="hidden" name="submissionId" value="${submission.id}"/>

            <label for="grade">Score * (Max: ${submission.assignment.maxScore})</label>
            <input type="number"
                   id="grade"
                   name="grade"
                   min="0"
                   max="${submission.assignment.maxScore}"
                   value="${submission.score != null ? submission.score : ''}"
                   placeholder="Enter score (0-${submission.assignment.maxScore})"
                   required>

            <label for="feedback">Teacher Feedback</label>
            <textarea id="feedback"
                      name="feedback"
                      rows="5"
                      placeholder="Write feedback for the student...">${submission.reviewerComment != null ? submission.reviewerComment : ''}</textarea>

            <button type="submit">
                ${submission.status == 'GRADED' ? 'Update Grade' : 'Submit Grade'}
            </button>
        </form>

        <p style="margin-top: 20px;">
            <a href="${pageContext.request.contextPath}/teacher/submissions?assignmentId=${submission.assignment.id}">
                ← Back to submissions
            </a>
        </p>

    </div>

</div>

<script>
    function validateForm() {
        const grade = document.getElementById('grade').value;
        const maxScore = ${submission.assignment.maxScore};

        if (grade === '' || grade < 0 || grade > maxScore) {
            alert('Please enter a valid score between 0 and ' + maxScore);
            return false;
        }

        return true;
    }
</script>

</body>
</html>