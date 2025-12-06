package com.lms.system.servlet.admin;

import com.lms.system.enums.UserRole;
import com.lms.system.model.*;
import com.lms.system.service.admin.AdminGroupService;
import com.lms.system.service.admin.AdminUserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;


@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {
    private AdminUserService adminUserService;
    private AdminGroupService adminGroupService;


    @Override
    public void init() {
        this.adminUserService = (AdminUserService) getServletContext().getAttribute("adminUserService");
        this.adminGroupService = (AdminGroupService) getServletContext().getAttribute("adminGroupService");

        System.out.println("✓ AdminServlet initialized with services");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        try {
            switch (pathInfo) {
                case "/dashboard" -> showDashboard(req, resp);
                case "/users" -> showUsers(req, resp);
                case "/users/students" -> showStudents(req, resp);
                case "/users/teachers" -> showTeachers(req, resp);
                case "/users/admins" -> showAdmins(req, resp);
                case "/users/create" -> showCreateUserForm(req, resp);
                case "/groups" -> showGroups(req, resp);
                case "/groups/view" -> showGroupDetails(req, resp);
                case "/group/create" -> showCreateGroupForm(req, resp);
                case "/assignments" -> showAssignments(req, resp);
                case "/assignment/view" -> showAssignmentDetails(req, resp);
                case "/submissions" -> showSubmissions(req, resp);
                default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/error.jsp").forward(req, resp);
        }
    }

    // ======================== SHOW GROUP DETAILS ========================

    private void showGroupDetails(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        String groupId = req.getParameter("groupId");

        if (groupId == null || groupId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/groups");
            return;
        }

        try {
            // ============================================
            // Получаем данные со статистикой
            // ============================================
            Map<String, Object> data = adminGroupService.getGroupWithStatistics(groupId);

            Group group = (Group) data.get("group");

            @SuppressWarnings("unchecked")
            List<Assignment> assignments = (List<Assignment>) data.get("assignments");

            // ✅ ИСПОЛЬЗУЕМ ДАННЫЕ ИЗ MAP, А НЕ ИЗ ГРУППЫ
            int studentCount = group.getStudents().size();  // ← это OK, students загружены
            int teacherCount = group.getTeachers().size();  // ← это OK, teachers загружены
            int assignmentCount = assignments.size();        // ← ИСПРАВЛЕНО: используем из Map

            // Устанавливаем все атрибуты
            req.setAttribute("group", group);
            req.setAttribute("assignments", assignments);
            req.setAttribute("submissionCounts", data.get("submissionCounts"));
            req.setAttribute("gradedCounts", data.get("gradedCounts"));
            req.setAttribute("completionRates", data.get("completionRates"));
            req.setAttribute("totalStudents", data.get("totalStudents"));

            req.setAttribute("studentSize", studentCount);
            req.setAttribute("teacherSize", teacherCount);
            req.setAttribute("assignmentSize", assignmentCount);

            // Получаем доступных студентов и учителей
            List<Student> availableStudents = adminGroupService.getAvailableStudents(groupId);
            Set<Teacher> allTeachers = adminGroupService.getAvailableTeachers(groupId);

            req.setAttribute("availableStudents", availableStudents);
            req.setAttribute("allTeachers", allTeachers);

            req.getRequestDispatcher("/WEB-INF/views/admin/group-details.jsp")
                    .forward(req, resp);

        } catch (IllegalArgumentException e) {
            System.err.println("Group not found: " + e.getMessage());
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error loading group details: " + e.getMessage());
            req.setAttribute("error", "Failed to load group: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }

    // ======================== ОСТАЛЬНЫЕ GET МЕТОДЫ ========================

    private void showCreateGroupForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/admin/group-create.jsp").forward(req, resp);
    }

    private void showSubmissions(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Submission> submissions = adminUserService.getAllSubmissions();
        req.setAttribute("submissions", submissions);
        req.getRequestDispatcher("/WEB-INF/views/admin/submissions.jsp").forward(req, resp);
    }

    private void showAssignmentDetails(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        String assignmentId = req.getParameter("assignmentId");

        if (assignmentId == null || assignmentId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/assignments");
            return;
        }

        Assignment assignment = adminUserService.getAssignmentById(assignmentId);
        req.setAttribute("assignment", assignment);
        req.getRequestDispatcher("/WEB-INF/views/admin/assignment-details.jsp").forward(req, resp);
    }

    private void showAssignments(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String filter = req.getParameter("filter");
            List<Assignment> assignments;

            if ("upcoming".equals(filter)) {
                assignments = adminUserService.getUpcomingAssignments(7);
                req.setAttribute("filter", "upcoming");
            } else if ("expired".equals(filter)) {
                assignments = adminUserService.getExpiredAssignments();
                req.setAttribute("filter", "expired");
            } else {
                assignments = adminUserService.getAllAssignments();
            }

            // Инициализация коллекций
            for (Assignment assignment : assignments) {
                if (assignment.getGroups() == null) {
                    assignment.setGroups(new ArrayList<>());
                } else {
                    assignment.getGroups().size();
                }

                if (assignment.getSubmissions() == null) {
                    assignment.setSubmissions(new ArrayList<>());
                } else {
                    assignment.getSubmissions().size();
                }

                if (assignment.getReviewers() == null) {
                    assignment.setReviewers(new ArrayList<>());
                } else {
                    assignment.getReviewers().size();
                }

                if (assignment.getCreator() != null) {
                    assignment.getCreator().getFullName();
                }
            }

            req.setAttribute("assignments", assignments);
            req.getRequestDispatcher("/WEB-INF/views/admin/assignments.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load assignments");
            req.setAttribute("errorDetails", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }

    private void showGroups(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Group> groups = adminUserService.getAllGroups();

            req.setAttribute("groups", groups);
            req.getRequestDispatcher("/WEB-INF/views/admin/groups.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load groups: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }

    private void showCreateUserForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(req, resp);
    }

    private void showAdmins(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Admin> admins = adminUserService.getAllAdmins();
        req.setAttribute("admins", admins);
        req.getRequestDispatcher("/WEB-INF/views/admin/admins.jsp").forward(req, resp);
    }

    private void showTeachers(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String search = req.getParameter("search");
        List<Teacher> teachers;

        if (search != null && !search.trim().isEmpty()) {
            teachers = adminUserService.searchTeachersByName(search);
            req.setAttribute("searchQuery", search);
        } else {
            teachers = adminUserService.getAllTeachers();
        }

        req.setAttribute("teachers", teachers);
        req.getRequestDispatcher("/WEB-INF/views/admin/teachers.jsp").forward(req, resp);
    }

    private void showStudents(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String search = req.getParameter("search");
        List<Student> students;

        if (search != null && !search.trim().isEmpty()) {
            students = adminUserService.searchStudentsByName(search);
            req.setAttribute("searchQuery", search);
        } else {
            students = adminUserService.getAllStudents();
        }

        req.setAttribute("students", students);
        req.setAttribute("studentSize", students.size());
        req.setAttribute("searchQuery", search);

        req.getRequestDispatcher("/WEB-INF/views/admin/students.jsp").forward(req, resp);
    }

    private void showUsers(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Student> students = adminUserService.getAllStudents();
        List<Teacher> teachers = adminUserService.getAllTeachers();
        List<Admin> admins = adminUserService.getAllAdmins();

        req.setAttribute("students", students);
        req.setAttribute("studentSize", students.size());
        req.setAttribute("teachers", teachers);
        req.setAttribute("teacherSize", teachers.size());
        req.setAttribute("admins", admins);
        req.setAttribute("adminSize", admins.size());

        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
    }

    private void showDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        System.out.println("✅ showDashboard() called!");  // ← ДОБАВЬ ЭТО

        long totalStudents = adminUserService.getTotalStudentsCount();
        System.out.println("totalStudents DEBUGGING CODE : " + totalStudents);
        long totalTeachers = adminUserService.getTotalTeachersCount();
        System.out.println("totalTeachers DEBUGGING CODE : " + totalTeachers);
        long activeTeachers = adminUserService.getActiveTeachersCount();
        System.out.println("activeTeachers DEBUGGING CODE : " + activeTeachers);
        long totalGroups = adminUserService.getTotalGroupsCount();
        System.out.println("totalGroups DEBUGGING CODE : " + totalGroups);
        long totalAssignments = adminUserService.getTotalAssignmentsCount();
        System.out.println("totalAssignments DEBUGGING CODE : " + totalAssignments);
        long totalSubmissions = adminUserService.getTotalSubmissionsCount();
        System.out.println("totalSubmissions DEBUGGING CODE : " + totalSubmissions);
        long pendingSubmissions = adminUserService.getPendingSubmissionsCount();
        System.out.println("pendingSubmissions DEBUGGING CODE : " + pendingSubmissions);

        req.setAttribute("totalStudents", totalStudents);
        req.setAttribute("totalTeachers", totalTeachers);
        req.setAttribute("activeTeachers", activeTeachers);
        req.setAttribute("totalGroups", totalGroups);
        req.setAttribute("totalAssignments", totalAssignments);
        req.setAttribute("totalSubmissions", totalSubmissions);
        req.setAttribute("pendingSubmissions", pendingSubmissions);

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }

    // ============================== POST METHODS ==============================

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();

        try {
            switch (pathInfo) {
                case "/users/create" -> createUser(req, resp);
                case "/users/activate" -> activateUser(req, resp);
                case "/users/deactivate" -> deactivateUser(req, resp);
                case "/groups/create" -> createGroup(req, resp);

                // ========== ОБНОВЛЕННЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С ГРУППАМИ ==========
                case "/groups/add-students" -> addStudentsToGroup(req, resp);
                case "/groups/add-teacher" -> addTeacherToGroup(req, resp);
                case "/groups/remove-teacher" -> removeTeacherFromGroup(req, resp);

                case "/groups/delete" -> deleteGroup(req, resp);
                case "/assignments/delete" -> deleteAssignment(req, resp);
                case "/submissions/delete" -> deleteSubmission(req, resp);
                default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error/404.jsp").forward(req, resp);
        }
    }

    // ========== МЕТОДЫ ДЛЯ РАБОТЫ С ГРУППАМИ (✅ ИСПРАВЛЕНО) ==========

    private void addStudentsToGroup(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String groupId = req.getParameter("groupId");
        String[] studentIds = req.getParameterValues("studentIds");

        try {
            if (studentIds != null && studentIds.length > 0) {
                adminGroupService.addStudentsToGroup(groupId, Arrays.asList(studentIds));
                resp.sendRedirect(req.getContextPath() + "/admin/groups/view?groupId=" +
                        groupId + "&success=students_added");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/groups/view?groupId=" +
                        groupId + "&error=no_students_selected");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/groups/view?groupId=" +
                    groupId + "&error=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void addTeacherToGroup(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String groupId = req.getParameter("groupId");
        String teacherId = req.getParameter("teacherId");

        try {
            if (teacherId == null || teacherId.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/groups/view?groupId=" +
                        groupId + "&error=no_teacher_selected");
                return;
            }

            adminGroupService.addTeacherToGroup(groupId, teacherId);
            resp.sendRedirect(req.getContextPath() + "/admin/groups/view?groupId=" +
                    groupId + "&success=teacher_added");

        } catch (IllegalStateException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/groups/view?groupId=" +
                    groupId + "&error=teacher_exists");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/groups/view?groupId=" +
                    groupId + "&error=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void removeTeacherFromGroup(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String groupId = req.getParameter("groupId");
        String teacherId = req.getParameter("teacherId");

        try {
            adminGroupService.removeTeacherFromGroup(groupId, teacherId);
            resp.sendRedirect(req.getContextPath() + "/admin/groups/view?groupId=" +
                    groupId + "&success=teacher_removed");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/groups/view?groupId=" +
                    groupId + "&error=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    // ========== ОСТАЛЬНЫЕ POST МЕТОДЫ ==========

    private void createGroup(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String name = req.getParameter("name");
        String description = req.getParameter("description");

        if (name == null || name.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/group/create?error=empty_name");
            return;
        }

        try {
            adminUserService.createGroup(name.trim(), description);
            resp.sendRedirect(req.getContextPath() + "/admin/groups?success=created");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/group/create?error=" +
                    URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void createUser(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String userType = req.getParameter("userType");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String fullName = req.getParameter("fullName");

        if (userType == null || email == null || password == null || fullName == null) {
            req.setAttribute("error", "All fields are required!");
            showCreateUserForm(req, resp);
            return;
        }

        try {
            switch (UserRole.valueOf(userType.toUpperCase())) {
                case STUDENT -> {
                    adminUserService.createStudent(email, password, fullName);
                    resp.sendRedirect(req.getContextPath() + "/admin/users/students?success=true");
                }
                case TEACHER -> {
                    String specialization = req.getParameter("specialization");
                    adminUserService.createTeacher(email, password, fullName, specialization);
                    resp.sendRedirect(req.getContextPath() + "/admin/users/teachers?success=true");
                }
                case ADMIN -> {
                    adminUserService.createAdmin(email, password, fullName);
                    resp.sendRedirect(req.getContextPath() + "/admin/users/admins?success=true");
                }
                default -> {
                    req.setAttribute("error", "Invalid user type!");
                    showCreateUserForm(req, resp);
                }
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("userType", userType);
            req.setAttribute("email", email);
            req.setAttribute("fullName", fullName);
            showCreateUserForm(req, resp);
        }
    }

    private void activateUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String userType = req.getParameter("userType");
        String userId = req.getParameter("userId");
        boolean success = false;

        switch (UserRole.valueOf(userType.toUpperCase())) {
            case STUDENT -> success = adminUserService.activateStudent(userId);
            case TEACHER -> success = adminUserService.activateTeacher(userId);
            case ADMIN -> success = adminUserService.activateAdmin(userId);
        }

        String redirectUrl = req.getContextPath() + "/admin/users/" + userType.toLowerCase() + "s";

        if (success) {
            resp.sendRedirect(redirectUrl + "?success=activated");
        } else {
            resp.sendRedirect(redirectUrl + "?error=activation_failed");
        }
    }

    public void deactivateUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String userType = req.getParameter("userType");
        String userId = req.getParameter("userId");
        boolean success = false;

        switch (UserRole.valueOf(userType.toUpperCase())) {
            case STUDENT -> success = adminUserService.deactivateStudent(userId);
            case TEACHER -> success = adminUserService.deactivateTeacher(userId);
            case ADMIN -> success = adminUserService.deactivateAdmin(userId);
        }

        String redirectUrl = req.getContextPath() + "/admin/users/" + userType.toLowerCase() + "s";

        if (success) {
            resp.sendRedirect(redirectUrl + "?success=deactivated");
        } else {
            resp.sendRedirect(redirectUrl + "?error=deactivation_failed");
        }
    }

    public void deleteGroup(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String groupId = req.getParameter("groupId");
        adminUserService.deleteGroup(groupId);
        resp.sendRedirect(req.getContextPath() + "/admin/groups?success=deleted");
    }

    public void deleteAssignment(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String assignmentId = req.getParameter("assignmentId");
        adminUserService.deleteAssignment(assignmentId);
        resp.sendRedirect(req.getContextPath() + "/admin/assignments?success=deleted");
    }

    public void deleteSubmission(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String submissionId = req.getParameter("submissionId");
        adminUserService.deleteSubmission(submissionId);
        resp.sendRedirect(req.getContextPath() + "/admin/submissions?success=deleted");
    }
}