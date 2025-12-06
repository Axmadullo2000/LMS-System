package com.lms.system.repository.status;

public interface ChangeStatusUser {
    boolean activate(String id);

    boolean deactivate(String id);
}
