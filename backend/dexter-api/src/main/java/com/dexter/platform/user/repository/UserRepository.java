package com.dexter.platform.user.repository;

import com.dexter.platform.user.model.User;

import java.util.List;
import java.util.Optional;

public interface UserRepository {

    Optional<User> findById(String id);

    List<User> findAll();

    User save(User user);

    void deleteById(String id);
}
