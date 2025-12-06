package com.lms.system.service.student;


import com.lms.system.enums.SubmissionStatus;
import com.lms.system.model.Assignment;
import com.lms.system.model.Group;
import com.lms.system.model.Student;
import com.lms.system.model.Submission;
import com.lms.system.repository.AssignmentRepository;
import com.lms.system.repository.GroupRepository;
import com.lms.system.repository.StudentRepository;
import com.lms.system.repository.SubmissionRepository;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;


public class StudentService {
    private final StudentRepository studentRepository;
    private final SubmissionRepository submissionRepository;
    private final GroupRepository groupRepository;
    private final AssignmentRepository assignmentRepository;

    public StudentService(StudentRepository studentRepository,
                          SubmissionRepository submissionRepository,
                          GroupRepository groupRepository,
                          AssignmentRepository assignmentRepository) {
        this.studentRepository = studentRepository;
        this.submissionRepository = submissionRepository;
        this.groupRepository = groupRepository;
        this.assignmentRepository = assignmentRepository;
    }

    // ====================== PROFILE

    public Student getProfile(String id) {
        return studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Student not found"));
    }

    public Student updateProfile(String id, String fullName, String email) {
        Student student = getProfile(id);

        if (!student.getEmail().equals(email) && studentRepository.existsByEmail(email)) {
            throw new RuntimeException("Email already exists");
        }

        student.setFullName(fullName);
        student.setEmail(email);
        studentRepository.save(student);
        return student;
    }

    public void changePassword(String id, String oldPassword, String newPassword) {
        Student student = getProfile(id);

        if (!student.getPassword().equals(oldPassword)) {
            throw new RuntimeException("Password does not match");
        }

        student.setPassword(newPassword);
        studentRepository.save(student);
    }

    // ===================== GROUPS

    public List<Group> getMyGroups(String studentId) {
        return groupRepository.findByStudentIdWithStudents(studentId);
    }

    public void joinGroup(String id, String groupId) {
        Student student = getProfile(id);
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new RuntimeException("Group not found"));

        if (student.hasGroup(group)) {
            throw new RuntimeException("Student already in this group");
        }

        student.addGroup(group);
        group.addStudent(student);
    }

    public void leaveGroup(String id, String groupId) {
        Student student = getProfile(id);
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new RuntimeException("Group not found"));

        student.removeGroup(group);
        group.removeStudent(student);

        studentRepository.save(student);
        groupRepository.save(group);
    }

    // ASSIGNMENTS

    public List<Assignment> getGroupAssignments(String id, String groupId) {
        Student student = getProfile(id);

        if (student.getGroups().stream().noneMatch(group -> group.getId().equals(groupId))) {
            throw new RuntimeException("You are not in this group");
        }

        return assignmentRepository.findByGroupId(groupId);
    }

    public List<Assignment> getAllMyAssignments(String id) {
        System.out.println("\n→ StudentService.getAllMyAssignments()");
        System.out.println("  Student ID: " + id);

        List<Group> myGroups = getMyGroups(id);
        System.out.println("  My groups count: " + myGroups.size());

        if (myGroups.isEmpty()) {
            System.out.println("  ⚠️ No groups found for student!");
            return new ArrayList<>();
        }

        for (Group g : myGroups) {
            System.out.println("    - Group: " + g.getId() + " | " + g.getName());
        }

        List<Assignment> assignments = myGroups.stream()
                .flatMap(group -> {
                    System.out.println("\n  Fetching assignments for group: " + group.getId());
                    List<Assignment> groupAssignments = assignmentRepository.findByGroupId(group.getId());
                    System.out.println("  Found " + groupAssignments.size() + " assignments in this group");

                    for (Assignment a : groupAssignments) {
                        System.out.println("    → " + a.getId() + ": " + a.getTitle());
                    }

                    return groupAssignments.stream();
                })
                .distinct()
                .toList();

        System.out.println("\n  Total unique assignments: " + assignments.size());
        return assignments;
    }

    // SUBMISSIONS

    public List<Submission> getMySubmissions(String id) {
        Student student = getProfile(id);
        return studentRepository.getSubmissionsByStudent(student.getId());
    }

    public List<Submission> getSubmissionsForAssignment(String id, String assignmentId) {
        return studentRepository.getSubmissionsForStudentAndAssignment(id, assignmentId);
    }

    public Optional<Submission> getLatestSubmission(String id, String assignmentId) {
        return studentRepository.getLatestSubmissionForAssignment(id, assignmentId);
    }

    /**
     * Отправка задания студентом
     * ИСПРАВЛЕНО: убран вызов assignment.addSubmission() - избегаем LazyInitializationException
     */
    public Submission submitAssignment(String id, String assignmentId, String comment,
                                       String filePath, String fileName) {

        System.out.println("📤 StudentService.submitAssignment()");
        System.out.println("   Student ID: " + id);
        System.out.println("   Assignment ID: " + assignmentId);
        System.out.println("   Comment: " + (comment != null ? comment.substring(0, Math.min(50, comment.length())) : "null"));
        System.out.println("   File path: " + filePath);
        System.out.println("   File name: " + fileName);

        // 1. Получаем студента
        Student student = getProfile(id);

        // 2. Получаем задание
        Assignment assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new RuntimeException("Assignment not found"));

        // 3. Проверяем доступ
        boolean hasAccess = student.getGroups().stream()
                .anyMatch(g -> assignment.getGroups().contains(g));

        if (!hasAccess) {
            throw new RuntimeException("You don't have access to this assignment");
        }

        // 4. Проверяем дубликаты
        Optional<Submission> existing = submissionRepository.findByAssignmentAndStudent(assignmentId, id);
        if (existing.isPresent()) {
            throw new RuntimeException("You have already submitted this assignment");
        }

        // 5. Создаём Submission
        Submission submission = Submission.builder()
                .id(UUID.randomUUID().toString())
                .student(student)
                .assignment(assignment)
                .comment(comment)
                .filePath(filePath)
                .fileName(fileName)
                .submittedAt(LocalDateTime.now())
                .status(SubmissionStatus.SUBMITTED)
                .build();

        // 6. ВАЖНО: НЕ вызываем assignment.addSubmission()!
        // Это вызывает LazyInitializationException, т.к. коллекция submissions не загружена
        // JPA автоматически обновит связь при следующей загрузке благодаря mappedBy

        // ❌ БЫЛО (вызывало ошибку):
        // assignment.addSubmission(submission);

        // ✅ ПРАВИЛЬНО (просто сохраняем):
        submissionRepository.save(submission);

        System.out.println("   ✓ Submission saved:");
        System.out.println("     ID: " + submission.getId());
        System.out.println("     Status: " + submission.getStatus());
        System.out.println("     File name: " + submission.getFileName());

        return submission;
    }

    public Optional<Submission> getSubmissionById(String id) {
        return submissionRepository.findById(id);
    }

    // STATISTICS

    public long getTotalSubmissionsCount(String id) {
        return getMySubmissions(id).size();
    }

    public long getGroupsCount(String id) {
        return getMyGroups(id).size();
    }

    public long getPendingSubmissionsCount(String id) {
        return getAllMyAssignments(id).stream()
                .filter(a -> !a.isOverdue() && getLatestSubmission(id, a.getId()).isEmpty())
                .count();
    }
}
