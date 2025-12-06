package com.lms.system.servlet.student;


import com.lms.system.model.Assignment;
import com.lms.system.model.Group;
import com.lms.system.model.Student;
import com.lms.system.model.Submission;
import com.lms.system.service.FileService;
import com.lms.system.service.student.StudentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;


@WebServlet("/student/*")
@MultipartConfig
public class StudentServlet extends HttpServlet {
    private StudentService studentService;
    private FileService fileService;

    @Override
    public void init() throws ServletException {
        System.out.println("→ StudentServlet.init() called");

        this.studentService = (StudentService) getServletContext().getAttribute("studentService");
        this.fileService = (FileService) getServletContext().getAttribute("fileService");

        System.out.println("  studentService: " + this.studentService);
        System.out.println("  fileService: " + this.fileService);

        if (this.studentService == null) {
            throw new ServletException("StudentService not initialized!");
        }
        if (this.fileService == null) {
            throw new ServletException("FileService not initialized!");
        }

        System.out.println("✓ StudentServlet initialized successfully");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String userId = (String) req.getSession().getAttribute("userId");

        System.out.println("\n→ StudentServlet.doGet");
        System.out.println("  pathInfo: " + pathInfo);
        System.out.println("  userId: " + userId);

        if (userId == null) {
            System.out.println("✗ No userId in session, redirecting to login");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            System.out.println("→ Redirecting to dashboard");
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        }

        try {
            switch (pathInfo) {
                case "/dashboard" -> {
                    System.out.println("→ Showing dashboard");
                    showDashboard(req, resp, userId);
                }
                case "/profile" -> {
                    System.out.println("→ Showing profile");
                    showProfile(req, resp, userId);
                }
                case "/groups" -> {
                    System.out.println("→ Showing groups");
                    showGroups(req, resp, userId);
                }
                case "/assignments" -> {
                    System.out.println("→ Showing assignments");
                    showAssignments(req, resp, userId);
                }
                case "/submissions" -> showSubmissions(req, resp, userId);
                case "/submit" -> {
                    System.out.println("→ Showing submit form");
                    showSubmitForm(req, resp, userId);
                }
                case "/submission/create" -> {
                    System.out.println("→ Showing submission create form");
                    showSubmissionCreateForm(req, resp, userId);
                }
                case "/submission/view" -> {
                    System.out.println("-> Showing submission view");
                    showSubmissionForm(req, resp, userId);
                }
                default -> {
                    System.out.println("✗ Unknown path: " + pathInfo);
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                }
            }
        } catch (Exception e) {
            System.err.println("✗ Error in StudentServlet.doGet:");
            e.printStackTrace(System.err);
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error/404.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String userId = (String) req.getSession().getAttribute("userId");

        System.out.println("\n→ StudentServlet.doPost");
        System.out.println("  pathInfo: " + pathInfo);
        System.out.println("  userId: " + userId);

        if (userId == null) {
            System.out.println("✗ No userId in session, redirecting to login");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            switch (pathInfo) {
                case "/profile/update" -> {
                    System.out.println("→ Updating profile");
                    updateProfile(req, resp, userId);
                }
                case "/submit" -> {
                    System.out.println("→ Submitting assignment");
                    submitAssignment(req, resp, userId);
                }
                case "/group/join" -> {
                    System.out.println("→ Joining group");
                    joinGroup(req, resp, userId);
                }
                case "/group/leave" -> {
                    System.out.println("→ Leaving group");
                    leaveGroup(req, resp, userId);
                }
                case "/submission/create" -> {
                    System.out.println("→ Processing submission");
                    submitAssignment(req, resp, userId);
                }
                default -> {
                    System.out.println("✗ Unknown path: " + pathInfo);
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                }
            }
        } catch (Exception e) {
            System.err.println("✗ Error in StudentServlet.doPost:");
            e.printStackTrace(System.err);
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error/404.jsp").forward(req, resp);
        }
    }

    // =========================== STUDENT ACTIVITY

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");

        System.out.println("  Updating profile: " + email);
        studentService.updateProfile(userId, fullName, email);
        System.out.println("  ✓ Profile updated");

        resp.sendRedirect(req.getContextPath() + "/student/profile?success=true");
    }

    private void submitAssignment(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws ServletException, IOException {
        String assignmentId = req.getParameter("assignmentId");
        String content = req.getParameter("content");
        Part filePart = req.getPart("file");

        System.out.println("  Assignment ID: " + assignmentId);
        System.out.println("  Content length: " + (content != null ? content.length() : 0));
        System.out.println("  File uploaded: " + (filePart != null && filePart.getSize() > 0));

        String filePath = null;
        String fileName = null;

        if (filePart != null && filePart.getSize() > 0) {
            var result = fileService.uploadFile(filePart, userId);
            filePath = result.get("path");  // ← сохраняем в переменную
            fileName = result.get("name");
        }
        studentService.submitAssignment(userId, assignmentId, content, filePath, fileName);        System.out.println("  ✓ Assignment submitted");
        resp.sendRedirect(req.getContextPath() + "/student/submissions?success=true");
    }

    private void joinGroup(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException {
        String groupId = req.getParameter("groupId");

        System.out.println("  Joining group: " + groupId);
        studentService.joinGroup(userId, groupId);
        System.out.println("  ✓ Joined group");

        resp.sendRedirect(req.getContextPath() + "/student/groups?success=true");
    }

    private void leaveGroup(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException {
        String groupId = req.getParameter("groupId");

        System.out.println("  Leaving group: " + groupId);
        studentService.leaveGroup(userId, groupId);
        System.out.println("  ✓ Left group");

        resp.sendRedirect(req.getContextPath() + "/student/groups?success=true");
    }

    // ============================ SHOW STUDENT INFO

    private void showSubmissionCreateForm(HttpServletRequest req, HttpServletResponse resp, String userId) throws IOException, ServletException {
        String assignmentId = req.getParameter("assignmentId");

        if (assignmentId == null || assignmentId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/student/assignments");
            return;
        }

        List<Assignment> assignments = studentService.getAllMyAssignments(userId);
        Assignment assignment = assignments.stream()
                .filter(a -> a.getId().equals(assignmentId))
                .findFirst()
                .orElse(null);

        System.out.println("Assignments : " + assignments);
        System.out.println("Assignment : " + assignment);

        if (assignment == null) {
            resp.sendRedirect(req.getContextPath() + "/student/assignments");
            return;
        }

        // Последняя отправка (для показа "вы уже сдавали")
        Submission latestSubmission = studentService.getLatestSubmission(userId, assignmentId)
                .orElse(null);

        req.setAttribute("assignment", assignment);
        req.setAttribute("latestSubmission", latestSubmission);
        req.setAttribute("now", LocalDateTime.now());

        req.getRequestDispatcher("/WEB-INF/views/student/create.jsp")
                .forward(req, resp);
    }

    private void showSubmissionForm(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException, ServletException {

        System.out.println("\n→ showSubmissionForm()");

        String submissionId = req.getParameter("submissionId");

        if (submissionId == null || submissionId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/student/submissions");
            return;
        }

        // 1. Найти submission
        Optional<Submission> optSubmission = studentService.getSubmissionById(submissionId);

        if (optSubmission.isEmpty()) {
            System.out.println("  ❌ Submission not found");
            resp.sendRedirect(req.getContextPath() + "/student/submissions");
            return;
        }

        Submission submission = optSubmission.get();

        // 2. Проверка — студент владелец?
        if (!submission.getStudent().getId().equals(userId)) {
            System.out.println("  ❌ Access denied");
            resp.sendError(403, "Forbidden");
            return;
        }

        // 3. Получить связанное задание
        Assignment assignment = submission.getAssignment();

        req.setAttribute("submission", submission);
        req.setAttribute("assignment", assignment);

        req.getRequestDispatcher("/WEB-INF/views/student/submission-view.jsp")
                .forward(req, resp);
    }


    private void showSubmitForm(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException, ServletException {
        String assignmentId = req.getParameter("assignmentId");

        System.out.println("  Assignment ID: " + assignmentId);

        if (assignmentId == null) {
            System.out.println("  ✗ No assignment ID provided");
            resp.sendRedirect(req.getContextPath() + "/student/assignments");
            return;
        }


        List<Assignment> assignments = studentService.getAllMyAssignments(userId);
        Assignment assignment = assignments.stream()
                .filter(a -> a.getId().equals(assignmentId))
                .findFirst()
                .orElse(null);

        if (assignment == null) {
            System.out.println("  ✗ Assignment not found: " + assignmentId);
            resp.sendRedirect(req.getContextPath() + "/student/assignments");
            return;
        }

        Optional<Submission> latestSubmissionOpt = studentService.getLatestSubmission(userId, assignmentId);
        Submission latestSubmission = latestSubmissionOpt.orElse(null);

        System.out.println("  ✓ Assignment found: " + assignment.getTitle());
        System.out.println("  Has previous submission: " + latestSubmissionOpt.isPresent());

        req.setAttribute("assignment", assignment);
        req.setAttribute("latestSubmission", latestSubmission);
        req.getRequestDispatcher("/WEB-INF/views/student/submit.jsp").forward(req, resp);
    }

    private void showSubmissions(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws ServletException, IOException {
        List<Submission> submissions = studentService.getMySubmissions(userId);
        System.out.println("  Total submissions: " + submissions.size());

        req.setAttribute("submissions", submissions);
        req.getRequestDispatcher("/WEB-INF/views/student/submissions.jsp").forward(req, resp);
    }

    private void showAssignments(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws ServletException, IOException {
        System.out.println("\n========== SHOW ASSIGNMENTS DEBUG ==========");
        System.out.println("User ID: " + userId);

        String groupId = req.getParameter("groupId");
        System.out.println("Group ID parameter: " + groupId);

        // Сначала проверим группы студента
        List<Group> groups = studentService.getMyGroups(userId);
        System.out.println("\n--- Student's Groups ---");
        System.out.println("Total groups: " + groups.size());
        if (groups.isEmpty()) {
            System.out.println("⚠️ PROBLEM: Student has NO groups!");
        } else {
            for (Group g : groups) {
                System.out.println("  Group ID: " + g.getId() + " | Name: " + g.getName());
                System.out.println("    Students in group: " + g.getStudents().size());
                System.out.println("    Assignments in group: " + g.getAssignments().size());
            }
        }

        // Теперь получим задания
        List<Assignment> assignments;
        if (groupId != null && !groupId.trim().isEmpty()) {
            System.out.println("\n--- Getting assignments for specific group: " + groupId + " ---");
            assignments = studentService.getGroupAssignments(userId, groupId);
        } else {
            System.out.println("\n--- Getting ALL assignments ---");
            assignments = studentService.getAllMyAssignments(userId);
        }

        System.out.println("\n--- Assignments Result ---");
        System.out.println("Total assignments found: " + assignments.size());

        if (assignments.isEmpty()) {
            System.out.println("⚠️ PROBLEM: No assignments found!");
        } else {
            for (Assignment a : assignments) {
                System.out.println("\n  Assignment ID: " + a.getId());
                System.out.println("    Title: " + a.getTitle());
                System.out.println("    Due Date: " + a.getDueDate());
                System.out.println("    Groups count: " + a.getGroups().size());
                for (Group g : a.getGroups()) {
                    System.out.println("      - Group: " + g.getId() + " | " + g.getName());
                }
            }
        }

        // Get student's submissions
        List<Submission> mySubmissions = studentService.getMySubmissions(userId);
        System.out.println("\n--- Submissions ---");
        System.out.println("Total submissions: " + mySubmissions.size());

        System.out.println("\n========== END DEBUG ==========\n");

        req.setAttribute("assignments", assignments);
        req.setAttribute("mySubmissions", mySubmissions);
        req.setAttribute("groups", groups);
        req.setAttribute("now", LocalDateTime.now());
        req.getRequestDispatcher("/WEB-INF/views/student/assignments.jsp").forward(req, resp);
    }

    private void showGroups(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws ServletException, IOException {
        List<Group> groups = studentService.getMyGroups(userId);
        System.out.println("  Total groups: " + groups.size());

        req.setAttribute("groups", groups);
        req.getRequestDispatcher("/WEB-INF/views/student/groups.jsp").forward(req, resp);
    }

    private void showProfile(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws ServletException, IOException {
        Student student = studentService.getProfile(userId);
        System.out.println("  Student: " + student.getFullName());

        req.setAttribute("student", student);
        req.getRequestDispatcher("/WEB-INF/views/student/profile.jsp").forward(req, resp);
    }

    private void showDashboard(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws ServletException, IOException {
        System.out.println("  Loading dashboard data...");

        Student student = studentService.getProfile(userId);
        List<Group> groups = studentService.getMyGroups(userId); // Загрузит со студентами
        List<Assignment> assignments = studentService.getAllMyAssignments(userId);
        List<Submission> submissions = studentService.getMySubmissions(userId);

        long totalSubmissions = studentService.getTotalSubmissionsCount(userId);
        long groupsCount = studentService.getGroupsCount(userId);
        long pendingCount = studentService.getPendingSubmissionsCount(userId);

        System.out.println("  Student: " + student.getFullName());
        System.out.println("  Groups: " + groupsCount);
        System.out.println("  Assignments: " + assignments.size());
        System.out.println("  Submissions: " + totalSubmissions);
        System.out.println("  Pending: " + pendingCount);

        req.setAttribute("student", student);
        req.setAttribute("groups", groups);
        req.setAttribute("assignments", assignments);
        req.setAttribute("submissions", submissions);
        req.setAttribute("totalSubmissions", totalSubmissions);
        req.setAttribute("groupsCount", groupsCount);
        req.setAttribute("pendingCount", pendingCount);

        System.out.println("  → Forwarding to /WEB-INF/views/student/dashboard.jsp");
        req.getRequestDispatcher("/WEB-INF/views/student/dashboard.jsp").forward(req, resp);
    }
}
