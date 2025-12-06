package com.lms.system.service.teacher;

import com.lms.system.enums.UserRole;
import com.lms.system.model.*;
import com.lms.system.repository.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class TeacherService {
    private final TeacherRepository teacherRepository;
    private final GroupRepository groupRepository;
    private final AssignmentRepository assignmentRepository;
    private final SubmissionRepository submissionRepository;
    private final StudentRepository studentRepository;
    private final AdminRepository adminRepository;


    public TeacherService(TeacherRepository teacherRepository, GroupRepository groupRepository, AssignmentRepository assignmentRepository, SubmissionRepository submissionRepository, StudentRepository studentRepository, AdminRepository adminRepository) {
        this.teacherRepository = teacherRepository;
        this.groupRepository = groupRepository;
        this.assignmentRepository = assignmentRepository;
        this.submissionRepository = submissionRepository;
        this.studentRepository = studentRepository;
        this.adminRepository = adminRepository;
    }

    // ======================================= PROFILE


    public Teacher updateProfile(String id, String fullName, String specialization) {
        Teacher teacher = getProfile(id);

        teacher.setFullName(fullName);
        teacher.setSpecialization(specialization);
        teacherRepository.save(teacher);
        return teacher;
    }

    public Teacher getProfile(String id) {
        return teacherRepository.findByIdWithGroups(id)
                .orElseThrow(() -> new RuntimeException("Teacher not found"));
    }

    public List<Group> getMyGroups(String id) {
        // Используем новый метод с инициализированными студентами
        return groupRepository.findByTeacherIdWithStudents(id);
    }

    public List<Assignment> getMyAssignments(String teacherId) {
        // Используем новый метод с инициализированными группами
        return assignmentRepository.findByCreatorIdWithGroups(teacherId);
    }

    public Map<String, Long> getSubmissionCountsForAssignments(List<Assignment> assignments) {
        Map<String, Long> counts = new HashMap<>();

        for (Assignment assignment : assignments) {
            long count = assignmentRepository.getSubmissionCount(assignment.getId());
            counts.put(assignment.getId(), count);
        }

        return counts;
    }

    // ================================ GROUPS MANAGEMENT

    public void createGroup(String id, String name, String description) {
        Teacher teacher = getProfile(id);

        if (teacher == null) throw new RuntimeException("Teacher not found");

        Group group = Group.builder()
                .name(name)
                .description(description)
                .createdAt(LocalDateTime.now())
                .build();

        group.getTeachers().add(teacher);
        teacher.getGroups().add(group);
        groupRepository.save(group);
    }

    public Group updateGroup(String teacherId, String groupId, String name, String description) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new RuntimeException("Group not found"));

        if (group.getTeachers().stream().noneMatch(teacher -> teacher.getId().equals(teacherId))) {
            throw new RuntimeException("Access denied. You are not a teacher of this group.");
        }

        group.setName(name);
        group.setDescription(description);
        groupRepository.save(group);

        return group;
    }

    public void deleteGroup(String teacherId, String groupId) {
        validateGroupAccess(teacherId, groupId);
        groupRepository.delete(groupId);
    }

    public void addStudentToGroup(String teacherId, String groupId, String studentId) {
        Group group = validateGroupAccess(teacherId, groupId);
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        group.addStudent(student);
        student.addGroup(group);
        groupRepository.save(group);
    }

    public void removeStudentFromGroup(String teacherId, String groupId, String studentId) {
        Group group = validateGroupAccess(teacherId, groupId);
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        group.removeStudent(student);
        groupRepository.save(group);
    }

    public List<Student> getStudentsInGroup(String teacherId, String groupId) {
        validateGroupAccess(teacherId, groupId);
        return studentRepository.findByGroupId(groupId);
    }

    public List<Group> getMyGroupsWithAllData(String teacherId) {
        return groupRepository.findByTeacherIdWithAllData(teacherId);
    }


    // ======================= ASSIGNMENTS MANAGEMENT

    // В TeacherService
    public Group getGroupWithAssignments(String teacherId, String groupId) {
        validateGroupAccess(teacherId, groupId);
        return groupRepository.findByIdWithAllData(groupId)
                .orElseThrow(() -> new RuntimeException("Group not found"));
    }



    public Assignment getAssignmentById(String teacherId, String assignmentId) {
        Assignment assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new RuntimeException("Assignment not found"));

        // Сначала проверяем, является ли пользователь админом
        User admin = adminRepository.findById(teacherId).orElse(null);
        if (admin != null && admin.getRole() == UserRole.ADMIN) {
            return assignment;
        }

        // Если не админ, проверяем как учителя
        Teacher teacher = teacherRepository.findById(teacherId).orElse(null);

        if (teacher == null) {
            throw new RuntimeException("User not found");
        }

        // Проверяем, что учитель - создатель задания
        if (assignment.getCreator() != null &&
                assignment.getCreator().getId().equals(teacherId)) {
            return assignment;
        }

        // ИЛИ учитель в списке рецензентов
        if (assignment.getReviewers() != null) {
            boolean isReviewer = assignment.getReviewers().stream()
                    .anyMatch(r -> r.getId().equals(teacherId));
            if (isReviewer) {
                return assignment;
            }
        }

        // ИЛИ учитель преподает в одной из групп этого задания
        if (assignment.getGroups() != null) {
            boolean teachesInGroup = assignment.getGroups().stream()
                    .anyMatch(group -> {
                        if (group.getTeachers() != null) {
                            return group.getTeachers().stream()
                                    .anyMatch(t -> t.getId().equals(teacherId));
                        }
                        return false;
                    });
            if (teachesInGroup) {
                return assignment;
            }
        }

        throw new RuntimeException("Access denied: you cannot view this assignment");
    }

    public Assignment createAssignment(String teacherId, String title, String description,
                                       LocalDateTime deadline, Integer maxScore,
                                       List<String> groupIds,
                                       String fileName, String filePath, Long fileSize) {

        // Валидация
        if (groupIds == null || groupIds.isEmpty()) {
            throw new RuntimeException("At least one group must be selected");
        }

        // Проверяем существование учителя
        Teacher teacher = getProfile(teacherId);

        // Проверяем доступ ко всем группам ДО создания assignment
        for (String groupId : groupIds) {
            Group group = groupRepository.findById(groupId)
                    .orElseThrow(() -> new RuntimeException("Group not found: " + groupId));

            if (group.getTeachers().stream().noneMatch(t -> t.getId().equals(teacherId))) {
                throw new RuntimeException("Access denied to group: " + group.getName());
            }
        }

        // Создаём assignment объект
        Assignment assignment = Assignment.builder()
                .title(title)
                .description(description)
                .dueDate(deadline)
                .maxScore(maxScore)
                .creator(teacher)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .fileName(fileName)
                .filePath(filePath)
                .fileSize(fileSize)
                .build();

        // Добавляем группы (detached объекты)
        for (String groupId : groupIds) {
            Group group = groupRepository.findById(groupId)
                    .orElseThrow(() -> new RuntimeException("Group not found: " + groupId));
            assignment.getGroups().add(group);
        }

        // Сохраняем через универсальный save
        assignmentRepository.save(assignment);

        return assignment;
    }

    public Assignment updateAssignment(String teacherId, String assignmentId, String title, String description, LocalDateTime deadline, Integer maxScore) {
        Assignment assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new RuntimeException("Assignment not found"));

        if (!assignment.getCreator().getId().equals(teacherId)) {
            throw new RuntimeException("Access denied. You are not a creator of this assignment.");
        }

        assignment.setTitle(title);
        assignment.setDescription(description);
        assignment.setDueDate(deadline);
        assignment.setMaxScore(maxScore);
        assignment.setUpdatedAt(LocalDateTime.now());

        assignmentRepository.save(assignment);
        return assignment;
    }

    public void deleteAssignment(String teacherId, String assignmentId) {
        Assignment assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new RuntimeException("Assignment not found"));

        if (!assignment.getCreator().getId().equals(teacherId)) {
            throw new RuntimeException("Access denied. You are not a creator of this assignment.");
        }

        assignmentRepository.delete(assignmentId);
    }

    public void addGroupToAssignment(String teacherId, String groupId, String assignmentId) {
        Assignment assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new RuntimeException("Assignment not found"));

        if (!assignment.canReview(getProfile(teacherId))) {
            throw new RuntimeException("Access denied. You are not a creator of this assignment.");
        }

        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new RuntimeException("Group not found"));

        assignment.getGroups().add(group);
        assignmentRepository.save(assignment);
    }


    // ======================== SUBMISSIONS REVIEW

    public List<Submission> getSubmissionsForAssignment(String teacherId, String assignmentId) {
        System.out.println("\n>>> TeacherService.getSubmissionsForAssignment");
        System.out.println("    Teacher ID: " + teacherId);
        System.out.println("    Assignment ID: " + assignmentId);

        // Проверяем доступ
        Assignment assignment = getAssignmentById(teacherId, assignmentId);
        System.out.println("    Assignment: " + assignment.getTitle());

        // Получаем submissions через репозиторий
        List<Submission> submissions = assignmentRepository.getSubmissionsForAssignment(assignmentId);
        System.out.println("    Found submissions: " + submissions.size());

        return submissions;
    }

    public Submission gradeSubmission(String teacherId, String submissionId, Integer grade, String feedback) {
        Submission submission = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new RuntimeException("Submission not found"));

        Assignment assignment = submission.getAssignment();
        Teacher teacher = getProfile(teacherId);

        if (!assignment.canReview(teacher)) {
            throw new RuntimeException("Access denied. You are not a creator of this assignment.");
        }

        if (assignment.getMaxScore() != null && grade > assignment.getMaxScore()) {
            throw new RuntimeException("Max score is greater than max score");
        }

        submission.setScore(grade);
        submission.setComment(feedback);
        submission.setSubmittedAt(LocalDateTime.now());
        submission.setReviewer(teacher);

        submissionRepository.save(submission);
        return submission;
    }

    // ========================= STATISTICS

    public long getTotalStudentsCount(String teacherId) {
        return getMyGroups(teacherId).size();
    }

    public long getTotalAssignmentsCount(String teacherId) {
        return getMyAssignments(teacherId).size();
    }

    public long getPendingAssignmentsCount(String teacherId) {
        return getMyAssignments(teacherId).size();
    }

    public long getTotalGroupsCount(String teacherId) {
        return getMyGroups(teacherId).size();
    }

    // ================ HELPER

    public Group validateGroupAccess(String teacherId, String groupId) {
        Group group = groupRepository.findByIdWithTeachers(groupId)  // ← Новый метод
                .orElseThrow(() -> new RuntimeException("Group not found"));

        if (group.getTeachers().stream().noneMatch(teacher -> teacher.getId().equals(teacherId))) {
            throw new RuntimeException("Access denied. You are not a teacher of this group.");
        }

        return group;
    }

}
