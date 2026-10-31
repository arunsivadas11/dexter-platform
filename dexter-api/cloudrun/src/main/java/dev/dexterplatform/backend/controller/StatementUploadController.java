package dev.dexterplatform.backend.controller;

import dev.dexterplatform.backend.service.CsvValidationService;
import dev.dexterplatform.backend.service.StatementStorageService;
import dev.dexterplatform.backend.service.StatementStorageService.UploadResult;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;

@RestController
@RequestMapping("/api/v1/statements")
public class StatementUploadController {

    private final CsvValidationService csvValidationService;
    private final StatementStorageService statementStorageService;

    public StatementUploadController(
            CsvValidationService csvValidationService,
            StatementStorageService statementStorageService
    ) {
        this.csvValidationService = csvValidationService;
        this.statementStorageService = statementStorageService;
    }

    @PostMapping(
            value = "/upload",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public ResponseEntity<UploadResult> uploadStatement(
            @RequestParam("file") MultipartFile file,
            Authentication authentication
    ) {

        if (authentication == null || !authentication.isAuthenticated()) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Authentication is required."
            );
        }

        // The Firebase UID comes from the verified security context.
        String firebaseUid = authentication.getName();

        // Validate before storing anything in GCS.
        CsvValidationService.CsvValidationResult validation =
                csvValidationService.validate(file);

        try {
            UploadResult result = statementStorageService.upload(
                    firebaseUid,
                    file,
                    validation
            );

            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(result);

        } catch (IOException exception) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "The statement could not be stored. Please try again."
            );
        }
    }
}