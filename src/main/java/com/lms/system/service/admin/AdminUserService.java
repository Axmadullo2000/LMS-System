package com.lms.system.service.admin;

import com.lms.system.enums.UserRole;
import com.lms.system.model.*;
import com.lms.system.repository.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.UUID;

public class AdminUserService {
    private final AdminRepository adminRepository;
    private final TeacherRepository teacherRepository;
    private final StudentRepository studentRepository;
    private final GroupRepository groupRepository;
    private final AssignmentRepository assignmentRepository;
    private final SubmissionRepository submissionRepository;

    public AdminUserService(AdminRepository adminRepository, TeacherRepository teacherRepository, StudentRepository studentRepository, GroupRepository groupRepository, AssignmentRepository assignmentRepository, SubmissionRepository submissionRepository) {
        this.adminRepository = adminRepository;
        this.teacherRepository = teacherRepository;
        this.studentRepository = studentRepository;
        this.groupRepository = groupRepository;
        this.assignmentRepository = assignmentRepository;
        this.submissionRepository = submissionRepository;
    }

    // =========================== USER MANAGEMENT

    public List<Student> getAllStudents() {
        return studentRepository.findAll();
    }

    public List<Teacher> getAllTeachers() {
        return teacherRepository.findAll();
    }

    public List<Admin> getAllAdmins() {
        return adminRepository.findAll();
    }

    public Student getStudentById(String id) {
        return studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Student not found"));
    }

    public Teacher getTeacherById(String id) {
        return teacherRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Teacher not found"));
    }

    public Admin getAdminById(String id) {
        return adminRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Admin not found"));
    }

    // ============================ CREATE USERS

    public Teacher createTeacher(String email, String password, String fullName, String specialization) {
        if (emailExists(email)) throw new RuntimeException("Email already exists");

        Teacher teacher = Teacher.builder()
                .id(UUID.randomUUID().toString())
                .email(email)
                .password(password)
                .fullName(fullName)
                .specialization(specialization)
                .role(UserRole.TEACHER)
                .active(true)
                .groups(new ArrayList<>())
                .createdAssignments(new ArrayList<>())
                .reviewingAssignments(new ArrayList<>())
                .build();

        teacherRepository.save(teacher);
        return teacher;
    }

    public Student createStudent(String email, String password, String fullName) {
        if (emailExists(email)) throw new RuntimeException("Email already exists");

        Student student = Student.builder()
                .id(UUID.randomUUID().toString())
                .email(email)
                .password(password)
                .fullName(fullName)
                .role(UserRole.STUDENT)
                .active(true)
                .groups(new ArrayList<>())
                .submissions(new ArrayList<>())
                .build();

        studentRepository.save(student);
        return student;
    }

    public Admin createAdmin(String email, String password, String fullName) {
        if (emailExists(email)) throw new RuntimeException("Email already exists");

        Admin admin = Admin.builder()
                .id(UUID.randomUUID().toString())
                .email(email)
                .password(password)
                .fullName(fullName)
                .role(UserRole.ADMIN)
                .active(true)
                .build();

        adminRepository.save(admin);
        return admin;
    }

    // ==================== USER STATUS

    public boolean activateStudent(String id) {
        return studentRepository.activate(id);
    }

    public boolean deactivateStudent(String id) {
        return studentRepository.deactivate(id);
    }

    public boolean activateTeacher(String id) {
        return teacherRepository.activate(id);
    }

    public boolean deactivateTeacher(String id) {
        return teacherRepository.deactivate(id);
    }

    public boolean activateAdmin(String id) {
        return adminRepository.activate(id);
    }

    public boolean deactivateAdmin(String id) {
        return adminRepository.deactivate(id);
    }

    // ==================================== SEARCH

    public List<Student> searchStudentsByName(String name) {
        return studentRepository.findAll().stream()
                .filter(s -> s.getFullName().toLowerCase().contains(name.toLowerCase()))
                .toList();
    }

    public List<Teacher> searchTeachersByName(String name) {
        return teacherRepository.findByName(name);
    }

    // ============================== GROUP MANAGEMENT

    public List<Group> getAllGroups() {
        return groupRepository.findAll();
    }

    public Group getGroupById(String groupId) {
        return groupRepository.findById(groupId)
                .orElseThrow(() -> new RuntimeException("Group not found"));
    }

    public void deleteGroup(String groupId) {
        groupRepository.delete(groupId);
    }

    public void addTeacherToGroup(String groupId, String teacherId) {
        Group group = groupRepository.findById(groupId).orElseThrow();
        Teacher teacher = teacherRepository.findById(teacherId).orElseThrow();
        teacher.getGroups().add(group);
        groupRepository.save(group);
    }

    public void addStudentsToGroup(String groupId, List<String> studentIds) {
        Group group = groupRepository.findById(groupId).orElseThrow();
        studentIds.forEach(id -> {
            Student s = studentRepository.findById(id).orElseThrow();
            s.getGroups().add(group);           // owning side — Student
            // group.getStudents().add(s);      // можно, если хочешь поддерживать обе стороны
        });
        groupRepository.save(group); // или studentRepository.save() — достаточно одного
    }

    public void removeTeacherFromGroup(String groupId, String teacherId) {
        Group group = getGroupById(groupId);
        Teacher teacher = getTeacherById(teacherId);

        group.removeTeacher(teacher);
        groupRepository.save(group);
    }



    // ================================ Assignment Management

    public List<Assignment> getAllAssignments() {
        return assignmentRepository.findAll();
    }

    public Assignment getAssignmentById(String assignmentId) {
        return assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new RuntimeException("Assignment not found"));
    }

    public void deleteAssignment(String assignmentId) {
        assignmentRepository.delete(assignmentId);
    }

    public List<Assignment> getUpcomingAssignments(int days) {
        return assignmentRepository.findUpcomingAssignments(days);
    }

    public List<Assignment> getExpiredAssignments() {
        return assignmentRepository.findExpiredAssignments();
    }


    // ============================== SUBMISSION MANAGEMENT

    public List<Submission> getAllSubmissions() {
        return submissionRepository.findAll();
    }

    public void deleteSubmission(String submissionId) {
        submissionRepository.delete(submissionId);
    }

    // ========================= STATISTICS

    public long getTotalStudentsCount() {
        return studentRepository.count();
    }

    public long getTotalTeachersCount() {
        return teacherRepository.findAll().size();
    }

    public long getActiveTeachersCount() {
        return teacherRepository.countActiveTeachers();
    }

    public long getTotalGroupsCount() {
        return groupRepository.count();
    }

    public long getTotalAssignmentsCount() {
        return assignmentRepository.findAll().size();
    }

    public long getTotalSubmissionsCount() {
        return submissionRepository.findAll().size();
    }

    public long getPendingSubmissionsCount() {
        return submissionRepository.findPendingGrading().size();
    }

    // ======================== HELPER

    private boolean emailExists(String email) {
        return adminRepository.existsByEmail(email)
                || teacherRepository.existsByEmail(email)
                || studentRepository.existsByEmail(email);
    }

    public void createGroup(String name, String description) {
        Group group = Group.builder()
                .id(UUID.randomUUID().toString())
                .name(name)
                .description(description)
                .students(new HashSet<>())
                .teachers(new HashSet<>())
                .assignments(new HashSet<>())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        groupRepository.save(group);
    }
}
