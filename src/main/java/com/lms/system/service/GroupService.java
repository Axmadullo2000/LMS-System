package com.lms.system.service;

import com.lms.system.model.Assignment;
import com.lms.system.model.Group;
import com.lms.system.model.Student;
import com.lms.system.repository.AssignmentRepository;
import com.lms.system.repository.GroupRepository;
import com.lms.system.repository.StudentRepository;
import com.lms.system.repository.TeacherRepository;

import java.time.LocalDateTime;
import java.util.List;

public class GroupService {
    private final GroupRepository groupRepository;
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final AssignmentRepository assignmentRepository;

    public GroupService(GroupRepository groupRepository, StudentRepository studentRepository, TeacherRepository teacherRepository, AssignmentRepository assignmentRepository) {
        this.groupRepository = groupRepository;
        this.studentRepository = studentRepository;
        this.teacherRepository = teacherRepository;
        this.assignmentRepository = assignmentRepository;
    }

    public Group getGroupById(String id) {
        return groupRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Group not found"));
    }

    public List<Group> getAllGroups() {
        return groupRepository.findAll();
    }

    public Group createGroup(String name, String description) {
        Group group = Group.builder()
                .name(name)
                .description(description)
                .createdAt(LocalDateTime.now())
                .build();

        groupRepository.save(group);
        return group;
    }

    public Group updateGroup(String id, String name, String description) {
        Group group = getGroupById(id);
        group.setName(name);
        group.setDescription(description);
        groupRepository.save(group);
        return group;
    }

    public void deleteGroup(String id) {
        Group group = getGroupById(id);
        groupRepository.delete(group.getId());
    }

    public List<Student> getStudents(String id) {
        return studentRepository.findByGroupId(id);
    }

    public List<Assignment> getAssignments(String id) {
        return assignmentRepository.findByGroupId(id);
    }

    public long getStudentsCount(String groupId) {
        return studentRepository.findByGroupId(groupId).size();
    }

}
