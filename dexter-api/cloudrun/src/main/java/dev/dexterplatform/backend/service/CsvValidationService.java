package dev.dexterplatform.backend.service;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.io.StringReader;
import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;

@Service
public class CsvValidationService {

    @Value("${dexter.upload.max-file-size-bytes:10485760}")
    private long maxFileSizeBytes;

    @Value("${dexter.upload.allowed-extensions:csv}")
    private List<String> allowedExtensions;

    public CsvValidationResult validate(MultipartFile file) {

        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "The uploaded file is empty."
            );
        }

        long fileSize = file.getSize();

        if (fileSize > maxFileSizeBytes) {
            throw new ResponseStatusException(
                    HttpStatus.PAYLOAD_TOO_LARGE,
                    "The file exceeds the maximum allowed size of 10 MB."
            );
        }

        validateFileExtension(file.getOriginalFilename());

        try {
            byte[] bytes = file.getBytes();

            // Check the actual byte count, not only the reported file size.
            if (bytes.length == 0) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "The uploaded file is empty."
                );
            }

            if (bytes.length > maxFileSizeBytes) {
                throw new ResponseStatusException(
                        HttpStatus.PAYLOAD_TOO_LARGE,
                        "The file exceeds the maximum allowed size of 10 MB."
                );
            }

            String content = decodeUtf8(bytes);

            // Remove an optional UTF-8 byte-order mark.
            if (!content.isEmpty() && content.charAt(0) == '\uFEFF') {
                content = content.substring(1);
            }

            // NUL characters are a strong indication that this is not a text CSV.
            if (content.indexOf('\0') >= 0) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "The file contains binary data and is not a supported CSV."
                );
            }

            return parseCsv(content, bytes.length);

        } catch (CharacterCodingException exception) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "The CSV must use valid UTF-8 text encoding."
            );
        } catch (IOException exception) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "The CSV file could not be read or parsed."
            );
        }
    }

    private void validateFileExtension(String originalFilename) {

        if (originalFilename == null || originalFilename.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "A CSV filename is required."
            );
        }

        // Treat both slash styles as path separators.
        String filename = originalFilename.replace('\\', '/');
        filename = filename.substring(filename.lastIndexOf('/') + 1);

        int dotIndex = filename.lastIndexOf('.');

        if (dotIndex < 0 || dotIndex == filename.length() - 1) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Only CSV files are accepted."
            );
        }

        String extension = filename.substring(dotIndex + 1)
                .toLowerCase(Locale.ROOT);

        boolean allowed = allowedExtensions.stream()
                .map(value -> value.replaceFirst("^\\.", ""))
                .map(value -> value.toLowerCase(Locale.ROOT))
                .anyMatch(extension::equals);

        if (!allowed) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Only CSV files are accepted."
            );
        }
    }

    private String decodeUtf8(byte[] bytes)
            throws CharacterCodingException {

        return StandardCharsets.UTF_8
                .newDecoder()
                .onMalformedInput(CodingErrorAction.REPORT)
                .onUnmappableCharacter(CodingErrorAction.REPORT)
                .decode(ByteBuffer.wrap(bytes))
                .toString();
    }

    private CsvValidationResult parseCsv(
            String content,
            long fileSizeBytes
    ) throws IOException {

        int recordCount = 0;
        int maxColumnCount = 0;
        boolean hasContent = false;

        try (
                CSVParser parser = CSVParser.parse(
                        new StringReader(content),
                        CSVFormat.DEFAULT
                )
        ) {
            for (CSVRecord record : parser) {

                recordCount++;
                maxColumnCount = Math.max(
                        maxColumnCount,
                        record.size()
                );

                for (String value : record) {
                    if (value != null && !value.isBlank()) {
                        hasContent = true;
                    }
                }
            }
        }

        if (!hasContent) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "The CSV does not contain any data."
            );
        }

        return new CsvValidationResult(
                fileSizeBytes,
                recordCount,
                maxColumnCount
        );
    }

    public record CsvValidationResult(
            long fileSizeBytes,
            int recordCount,
            int maxColumnCount
    ) {
    }
}