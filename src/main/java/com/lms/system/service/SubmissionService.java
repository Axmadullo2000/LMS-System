package com.lms.system.service;

import com.lms.system.model.Student;
import com.lms.system.model.Submission;
import com.lms.system.repository.AssignmentRepository;
import com.lms.system.repository.StudentRepository;
import com.lms.system.repository.SubmissionRepository;

import java.util.List;


public class SubmissionService {
    private final SubmissionRepository submissionRepository;
    private final StudentRepository studentRepository;
    private final AssignmentRepository assignmentRepository;

    public SubmissionService(SubmissionRepository submissionRepository, StudentRepository studentRepository, AssignmentRepository assignmentRepository) {
        this.submissionRepository = submissionRepository;
        this.studentRepository = studentRepository;
        this.assignmentRepository = assignmentRepository;
    }

    public Submission getSubmissionById(String submissionId) {
        return submissionRepository.findById(submissionId)
                .orElseThrow(() -> new RuntimeException("Submission not found"));
    }

    public List<Submission> getAllSubmissions() {
        return submissionRepository.findAll();
    }

    public List<Submission> getSubmissionsByStudent(String studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        return studentRepository.getSubmissionsByStudent(student.getId());
    }

    public List<Submission> getSubmissionsByAssignment(String assignmentId) {
        return submissionRepository.findByAssignmentId(assignmentId);
    }

    public List<Submission> getPendingSubmissions() {
        return submissionRepository.findPendingGrading();
    }

    public List<Submission> getGradedSubmissions() {
        return submissionRepository.findGradedSubmissions();
    }

    public void deleteSubmission(String submissionId) {
        submissionRepository.delete(submissionId);
    }

    public boolean isGraded(String submissionId) {
        Submission submission = getSubmissionById(submissionId);
        return submission.getScore() != null;
    }

}
