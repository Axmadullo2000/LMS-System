<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>Submissions • ${assignment.title}</title>
    <style><%@include file="/css/teacher/submissions.css"%></style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>${assignment.title}</h1>
            <p>Max Score: ${assignment.maxScore}</p>

                <c:if test="${assignment.hasFile()}">
                    <div style="margin-top: 10px; padding: 10px; background: #333; border-radius: 5px;">
                        <strong>📎 Attached File:</strong> ${assignment.fileName}

                        <a href="${pageContext.request.contextPath}/files/download?type=assignment&id=${assignment.id}"
                           class="btn btn-sm btn-success" target="_blank">
                            Скачать ${submission.fileName}
                        </a>
                    </div>
                </c:if>
        </div>

        <c:choose>
            <c:when test="${empty submissions}">
                <div class="no-data">No submissions yet</div>
            </c:when>
            <c:otherwise>
                <table>
                    <tr>
                        <th>Student</th>
                        <th>Submitted At</th>
                        <th>Score</th>
                        <th>Actions</th>
                    </tr>
                    <c:forEach var="sub" items="${submissions}">
                        <tr>
                            <td>${sub.student.fullName}</td>
                            <td>${sub.submittedAt}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${sub.score != null}">
                                        ${sub.score}
                                    </c:when>
                                    <c:otherwise>Not graded</c:otherwise>
                                </c:choose>
                            </td>
                            <td>

                                <a href="${pageContext.request.contextPath}/teacher/submissions/grade?submissionId=${sub.id}"
                                   class="btn">Grade</a>
                            </td>
                        </tr>
                    </c:forEach>
                </table>
            </c:otherwise>
        </c:choose>

        <p style="margin-top: 20px;">
            <a href="${pageContext.request.contextPath}/teacher/assignments" class="btn">← Back</a>
        </p>
    </div>
</body>
</html>
