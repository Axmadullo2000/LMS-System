package com.lms.system.util;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

public class JPAUtil {
    private static EntityManagerFactory entityManagerFactory;

    public static void initialize(String persistenceUnitName) {
        if (entityManagerFactory == null || !entityManagerFactory.isOpen()) {
            try {
                System.out.println("========================================");
                System.out.println("Initializing JPA...");
                System.out.println("Persistence Unit: " + persistenceUnitName);
                System.out.println("========================================");

                entityManagerFactory = Persistence.createEntityManagerFactory(persistenceUnitName);

                System.out.println("✓ EntityManagerFactory created successfully");
                System.out.println("✓ Database tables should be created now");
                System.out.println("========================================");

            } catch (Exception e) {
                System.err.println("========================================");
                System.err.println("✗ FATAL: Failed to create EntityManagerFactory!");
                System.err.println("========================================");
                e.printStackTrace();
                throw new RuntimeException("Cannot initialize JPA", e);
            }
        }
    }

    public static EntityManagerFactory getEntityManagerFactory() {
        if (entityManagerFactory == null || !entityManagerFactory.isOpen()) {
            throw new IllegalStateException(
                    "EntityManagerFactory not initialized! " +
                            "Call JPAUtil.initialize() first from ApplicationInitializer."
            );
        }
        return entityManagerFactory;
    }

    public static void close() {
        if (entityManagerFactory != null && entityManagerFactory.isOpen()) {
            System.out.println("→ Closing EntityManagerFactory...");
            entityManagerFactory.close();
            entityManagerFactory = null;
            System.out.println("✓ EntityManagerFactory closed");
        }
    }

    public static boolean isInitialized() {
        return entityManagerFactory != null && entityManagerFactory.isOpen();
    }
}
