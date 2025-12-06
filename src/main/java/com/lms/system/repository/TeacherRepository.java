package com.lms.system.repository;

import com.lms.system.model.Group;
import com.lms.system.model.Teacher;
import com.lms.system.repository.status.ChangeStatusUser;
import com.lms.system.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

public class TeacherRepository implements ChangeStatusUser {

    private static TeacherRepository instance;

    private TeacherRepository() {}

    public static TeacherRepository getInstance() {
        if (instance == null) {
            instance = new TeacherRepository();
        }
        return instance;
    }

    // ======================================= CRUD

    public void save(Teacher teacher) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Optional<Teacher> existing = findById(teacher.getId());
        System.out.println(existing);
        if (existing.isPresent()) {
            entityManager.merge(teacher);
        } else {
            entityManager.persist(teacher);
        }

        entityManager.getTransaction().commit();
        entityManager.close();
    }

    public List<Teacher> findAll() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Teacher> teachers = entityManager.createQuery("SELECT t FROM Teacher t", Teacher.class)
                .getResultList();
        entityManager.close();
        return teachers;
    }

    public Optional<Teacher> findByIdWithGroups(String id) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            Optional<Teacher> teacherOpt = entityManager.createQuery(
                            "SELECT DISTINCT t FROM Teacher t " +
                                    "LEFT JOIN FETCH t.groups " +
                                    "WHERE t.id = :id", Teacher.class)
                    .setParameter("id", id)
                    .getResultList()
                    .stream()
                    .findFirst();
            return teacherOpt;
        } finally {
            entityManager.close();
        }
    }

    public Optional<Teacher> findById(String id) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Optional<Teacher> teacherOpt = entityManager.createQuery("SELECT t FROM Teacher t WHERE t.id = :id", Teacher.class)
                .setParameter("id", id).getResultList().stream().findFirst();
        entityManager.close();
        return teacherOpt;
    }

    public boolean existsById(String id) {
        return findById(id).isPresent();
    }

    // ======================================= AUTH & SEARCH

    public Optional<Teacher> findByEmail(String email) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Optional<Teacher> teacherOpt = entityManager.createQuery(
                        "SELECT t FROM Teacher t WHERE t.email = :email", Teacher.class)
                .setParameter("email", email)
                .getResultList()
                .stream()
                .findFirst();
        entityManager.close();
        return teacherOpt;
    }

    public boolean existsByEmail(String email) {
        return findByEmail(email).isPresent();
    }

    public List<Teacher> findByName(String name) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Teacher> teachers = entityManager.createQuery(
                        "SELECT t FROM Teacher t WHERE LOWER(t.fullName) LIKE LOWER(:name)", Teacher.class)
                .setParameter("name", "%" + name + "%")
                .getResultList();
        entityManager.close();
        return teachers;
    }

    // ======================================= RELATIONS

    public List<Teacher> findReviewersForAssignment(String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Teacher> teachers = entityManager.createQuery(
                        "SELECT DISTINCT t FROM Teacher t JOIN t.reviewingAssignments a WHERE a.id = :aid", Teacher.class)
                .setParameter("aid", assignmentId)
                .getResultList();
        entityManager.close();
        return teachers;
    }

    public Optional<Teacher> findByGroupId(String groupId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Optional<Teacher> teacherOpt = entityManager.createQuery(
                        "SELECT t FROM Teacher t JOIN t.groups g WHERE g.id = :gid", Teacher.class)
                .setParameter("gid", groupId)
                .getResultList()
                .stream()
                .findFirst();
        entityManager.close();
        return teacherOpt;
    }

    public Optional<Teacher> findByCreatedAssignmentId(String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Optional<Teacher> teacherOpt = entityManager.createQuery(
                        "SELECT t FROM Teacher t JOIN t.createdAssignments a WHERE a.id = :aid", Teacher.class)
                .setParameter("aid", assignmentId)
                .getResultList()
                .stream()
                .findFirst();
        entityManager.close();
        return teacherOpt;
    }

    // ======================================= STATS

    public long countActiveTeachers() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Long count = entityManager.createQuery("SELECT COUNT(t) FROM Teacher t WHERE t.active = true", Long.class)
                .getSingleResult();
        entityManager.close();
        return count != null ? count : 0;
    }

    // ======================================= STATUS CHANGE

    @Override
    public boolean activate(String id) {
        return changeActiveStatus(id, true);
    }

    @Override
    public boolean deactivate(String id) {
        return changeActiveStatus(id, false);
    }

    private boolean changeActiveStatus(String id, boolean active) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Teacher teacher = entityManager.find(Teacher.class, id);
        if (teacher == null) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }

        teacher.setActive(active);
        entityManager.merge(teacher);
        entityManager.getTransaction().commit();
        entityManager.close();
        return true;
    }

    public Set<Teacher> findTeachersNotInGroup(String groupId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            // Сначала получаем группу
            Group group = em.find(Group.class, groupId);
            if (group == null) {
                return new HashSet<>();
            }

            // Теперь используем объект группы
            return new HashSet<>(em.createQuery("""
            SELECT t FROM Teacher t
            WHERE :group NOT MEMBER OF t.groups
            ORDER BY t.fullName
            """, Teacher.class)
                    .setParameter("group", group)  // ✅ Передаём объект, а не ID
                    .getResultList());
        } finally {
            em.close();
        }
    }

}
