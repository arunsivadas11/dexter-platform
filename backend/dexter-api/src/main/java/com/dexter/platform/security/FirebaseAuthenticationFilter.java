package com.dexter.platform.security;

import com.google.firebase.auth.FirebaseAuthException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import com.dexter.platform.user.service.UserService;

import java.io.IOException;
import java.util.List;

@Component
public class FirebaseAuthenticationFilter extends OncePerRequestFilter {

    private final FirebaseTokenVerifier tokenVerifier;
    private final UserService userService;
    private static final Logger logger = LoggerFactory.getLogger(FirebaseAuthenticationFilter.class);

    public FirebaseAuthenticationFilter(FirebaseTokenVerifier tokenVerifier, UserService userService) {
        this.tokenVerifier = tokenVerifier;
        this.userService = userService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String authorizationHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String idToken = authorizationHeader.substring(7).trim();
        if (idToken.isEmpty()) {
            response.sendError(HttpStatus.UNAUTHORIZED.value(), "Authorization token is missing");
            return;
        }

        try {
            var decodedToken = tokenVerifier.verifyToken(idToken);

            // synchronize user record on each successful login
            try {
                var synced = userService.syncOnLogin(decodedToken);
                logger.info("Login succeeded for uid={}", decodedToken.getUid());
            } catch (Exception ex) {
                logger.warn("User sync failed for uid={}", decodedToken.getUid());
            }

            var principal = new FirebaseUserPrincipal(
                    decodedToken.getUid(),
                    decodedToken.getEmail(),
                    decodedToken.getName()
            );

            var authentication = new FirebaseAuthenticationToken(
                    principal,
                    List.of(new SimpleGrantedAuthority("ROLE_USER"))
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);
            filterChain.doFilter(request, response);
        } catch (FirebaseAuthException exception) {
            response.sendError(HttpStatus.UNAUTHORIZED.value(), "Invalid Firebase token");
        }
    }
}
