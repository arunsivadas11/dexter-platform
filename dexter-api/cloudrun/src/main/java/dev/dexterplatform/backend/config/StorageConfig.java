package dev.dexterplatform.backend.config;

import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class StorageConfig {

    @Value("${dexter.gcp.project-id}")
    private String projectId;

    @Bean
    public Storage googleCloudStorage() {
        return StorageOptions.newBuilder()
                .setProjectId(projectId)
                .build()
                .getService();
    }
}