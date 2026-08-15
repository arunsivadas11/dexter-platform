package com.dexter.platform.user.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.Set;

@Data
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class User {

    private String id;
    private String email;
    private String displayName;
    private String photoUrl;
    private Role role;
    private Set<String> enabledProducts;
    private String baseCurrency;
    private String timezone;
    private String theme;
    private Instant createdAt;
    private Instant lastLogin;
    private UserStatus status;
}
