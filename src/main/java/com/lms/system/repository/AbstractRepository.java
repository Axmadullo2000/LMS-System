package com.lms.system.repository;

import java.util.List;
import java.util.Optional;


public abstract class AbstractRepository<T> {
    protected abstract void setId(T t, String id);

    protected abstract String getId(T item);

    public abstract void save(T entity);

    public abstract List<T> findAll();

    public abstract Optional<T> findById(String groupId);
}
