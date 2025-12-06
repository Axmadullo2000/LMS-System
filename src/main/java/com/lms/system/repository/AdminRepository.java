package com.lms.system.repository;

import com.lms.system.model.Admin;
import com.lms.system.repository.status.ChangeStatusUser;
import com.lms.system.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;


public class AdminRepository implements ChangeStatusUser {

    private static AdminRepository instance;

    private AdminRepository() {}

    public static AdminRepository getInstance() {
        if (instance == null) {
            instance = new AdminRepository();
        }
        return instance;
    }

    // ================================================= CRUD

    public List<Admin> findAll() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        List<Admin> admins = entityManager.createQuery("SELECT a FROM Admin a", Admin.class)
                .getResultList();
        entityManager.close();
        return admins;
    }

    public Optional<Admin> findById(String id) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Optional<Admin> adminOpt = entityManager.createQuery("SELECT a FROM Admin a WHERE a.id = :id", Admin.class)
                .setParameter("id", id).getResultList().stream().findFirst();

        entityManager.close();

        return adminOpt;
    }

    public void save(Admin admin) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();

        try {
            entityManager.getTransaction().begin();

            Optional<Admin> existing = findById(admin.getId());
            if (existing.isPresent()) {
                entityManager.merge(admin);
            } else {
                entityManager.persist(admin);
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
            Admin admin = entityManager.find(Admin.class, id);
            if (admin != null) {
                entityManager.remove(admin);
                entityManager.getTransaction().commit();
                entityManager.close();
                return true;
            }

            entityManager.getTransaction().rollback();
            return false;
        } catch (Exception e) {
            if (entityManager.getTransaction().isActive()) {
                entityManager.getTransaction().rollback();
            }
            entityManager.close();
            return false;
        }finally {
            entityManager.close();
        }
    }

    // ================================================= QUERIES

    public Optional<Admin> findByEmail(String email) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Optional<Admin> adminOpt = entityManager.createQuery(
                        "SELECT a FROM Admin a WHERE a.email = :email", Admin.class)
                .setParameter("email", email)
                .getResultList()
                .stream()
                .findFirst();
        entityManager.close();
        return adminOpt;
    }

    public boolean existsByEmail(String email) {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Long count = entityManager.createQuery(
                        "SELECT COUNT(a) FROM Admin a WHERE a.email = :email", Long.class)
                .setParameter("email", email)
                .getSingleResult();
        entityManager.close();
        return count != null && count > 0;
    }

    public boolean existsById(String id) {
        return findById(id).isPresent();
    }

    // ================================================= STATUS CHANGE

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

        try {
            entityManager.getTransaction().begin();

            Admin admin = entityManager.find(Admin.class, id);
            if (admin == null) {
                entityManager.getTransaction().rollback();
                entityManager.close();
                return false;
            }

            admin.setActive(active);
            entityManager.merge(admin);
            entityManager.getTransaction().commit();

            return true;
        }finally {
            entityManager.close();
        }
    }

    // ================================================= UTILS

    public long count() {
        EntityManager entityManager = JPAUtil.getEntityManagerFactory().createEntityManager();
        Long count = entityManager.createQuery("SELECT COUNT(a) FROM Admin a", Long.class)
                .getSingleResult();
        entityManager.close();
        return count != null ? count : 0;
    }
}
