package com.lms.system.repository;

import com.lms.system.enums.SubmissionStatus;
import com.lms.system.model.Submission;
import com.lms.system.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public class SubmissionRepository {

    private static SubmissionRepository instance;

    private SubmissionRepository() {}

    public static SubmissionRepository getInstance() {
        if (instance == null) {
            instance = new SubmissionRepository();
        }
        return instance;
    }

    // ======================================= CRUD

    public Optional<Submission> findById(String id) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();

        try {
            Submission submission = em.createQuery("""
            SELECT s FROM Submission s
            LEFT JOIN FETCH s.student
            LEFT JOIN FETCH s.assignment
            LEFT JOIN FETCH s.reviewer
            WHERE s.id = :id
        """, Submission.class)
                    .setParameter("id", id)
                    .getResultList()
                    .stream()
                    .findFirst()
                    .orElse(null);

            return Optional.ofNullable(submission);

        } finally {
            em.close();
        }
    }


    public List<Submission> findAll() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Submission> submissions = entityManager.createQuery("SELECT s FROM Submission s", Submission.class)
                .getResultList();
        entityManager.close();
        return submissions;
    }

    public void save(Submission submission) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Optional<Submission> existing = findById(submission.getId());
        if (existing.isPresent()) {
            entityManager.merge(submission);
        } else {
            entityManager.persist(submission);
        }

        entityManager.getTransaction().commit();
        entityManager.close();
    }

    public boolean delete(String id) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            entityManager.getTransaction().begin();
            Submission submission = entityManager.find(Submission.class, id);
            if (submission != null) {
                entityManager.remove(submission);
                entityManager.getTransaction().commit();
                entityManager.close();
                return true;
            }
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        } catch (Exception e) {
            if (entityManager.getTransaction().isActive()) {
                entityManager.getTransaction().rollback();
            }
            entityManager.close();
            return false;
        }
    }

    public boolean existsById(String id) {
        return findById(id).isPresent();
    }

    // ======================================= QUERIES

    public List<Submission> findByAssignmentId(String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Submission> submissions = entityManager.createQuery(
                        "SELECT s FROM Submission s WHERE s.assignment.id = :assignmentId", Submission.class)
                .setParameter("assignmentId", assignmentId)
                .getResultList();
        entityManager.close();
        return submissions;
    }

    public List<Submission> findByStudentId(String studentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Submission> submissions = entityManager.createQuery(
                        "SELECT s FROM Submission s WHERE s.student.id = :studentId", Submission.class)
                .setParameter("studentId", studentId)
                .getResultList();
        entityManager.close();
        return submissions;
    }

    public Optional<Submission> findByAssignmentAndStudent(String assignmentId, String studentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Optional<Submission> submissionOpt = entityManager.createQuery(
                        "SELECT s FROM Submission s WHERE s.assignment.id = :aid AND s.student.id = :sid", Submission.class)
                .setParameter("aid", assignmentId)
                .setParameter("sid", studentId)
                .getResultList()
                .stream()
                .findFirst();
        entityManager.close();
        return submissionOpt;
    }

    public List<Submission> findPendingGrading() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Submission> submissions = entityManager.createQuery(
                        "SELECT s FROM Submission s WHERE s.status = :status ORDER BY s.submittedAt", Submission.class)
                .setParameter("status", SubmissionStatus.PENDING)
                .getResultList();
        entityManager.close();
        return submissions;
    }

    public List<Submission> findGradedByTeacher(String teacherId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Submission> submissions = entityManager.createQuery(
                        "SELECT s FROM Submission s WHERE s.reviewer.id = :teacherId", Submission.class)
                .setParameter("teacherId", teacherId)
                .getResultList();
        entityManager.close();
        return submissions;
    }

    public List<Submission> findLateSubmissions(String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Submission> submissions = entityManager.createQuery(
                        "SELECT s FROM Submission s WHERE s.assignment.id = :aid AND s.submittedAt > s.assignment.dueDate", Submission.class)
                .setParameter("aid", assignmentId)
                .getResultList();
        entityManager.close();
        return submissions;
    }

    public List<Submission> findGradedSubmissions() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Submission> submissions = entityManager.createQuery(
                        "SELECT s FROM Submission s WHERE s.grade IS NOT NULL", Submission.class)
                .getResultList();
        entityManager.close();
        return submissions;
    }

    // ======================================= AGGREGATIONS & STATS

    public long countByStatus(SubmissionStatus status) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Long count = entityManager.createQuery(
                        "SELECT COUNT(s) FROM Submission s WHERE s.status = :status", Long.class)
                .setParameter("status", status)
                .getSingleResult();
        entityManager.close();
        return count != null ? count : 0;
    }

    public Double getAverageGrade(String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Double avg = entityManager.createQuery(
                        "SELECT AVG(s.grade) FROM Submission s WHERE s.assignment.id = :aid AND s.grade IS NOT NULL", Double.class)
                .setParameter("aid", assignmentId)
                .getSingleResult();
        entityManager.close();
        return avg;
    }

    public long countByAssignmentId(String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Long count = entityManager.createQuery(
                        "SELECT COUNT(s) FROM Submission s WHERE s.assignment.id = :aid", Long.class)
                .setParameter("aid", assignmentId)
                .getSingleResult();
        entityManager.close();
        return count != null ? count : 0;
    }

    public long countGradedByAssignmentId(String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Long count = entityManager.createQuery(
                        "SELECT COUNT(s) FROM Submission s WHERE s.assignment.id = :aid AND s.status = :graded", Long.class)
                .setParameter("aid", assignmentId)
                .setParameter("graded", SubmissionStatus.GRADED)
                .getSingleResult();
        entityManager.close();
        return count != null ? count : 0;
    }
}
