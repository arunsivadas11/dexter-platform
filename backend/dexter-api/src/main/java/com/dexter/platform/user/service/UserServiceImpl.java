package com.dexter.platform.user.service;

import com.dexter.platform.user.model.Role;
import com.dexter.platform.user.model.User;
import com.dexter.platform.user.model.UserStatus;
import com.dexter.platform.user.repository.UserRepository;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.HashSet;
import java.util.Optional;

@Service
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    private static final org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger(UserServiceImpl.class);

    @Override
    public Optional<User> findById(String id) {
        return userRepository.findById(id);
    }

    @Override
    public User save(User user) {
        return userRepository.save(user);
    }

    @Override
    public User syncOnLogin(FirebaseToken token) {
        String uid = token.getUid();
        var now = Instant.now();

        return userRepository.findById(uid)
                .map(existing -> {
                    existing.setLastLogin(now);
                    if (existing.getCreatedAt() == null) {
                        existing.setCreatedAt(now);
                    }
                    return userRepository.save(existing);
                })
                .orElseGet(() -> {
                    User created = User.builder()
                            .id(uid)
                            .email(token.getEmail())
                            .displayName(token.getName())
                            .photoUrl(token.getPicture())
                            .role(Role.USER)
                            .enabledProducts(new HashSet<>())
                            .baseCurrency(null)
                            .timezone(null)
                            .theme(null)
                            .createdAt(now)
                            .lastLogin(now)
                            .status(UserStatus.ACTIVE)
                            .build();
                    var saved = userRepository.save(created);
                    logger.info("Created user uid={}", uid);
                    return saved;
                });
    }
}
