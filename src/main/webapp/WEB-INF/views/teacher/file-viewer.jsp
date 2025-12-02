<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View File • ${assignment.fileName}</title>
    <style><%@include file="/css/teacher/file-viewer.css"%></style>
</head>
<body>
<div class="topbar">
    <h1>📄 ${assignment.fileName}</h1>

    <div style="display: flex; gap: 15px;">
        <a href="${pageContext.request.contextPath}/teacher/assignments/download?assignmentId=${assignment.id}"
           class="btn">
            ⬇️ Download
        </a>
        <a href="${pageContext.request.contextPath}/teacher/submissions?assignmentId=${assignment.id}"
           class="btn btn-back">
            ← Back
        </a>
    </div>
</div>

<div class="container">
    <div class="file-info">
        <p><strong>Assignment:</strong> ${assignment.title}</p>
        <p><strong>File Name:</strong> ${assignment.fileName}</p>
        <p><strong>File Size:</strong> ${assignment.fileSize} bytes</p>
    </div>

    <div class="file-content">
        <c:choose>
            <%-- Текстовый файл --%>
            <c:when test="${fileType == 'text'}">
                <div class="text-content">${fileContent}</div>
            </c:when>

            <%-- PDF файл --%>
            <c:when test="${fileType == 'pdf'}">
                <div class="pdf-container">
                    <object
                            data="${pageContext.request.contextPath}/teacher/assignments/view-pdf?assignmentId=${assignment.id}#toolbar=1&navpanes=1&scrollbar=1&view=FitH"
                            type="application/pdf"
                            width="100%"
                            height="800px"
                            style="border: 1px solid #ddd; border-radius: 8px;">

                        <embed
                                src="${pageContext.request.contextPath}/teacher/assignments/view-pdf?assignmentId=${assignment.id}#toolbar=1"
                                type="application/pdf"
                                width="100%"
                                height="800px"
                                style="border: 1px solid #ddd; border-radius: 8px;" />

                        <!-- Fallback если браузер не поддерживает встроенный просмотр -->
                        <div class="no-preview">
                            <i style="font-size: 64px;">📄</i>
                            <h2>PDF Preview Not Available</h2>
                            <p>Your browser doesn't support inline PDF viewing.</p>
                            <div class="actions" style="margin-top: 20px;">
                                <a href="${pageContext.request.contextPath}/teacher/assignments/view-pdf?assignmentId=${assignment.id}"
                                   target="_blank"
                                   class="btn"
                                   style="margin-right: 10px;">
                                    🔍 Open in New Tab
                                </a>
                                <a href="${pageContext.request.contextPath}/teacher/assignments/download?assignmentId=${assignment.id}"
                                   class="btn">
                                    ⬇️ Download PDF
                                </a>
                            </div>
                        </div>
                    </object>

                    <!-- Дополнительная кнопка для удобства -->
                    <div style="margin-top: 15px; text-align: center;">
                        <a href="${pageContext.request.contextPath}/teacher/assignments/view-pdf?assignmentId=${assignment.id}"
                           target="_blank"
                           class="btn"
                           style="margin-right: 10px;">
                            🔍 Open in New Tab
                        </a>
                        <span style="color: #666; font-size: 14px;">
                                (recommended if preview doesn't work)
                            </span>
                    </div>
                </div>
            </c:when>

            <%-- Другие типы файлов --%>
            <c:otherwise>
                <div class="no-preview">
                    <i>📦</i>
                    <h2>Preview not available</h2>
                    <p>${fileContent}</p>
                    <div class="actions">
                        <a href="${pageContext.request.contextPath}/teacher/assignments/download?assignmentId=${assignment.id}"
                           class="btn">
                            Download File
                        </a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</body>
</html>