package com.dexter.platform.user.service;

import com.dexter.platform.user.model.User;
import com.google.firebase.auth.FirebaseToken;

import java.util.Optional;

public interface UserService {

    Optional<User> findById(String id);

    User save(User user);

    /**
     * Sync user on successful Firebase login. Creates the user if missing and updates lastLogin.
     */
    User syncOnLogin(FirebaseToken token);
}
