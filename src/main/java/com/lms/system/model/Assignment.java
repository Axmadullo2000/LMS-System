package com.lms.system.model;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "assignments")
@SuperBuilder
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = {"groups", "submissions", "creator", "reviewers"})
public class Assignment {
    @Id
    @Column(name = "id", updatable = false, nullable = false)
    private String id;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "due_date")
    private LocalDateTime dueDate;

    @Column(name = "max_score")
    private Integer maxScore;

    @Column(name = "file_name")
    private String fileName;

    @Column(name = "file_path")
    private String filePath;

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "created_at", updatable = false, nullable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    @Builder.Default
    private LocalDateTime updatedAt = LocalDateTime.now();

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "assignment_groups",
            joinColumns = @JoinColumn(name = "assignment_id"),
            inverseJoinColumns = @JoinColumn(name = "group_id")
    )
    @Builder.Default
    private List<Group> groups = new ArrayList<>();

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "creator_id")
    private Teacher creator;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "assignment_reviewers",
            joinColumns = @JoinColumn(name = "assignment_id"),
            inverseJoinColumns = @JoinColumn(name = "teacher_id")
    )
    @Builder.Default
    private List<Teacher> reviewers = new ArrayList<>();

    @OneToMany(mappedBy = "assignment")
    @Builder.Default
    private List<Submission> submissions = new ArrayList<>();

    @Transient
    private String dueDateFormatted;

    @PrePersist
    protected void onCreate() {
        if (id == null || id.isBlank()) {
            id = java.util.UUID.randomUUID().toString();
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

    // ИСПРАВЛЕНО: добавлена проверка на null
    public boolean isOverdue() {
        return dueDate != null && LocalDateTime.now().isAfter(dueDate);
    }

    // Дополнительный метод для проверки активности
    public boolean isActive() {
        return dueDate != null && LocalDateTime.now().isBefore(dueDate);
    }

    public boolean hasFile() {
        return fileName != null && filePath != null;
    }

    // Вспомогательные методы для работы с группами
    public void addGroup(Group group) {
        if (group != null && !groups.contains(group)) {
            groups.add(group);
            group.getAssignments().add(this);
        }
    }

    public void removeGroup(Group group) {
        if (groups.remove(group)) {
            group.getAssignments().remove(this);
        }
    }

    // Вспомогательные методы для работы с рецензентами
    public void addReviewer(Teacher teacher) {
        if (teacher != null && !reviewers.contains(teacher)) {
            reviewers.add(teacher);
            teacher.getReviewingAssignments().add(this);
        }
    }

    public void removeReviewer(Teacher teacher) {
        if (reviewers.remove(teacher)) {
            teacher.getReviewingAssignments().remove(this);
        }
    }

    public boolean canReview(Teacher teacher) {
        return teacher != null && (creator.getId().equals(teacher.getId()) || reviewers.contains(teacher));
    }

    // Вспомогательные методы для работы с отправками
    public void addSubmission(Submission submission) {
        if (submission != null && !submissions.contains(submission)) {
            submissions.add(submission);
            submission.setAssignment(this);
        }
    }

    public void removeSubmission(Submission submission) {
        if (submissions.remove(submission)) {
            submission.setAssignment(null);
        }
    }

    // Получить количество отправок
    public int getSubmissionCount() {
        return submissions != null ? submissions.size() : 0;
    }

    // Получить количество проверенных работ
    public long getGradedSubmissionCount() {
        return submissions != null
                ? submissions.stream().filter(s -> s.getScore() != null).count()
                : 0;
    }

    public String getFormattedDueDate() {
        if (this.dueDate == null) {
            return "N/A";
        }

        return this.dueDate.format(DateTimeFormatter.ofPattern("dd MMM yyyy"));
    }
}