# dexter-api (backend/dexter-api)

Short guide to run and test the `dexter-api` service locally.

Prerequisites
- JDK 21
- Internet access to resolve Maven dependencies
- `./mvnw` is included in the module

Environment variables (required)
- `GCP_PROJECT_ID` - your GCP project id
- `FIREBASE_CREDENTIALS` - JSON string of the service account OR a path to the JSON file. NEVER commit service account files.
- `BUCKET_NAME` - GCS bucket name (if used)
- `SPRING_PROFILES_ACTIVE` - optional (`local` by default)

Run locally
```bash
cd backend/dexter-api
export GCP_PROJECT_ID=your-project-id
# Either set the JSON text directly or a path to the JSON file
export FIREBASE_CREDENTIALS='{"type": "service_account", ... }'
export BUCKET_NAME=your-bucket
./mvnw spring-boot:run
```

Health and observability
- Actuator health: `http://localhost:8080/actuator/health`

Swagger / OpenAPI UI
- OpenAPI UI: `http://localhost:8080/swagger-ui.html`

Testing the authenticated `/api/v1/me` endpoint

This endpoint requires a valid Firebase ID token in the `Authorization` header.

Example (replace `FIREBASE_ID_TOKEN` with a real token):
```bash
curl -H "Authorization: Bearer FIREBASE_ID_TOKEN" http://localhost:8080/api/v1/me
```

Notes
- Authentication is handled by Firebase; the app initializes Firebase once via `FirebaseConfig` and other components inject `Firestore` or `UserRepository`.
- The `UserService` performs on-login synchronization (create user if missing, update `lastLogin`).
- Logging avoids printing tokens, credentials, or other secrets.

If you'd like, I can add a dockerfile or a small Postman collection for quick manual testing.
