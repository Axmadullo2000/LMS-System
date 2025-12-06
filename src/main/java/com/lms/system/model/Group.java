package com.lms.system.model;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Entity
@Table(name = "groups")
@SuperBuilder
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = {"students", "teachers", "assignments"})
public class Group {

    @Id
    @Column(name = "id", updatable = false, nullable = false)
    private String id;

    @Column(name = "group_name", nullable = false)
    private String name;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "created_at", updatable = false, nullable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    @Builder.Default
    private LocalDateTime updatedAt = LocalDateTime.now();

    // Студенты в группе
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "group_students",  // ← Оставил как есть
            joinColumns = @JoinColumn(name = "group_id"),
            inverseJoinColumns = @JoinColumn(name = "student_id")
    )
    @Builder.Default
    private Set<Student> students = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "group_teachers",
            joinColumns = @JoinColumn(name = "group_id"),
            inverseJoinColumns = @JoinColumn(name = "teacher_id")
    )
    @Builder.Default
    private Set<Teacher> teachers = new HashSet<>();

    @ManyToMany(mappedBy = "groups", fetch = FetchType.LAZY)
    @Builder.Default
    private Set<Assignment> assignments = new HashSet<>();

    @PrePersist
    protected void onCreate() {
        if (id == null || id.isBlank()) {
            id = UUID.randomUUID().toString();
        }
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public int getStudentsCount() {
        return students != null ? students.size() : 0;
    }

    public boolean addStudent(Student student) {
        if (student != null && !students.contains(student)) {
            students.add(student);
            student.getGroups().add(this);
            return true;
        }
        return false;
    }

    public boolean removeStudent(Student student) {
        if (student != null && this.students.remove(student)) {
            student.getGroups().remove(this);
            return true;
        }
        return false;
    }

    public boolean addTeacher(Teacher teacher) {
        if (teacher != null && !teachers.contains(teacher)) {
            teachers.add(teacher);
            teacher.getGroups().add(this);
            return true;
        }

        return false;
    }

    public boolean removeTeacher(Teacher teacher) {
        if (teachers.remove(teacher)) {
            teacher.getGroups().remove(this);
            return true;
        }
        return false;
    }

    public boolean addAssignment(Assignment assignment) {
        if (assignment != null && !assignments.contains(assignment)) {
            assignments.add(assignment);
            assignment.getGroups().add(this);  // ← ИСПРАВЛЕНО: было дублирование
            return true;
        }

        return false;
    }

    public boolean removeAssignment(Assignment assignment) {
        if (assignments.remove(assignment)) {
            assignment.getGroups().remove(this);  // ← ИСПРАВЛЕНО: было дублирование
            return true;
        }

        return false;
    }

    public String getFormattedCreatedAt() {
        if (this.createdAt == null) {
            return "N/A";
        }

        return this.createdAt.format(DateTimeFormatter.ofPattern("dd MMM yyyy"));
    }

    public String getFormattedUpdatedAt() {
        if (this.updatedAt == null) {
            return "N/A";
        }

        return this.updatedAt.format(DateTimeFormatter.ofPattern("dd MMM yyyy"));
    }

}
