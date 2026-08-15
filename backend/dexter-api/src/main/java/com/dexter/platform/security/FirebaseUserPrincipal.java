package com.dexter.platform.security;

import java.security.Principal;
import java.util.Objects;

public final class FirebaseUserPrincipal implements Principal {

    private final String uid;
    private final String email;
    private final String displayName;

    public FirebaseUserPrincipal(String uid, String email, String displayName) {
        this.uid = Objects.requireNonNull(uid, "uid must not be null");
        this.email = email;
        this.displayName = displayName;
    }

    @Override
    public String getName() {
        return uid;
    }

    public String getUid() {
        return uid;
    }

    public String getEmail() {
        return email;
    }

    public String getDisplayName() {
        return displayName;
    }
}
