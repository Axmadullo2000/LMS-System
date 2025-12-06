package com.lms.system.model;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;


@Entity
@SuperBuilder
@Data
@Table(name = "students")
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class Student extends User {
    @ManyToMany(mappedBy = "students", fetch = FetchType.LAZY)  // ← ИСПРАВЛЕНО: было "group_students"
    @Builder.Default
    private List<Group> groups = new ArrayList<>();

    @OneToMany(mappedBy = "student", fetch = FetchType.LAZY)
    @Builder.Default
    private List<Submission> submissions = new ArrayList<>();

    public void addGroup(Group group) {
        if (group != null && !groups.contains(group) ) {
            groups.add(group);
        }
    }

    public void removeGroup(Group group) {
        groups.remove(group);
    }

    public boolean hasGroup(Group group) {
        return groups.contains(group);
    }

    public void addSubmission(Submission submission) {
        if (submission != null && !submissions.contains(submission) ) {
            submissions.add(submission);
            submission.setStudent(this);
        }
    }

    public void removeSubmission(Submission submission) {
        if (submissions.remove(submission)) {
            submission.setStudent(null);
        }
    }

    public List<Submission> getSubmissionsForAssignment(Assignment assignment) {
        return submissions.stream()
                .filter(s -> s.getAssignment().equals(assignment))
                .toList();
    }

    public Submission getLatestSubmissionForAssignment(Assignment assignment) {
        return submissions.stream()
                .filter(s -> s.getAssignment().equals(assignment))
                .max(Comparator.comparing(Submission::getSubmittedAt))
                .orElse(null);
    }
}
