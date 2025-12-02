package com.lms.system.servlet;

import com.lms.system.enums.UserRole;
import com.lms.system.model.Assignment;
import com.lms.system.model.Submission;
import com.lms.system.model.User;
import com.lms.system.repository.AdminRepository;
import com.lms.system.repository.AssignmentRepository;
import com.lms.system.repository.StudentRepository;
import com.lms.system.repository.TeacherRepository;
import com.lms.system.service.SubmissionService;
import com.lms.system.service.teacher.TeacherService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;


@WebServlet("/files/download")
public class FileDownloadServlet extends HttpServlet {
    private SubmissionService submissionService;
    private TeacherService teacherService;
    private AdminRepository adminRepository;
    private TeacherRepository teacherRepository;
    private AssignmentRepository assignmentRepository;
    private Path uploadRoot;

    @Override
    public void init() throws ServletException {
        System.out.println("=== Initializing FileDownloadServlet ===");

        submissionService = (SubmissionService) getServletContext().getAttribute("submissionService");
        teacherService = (TeacherService) getServletContext().getAttribute("teacherService");
        adminRepository = (AdminRepository) getServletContext().getAttribute("adminRepository");
        teacherRepository = (TeacherRepository) getServletContext().getAttribute("teacherRepository");
        assignmentRepository = (AssignmentRepository) getServletContext().getAttribute("assignmentRepository");

        if (submissionService == null) {
            throw new ServletException("SubmissionService не найден в контексте приложения!");
        }

        if (teacherService == null) {
            throw new ServletException("TeacherService не найден в контексте приложения!");
        }

        if (adminRepository == null) {
            throw new ServletException("AdminRepository не найден в контексте приложения!");
        }

        if (teacherRepository == null) {
            throw new ServletException("TeacherRepository не найден в контексте приложения!");
        }

        // Определяем корневую папку uploads
        String uploadDir = getServletContext().getRealPath("/uploads");
        System.out.println("getRealPath('/uploads') returned: " + uploadDir);

        if (uploadDir == null || !Files.exists(Paths.get(uploadDir))) {
            uploadDir = System.getProperty("java.io.tmpdir") + "/lms_uploads";
            System.out.println("Using temp directory: " + uploadDir);
        }

        this.uploadRoot = Paths.get(uploadDir).toAbsolutePath().normalize();

        try {
            Files.createDirectories(uploadRoot);
            System.out.println("✓ Upload root initialized: " + uploadRoot);
            System.out.println("✓ Upload root exists: " + Files.exists(uploadRoot));
        } catch (IOException e) {
            throw new ServletException("Не удалось создать папку для загрузок: " + uploadRoot, e);
        }

        System.out.println("✓ FileDownloadServlet initialized successfully");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        System.out.println("\n=== FILE DOWNLOAD REQUEST ===");
        System.out.println("URI: " + req.getRequestURI());
        System.out.println("Query: " + req.getQueryString());

        // 1. Проверка авторизации
        String userId = (String) req.getSession().getAttribute("userId");
        if (userId == null) {
            System.err.println("⚠️ User not authenticated");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        System.out.println("User ID: " + userId);

        // 2. Определяем тип файла
        String type = req.getParameter("type");
        String id = req.getParameter("id");

        System.out.println("TYPE: " + type);
        System.out.println("ID: " + id);

        if (type == null || type.isBlank()) {
            System.err.println("⚠️ Missing file type parameter");
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parameter 'type' is required");
            return;
        }

        if (id == null || id.isBlank()) {
            System.err.println("⚠️ Missing ID parameter");
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parameter 'id' is required");
            return;
        }

        // 3. Маршрутизация по типу файла
        try {
            switch (type.toLowerCase()) {
                case "submission" -> downloadSubmission(req, resp, userId, id);
                case "assignment" -> downloadAssignment(req, resp, userId, id);
                default -> {
                    System.err.println("⚠️ Unknown file type: " + type);
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown file type: " + type);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("⚠️ Download error: " + e.getMessage());
            if (!resp.isCommitted()) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Error downloading file. Please try again later.");
            }
        }
    }

    // ========================================
    // СКАЧИВАНИЕ SUBMISSION
    // ========================================
    private void downloadSubmission(HttpServletRequest req, HttpServletResponse resp,
                                    String userId, String submissionId) throws IOException {

        System.out.println("→ Downloading submission: " + submissionId);

        // 1. Получение submission из БД
        Submission submission = submissionService.getSubmissionById(submissionId);
        if (submission == null) {
            System.err.println("⚠️ Submission not found");
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Submission not found");
            return;
        }

        System.out.println("=== SUBMISSION DEBUG ===");
        System.out.println("Submission ID: " + submission.getId());
        System.out.println("Student ID: " + (submission.getStudent() != null ? submission.getStudent().getId() : "null"));
        System.out.println("File Path: '" + submission.getFilePath() + "'");
        System.out.println("File Name: '" + submission.getFileName() + "'");
        System.out.println("Has file path: " + (submission.getFilePath() != null && !submission.getFilePath().isBlank()));

        // 2. Проверка прав доступа
        if (!hasSubmissionAccess(userId, submission)) {
            System.err.println("⚠️ Access denied to submission");
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // 3. Проверка наличия файла
        String filePathFromDb = submission.getFilePath();
        if (filePathFromDb == null || filePathFromDb.isBlank()) {
            System.err.println("⚠️ No file attached to submission");
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "No file attached to this submission");
            return;
        }

        String fileName = submission.getFileName();
        if (fileName == null || fileName.trim().isEmpty()) {
            fileName = "submission_" + submission.getId() + ".file";
        }

        // 4. Скачивание файла
        downloadFile(resp, filePathFromDb, fileName, "submission");
    }

    // ========================================
    // СКАЧИВАНИЕ ASSIGNMENT
    // ========================================
    private void downloadAssignment(HttpServletRequest req, HttpServletResponse resp,
                                    String userId, String assignmentId) throws IOException {

        System.out.println("→ Downloading assignment file: " + assignmentId);

        // 1. Получение assignment со всеми связями (чтобы избежать LazyInitializationException)
        Assignment assignment = assignmentRepository
                .findByIdWithRelations(assignmentId)
                .orElse(null);

        if (assignment == null) {
            System.err.println("⚠️ Assignment not found");
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Assignment not found");
            return;
        }

        // 2. Проверка прав доступа
        if (!hasAssignmentAccess(userId, assignment)) {
            System.err.println("⚠️ Access denied to assignment");
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // 3. Проверка наличия файла
        if (!assignment.hasFile()) {
            System.err.println("⚠️ No file attached to assignment");
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "No file attached to this assignment");
            return;
        }

        String filePathFromDb = assignment.getFilePath();
        String fileName = assignment.getFileName();

        if (fileName == null || fileName.trim().isEmpty()) {
            fileName = "assignment_" + assignment.getId() + ".file";
        }

        // 4. Скачивание файла
        downloadFile(resp, filePathFromDb, fileName, "assignment");
    }

    // ========================================
    // УНИВЕРСАЛЬНЫЙ МЕТОД СКАЧИВАНИЯ ФАЙЛА
    // ========================================
    private void downloadFile(HttpServletResponse resp, String filePathFromDb,
                              String fileName, String fileType) throws IOException {

        System.out.println("\n=== DOWNLOAD FILE DEBUG ===");
        System.out.println("uploadRoot = " + uploadRoot);
        System.out.println("filePathFromDb = " + filePathFromDb);

        // 1. Нормализация пути
        String relativePath = filePathFromDb;
        if (relativePath.startsWith("uploads/")) {
            relativePath = relativePath.substring("uploads/".length());
        } else if (relativePath.startsWith("/uploads/")) {
            relativePath = relativePath.substring("/uploads/".length());
        }

        // 2. Формирование полного пути
        Path fullPath = uploadRoot.resolve(relativePath).normalize();

        System.out.println("File details:");
        System.out.println("  Path from DB: " + filePathFromDb);
        System.out.println("  Relative path: " + relativePath);
        System.out.println("  Full path: " + fullPath);
        System.out.println("  File name: " + fileName);
        System.out.println("  fullPath.startsWith(uploadRoot): " + fullPath.startsWith(uploadRoot));
        System.out.println("  Files.exists(fullPath): " + Files.exists(fullPath));

        // Проверка родительской директории
        Path parentDir = fullPath.getParent();
        if (parentDir != null) {
            System.out.println("  Parent directory: " + parentDir);
            System.out.println("  Parent exists: " + Files.exists(parentDir));

            if (Files.exists(parentDir)) {
                System.out.println("  Files in parent directory:");
                try {
                    Files.list(parentDir).forEach(p ->
                            System.out.println("    - " + p.getFileName())
                    );
                } catch (IOException e) {
                    System.err.println("  Error listing directory: " + e.getMessage());
                }
            }
        }

        // 3. Защита от path traversal
        if (!fullPath.startsWith(uploadRoot)) {
            System.err.println("⚠️ Security: Path traversal attempt blocked!");
            System.err.println("  Attempted: " + fullPath);
            System.err.println("  Root: " + uploadRoot);
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid file path");
            return;
        }

        // 4. Проверка существования файла
        if (!Files.exists(fullPath)) {
            System.err.println("⚠️ File not found on disk: " + fullPath);
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found on server");
            return;
        }

        if (!Files.isRegularFile(fullPath)) {
            System.err.println("⚠️ Path is not a regular file: " + fullPath);
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Invalid file");
            return;
        }

        if (!Files.isReadable(fullPath)) {
            System.err.println("⚠️ File not readable: " + fullPath);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "File cannot be read");
            return;
        }

        // 5. Определение MIME-типа
        String mimeType = getMimeType(fileName);

        // 6. Установка заголовков
        resp.reset();
        resp.setContentType(mimeType);
        resp.setContentLengthLong(Files.size(fullPath));

        // 7. Content-Disposition для корректной кириллицы
        String encodedName = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
        String latin1Name = new String(fileName.getBytes("UTF-8"), "ISO-8859-1");

        resp.setHeader("Content-Disposition",
                "attachment; filename=\"" + latin1Name + "\"; filename*=UTF-8''" + encodedName);

        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setHeader("Expires", "0");

        // 8. Отправка файла
        System.out.println("→ Sending file...");
        try (InputStream in = Files.newInputStream(fullPath);
             OutputStream out = resp.getOutputStream()) {

            byte[] buffer = new byte[8192];
            int bytesRead;
            long totalBytes = 0;

            while ((bytesRead = in.read(buffer)) != -1) {
                try {
                    out.write(buffer, 0, bytesRead);
                    totalBytes += bytesRead;
                } catch (IOException e) {
                    System.err.println("⚠️ Connection closed by client after " + totalBytes + " bytes");
                    break;
                }
            }

            out.flush();
            System.out.println("✓ File sent successfully:");
            System.out.println("  Type: " + fileType);
            System.out.println("  Name: " + fileName);
            System.out.println("  Size: " + totalBytes + " bytes");

        } catch (IOException e) {
            String msg = e.getMessage();
            if (msg != null && (msg.contains("Broken pipe") ||
                    msg.contains("Connection reset") ||
                    msg.contains("aborted") ||
                    msg.contains("ClientAbortException"))) {
                System.err.println("⚠️ Client aborted download: " + msg);
            } else {
                System.err.println("⚠️ Error sending file: " + e.getMessage());
                throw e;
            }
        }
    }

    // ========================================
    // ПРОВЕРКА ПРАВ ДОСТУПА К ASSIGNMENT
    // ========================================
    private boolean hasAssignmentAccess(String userId, Assignment assignment) {
        // 1. Админ имеет доступ ко всем файлам
        if (isAdmin(userId)) {
            System.out.println("✓ Admin access granted");
            return true;
        }

        // 2. Преподаватель - создатель задания
        if (assignment.getCreator() != null &&
                assignment.getCreator().getId().equals(userId)) {
            System.out.println("✓ Teacher access granted (creator)");
            return true;
        }

        // 3. Преподаватель - рецензент
        if (assignment.getReviewers() != null) {
            boolean isReviewer = assignment.getReviewers().stream()
                    .anyMatch(r -> r.getId().equals(userId));
            if (isReviewer) {
                System.out.println("✓ Teacher access granted (reviewer)");
                return true;
            }
        }

        // 4. Преподаватель группы
        if (assignment.getGroups() != null) {
            boolean teachesInGroup = assignment.getGroups().stream()
                    .anyMatch(group -> {
                        if (group.getTeachers() != null) {
                            return group.getTeachers().stream()
                                    .anyMatch(t -> t.getId().equals(userId));
                        }
                        return false;
                    });
            if (teachesInGroup) {
                System.out.println("✓ Teacher access granted (group teacher)");
                return true;
            }
        }

        // 5. Студент может скачать задание, если он в одной из групп
        if (isStudent(userId)) {
            if (assignment.getGroups() != null) {
                boolean studentInGroup = assignment.getGroups().stream()
                        .anyMatch(group -> {
                            if (group.getStudents() != null) {
                                return group.getStudents().stream()
                                        .anyMatch(s -> s.getId().equals(userId));
                            }
                            return false;
                        });
                if (studentInGroup) {
                    System.out.println("✓ Student access granted (in assignment group)");
                    return true;
                }
            }
        }

        System.err.println("⚠️ Access denied for user: " + userId);
        return false;
    }

    // ========================================
    // ПРОВЕРКА ПРАВ ДОСТУПА К SUBMISSION
    // ========================================
    private boolean hasSubmissionAccess(String userId, Submission submission) {
        // 1. Админ имеет доступ ко всем файлам
        if (isAdmin(userId)) {
            System.out.println("✓ Admin access granted");
            return true;
        }

        // 2. Студент может скачать только свою работу
        if (submission.getStudent() != null && userId.equals(submission.getStudent().getId())) {
            System.out.println("✓ Student access granted (owner)");
            return true;
        }

        // 3. Преподаватель может скачать работы из своих заданий
        if (isTeacher(userId)) {
            Assignment assignment = submission.getAssignment();
            if (assignment != null) {
                // Создатель задания
                if (assignment.getCreator() != null &&
                        assignment.getCreator().getId().equals(userId)) {
                    System.out.println("✓ Teacher access granted (creator)");
                    return true;
                }

                // Рецензент
                if (assignment.getReviewers() != null) {
                    boolean isReviewer = assignment.getReviewers().stream()
                            .anyMatch(r -> r.getId().equals(userId));
                    if (isReviewer) {
                        System.out.println("✓ Teacher access granted (reviewer)");
                        return true;
                    }
                }

                // Преподаватель группы
                if (assignment.getGroups() != null) {
                    boolean teachesInGroup = assignment.getGroups().stream()
                            .anyMatch(group -> {
                                if (group.getTeachers() != null) {
                                    return group.getTeachers().stream()
                                            .anyMatch(t -> t.getId().equals(userId));
                                }
                                return false;
                            });
                    if (teachesInGroup) {
                        System.out.println("✓ Teacher access granted (group teacher)");
                        return true;
                    }
                }
            }
        }

        System.err.println("⚠️ Access denied for user: " + userId);
        return false;
    }

    // ========================================
    // HELPER МЕТОДЫ
    // ========================================

    private boolean isAdmin(String userId) {
        if (userId == null) return false;
        User user = adminRepository.findById(userId).orElse(null);
        return user != null && user.getRole() == UserRole.ADMIN;
    }

    private boolean isTeacher(String userId) {
        if (userId == null) return false;
        return teacherRepository.findById(userId).isPresent();
    }

    private boolean isStudent(String userId) {
        if (userId == null) return false;
        StudentRepository studentRepository = (StudentRepository)
                getServletContext().getAttribute("studentRepository");
        return studentRepository != null && studentRepository.findById(userId).isPresent();
    }

    private String getMimeType(String fileName) {
        String mimeType = getServletContext().getMimeType(fileName);
        if (mimeType != null) {
            return mimeType;
        }

        // Определяем по расширению
        String lowerFileName = fileName.toLowerCase();
        if (lowerFileName.endsWith(".pdf")) return "application/pdf";
        if (lowerFileName.endsWith(".doc")) return "application/msword";
        if (lowerFileName.endsWith(".docx")) return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        if (lowerFileName.endsWith(".xls")) return "application/vnd.ms-excel";
        if (lowerFileName.endsWith(".xlsx")) return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        if (lowerFileName.endsWith(".ppt")) return "application/vnd.ms-powerpoint";
        if (lowerFileName.endsWith(".pptx")) return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
        if (lowerFileName.endsWith(".zip")) return "application/zip";
        if (lowerFileName.endsWith(".rar")) return "application/x-rar-compressed";
        if (lowerFileName.endsWith(".7z")) return "application/x-7z-compressed";
        if (lowerFileName.endsWith(".tar")) return "application/x-tar";
        if (lowerFileName.endsWith(".gz")) return "application/gzip";
        if (lowerFileName.endsWith(".txt")) return "text/plain";
        if (lowerFileName.endsWith(".html") || lowerFileName.endsWith(".htm")) return "text/html";
        if (lowerFileName.endsWith(".css")) return "text/css";
        if (lowerFileName.endsWith(".js")) return "application/javascript";
        if (lowerFileName.endsWith(".json")) return "application/json";
        if (lowerFileName.endsWith(".xml")) return "application/xml";
        if (lowerFileName.endsWith(".jpg") || lowerFileName.endsWith(".jpeg")) return "image/jpeg";
        if (lowerFileName.endsWith(".png")) return "image/png";
        if (lowerFileName.endsWith(".gif")) return "image/gif";
        if (lowerFileName.endsWith(".bmp")) return "image/bmp";
        if (lowerFileName.endsWith(".svg")) return "image/svg+xml";
        if (lowerFileName.endsWith(".ico")) return "image/x-icon";
        if (lowerFileName.endsWith(".mp3")) return "audio/mpeg";
        if (lowerFileName.endsWith(".wav")) return "audio/wav";
        if (lowerFileName.endsWith(".mp4")) return "video/mp4";
        if (lowerFileName.endsWith(".avi")) return "video/x-msvideo";

        return "application/octet-stream";
    }
}