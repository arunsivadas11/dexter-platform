
package dev.dexterplatform.backend.controller;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    @GetMapping("/me")
    public Map<String, String> getCurrentUser(
            Authentication authentication
    ) {
        return Map.of(
                "firebaseUid",
                authentication.getName()
        );
    }
}
