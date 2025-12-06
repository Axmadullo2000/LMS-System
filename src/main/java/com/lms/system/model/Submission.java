package com.lms.system.model;

import com.lms.system.enums.SubmissionStatus;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "submissions")
@SuperBuilder
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = {"student", "assignment", "reviewer"})
public class Submission {

    @Id
    @Column(name = "id", updatable = false, nullable = false)
    private String id;

    @Column(name = "file_path")
    private String filePath;

    @Column(name = "file_name")
    private String fileName;

    // Комментарий студента при отправке
    @Column(name = "content", columnDefinition = "TEXT")
    private String comment;

    @Column(name = "score")
    private Integer score;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    @Builder.Default
    private SubmissionStatus status = SubmissionStatus.SUBMITTED;

    @Column(name = "submitted_at", updatable = false, nullable = false)
    @Builder.Default
    private LocalDateTime submittedAt = LocalDateTime.now();

    @Column(name = "reviewed_at")
    private LocalDateTime reviewedAt;

    // ✅ ДОБАВЛЕНО: Фидбек от преподавателя
    @Column(name = "reviewer_comment", columnDefinition = "TEXT")
    private String reviewerComment;

    // Студент, который отправил
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    // Задание
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assignment_id", nullable = false)
    private Assignment assignment;

    // Преподаватель, который проверил
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewer_id")
    private Teacher reviewer;

    @PrePersist
    protected void onCreate() {
        if (id == null || id.isBlank()) {
            id = java.util.UUID.randomUUID().toString();
        }
        if (submittedAt == null) {
            submittedAt = LocalDateTime.now();
        }
        if (status == null) {
            status = SubmissionStatus.SUBMITTED;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        if (status == SubmissionStatus.GRADED && reviewedAt == null) {
            reviewedAt = LocalDateTime.now();
        }
    }

    // Форматированные даты для JSP
    public String getSubmittedDate() {
        if (this.submittedAt == null) {
            return "N/A";
        }
        return this.submittedAt.format(DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm"));
    }

    public String getReviewedDate() {
        if (this.reviewedAt == null) {
            return "N/A";
        }
        return this.reviewedAt.format(DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm"));
    }

    // ✅ ДОБАВЛЕНО: Алиас для удобства в JSP
    @Transient
    public String getFeedback() {
        return reviewerComment;
    }

    public void setFeedback(String feedback) {
        this.reviewerComment = feedback;
    }

    // Дополнительные утилиты
    @Transient
    public boolean isGraded() {
        return status == SubmissionStatus.GRADED;
    }

    @Transient
    public boolean isLate() {
        if (assignment == null || assignment.getDueDate() == null || submittedAt == null) {
            return false;
        }
        return submittedAt.isAfter(assignment.getDueDate());
    }
}
