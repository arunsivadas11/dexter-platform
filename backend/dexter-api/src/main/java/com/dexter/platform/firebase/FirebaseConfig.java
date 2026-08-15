package com.dexter.platform.firebase;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;
import com.google.cloud.firestore.Firestore;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

@Configuration
public class FirebaseConfig {

    @Value("${gcp.project-id}")
    private String projectId;

    @Value("${firebase.credentials}")
    private String firebaseCredentials;

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (!StringUtils.hasText(projectId)) {
            throw new IllegalStateException("GCP project ID must be provided via GCP_PROJECT_ID or application properties");
        }

        if (!StringUtils.hasText(firebaseCredentials)) {
            throw new IllegalStateException("Firebase credentials must be provided via FIREBASE_CREDENTIALS or application properties");
        }

        GoogleCredentials credentials = buildCredentials();

        return FirebaseApp.getApps().stream()
                .filter(app -> "dexter-firebase".equals(app.getName()))
                .findFirst()
                .orElseGet(() -> FirebaseApp.initializeApp(
                        FirebaseOptions.builder()
                                .setCredentials(credentials)
                                .setProjectId(projectId)
                                .build(),
                        "dexter-firebase"
                ));
    }

    @Bean
    public Firestore firestore(FirebaseApp firebaseApp) {
        return FirestoreClient.getFirestore(firebaseApp);
    }

    private GoogleCredentials buildCredentials() throws IOException {
        String candidate = firebaseCredentials.trim();

        if (candidate.startsWith("{") && candidate.endsWith("}")) {
            try (InputStream stream = new ByteArrayInputStream(candidate.getBytes(StandardCharsets.UTF_8))) {
                return GoogleCredentials.fromStream(stream);
            }
        }

        Path credentialPath = Path.of(candidate);
        if (Files.exists(credentialPath)) {
            try (InputStream stream = Files.newInputStream(credentialPath)) {
                return GoogleCredentials.fromStream(stream);
            }
        }

        try (InputStream stream = new ByteArrayInputStream(candidate.getBytes(StandardCharsets.UTF_8))) {
            return GoogleCredentials.fromStream(stream);
        }
    }
}
