package com.lms.system.listeners;

import com.lms.system.model.Admin;
import com.lms.system.repository.*;
import com.lms.system.service.*;
import com.lms.system.service.admin.AdminGroupService;
import com.lms.system.service.admin.AdminUserService;
import com.lms.system.service.student.StudentService;
import com.lms.system.service.teacher.TeacherService;
import com.lms.system.util.JPAUtil;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.io.File;
import java.util.UUID;

import static com.lms.system.enums.UserRole.ADMIN;


@WebListener
public class ApplicationInitializer implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            JPAUtil.initialize("MOODLE_LMS");

            // ========== Инициализация репозиториев ==========
            AdminRepository adminRepository = AdminRepository.getInstance();
            StudentRepository studentRepository = StudentRepository.getInstance();
            TeacherRepository teacherRepository = TeacherRepository.getInstance();
            GroupRepository groupRepository = GroupRepository.getInstance();
            AssignmentRepository assignmentRepository = AssignmentRepository.getInstance();
            SubmissionRepository submissionRepository = SubmissionRepository.getInstance();

            createDefaultAdminIfNeeded(adminRepository);

            // ========== Настройка файловой системы ==========
            String realPath = sce.getServletContext().getRealPath("/");
            String uploadPath = realPath + File.separator + "uploads";

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            FileService fileService = new FileService(uploadPath);
            System.out.println("✓ File service initialized");

            // ========== Инициализация сервисов ==========
            AuthService authService = new AuthService(
                    studentRepository,
                    teacherRepository,
                    adminRepository
            );

            StudentService studentService = new StudentService(
                    studentRepository,
                    submissionRepository,
                    groupRepository,
                    assignmentRepository
            );

            TeacherService teacherService = new TeacherService(
                    teacherRepository,
                    groupRepository,
                    assignmentRepository,
                    submissionRepository,
                    studentRepository,
                    adminRepository
            );

            AdminUserService adminUserService = new AdminUserService(
                    adminRepository,
                    teacherRepository,
                    studentRepository,
                    groupRepository,
                    assignmentRepository,
                    submissionRepository
            );

            // ========== НОВЫЙ СЕРВИС: AdminGroupService ==========
            AdminGroupService adminGroupService = new AdminGroupService(
                    groupRepository,
                    studentRepository,
                    teacherRepository
            );
            System.out.println("✓ AdminGroupService initialized");

            AssignmentService assignmentService = new AssignmentService(
                    assignmentRepository,
                    submissionRepository
            );

            GroupService groupService = new GroupService(
                    groupRepository,
                    studentRepository,
                    teacherRepository,
                    assignmentRepository
            );

            SubmissionService submissionService = new SubmissionService(
                    submissionRepository,
                    studentRepository,
                    assignmentRepository
            );

            // ========== Настройка зависимостей ==========
            authService.setStudentService(studentService);
            authService.setTeacherService(teacherService);

            // ========== Регистрация в контексте ==========

            // Сервисы
            sce.getServletContext().setAttribute("authService", authService);
            sce.getServletContext().setAttribute("fileService", fileService);
            sce.getServletContext().setAttribute("studentService", studentService);
            sce.getServletContext().setAttribute("teacherService", teacherService);
            sce.getServletContext().setAttribute("adminUserService", adminUserService);
            sce.getServletContext().setAttribute("adminGroupService", adminGroupService);
            sce.getServletContext().setAttribute("assignmentService", assignmentService);
            sce.getServletContext().setAttribute("groupService", groupService);
            sce.getServletContext().setAttribute("submissionService", submissionService);

            // Репозитории (ДОБАВЛЕНО для FileDownloadServlet)
            sce.getServletContext().setAttribute("adminRepository", adminRepository);
            sce.getServletContext().setAttribute("teacherRepository", teacherRepository);
            sce.getServletContext().setAttribute("studentRepository", studentRepository);
            sce.getServletContext().setAttribute("groupRepository", groupRepository);
            sce.getServletContext().setAttribute("assignmentRepository", assignmentRepository);
            sce.getServletContext().setAttribute("submissionRepository", submissionRepository);

            System.out.println("✅ Application initialized successfully");
            System.out.println("✅ Services registered: 9");
            System.out.println("✅ Repositories registered: 6");

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to initialize application", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        JPAUtil.close();
        System.out.println("✓ Application context destroyed");
    }

    private void createDefaultAdminIfNeeded(AdminRepository adminRepo) {
        if (adminRepo.count() == 0) {
            Admin admin = Admin.builder()
                    .id(UUID.randomUUID().toString())
                    .role(ADMIN)
                    .email("admin@lms.com")
                    .password("admin123") // TODO: Use BCrypt
                    .fullName("System Administrator")
                    .active(true)
                    .build();

            adminRepo.save(admin);
            System.out.println("✓ Default admin created: admin@lms.com");
        } else {
            System.out.println("✓ Admin already exists");
        }
    }
}
