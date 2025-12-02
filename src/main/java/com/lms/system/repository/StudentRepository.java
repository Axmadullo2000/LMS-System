package com.lms.system.repository;

import com.lms.system.model.Student;
import com.lms.system.model.Submission;
import com.lms.system.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Query;
import jakarta.persistence.TypedQuery;

import java.util.List;
import java.util.Optional;


public class StudentRepository extends AbstractRepository<Student> {
    private static StudentRepository instance;

    private StudentRepository() {}

    public static StudentRepository getInstance() {
        if (instance == null) {
            instance = new StudentRepository();
        }

        return instance;
    }

    public List<Student> findAll() {
        EntityManagerFactory emf = JPAUtil.getEntityManagerFactory();
        EntityManager em = emf.createEntityManager();
        TypedQuery<Student> query = em.createQuery("SELECT s FROM Student s", Student.class);
        List<Student> resultList = query.getResultList();

        em.close();
        return resultList;
    }

    public Optional<Student> findById(String id) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();

        Optional<Student> studentOpt = em.createQuery(
                        "SELECT s FROM Student s LEFT JOIN FETCH s.groups WHERE s.id = :id",
                        Student.class
                )
                .setParameter("id", id)
                .getResultList()
                .stream()
                .findFirst();

        em.close();
        return studentOpt;
    }


    @Override
    protected void setId(Student student, String id) {
        student.setId(id);
    }

    @Override
    protected String getId(Student item) {
        return item.getId();
    }

    public void save(Student student) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        try {
            entityManager.getTransaction().begin();

            if (student.getId() == null || student.getId().isBlank()) {
                entityManager.persist(student);
            }else {
                Student s = entityManager.find(Student.class, student.getId());

                if (s != null) {
                    entityManager.merge(student);
                }else {
                    entityManager.persist(student);
                }
            }
            entityManager.getTransaction().commit();
        }finally {
            entityManager.close();
        }

    }

    public boolean delete(String id) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            entityManager.getTransaction().begin();

            Query query = entityManager.createQuery("DELETE FROM Student s WHERE s.id = :id")
                    .setParameter("id", id);
            query.executeUpdate();
            entityManager.getTransaction().commit();
            entityManager.close();

            return true;
        }catch (Exception e) {
            entityManager.getTransaction().rollback();
            entityManager.close();
            return false;
        }
    }

    // ================================================= QUERIES

    public Optional<Student> findByEmail(String email) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Optional<Student> studentByEmail = entityManager.createQuery("SELECT s FROM Student s WHERE s.email = :email", Student.class)
                .setParameter("email", email).getResultList().stream().findFirst();
        entityManager.close();

        return studentByEmail;
    }

    public List<Student> findByGroupId(String groupId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        List<Student> resultList = entityManager.createQuery("SELECT s FROM Student s JOIN s.groups g WHERE g.id = :groupId", Student.class)
                .setParameter("groupId", groupId)
                .getResultList();

        entityManager.close();

        return resultList;
    }

    public Optional<Student> findByIdWithGroups(String id) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        Optional<Student> studentOpt = entityManager.createQuery("SELECT s FROM Student s LEFT JOIN FETCH s.groups WHERE s.id = :id", Student.class)
                .setParameter("id", id)
                .getResultList().stream().findFirst();

        entityManager.close();

        return studentOpt;
    }

    public Optional<Student> findByIdWithSubmissions(String id) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        Optional<Student> studentOpt = entityManager.createQuery("SELECT s FROM Student s LEFT JOIN FETCH s.submissions WHERE s.id = :id", Student.class)
                .setParameter("id", id).getResultList().stream().findFirst();
        entityManager.close();

        return studentOpt;
    }

    public List<Submission> getSubmissionsByStudent(String studentId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();

        List<Submission> list = em.createQuery("""
        SELECT sub FROM Submission sub
        JOIN FETCH sub.assignment
        JOIN FETCH sub.student
        WHERE sub.student.id = :studentId
        ORDER BY sub.submittedAt DESC
        """, Submission.class)
                .setParameter("studentId", studentId)
                .getResultList();

        em.close();
        return list;
    }


    public List<Submission> getSubmissionsForAssignment(String studentId, String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        List<Submission> resultList = entityManager.createQuery("SELECT sub FROM Submission sub WHERE sub.student.id = :studentId AND sub.assignment.id = :assignmentId ORDER BY sub.submittedAt DESC",
                        Submission.class)
                .setParameter("studentId", studentId)
                .setParameter("assignmentId", assignmentId)
                .getResultList();

        entityManager.close();

        return resultList;
    }

    public List<Submission> getSubmissionsForStudentAndAssignment(String studentId, String assignmentId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();

        List<Submission> list = em.createQuery("""
        SELECT sub FROM Submission sub
        JOIN FETCH sub.assignment
        JOIN FETCH sub.student
        WHERE sub.student.id = :studentId
          AND sub.assignment.id = :assignmentId
        ORDER BY sub.submittedAt DESC
        """, Submission.class)
                .setParameter("studentId", studentId)
                .setParameter("assignmentId", assignmentId)
                .getResultList();

        em.close();
        return list;
    }


    public Optional<Submission> getLatestSubmissionForAssignment(String studentId, String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        Optional<Submission> submissionOpt = entityManager.createQuery("SELECT sub FROM Submission sub WHERE sub.student.id = :studentId AND sub.assignment.id = :assignmentId ORDER BY sub.submittedAt DESC", Submission.class)
                .setParameter("studentId", studentId)
                .setParameter("assignmentId", assignmentId)
                .getResultList()
                .stream()
                .findFirst();

        entityManager.close();

        return submissionOpt;
    }

    public Optional<Submission> getLatestSubmission(String studentId, String assignmentId) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        Optional<Submission> submissionOpt = entityManager.createQuery("SELECT sub FROM Submission sub WHERE sub.student.id = :studentId AND sub.assignment.id = :assignmentId ORDER BY sub.submittedAt DESC",
                        Submission.class)
                .setParameter("studentId", studentId)
                .setParameter("assignmentId", assignmentId)
                .getResultList()
                .stream().findFirst();

        entityManager.close();
        return submissionOpt;
    }

    public boolean activate(String id) {
        return changeActiveStatus(id, true);
    }

    public boolean deactivate(String id) {
        return changeActiveStatus(id, false);
    }

    private boolean changeActiveStatus(String id, boolean active) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        entityManager.getTransaction().begin();
        Student student = entityManager.find(Student.class, id);

        if (student == null) {
            entityManager.getTransaction().rollback();
            return false;
        }

        student.setActive(active);
        entityManager.merge(entityManager.getReference(Student.class, id));
        entityManager.getTransaction().commit();
        entityManager.close();
        return true;
    }

    public boolean existsByEmail(String email) {
        return findByEmail(email).isPresent();
    }

    public long count() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Long studentCount = entityManager.createQuery("SELECT COUNT(*) FROM Student", Long.class).getSingleResult();
        entityManager.close();
        return studentCount;
    }

    public List<Student> findStudentsNotInGroup(String groupId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery("""
            SELECT s FROM Student s
            WHERE NOT EXISTS (
                SELECT 1 FROM Group g
                JOIN g.students st
                WHERE g.id = :groupId
                AND st.id = s.id
            )
            ORDER BY s.fullName
            """, Student.class)
                    .setParameter("groupId", groupId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    // Студенты, которые уже в группе — для отображения
    public List<Student> findStudentsInGroup(String groupId) {
        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery(
                            "SELECT s FROM Student s WHERE :groupId MEMBER OF s.groups ORDER BY s.fullName",
                            Student.class)
                    .setParameter("groupId", groupId)
                    .getResultList();
        } finally {
            em.close();
        }
    }



}
