package com.lms.system.servlet.teacher;

import com.lms.system.model.*;
import com.lms.system.service.SubmissionService;
import com.lms.system.service.teacher.TeacherService;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.Map;


@WebServlet("/teacher/*")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,        // 10MB
        maxRequestSize = 1024 * 1024 * 50      // 50MB
)
public class TeacherServlet extends HttpServlet {
    private TeacherService teacherService;
    private SubmissionService submissionService;

    @Override
    public void init() {
        this.teacherService = (TeacherService) getServletContext().getAttribute("teacherService");
        this.submissionService = (SubmissionService) getServletContext().getAttribute("submissionService");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String pathInfo = req.getPathInfo();
        String userId = (String) req.getSession().getAttribute("userId");
        String requestURI = req.getRequestURI(); // ← ДОБАВЬ ЭТУ СТРОКУ

        System.out.println(">>> URI: " + requestURI);           // ← И ЭТУ
        System.out.println(">>> pathInfo: [" + pathInfo + "]"); // ← И ЭТУ

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendRedirect(req.getContextPath() + "/teacher/dashboard");
            return;
        }

        try {
            switch (pathInfo) {
                case "/dashboard" -> showDashboard(req, resp, userId);
                case "/profile" -> showProfile(req, resp, userId);
                case "/groups" -> showGroups(req, resp, userId);
                case "/groups/create" -> req.getRequestDispatcher("/WEB-INF/views/teacher/group-form.jsp").forward(req, resp);
                case "/groups/view" -> {
                    String groupId = req.getParameter("groupId");
                    if (groupId == null || groupId.isBlank()) {
                        resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "groupId is required");
                        return;
                    }

                    showGroupDetails(req, resp, userId);
                }
                case "/groups/edit" -> showEditGroupForm(req, resp, userId);
                case "/assignments" -> showAssignments(req, resp, userId);
                case "/assignments/create" -> showCreateAssignmentForm(req, resp, userId);
                case "/submissions" -> showSubmissions(req, resp, userId);
                case "/submissions/grade" -> showGradeForm(req, resp, userId);
                default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        }catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error/404.jsp").forward(req, resp);
        }
    }

    private void showEditGroupForm(HttpServletRequest req, HttpServletResponse resp, String userId) throws ServletException, IOException {
        String groupId = req.getParameter("groupId");
        Group group = teacherService.validateGroupAccess(userId, groupId);
        req.setAttribute("group", group);
        req.getRequestDispatcher("/WEB-INF/views/teacher/group-edit.jsp").forward(req, resp);
    }

    // ========================= SHOW TEACHER INFO

    private void showGradeForm(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws ServletException, IOException {

        String submissionId = req.getParameter("submissionId");

        if (submissionId == null || submissionId.isBlank()) {
            submissionId = (String) req.getAttribute("submissionId");
        }

        if (submissionId == null || submissionId.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Submission ID is required");
            return;
        }

        try {
            // ============================================
            // 1. ЗАГРУЗКА SUBMISSION
            // ============================================
            Submission submission = submissionService.getSubmissionById(submissionId);

            if (submission == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Submission not found");
                return;
            }

            // ============================================
            // 2. ПРОВЕРКА ПРАВ ДОСТУПА
            // ============================================
            Assignment assignment = submission.getAssignment();
            boolean hasAccess = false;

            // Проверка прав (аналогично методу gradeSubmission)
            if (assignment.getCreator() != null &&
                    assignment.getCreator().getId().equals(userId)) {
                hasAccess = true;
            }

            if (!hasAccess && assignment.getReviewers() != null) {
                hasAccess = assignment.getReviewers().stream()
                        .anyMatch(reviewer -> reviewer.getId().equals(userId));
            }

            if (!hasAccess && assignment.getGroups() != null) {
                hasAccess = assignment.getGroups().stream()
                        .anyMatch(group -> {
                            if (group.getTeachers() != null) {
                                return group.getTeachers().stream()
                                        .anyMatch(teacher -> teacher.getId().equals(userId));
                            }
                            return false;
                        });
            }

            if (!hasAccess) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "You don't have permission to grade this submission");
                return;
            }

            // ============================================
            // 3. УСТАНОВКА АТРИБУТОВ
            // ============================================
            req.setAttribute("submission", submission);

            // Сохраняем введенные данные при ошибке
            if (req.getAttribute("enteredGrade") != null) {
                req.setAttribute("enteredGrade", req.getAttribute("enteredGrade"));
            }
            if (req.getAttribute("enteredFeedback") != null) {
                req.setAttribute("enteredFeedback", req.getAttribute("enteredFeedback"));
            }

            // ============================================
            // 4. ФОРВАРД НА JSP
            // ============================================
            req.getRequestDispatcher("/WEB-INF/views/teacher/grade-form.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error loading grade form: " + e.getMessage());

            req.setAttribute("error", "Failed to load submission data: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error/general.jsp").forward(req, resp);
        }
    }

    private void showSubmissions(HttpServletRequest req, HttpServletResponse resp, String userId) throws ServletException, IOException {
        String assignmentId = req.getParameter("assignmentId");

        if (assignmentId == null || assignmentId.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "assignmentId is required");
            return;
        }

        try {
            Assignment assignment = teacherService.getAssignmentById(userId, assignmentId);
            List<Submission> submissions = teacherService.getSubmissionsForAssignment(userId, assignmentId);

            req.setAttribute("assignment", assignment);
            req.setAttribute("submissions", submissions);

            req.getRequestDispatcher("/WEB-INF/views/teacher/submissions.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error/general.jsp").forward(req, resp);
        }
    }

    private void showCreateAssignmentForm(HttpServletRequest req, HttpServletResponse resp, String userId) throws ServletException, IOException {
        List<Group> groups = teacherService.getMyGroups(userId);
        req.setAttribute("groups", groups);
        req.getRequestDispatcher("/WEB-INF/views/teacher/assignment-form.jsp").forward(req, resp);
    }

    private void showAssignments(HttpServletRequest req, HttpServletResponse resp, String userId) throws ServletException, IOException {
        List<Assignment> assignments = teacherService.getMyAssignments(userId);
        req.setAttribute("assignments", assignments);
        req.getRequestDispatcher("/WEB-INF/views/teacher/assignments.jsp").forward(req, resp);
    }

    private void showGroupDetails(HttpServletRequest req, HttpServletResponse resp, String userId) throws ServletException, IOException {
        String groupId = req.getParameter("groupId");
        Group group = teacherService.validateGroupAccess(userId, groupId);

        List<Student> studentsByGroup = teacherService.getStudentsInGroup(userId, groupId);
        teacherService.getTotalStudentsCount(userId);

        req.setAttribute("studentsByGroup", studentsByGroup);
        req.setAttribute("group", group);
        req.setAttribute("studentSize", studentsByGroup.size());
        req.setAttribute("assignments", teacherService.getMyAssignments(userId).size());
        req.getRequestDispatcher("/WEB-INF/views/teacher/group-details.jsp").forward(req, resp);
    }

    private void showGroups(HttpServletRequest req, HttpServletResponse resp, String userId) throws ServletException, IOException {
        List<Group> groups = teacherService.getMyGroups(userId);
        req.setAttribute("groups", groups);
        req.getRequestDispatcher("/WEB-INF/views/teacher/groups.jsp").forward(req, resp);
    }

    private void showProfile(HttpServletRequest req, HttpServletResponse resp, String userId) throws ServletException, IOException {
        Teacher teacher = teacherService.getProfile(userId);
        req.setAttribute("teacher", teacher);
        req.getRequestDispatcher("/WEB-INF/views/teacher/profile.jsp").forward(req, resp);
    }

    private void showDashboard(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws ServletException, IOException {

        System.out.println("→ Loading teacher dashboard");
        System.out.println("  Teacher ID: " + userId);

        // 1. Загружаем данные учителя
        Teacher teacher = teacherService.getProfile(userId);

        // 2. Загружаем группы со всеми данными
        List<Group> groups = teacherService.getMyGroupsWithAllData(userId);
        System.out.println("  Groups loaded: " + groups.size());

        // 3. Загружаем assignments
        List<Assignment> assignments = teacherService.getMyAssignments(userId);
        System.out.println("  Assignments loaded: " + assignments.size());

        // 4. ✅ ВАЖНО: Загружаем количество submissions для каждого assignment
        Map<String, Long> submissionCounts = teacherService.getSubmissionCountsForAssignments(assignments);
        System.out.println("  Submission counts loaded: " + submissionCounts.size());

        // Debug: показываем количества
        for (Assignment a : assignments) {
            Long count = submissionCounts.get(a.getId());
            System.out.println("    Assignment '" + a.getTitle() + "': " + count + " submissions");
        }

        // 5. Форматируем даты
        assignments.forEach(a -> {
            if (a.getDueDate() != null) {
                a.setDueDateFormatted(
                        a.getDueDate().format(DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm"))
                );
            } else {
                a.setDueDateFormatted("No due date");
            }
        });

        // 6. Устанавливаем атрибуты для JSP
        req.setAttribute("teacher", teacher);
        req.setAttribute("groups", groups);
        req.setAttribute("formattedAssignments", assignments);
        req.setAttribute("submissionCounts", submissionCounts);  // ← ВАЖНО!

        // Статистика (можете добавить позже)
        req.setAttribute("studentsCount", 0);
        req.setAttribute("totalAssignments", assignments.size());
        req.setAttribute("pendingCount", 0);
        req.setAttribute("groupsCount", groups.size());

        System.out.println("  ✓ Forwarding to dashboard.jsp");
        req.getRequestDispatcher("/WEB-INF/views/teacher/dashboard.jsp").forward(req, resp);
    }


    // ==================================== TEACHER ACTIVITY
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String userId = (String) req.getSession().getAttribute("userId");

        try {
            switch (pathInfo) {
                case "/profile/update" -> updateProfile(req, resp, userId);

                case "/groups/create" -> createGroup(req, resp, userId);
                case "/groups/update" -> updateGroup(req, resp, userId);
                case "/groups/delete" -> deleteGroup(req, resp, userId);

                case "/groups/add-student" -> addStudentToGroup(req, resp, userId);
                case "/groups/remove-student" -> removeStudentToGroup(req, resp, userId);

                case "/assignments/create" -> createAssignment(req, resp, userId);
                case "/assignments/update" -> updateAssignments(req, resp, userId);
                case "/assignments/delete" -> deleteAssignment(req, resp, userId);

                case "/submissions/grade" -> gradeSubmission(req, resp, userId);

                default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        }catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error/404.jsp").forward(req, resp);
        }
    }

    private void gradeSubmission(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException, ServletException {

        String submissionId = req.getParameter("submissionId");
        String gradeStr = req.getParameter("grade");
        String feedback = req.getParameter("feedback");

        try {
            // ============================================
            // 1. ВАЛИДАЦИЯ ВХОДНЫХ ДАННЫХ
            // ============================================
            if (submissionId == null || submissionId.isBlank()) {
                throw new IllegalArgumentException("Submission ID is required");
            }

            if (gradeStr == null || gradeStr.isBlank()) {
                throw new IllegalArgumentException("Grade is required");
            }

            // ============================================
            // 2. ПАРСИНГ И ВАЛИДАЦИЯ ОЦЕНКИ
            // ============================================
            Integer grade;
            try {
                grade = Integer.parseInt(gradeStr.trim());
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Invalid grade format. Please enter a valid number.");
            }

            if (grade < 0) {
                throw new IllegalArgumentException("Grade cannot be negative");
            }

            // ============================================
            // 3. ПОЛУЧЕНИЕ SUBMISSION И СВЯЗАННЫХ ДАННЫХ
            // ============================================
            Submission submission = submissionService.getSubmissionById(submissionId);

            if (submission == null) {
                throw new IllegalArgumentException("Submission not found");
            }

            Assignment assignment = submission.getAssignment();
            if (assignment == null) {
                throw new IllegalArgumentException("Assignment not found for this submission");
            }

            // ============================================
            // 4. ПРОВЕРКА МАКСИМАЛЬНОГО БАЛЛА
            // ============================================
            Integer maxScore = assignment.getMaxScore();
            if (maxScore == null) {
                throw new IllegalArgumentException("Maximum score is not defined for this assignment");
            }

            if (grade > maxScore) {
                throw new IllegalArgumentException(
                        String.format("Grade (%d) cannot exceed maximum score (%d)", grade, maxScore)
                );
            }

            // ============================================
            // 5. ПРОВЕРКА ПРАВ ДОСТУПА УЧИТЕЛЯ
            // ============================================
            boolean hasAccess = false;

            // Проверка 1: Учитель - создатель задания
            if (assignment.getCreator() != null &&
                    assignment.getCreator().getId().equals(userId)) {
                hasAccess = true;
            }

            // Проверка 2: Учитель в списке reviewers
            if (!hasAccess && assignment.getReviewers() != null) {
                hasAccess = assignment.getReviewers().stream()
                        .anyMatch(reviewer -> reviewer.getId().equals(userId));
            }

            // Проверка 3: Учитель преподает в одной из групп этого задания
            if (!hasAccess && assignment.getGroups() != null) {
                hasAccess = assignment.getGroups().stream()
                        .anyMatch(group -> {
                            if (group.getTeachers() != null) {
                                return group.getTeachers().stream()
                                        .anyMatch(teacher -> teacher.getId().equals(userId));
                            }
                            return false;
                        });
            }

            if (!hasAccess) {
                throw new SecurityException("You don't have permission to grade this submission");
            }

            // ============================================
            // 6. НОРМАЛИЗАЦИЯ FEEDBACK
            // ============================================
            String normalizedFeedback = null;
            if (feedback != null && !feedback.trim().isEmpty()) {
                normalizedFeedback = feedback.trim();
            }

            // ============================================
            // 7. ОЦЕНИВАНИЕ РАБОТЫ
            // ============================================
            System.out.println("=== Grading Submission ===");
            System.out.println("Submission ID: " + submissionId);
            System.out.println("Student: " + submission.getStudent().getFullName());
            System.out.println("Assignment: " + assignment.getTitle());
            System.out.println("Grade: " + grade + " / " + maxScore);
            System.out.println("Feedback: " + (normalizedFeedback != null ? "Yes" : "No"));

            teacherService.gradeSubmission(userId, submissionId, grade, normalizedFeedback);

            // ============================================
            // 8. УСПЕШНЫЙ РЕДИРЕКТ
            // ============================================
            String assignmentId = assignment.getId();
            String redirectUrl = String.format(
                    "%s/teacher/submissions?assignmentId=%s&success=graded",
                    req.getContextPath(),
                    assignmentId
            );

            System.out.println("Redirecting to: " + redirectUrl);
            resp.sendRedirect(redirectUrl);

        } catch (IllegalArgumentException e) {
            // ============================================
            // 9. ОБРАБОТКА ОШИБОК ВАЛИДАЦИИ
            // ============================================
            System.err.println("❌ Validation error: " + e.getMessage());

            req.setAttribute("error", e.getMessage());
            req.setAttribute("submissionId", submissionId);
            req.setAttribute("enteredGrade", gradeStr);
            req.setAttribute("enteredFeedback", feedback);

            showGradeForm(req, resp, userId);

        } catch (SecurityException e) {
            // ============================================
            // 10. ОБРАБОТКА ОШИБОК ДОСТУПА
            // ============================================
            System.err.println("🔒 Security error: " + e.getMessage());

            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());

        } catch (Exception e) {
            // ============================================
            // 11. ОБРАБОТКА СИСТЕМНЫХ ОШИБОК
            // ============================================
            e.printStackTrace();
            System.err.println("💥 System error: " + e.getMessage());

            req.setAttribute("error", "An unexpected error occurred. Please try again later.");
            req.setAttribute("submissionId", submissionId);

            try {
                showGradeForm(req, resp, userId);
            } catch (Exception formError) {
                formError.printStackTrace();
                req.setAttribute("errorMessage", "Critical error. Please contact support.");
                req.getRequestDispatcher("/WEB-INF/views/error/general.jsp").forward(req, resp);
            }
        }
    }

    private void createAssignment(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException, ServletException {
        try {
            // === Получение параметров ===
            String title = req.getParameter("title");
            String description = req.getParameter("description");
            String maxScoreStr = req.getParameter("maxScore");
            String[] groupIds = req.getParameterValues("groupIds");

            // === Валидация ===
            validateRequired(title, "Assignment title is required");
            validateRequired(description, "Description is required");
            validateRequired(maxScoreStr, "Maximum score is required");

            // === Обработка файла ===
            String fileName = null;
            String filePath = null;
            Long fileSize = null;

            Part filePart = req.getPart("assignmentFile");
            if (filePart != null && filePart.getSize() > 0) {
                fileName = getSubmittedFileName(filePart);

                // Валидация расширения
                String extension = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
                List<String> allowed = Arrays.asList(".pdf", ".doc", ".docx", ".zip", ".pptx", ".txt", ".rar");

                if (!allowed.contains(extension)) {
                    throw new IllegalArgumentException(
                            "Invalid file type. Allowed: PDF, DOC, DOCX, ZIP, PPTX, TXT, RAR"
                    );
                }

                // Сохранение файла
                String uploadDir = getServletContext().getRealPath("") + File.separator +
                        "uploads" + File.separator + "assignments";
                File dir = new File(uploadDir);
                if (!dir.exists()) {
                    dir.mkdirs();
                }

                String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                filePath = uploadDir + File.separator + uniqueFileName;
                filePart.write(filePath);
                fileSize = filePart.getSize();
            }

            // === Дата и время ===
            String dateStr = req.getParameter("dueDateDate");
            String timeStr = req.getParameter("dueDateTime");

            validateRequired(dateStr, "Deadline date is required");
            validateRequired(timeStr, "Deadline time is required");

            if (timeStr.length() == 5) {
                timeStr += ":00";
            }

            LocalDateTime deadline = LocalDateTime.parse(dateStr + "T" + timeStr);

            if (deadline.isBefore(LocalDateTime.now())) {
                throw new IllegalArgumentException("Deadline cannot be in the past");
            }

            // === Max Score ===
            int maxScore = parseScore(maxScoreStr);

            // === Группы ===
            List<String> groupIdList = (groupIds != null && groupIds.length > 0)
                    ? Arrays.asList(groupIds)
                    : List.of();

            if (groupIdList.isEmpty()) {
                throw new IllegalArgumentException("Select at least one group");
            }

            // === Создание assignment ===
            teacherService.createAssignment(
                    userId,
                    title.trim(),
                    description.trim(),
                    deadline,
                    maxScore,
                    groupIdList,
                    fileName,
                    filePath,
                    fileSize
            );

            resp.sendRedirect(req.getContextPath() + "/teacher/assignments?success=created");

        } catch (IllegalArgumentException e) {
            handleError(req, resp, userId, e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            handleError(req, resp, userId, "Failed to create assignment. Please try again.");
        }
    }

// === Вспомогательные методы ===

    private void validateRequired(String value, String message) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(message);
        }
    }

    private int parseScore(String scoreStr) {
        try {
            int score = Integer.parseInt(scoreStr);
            if (score < 1 || score > 10000) {
                throw new IllegalArgumentException("Score must be between 1 and 10,000");
            }
            return score;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid score value");
        }
    }

    private void handleError(HttpServletRequest req, HttpServletResponse resp,
                             String userId, String errorMessage)
            throws ServletException, IOException {
        req.setAttribute("error", errorMessage);
        req.setAttribute("groups", teacherService.getMyGroups(userId));
        showCreateAssignmentForm(req, resp, userId);
    }

    private String getSubmittedFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
    private void updateAssignments(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException {
        String assignmentId = req.getParameter("assignmentId");
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String deadlineStr = req.getParameter("deadline");
        String maxScoreStr = req.getParameter("maxScore");

        LocalDateTime deadline = LocalDateTime.parse(deadlineStr);
        Integer maxScore = Integer.parseInt(maxScoreStr);

        teacherService.updateAssignment(userId, assignmentId, title, description, deadline, maxScore);
        resp.sendRedirect(req.getContextPath() + "/teacher/assignments?success=true");
    }

    private void deleteAssignment(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException {
        String assignmentId = req.getParameter("assignmentId");
        teacherService.deleteAssignment(userId, assignmentId);
        resp.sendRedirect(req.getContextPath() + "/teacher/assignments?success=true");
    }

    private void addStudentToGroup(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException {
        String groupId = req.getParameter("groupId");
        String studentId = req.getParameter("studentId");

        teacherService.addStudentToGroup(userId, groupId, studentId);
        resp.sendRedirect(req.getContextPath() + "/teacher/groups/view?groupId=" + groupId);
    }

    private void removeStudentToGroup(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException {
        String groupId = req.getParameter("groupId");
        String studentId = req.getParameter("studentId");

        teacherService.removeStudentFromGroup(userId, groupId, studentId);
        resp.sendRedirect(req.getContextPath() + "/teacher/groups/view?groupId=" + groupId);
    }

    private void createGroup(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException {
        String name = req.getParameter("name");
        String description = req.getParameter("description");

        System.out.println("Name: " + name);
        System.out.println("Description: " + description);

        teacherService.createGroup(userId, name, description);
        resp.sendRedirect(req.getContextPath() + "/teacher/groups?success=true");
    }

    private void updateGroup(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException {
        String groupId = req.getParameter("groupId");
        String name = req.getParameter("name");
        String description = req.getParameter("description");

        System.out.println("Name: " + name);

        teacherService.updateGroup(userId, groupId, name, description);
        resp.sendRedirect(req.getContextPath() + "/teacher/groups?success=true");
    }

    private void deleteGroup(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException {
        String groupId = req.getParameter("groupId");
        teacherService.deleteGroup(userId, groupId);
        resp.sendRedirect(req.getContextPath() + "/teacher/groups?success=true");
    }

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException {
        String fullName = req.getParameter("fullName");
        String specialization = req.getParameter("specialization");

        teacherService.updateProfile(userId, fullName, specialization);
        resp.sendRedirect(req.getContextPath() + "/teacher/profile?success=true");
    }

}
