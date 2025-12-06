package com.lms.system.repository;

import com.lms.system.model.*;
import com.lms.system.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class AssignmentRepository {

    private static AssignmentRepository instance;

    private AssignmentRepository() {
    }

    public static AssignmentRepository getInstance() {
        if (instance == null) {
            instance = new AssignmentRepository();
        }
        return instance;
    }

    // ======================================= CRUD

    public Optional<Assignment> findById(String id) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();

        Optional<Assignment> assignmentOpt = em.createQuery(
                        "SELECT a FROM Assignment a LEFT JOIN FETCH a.groups WHERE a.id = :id",
                        Assignment.class
                )
                .setParameter("id", id)
                .getResultList()
                .stream()
                .findFirst();

        em.close();
        return assignmentOpt;
    }

    public List<Assignment> findAll() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Assignment> assignments = entityManager.createQuery(
                        "SELECT a FROM Assignment a ORDER BY a.dueDate DESC", Assignment.class)
                .getResultList();
        entityManager.close();
        return assignments;
    }

    public List<Assignment> findByCreatorIdWithGroups(String creatorId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery(
                            "SELECT DISTINCT a FROM Assignment a " +
                                    "LEFT JOIN FETCH a.groups " +
                                    "WHERE a.creator.id = :creatorId " +
                                    "ORDER BY a.dueDate DESC", Assignment.class)
                    .setParameter("creatorId", creatorId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public void save(Assignment assignment) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();

        try {
            em.getTransaction().begin();

            boolean isNew = (assignment.getId() == null || assignment.getId().isBlank());

            if (isNew) {
                // === СОЗДАНИЕ НОВОГО ASSIGNMENT ===

                // Присоединяем creator
                if (assignment.getCreator() != null && assignment.getCreator().getId() != null) {
                    Teacher managedCreator = em.find(Teacher.class, assignment.getCreator().getId());
                    if (managedCreator != null) {
                        assignment.setCreator(managedCreator);
                    } else {
                        throw new RuntimeException("Teacher not found");
                    }
                }

                // Присоединяем группы
                List<Group> managedGroups = new ArrayList<>();
                for (Group group : assignment.getGroups()) {
                    if (group.getId() != null) {
                        Group managedGroup = em.find(Group.class, group.getId());
                        if (managedGroup != null) {
                            managedGroups.add(managedGroup);
                        }
                    }
                }
                assignment.getGroups().clear();
                assignment.getGroups().addAll(managedGroups);

                // Persist
                em.persist(assignment);
                System.out.println("✓ Assignment created: " + assignment.getId());

            } else {
                // === ОБНОВЛЕНИЕ СУЩЕСТВУЮЩЕГО ===

                // Присоединяем creator
                if (assignment.getCreator() != null && assignment.getCreator().getId() != null) {
                    Teacher managedCreator = em.find(Teacher.class, assignment.getCreator().getId());
                    if (managedCreator != null) {
                        assignment.setCreator(managedCreator);
                    }
                }

                // Присоединяем группы
                List<Group> managedGroups = new ArrayList<>();
                for (Group group : assignment.getGroups()) {
                    if (group.getId() != null) {
                        Group managedGroup = em.find(Group.class, group.getId());
                        if (managedGroup != null) {
                            managedGroups.add(managedGroup);
                        }
                    }
                }
                assignment.getGroups().clear();
                assignment.getGroups().addAll(managedGroups);

                // Merge
                em.merge(assignment);
                System.out.println("✓ Assignment updated: " + assignment.getId());
            }

            em.getTransaction().commit();

        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("✗ Failed to save assignment: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to save assignment", e);
        } finally {
            em.close();
        }
    }

    public boolean delete(String id) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            entityManager.getTransaction().begin();
            Assignment assignment = entityManager.find(Assignment.class, id);
            if (assignment != null) {
                entityManager.remove(assignment);
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
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Long count = entityManager.createQuery(
                        "SELECT COUNT(a) FROM Assignment a WHERE a.id = :id", Long.class)
                .setParameter("id", id)
                .getSingleResult();
        entityManager.close();
        return count != null && count > 0;
    }

    // =================================== QUERIES

    public List<Assignment> findByCreatorId(String teacherId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Assignment> assignments = entityManager.createQuery(
                        "SELECT a FROM Assignment a WHERE a.creator.id = :teacherId ORDER BY a.dueDate DESC",
                        Assignment.class)
                .setParameter("teacherId", teacherId)
                .getResultList();
        entityManager.close();
        return assignments;
    }

    public List<Assignment> findByGroupId(String groupId) {
        System.out.println("\n→ AssignmentRepository.findByGroupId()");
        System.out.println("  Group ID: " + groupId);

        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            List<Assignment> result = em.createQuery(
                            "SELECT DISTINCT a FROM Assignment a " +
                                    "JOIN a.groups g " +
                                    "WHERE g.id = :groupId " +
                                    "ORDER BY a.dueDate", Assignment.class)
                    .setParameter("groupId", groupId)
                    .getResultList();

            System.out.println("  Query returned " + result.size() + " assignments");
            return result;
        } catch (Exception e) {
            System.err.println("  ⚠️ ERROR in query: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public List<Assignment> findUpcomingAssignments(int days) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime end = now.plusDays(days);
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Assignment> assignments = entityManager.createQuery(
                        "SELECT a FROM Assignment a WHERE a.dueDate BETWEEN :now AND :end ORDER BY a.dueDate",
                        Assignment.class)
                .setParameter("now", now)
                .setParameter("end", end)
                .getResultList();
        entityManager.close();
        return assignments;
    }

    public List<Assignment> findActiveAssignments() {
        return findUpcomingAssignments(30);
    }

    public List<Assignment> findExpiredAssignments() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Assignment> assignments = entityManager.createQuery(
                        "SELECT a FROM Assignment a WHERE a.dueDate < :now ORDER BY a.dueDate DESC",
                        Assignment.class)
                .setParameter("now", LocalDateTime.now())
                .getResultList();
        entityManager.close();
        return assignments;
    }

    // ===================================== SUBMISSIONS

    public List<Submission> getSubmissionsForAssignment(String assignmentId) {
        System.out.println("\n>>> AssignmentRepository.getSubmissionsForAssignment");
        System.out.println("    Assignment ID: " + assignmentId);

        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            // Вариант 1: Через JOIN FETCH (рекомендуется)
            List<Submission> submissions = em.createQuery(
                            "SELECT s FROM Submission s " +
                                    "LEFT JOIN FETCH s.student " +
                                    "LEFT JOIN FETCH s.assignment " +
                                    "WHERE s.assignment.id = :assignmentId " +
                                    "ORDER BY s.submittedAt DESC",
                            Submission.class)
                    .setParameter("assignmentId", assignmentId)
                    .getResultList();

            System.out.println("    Found " + submissions.size() + " submissions via JPQL");

            // Debug каждой submission
            for (int i = 0; i < Math.min(submissions.size(), 3); i++) {
                Submission s = submissions.get(i);
                System.out.println("    [" + i + "] ID: " + s.getId() +
                        ", Student: " + (s.getStudent() != null ? s.getStudent().getFullName() : "null") +
                        ", Score: " + s.getScore());
            }

            return submissions;

        } catch (Exception e) {
            System.err.println("    ERROR: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public long getSubmissionCount(String assignmentId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            // ✅ ПРАВИЛЬНО: используем COUNT запрос вместо загрузки коллекции
            Long count = em.createQuery(
                            "SELECT COUNT(s) FROM Submission s WHERE s.assignment.id = :assignmentId",
                            Long.class)
                    .setParameter("assignmentId", assignmentId)
                    .getSingleResult();

            return count != null ? count : 0;
        } finally {
            em.close();
        }
    }

    // Если у вас есть EntityManager напрямую:
    public Optional<Assignment> findByIdWithRelations(String id) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager(); // или ваш способ

        try {
            em.getTransaction().begin();

            // Загружаем с groups
            Assignment assignment = em.createQuery(
                            "SELECT DISTINCT a FROM Assignment a " +
                                    "LEFT JOIN FETCH a.creator " +
                                    "LEFT JOIN FETCH a.groups g " +
                                    "LEFT JOIN FETCH g.teachers " +
                                    "LEFT JOIN FETCH g.students " +
                                    "WHERE a.id = :id",
                            Assignment.class)
                    .setParameter("id", id)
                    .getSingleResult();

            // Догружаем reviewers
            em.createQuery(
                            "SELECT a FROM Assignment a " +
                                    "LEFT JOIN FETCH a.reviewers " +
                                    "WHERE a.id = :id",
                            Assignment.class)
                    .setParameter("id", id)
                    .getSingleResult();

            em.getTransaction().commit();
            return Optional.of(assignment);

        } catch (NoResultException e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return Optional.empty();
        } finally {
            em.close();
        }
    }

    public boolean addSubmission(String assignmentId, String submissionId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Assignment assignment = entityManager.find(Assignment.class, assignmentId);
        Submission submission = entityManager.find(Submission.class, submissionId);

        if (assignment == null || submission == null) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }

        if (assignment.getSubmissions().stream().anyMatch(s -> s.getId().equals(submissionId))) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }

        assignment.getSubmissions().add(submission);
        submission.setAssignment(assignment);
        entityManager.getTransaction().commit();
        entityManager.close();
        return true;
    }

    public boolean removeSubmission(String assignmentId, String submissionId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Assignment assignment = entityManager.find(Assignment.class, assignmentId);
        if (assignment == null || assignment.getSubmissions() == null) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }

        boolean removed = assignment.getSubmissions()
                .removeIf(s -> s.getId().equals(submissionId));

        if (removed) {
            entityManager.getTransaction().commit();
        } else {
            entityManager.getTransaction().rollback();
        }
        entityManager.close();
        return removed;
    }
}
