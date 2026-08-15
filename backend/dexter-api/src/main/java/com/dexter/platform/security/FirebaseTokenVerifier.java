package com.dexter.platform.security;

import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

@Service
public class FirebaseTokenVerifier {

    private final FirebaseApp firebaseApp;

    public FirebaseTokenVerifier(FirebaseApp firebaseApp) {
        this.firebaseApp = firebaseApp;
    }

    public FirebaseToken verifyToken(String idToken) throws FirebaseAuthException {
        Assert.hasText(idToken, "Firebase ID token must be provided");
        return FirebaseAuth.getInstance(firebaseApp).verifyIdToken(idToken);
    }
}
