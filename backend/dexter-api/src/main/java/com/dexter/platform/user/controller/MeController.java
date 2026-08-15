package com.dexter.platform.user.controller;

import com.dexter.platform.common.ApiResponse;
import com.dexter.platform.user.dto.MeResponse;
import com.dexter.platform.user.model.User;
import com.dexter.platform.user.service.UserService;
import com.dexter.platform.security.FirebaseUserPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class MeController {

    private final UserService userService;

    public MeController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<MeResponse>> me() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof FirebaseUserPrincipal)) {
            return ResponseEntity.status(401).body(ApiResponse.<MeResponse>builder().success(false).message("Unauthorized").build());
        }

        FirebaseUserPrincipal principal = (FirebaseUserPrincipal) auth.getPrincipal();
        User user = userService.findById(principal.getUid()).orElse(null);

        MeResponse res = new MeResponse();
        res.setId(principal.getUid());
        res.setName(principal.getDisplayName());
        res.setEmail(principal.getEmail());
        res.setProducts(user != null && user.getEnabledProducts() != null ? List.copyOf(user.getEnabledProducts()) : List.of());

        return ResponseEntity.ok(ApiResponse.<MeResponse>builder().success(true).data(res).message("Success").build());
    }
}
