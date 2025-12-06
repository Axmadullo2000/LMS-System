package com.lms.system.service;


import com.lms.system.model.Assignment;
import com.lms.system.model.Submission;
import com.lms.system.repository.AssignmentRepository;
import com.lms.system.repository.SubmissionRepository;

import java.util.List;

public class AssignmentService {
    private final AssignmentRepository assignmentRepository;
    private final SubmissionRepository submissionRepository;

    public AssignmentService(AssignmentRepository assignmentRepository, SubmissionRepository submissionRepository) {
        this.assignmentRepository = assignmentRepository;
        this.submissionRepository = submissionRepository;
    }

    public Assignment getAssignmentById(String assignmentId) {
        return assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new RuntimeException("Assignment not found"));
    }

    public List<Assignment> getAllAssignments() {
        return assignmentRepository.findAll();
    }

    public List<Assignment> getUpcomingAssignments(int days) {
        return assignmentRepository.findUpcomingAssignments(days);
    }

    public List<Assignment> getActiveAssignments() {
        return assignmentRepository.findActiveAssignments();
    }

    public List<Assignment> getExpiredAssignments() {
        return assignmentRepository.findExpiredAssignments();
    }

    public List<Submission> getSubmissions(String assignmentId) {
        return assignmentRepository.getSubmissionsForAssignment(assignmentId);
    }

    public long getSubmissionsCount(String assignmentId) {
        return assignmentRepository.getSubmissionCount(assignmentId);
    }

    public boolean isOverdue(String assignmentId) {
        Assignment assignmentById = getAssignmentById(assignmentId);
        return assignmentById.isOverdue();
    }

}
