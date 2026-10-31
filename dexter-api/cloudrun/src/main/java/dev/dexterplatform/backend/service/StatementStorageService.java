package dev.dexterplatform.backend.service;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;
import java.util.UUID;

@Service
public class StatementStorageService {

    private final Storage storage;

    @Value("${dexter.gcp.preprocessing-bucket}")
    private String preprocessingBucket;

    public StatementStorageService(Storage storage) {
        this.storage = storage;
    }

    public UploadResult upload(
            String firebaseUid,
            MultipartFile file,
            CsvValidationService.CsvValidationResult validation
    ) throws IOException {

        String uploadId = UUID.randomUUID().toString();

        String objectName = firebaseUid
                + "/"
                + uploadId
                + "/original.csv";

        BlobInfo blobInfo = BlobInfo.newBuilder(
                        BlobId.of(preprocessingBucket, objectName)
                )
                .setContentType("text/csv")
                .setCacheControl("no-store")
                .setMetadata(Map.of(
                        "uploadId", uploadId,
                        "recordCount", String.valueOf(validation.recordCount())
                ))
                .build();

        // Store the original bytes without modifying the CSV.
        storage.create(blobInfo, file.getBytes());

        return new UploadResult(
                uploadId,
                objectName,
                validation.fileSizeBytes(),
                validation.recordCount(),
                validation.maxColumnCount(),
                "UPLOADED"
        );
    }

    public record UploadResult(
            String uploadId,
            String objectPath,
            long fileSizeBytes,
            int recordCount,
            int maxColumnCount,
            String status
    ) {
    }
}