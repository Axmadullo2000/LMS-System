package com.lms.system.service.admin;


import com.lms.system.model.Group;
import com.lms.system.model.Student;
import com.lms.system.model.Teacher;
import com.lms.system.repository.GroupRepository;
import com.lms.system.repository.StudentRepository;
import com.lms.system.repository.TeacherRepository;
import jakarta.transaction.Transactional;

import java.util.*;

public class AdminGroupService {
    private final GroupRepository groupRepository;
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    public AdminGroupService(GroupRepository groupRepository,
                             StudentRepository studentRepository,
                             TeacherRepository teacherRepository) {
        this.groupRepository = groupRepository;
        this.studentRepository = studentRepository;
        this.teacherRepository = teacherRepository;
    }

    /**
     * Получить группу со всеми связанными данными (students, teachers, assignments)
     */
    public Map<String, Object> getGroupWithStatistics(String groupId) {
        return groupRepository.findGroupWithStatistics(groupId);
    }

    /**
     * Получить студентов, которые НЕ состоят в данной группе
     */
    public List<Student> getAvailableStudents(String groupId) {
        return studentRepository.findStudentsNotInGroup(groupId);
    }

    /**
     * Получить учителей, которые НЕ состоят в данной группе
     */
    public Set<Teacher> getAvailableTeachers(String groupId) {
        return teacherRepository.findTeachersNotInGroup(groupId);
    }

    /**
     * Добавить студентов в группу (массовое добавление)
     */
    @Transactional
    public void addStudentsToGroup(String groupId, List<String> studentIds) {
        if (studentIds == null || studentIds.isEmpty()) {
            throw new IllegalArgumentException("Student IDs list cannot be empty");
        }

        Group group = groupRepository.findByIdWithStudents(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Group not found: " + groupId));

        for (String studentId : studentIds) {
            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new IllegalArgumentException("Student not found: " + studentId));

            // Работаем только со стороны владельца
            if (!group.getStudents().contains(student)) {
                group.getStudents().add(student);
            }
        }

        groupRepository.save(group);
    }

    /**
     * Добавить одного учителя в группу
     */
    public void addTeacherToGroup(String groupId, String teacherId) {
        if (teacherId == null || teacherId.trim().isEmpty()) {
            throw new IllegalArgumentException("Teacher ID cannot be empty");
        }

        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Group not found: " + groupId));

        Teacher teacher = teacherRepository.findById(teacherId)
                .orElseThrow(() -> new IllegalArgumentException("Teacher not found: " + teacherId));

        // Инициализируем коллекцию учителей, если null
        if (group.getTeachers() == null) {
            group.setTeachers(new HashSet<>());
        }

        // Проверяем, не добавлен ли уже учитель
        if (group.getTeachers().contains(teacher)) {
            throw new IllegalStateException("Teacher already assigned to this group");
        }

        // Двусторонняя связь
        group.getTeachers().add(teacher);

        if (teacher.getGroups() == null) {
            teacher.setGroups(new ArrayList<>());
        }
        teacher.getGroups().add(group);

        // Сохраняем обе стороны
        teacherRepository.save(teacher);
        groupRepository.save(group);
    }

    /**
     * Удалить учителя из группы
     */
    public void removeTeacherFromGroup(String groupId, String teacherId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("Group not found: " + groupId));

        Teacher teacher = teacherRepository.findById(teacherId)
                .orElseThrow(() -> new IllegalArgumentException("Teacher not found: " + teacherId));

        // Удаляем двустороннюю связь
        if (group.getTeachers() != null) {
            group.getTeachers().remove(teacher);
        }

        if (teacher.getGroups() != null) {
            teacher.getGroups().remove(group);
        }

        // Сохраняем изменения
        teacherRepository.save(teacher);
        groupRepository.save(group);
    }

}