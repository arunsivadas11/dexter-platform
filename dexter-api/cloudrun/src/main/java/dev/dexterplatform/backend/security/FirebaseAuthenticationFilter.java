
package dev.dexterplatform.backend.security;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

@Component
public class FirebaseAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger log =
            LoggerFactory.getLogger(FirebaseAuthenticationFilter.class);

    private final FirebaseAuth firebaseAuth;

    public FirebaseAuthenticationFilter(FirebaseAuth firebaseAuth) {
        this.firebaseAuth = firebaseAuth;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String requestPath = request.getRequestURI();

        String authorization =
                request.getHeader(HttpHeaders.AUTHORIZATION);

        if (authorization == null ||
                !authorization.startsWith("Bearer ")) {

            if (requestPath.startsWith("/api/")) {
                log.warn(
                        "Authentication header missing or invalid for {}",
                        requestPath
                );
            }

            filterChain.doFilter(request, response);
            return;
        }

        String idToken = authorization.substring(7).trim();

        if (idToken.isEmpty()) {
            log.warn("Empty Bearer token received for {}", requestPath);
            SecurityContextHolder.clearContext();
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Empty authentication token"
            );
            return;
        }

        try {
            log.debug("Verifying Firebase ID token for {}", requestPath);

            FirebaseToken decodedToken =
                    firebaseAuth.verifyIdToken(idToken, true);

            log.debug(
                    "Firebase token verification successful for {}",
                    requestPath
            );

            boolean emailVerified = Boolean.TRUE.equals(
                    decodedToken.getClaims().get("email_verified")
            );

            if (!emailVerified) {
                log.warn(
                        "Firebase authentication rejected for {}: email not verified",
                        requestPath
                );

                SecurityContextHolder.clearContext();
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Email verification required"
                );
                return;
            }

            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(
                            decodedToken.getUid(),
                            null,
                            Collections.emptyList()
                    );

            authentication.setDetails(
                    new WebAuthenticationDetailsSource()
                            .buildDetails(request)
            );

            SecurityContextHolder.getContext()
                    .setAuthentication(authentication);

            log.info(
                    "Firebase authentication successful for {}",
                    requestPath
            );

        } catch (Exception exception) {

            log.error(
                    "Firebase token verification failed for {}. Exception type: {}",
                    requestPath,
                    exception.getClass().getName(),
                    exception
            );

            SecurityContextHolder.clearContext();

            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Invalid authentication token"
            );
            return;
        }

        filterChain.doFilter(request, response);
    }
}
