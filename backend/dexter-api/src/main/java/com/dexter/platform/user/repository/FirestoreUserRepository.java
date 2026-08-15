package com.dexter.platform.user.repository;

import com.dexter.platform.user.model.Role;
import com.dexter.platform.user.model.User;
import com.dexter.platform.user.model.UserStatus;
import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.CollectionReference;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Optional;
import java.util.concurrent.ExecutionException;

@Repository
public class FirestoreUserRepository implements UserRepository {

    private static final String USERS_COLLECTION = "users";

    private final CollectionReference users;

    public FirestoreUserRepository(Firestore firestore) {
        this.users = firestore.collection(USERS_COLLECTION);
    }

    @Override
    public Optional<User> findById(String id) {
        try {
            DocumentSnapshot snapshot = users.document(id).get().get();
            if (!snapshot.exists()) {
                return Optional.empty();
            }
            return Optional.of(mapToUser(snapshot));
        } catch (InterruptedException | ExecutionException ex) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Failed to load user from Firestore", ex);
        }
    }

    @Override
    public List<User> findAll() {
        try {
            QuerySnapshot querySnapshot = users.get().get();
            List<User> result = new ArrayList<>();
            for (DocumentSnapshot snapshot : querySnapshot.getDocuments()) {
                result.add(mapToUser(snapshot));
            }
            return result;
        } catch (InterruptedException | ExecutionException ex) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Failed to load users from Firestore", ex);
        }
    }

    @Override
    public User save(User user) {
        try {
            DocumentReference reference = user.getId() == null
                    ? users.document()
                    : users.document(user.getId());
            String documentId = reference.getId();
            User stored = user.getId() == null ? user.toBuilder().id(documentId).build() : user;
            reference.set(mapFromUser(stored)).get();
            return stored;
        } catch (InterruptedException | ExecutionException ex) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Failed to save user to Firestore", ex);
        }
    }

    @Override
    public void deleteById(String id) {
        try {
            users.document(id).delete().get();
        } catch (InterruptedException | ExecutionException ex) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Failed to delete user from Firestore", ex);
        }
    }

    private User mapToUser(DocumentSnapshot snapshot) {
        Timestamp createdAt = snapshot.getTimestamp("createdAt");
        Timestamp lastLogin = snapshot.getTimestamp("lastLogin");

        return User.builder()
                .id(snapshot.getId())
                .email(snapshot.getString("email"))
                .displayName(snapshot.getString("displayName"))
                .photoUrl(snapshot.getString("photoUrl"))
                .role(toRole(snapshot.getString("role")))
                .enabledProducts(new HashSet<>(snapshot.get("enabledProducts", List.class) != null ? snapshot.get("enabledProducts", List.class) : List.of()))
                .baseCurrency(snapshot.getString("baseCurrency"))
                .timezone(snapshot.getString("timezone"))
                .theme(snapshot.getString("theme"))
                .createdAt(createdAt != null ? createdAt.toDate().toInstant() : null)
                .lastLogin(lastLogin != null ? lastLogin.toDate().toInstant() : null)
                .status(toStatus(snapshot.getString("status")))
                .build();
    }

    private Map<String, Object> mapFromUser(User user) {
        Map<String, Object> map = new HashMap<>();
        map.put("email", user.getEmail());
        map.put("displayName", user.getDisplayName());
        map.put("photoUrl", user.getPhotoUrl());
        map.put("role", user.getRole() != null ? user.getRole().name() : null);
        map.put("enabledProducts", user.getEnabledProducts());
        map.put("baseCurrency", user.getBaseCurrency());
        map.put("timezone", user.getTimezone());
        map.put("theme", user.getTheme());
        map.put("createdAt", user.getCreatedAt());
        map.put("lastLogin", user.getLastLogin());
        map.put("status", user.getStatus() != null ? user.getStatus().name() : null);
        return map;
    }

    private Role toRole(String raw) {
        if (raw == null) {
            return null;
        }
        try {
            return Role.valueOf(raw);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    private UserStatus toStatus(String raw) {
        if (raw == null) {
            return null;
        }
        try {
            return UserStatus.valueOf(raw);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}
