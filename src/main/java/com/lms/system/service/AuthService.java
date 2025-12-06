package com.lms.system.service;

import com.lms.system.model.Admin;
import com.lms.system.model.Student;
import com.lms.system.model.Teacher;
import com.lms.system.repository.AdminRepository;
import com.lms.system.repository.StudentRepository;
import com.lms.system.repository.TeacherRepository;
import com.lms.system.service.student.StudentService;
import com.lms.system.service.teacher.TeacherService;
import lombok.SneakyThrows;

import java.util.Optional;
import java.util.UUID;

import static com.lms.system.enums.UserRole.STUDENT;
import static com.lms.system.enums.UserRole.TEACHER;

public class AuthService {
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final AdminRepository adminRepository;
    private StudentService studentService;
    private TeacherService teacherService;

    public AuthService(StudentRepository studentRepository, TeacherRepository teacherRepository, AdminRepository adminRepository) {
        this.studentRepository = studentRepository;
        this.teacherRepository = teacherRepository;
        this.adminRepository = adminRepository;
    }

    public Student loginAsStudent(String email, String password) {
        Optional<Student> student = studentRepository.findByEmail(email);
        if (student.isPresent() && student.get().getPassword().equals(password)) {
            return student.get();
        }

        return null;
    }

    public Teacher loginAsTeacher(String email, String password) {
        Optional<Teacher> teacher = teacherRepository.findByEmail(email);

        if (teacher.isPresent() && teacher.get().getPassword().equals(password)) {
            return teacher.get();
        }

        return null;
    }

    public Admin loginAsAdmin(String email, String password) {
        Optional<Admin> admin = adminRepository.findByEmail(email);

        if (admin.isPresent() && admin.get().getPassword().equals(password)) {
            return admin.get();
        }

        return null;
    }

    public Student registerStudent(String email, String password, String fullName, String username) {
        if (emailExists(email)) {
            throw new RuntimeException("Email already exists");
        }

        Student student = Student.builder()
                .id(UUID.randomUUID().toString())
                .role(STUDENT)
                .email(email)
                .password(password)
                .fullName(fullName)
                .userName(username)
                .active(true)
                .build();

        studentRepository.save(student);
        return student;
    }

    public Teacher registerTeacher(String email, String password, String fullName, String username, String specialization) {
        if (emailExists(email)) {
            throw new RuntimeException("Email already exists");
        }

        Teacher teacher = Teacher.builder()
                .id(UUID.randomUUID().toString())
                .role(TEACHER)
                .email(email)
                .password(password)
                .fullName(fullName)
                .userName(username)
                .specialization(specialization)
                .active(true)
                .build();

        teacherRepository.save(teacher);
        return teacher;
    }

    private boolean emailExists(String email) {
        return studentRepository.existsByEmail(email)
                || teacherRepository.existsByEmail(email)
                || adminRepository.existsByEmail(email);
    }

    @SneakyThrows
    public void setStudentService(StudentService studentService) {
        this.studentService = studentService;
    }

    @SneakyThrows
    public void setTeacherService(TeacherService teacherService) {
        this.teacherService = teacherService;
    }

}
