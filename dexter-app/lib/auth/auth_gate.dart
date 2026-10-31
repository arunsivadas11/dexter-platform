import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // userChanges also detects profile changes after email verification.
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Unable to check your sign-in status.')),
          );
        }

        final user = snapshot.data;

        // Not signed in: show login.
        if (user == null) {
          return const LoginScreen();
        }

        // Require email verification for email/password accounts.
        final isEmailPasswordUser = user.providerData.any(
          (provider) => provider.providerId == 'password',
        );

        if (isEmailPasswordUser && !user.emailVerified) {
          return const VerifyEmailScreen();
        }

        // Authenticated: go directly to the dashboard.
        return const DexterHome();
      },
    );
  }
}

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool loading = false;
  String? message;

  Future<void> checkVerification() async {
    setState(() {
      loading = true;
      message = null;
    });

    try {
      await FirebaseAuth.instance.currentUser?.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (refreshedUser?.emailVerified == true) {
        setState(() {
          message = 'Email verified successfully. Opening your dashboard...';
        });
      } else {
        setState(() {
          message = 'Your email is not verified yet.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          message = 'Could not check verification status.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> resendEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (mounted) {
        setState(() {
          message = 'Verification email sent. Check your inbox.';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          message = e.message ?? 'Could not send verification email.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_unread_outlined, size: 54),
                const SizedBox(height: 20),
                const Text(
                  'Verify your email',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please verify your email address using the link we sent you. '
                  'After verification, return here and check again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (message != null) Text(message!),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: loading ? null : checkVerification,
                  child: Text(
                    loading ? 'Checking...' : 'I have verified my email',
                  ),
                ),
                TextButton(
                  onPressed: loading ? null : resendEmail,
                  child: const Text('Resend verification email'),
                ),
                TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
