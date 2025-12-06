package com.lms.system.repository;

import com.lms.system.model.Assignment;
import com.lms.system.model.Group;
import com.lms.system.model.Student;
import com.lms.system.model.Teacher;
import com.lms.system.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class GroupRepository {

    private static GroupRepository instance;

    private GroupRepository() {}

    public static GroupRepository getInstance() {
        if (instance == null) {
            instance = new GroupRepository();
        }
        return instance;
    }

    // ======================================= CRUD

    public List<Group> findAll() {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery("""
            SELECT DISTINCT g FROM Group g
            LEFT JOIN FETCH g.students
            LEFT JOIN FETCH g.teachers
            LEFT JOIN FETCH g.assignments
            ORDER BY g.createdAt DESC
            """, Group.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public Optional<Group> findById(String id) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        Optional<Group> groupOpt = entityManager.createQuery(
                        "SELECT g FROM Group g WHERE g.id = :id", Group.class)
                .setParameter("id", id)
                .getResultList()
                .stream().findFirst();

        // Принудительно инициализируем коллекции перед закрытием EntityManager
        groupOpt.ifPresent(g -> {
            g.getTeachers().size();
            g.getStudents().size();
            g.getAssignments().size();
        });

        entityManager.close();
        return groupOpt;
    }

    public List<Group> findByStudentIdWithStudents(String studentId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery(
                            "SELECT DISTINCT g FROM Group g " +
                                    "LEFT JOIN FETCH g.students " +
                                    "LEFT JOIN FETCH g.assignments " +  // ← ДОБАВЬТЕ ЭТО!
                                    "JOIN g.students s " +
                                    "WHERE s.id = :studentId " +
                                    "ORDER BY g.name", Group.class)
                    .setParameter("studentId", studentId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    // В GroupRepository
    public Optional<Group> findByIdWithAssignments(String groupId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery(
                            "SELECT DISTINCT g FROM Group g " +
                                    "LEFT JOIN FETCH g.assignments " +
                                    "WHERE g.id = :groupId", Group.class)
                    .setParameter("groupId", groupId)
                    .getResultList()
                    .stream()
                    .findFirst();
        } finally {
            em.close();
        }
    }

    public Optional<Group> findByIdWithAllData(String groupId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            // Шаг 1: Загружаем группу со студентами
            Optional<Group> groupOpt = em.createQuery(
                            "SELECT DISTINCT g FROM Group g " +
                                    "LEFT JOIN FETCH g.students " +
                                    "WHERE g.id = :groupId", Group.class)
                    .setParameter("groupId", groupId)
                    .getResultList()
                    .stream()
                    .findFirst();

            // Шаг 2: Если группа найдена, загружаем assignments
            if (groupOpt.isPresent()) {
                em.createQuery(
                                "SELECT DISTINCT g FROM Group g " +
                                        "LEFT JOIN FETCH g.assignments " +
                                        "WHERE g.id = :groupId", Group.class)
                        .setParameter("groupId", groupId)
                        .getResultList();
            }

            return groupOpt;
        } finally {
            em.close();
        }
    }

    // Метод для загрузки списка групп со всеми данными
    public List<Group> findByTeacherIdWithAllData(String teacherId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            // Шаг 1: Загружаем группы со студентами
            List<Group> groups = em.createQuery(
                            "SELECT DISTINCT g FROM Group g " +
                                    "LEFT JOIN FETCH g.students " +
                                    "JOIN g.teachers t " +
                                    "WHERE t.id = :teacherId", Group.class)
                    .setParameter("teacherId", teacherId)
                    .getResultList();

            // Шаг 2: Загружаем assignments для тех же групп
            if (!groups.isEmpty()) {
                em.createQuery(
                                "SELECT DISTINCT g FROM Group g " +
                                        "LEFT JOIN FETCH g.assignments " +
                                        "WHERE g IN :groups", Group.class)
                        .setParameter("groups", groups)
                        .getResultList();
            }

            return groups;
        } finally {
            em.close();
        }
    }

    public void save(Group group) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        try {
            entityManager.getTransaction().begin();

            if (group.getId() == null || group.getId().isBlank() ) {
                entityManager.persist(group);
            }else {
                entityManager.merge(group);
            }

            entityManager.getTransaction().commit();
        }finally {
            entityManager.close();
        }
    }

    public boolean delete(String id) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();

        try {
            em.getTransaction().begin();

            Group group = em.find(Group.class, id);

            if (group == null) {
                em.getTransaction().rollback();
                return false;
            }

            // Инициализируем коллекции
            group.getTeachers().size();
            group.getStudents().size();
            group.getAssignments().size();

            // Очищаем связи
            group.getTeachers().clear();
            group.getStudents().clear();
            group.getAssignments().clear();

            // Удаляем
            em.remove(group);
            em.getTransaction().commit();

            return true;

        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean existsById(String id) {
        return findById(id).isPresent();
    }

    // ======================================= BUSINESS LOGIC

    public Optional<Group> findByName(String name) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Optional<Group> groupOpt = entityManager.createQuery(
                        "SELECT g FROM Group g WHERE g.name = :name", Group.class)
                .setParameter("name", name)
                .getResultList()
                .stream()
                .findFirst();
        entityManager.close();
        return groupOpt;
    }

    public Optional<Group> findByIdWithTeachers(String id) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        Optional<Group> groupOpt = entityManager.createQuery(
                        "SELECT g FROM Group g " +
                                "LEFT JOIN FETCH g.teachers " +
                                "WHERE g.id = :id", Group.class)
                .setParameter("id", id)
                .getResultList()
                .stream().findFirst();

        entityManager.close();
        return groupOpt;
    }

    public boolean existsByName(String name) {
        return findByName(name).isPresent();
    }

    public long getStudentCount(String groupId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Group group = entityManager.find(Group.class, groupId);
        long count = group != null && group.getStudents() != null ? group.getStudents().size() : 0;
        entityManager.close();
        return count;
    }

    public long getTeacherCount(String groupId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Group group = entityManager.find(Group.class, groupId);
        long count = group != null && group.getTeachers() != null ? group.getTeachers().size() : 0;
        entityManager.close();
        return count;
    }

    public List<Group> findEmptyGroups() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Group> groups = entityManager.createQuery(
                        "SELECT g FROM Group g WHERE SIZE(g.students) = 0", Group.class)
                .getResultList();
        entityManager.close();
        return groups;
    }

    // ======================================= STUDENT OPERATIONS

    public boolean addStudent(String groupId, String studentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Group group = entityManager.find(Group.class, groupId);
        Student student = entityManager.find(Student.class, studentId);

        if (group == null || student == null) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }

        boolean added = group.addStudent(student);
        if (added) {
            entityManager.getTransaction().commit();
        } else {
            entityManager.getTransaction().rollback();
        }
        entityManager.close();
        return added;
    }

    public boolean removeStudent(String groupId, String studentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Group group = entityManager.find(Group.class, groupId);
        Student student = entityManager.find(Student.class, studentId);

        if (group == null || student == null) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }

        boolean removed = group.removeStudent(student);
        if (removed) {
            entityManager.getTransaction().commit();
        } else {
            entityManager.getTransaction().rollback();
        }
        entityManager.close();
        return removed;
    }

    // ======================================= TEACHER OPERATIONS

    public boolean addTeacher(String groupId, String teacherId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Group group = entityManager.find(Group.class, groupId);
        Teacher teacher = entityManager.find(Teacher.class, teacherId);

        if (group == null || teacher == null) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }

        boolean added = group.addTeacher(teacher);
        if (added) {
            entityManager.getTransaction().commit();
        } else {
            entityManager.getTransaction().rollback();
        }
        entityManager.close();
        return added;
    }

    public boolean removeTeacher(String groupId, String teacherId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Group group = entityManager.find(Group.class, groupId);
        Teacher teacher = entityManager.find(Teacher.class, teacherId);

        if (group == null || teacher == null) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }

        boolean removed = group.removeTeacher(teacher);
        if (removed) {
            entityManager.getTransaction().commit();
        } else {
            entityManager.getTransaction().rollback();
        }
        entityManager.close();
        return removed;
    }

    // ======================================= ASSIGNMENT OPERATIONS

    public boolean addAssignment(String groupId, String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Group group = entityManager.find(Group.class, groupId);
        Assignment assignment = entityManager.find(Assignment.class, assignmentId);

        if (group == null || assignment == null) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }

        boolean added = group.addAssignment(assignment);
        if (added) {
            entityManager.getTransaction().commit();
        } else {
            entityManager.getTransaction().rollback();
        }
        entityManager.close();
        return added;
    }

    public boolean removeAssignment(String groupId, String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();

        Group group = entityManager.find(Group.class, groupId);
        Assignment assignment = entityManager.find(Assignment.class, assignmentId);

        if (group == null || assignment == null) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }

        boolean removed = group.removeAssignment(assignment);
        if (removed) {
            entityManager.getTransaction().commit();
        } else {
            entityManager.getTransaction().rollback();
        }
        entityManager.close();
        return removed;
    }

    public Map<String, Object> findGroupWithStatistics(String groupId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            // ============================================
            // ШАГ 1: Загружаем группу со студентами и учителями
            // ============================================
            Group group = em.createQuery("""
            SELECT DISTINCT g FROM Group g
            LEFT JOIN FETCH g.students
            LEFT JOIN FETCH g.teachers
            WHERE g.id = :groupId
            """, Group.class)
                    .setParameter("groupId", groupId)
                    .getSingleResult();

            // ============================================
            // ШАГ 2: Загружаем assignments с creator
            // ============================================
            List<Assignment> assignments = em.createQuery("""
            SELECT DISTINCT a FROM Assignment a
            LEFT JOIN FETCH a.creator
            JOIN a.groups g
            WHERE g.id = :groupId
            ORDER BY a.dueDate DESC
            """, Assignment.class)
                    .setParameter("groupId", groupId)
                    .getResultList();

            // ============================================
            // ШАГ 3: Загружаем reviewers для assignments
            // ============================================
            if (!assignments.isEmpty()) {
                em.createQuery("""
                SELECT DISTINCT a FROM Assignment a
                LEFT JOIN FETCH a.reviewers
                WHERE a IN :assignments
                """, Assignment.class)
                        .setParameter("assignments", assignments)
                        .getResultList();
            }

            // ============================================
            // ШАГ 4: Загружаем submissions для assignments
            // ============================================
            if (!assignments.isEmpty()) {
                em.createQuery("""
                SELECT DISTINCT a FROM Assignment a
                LEFT JOIN FETCH a.submissions s
                LEFT JOIN FETCH s.student
                WHERE a IN :assignments
                """, Assignment.class)
                        .setParameter("assignments", assignments)
                        .getResultList();
            }

            // ============================================
            // ШАГ 5: Считаем статистику
            // ============================================
            Map<String, Integer> submissionCounts = new HashMap<>();
            Map<String, Integer> gradedCounts = new HashMap<>();
            Map<String, Double> completionRates = new HashMap<>();

            int totalStudents = group.getStudents().size();

            for (Assignment assignment : assignments) {
                int totalSubs = assignment.getSubmissions().size();
                int gradedSubs = (int) assignment.getSubmissions().stream()
                        .filter(s -> s.getScore() != null)
                        .count();

                double rate = totalStudents > 0
                        ? (totalSubs * 100.0) / totalStudents
                        : 0.0;

                submissionCounts.put(assignment.getId(), totalSubs);
                gradedCounts.put(assignment.getId(), gradedSubs);
                completionRates.put(assignment.getId(), rate);
            }

            // ============================================
            // ШАГ 6: Собираем результат в Map
            // ============================================
            Map<String, Object> result = new HashMap<>();
            result.put("group", group);
            result.put("assignments", assignments);
            result.put("submissionCounts", submissionCounts);
            result.put("gradedCounts", gradedCounts);
            result.put("completionRates", completionRates);
            result.put("totalStudents", totalStudents);

            return result;

        } catch (NoResultException e) {
            throw new IllegalArgumentException("Group not found: " + groupId);
        } finally {
            em.close();
        }
    }
    public long count() {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();

        Long singleResult = em.createQuery("SELECT COUNT(*) FROM Group g", Long.class)
                .getSingleResult();

        em.close();
        return singleResult;
    }

    // findByTeacherIdWithStudentsAndAssignments
    public List<Group> findByTeacherIdWithStudents(String teacherId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();

        try {
            // ⚠️ ВАЖНО: нельзя делать два JOIN FETCH на две коллекции одновременно
            // Сначала загружаем группы со студентами
            List<Group> groups = em.createQuery(
                            "SELECT DISTINCT g FROM Group g " +
                                    "LEFT JOIN FETCH g.students " +
                                    "JOIN g.teachers t " +
                                    "WHERE t.id = :teacherId", Group.class)
                    .setParameter("teacherId", teacherId)
                    .getResultList();

            // Затем загружаем assignments для этих групп
            if (!groups.isEmpty()) {
                em.createQuery(
                                "SELECT DISTINCT g FROM Group g " +
                                        "LEFT JOIN FETCH g.assignments " +
                                        "WHERE g IN :groups", Group.class)
                        .setParameter("groups", groups)
                        .getResultList();
            }

            return groups;

        } finally {
            em.close();
        }
    }



    public Optional<Group> findByIdWithStudents(String groupId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();

        Optional<Group> groupById = em.createQuery("SELECT g FROM Group g LEFT JOIN FETCH g.students WHERE g.id = :id", Group.class)
                .setParameter("id", groupId)
                .getResultList().stream().findFirst();
        em.close();

        return groupById;
    }

}
