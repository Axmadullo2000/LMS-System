package com.lms.system.model;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.ArrayList;
import java.util.List;


@Entity
@EqualsAndHashCode(callSuper = true)
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "teachers")
public class Teacher extends User {
    @Column(name = "specialization")
    private String specialization;

    @ManyToMany(mappedBy = "teachers", fetch = FetchType.EAGER)
    private List<Group> groups = new ArrayList<>();

    @OneToMany(mappedBy = "creator", fetch = FetchType.EAGER)
    @Builder.Default
    private List<Assignment> createdAssignments = new ArrayList<>();

    @ManyToMany(mappedBy = "reviewers", fetch = FetchType.EAGER)
    @Builder.Default
    private List<Assignment> reviewingAssignments = new ArrayList<>();

    @OneToMany(mappedBy = "reviewer", fetch = FetchType.EAGER)
    private List<Submission> reviewedSubmissions = new ArrayList<>();

}
