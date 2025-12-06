package com.lms.system.servlet.auth;

import com.lms.system.enums.UserRole;
import com.lms.system.model.Admin;
import com.lms.system.model.Student;
import com.lms.system.model.Teacher;
import com.lms.system.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import static com.lms.system.enums.UserRole.*;


@WebServlet({"/", "/login", "/register", "/logout"})
public class AuthServlet extends HttpServlet {
    AuthService authService;

    @Override
    public void init() throws ServletException {
        this.authService = (AuthService) getServletContext().getAttribute("authService");

        if (this.authService == null) {
            throw new ServletException("AuthService не инициализирован!");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        String userId = (String) req.getSession().getAttribute("userId");
        UserRole role = (UserRole) req.getSession().getAttribute("role");

        if ("/logout".equals(path)) {
            req.getSession().invalidate();
            HttpSession session = req.getSession();
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (role != null && userId != null) {
            switch (role) {
                case STUDENT -> {
                    resp.sendRedirect(req.getContextPath() + "/student/dashboard");
                    return;
                }
                case TEACHER -> {
                    resp.sendRedirect(req.getContextPath() + "/teacher/dashboard");
                    return;
                }
                case ADMIN -> {
                    resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                    return;
                }
            }
        }


        switch (path) {
            case "/" -> resp.sendRedirect(req.getContextPath() + "/login");
            case "/login" -> req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            case "/register" -> req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/login".equals(path)) {
            handleLogin(req, resp);
        }

        if ("/register".equals(path)) {
            handleRegister(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        Student student = authService.loginAsStudent(email, password);

        if (student != null) {
            createSession(req, student.getId(), student.getFullName(), STUDENT);
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        }

        Teacher teacher = authService.loginAsTeacher(email, password);

        if (teacher != null) {
            createSession(req, teacher.getId(), teacher.getFullName(), UserRole.TEACHER);
            resp.sendRedirect(req.getContextPath() + "/teacher/dashboard");
            return;
        }

        Admin admin = authService.loginAsAdmin(email, password);

        if (admin != null) {
            createSession(req, admin.getId(), admin.getFullName(), UserRole.ADMIN);
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        req.setAttribute("error", "Invalid email or password");
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String fullName = req.getParameter("fullName");
        String username = req.getParameter("username");
        String roleStr = req.getParameter("role");

        System.out.println(roleStr);

        try {
            UserRole role = UserRole.valueOf(roleStr.toUpperCase());

            System.out.println(role);

            if (role == STUDENT) {
                Student student = authService.registerStudent(email, password, fullName, username);
                System.out.println(student);
                createSession(req, student.getId(), student.getFullName(), STUDENT);
                resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            }

            if (role == UserRole.TEACHER) {
                String specialization = req.getParameter("specialization");
                Teacher teacher = authService.registerTeacher(email, password, fullName, username, specialization);

                createSession(req, teacher.getId(), teacher.getFullName(), UserRole.TEACHER);
                resp.sendRedirect(req.getContextPath() + "/teacher/dashboard");
            }
        }catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        }
    }

    private void createSession(HttpServletRequest req, String id, String fullName, UserRole userRole) {
        HttpSession session = req.getSession(true);
        session.setAttribute("userId", id);
        session.setAttribute("fullName", fullName);
        session.setAttribute("role", userRole);
        session.setAttribute("username", userRole);
    }

}
