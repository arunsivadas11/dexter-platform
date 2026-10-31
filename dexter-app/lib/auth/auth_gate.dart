import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_client.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
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

        if (user == null) {
          return const LoginScreen();
        }

        if (!user.emailVerified &&
            user.providerData.any(
              (provider) => provider.providerId == 'password',
            )) {
          return const VerifyEmailScreen();
        }

        // Temporary screen to test Firebase authentication with Spring Boot.
        return const BackendAuthTestScreen();
      },
    );
  }
}

class BackendAuthTestScreen extends StatefulWidget {
  const BackendAuthTestScreen({super.key});

  @override
  State<BackendAuthTestScreen> createState() => _BackendAuthTestScreenState();
}

class _BackendAuthTestScreenState extends State<BackendAuthTestScreen> {
  final ApiClient apiClient = ApiClient();

  bool loading = false;
  int? statusCode;
  String? responseBody;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    testBackendAuthentication();
  }

  Future<void> testBackendAuthentication() async {
    setState(() {
      loading = true;
      statusCode = null;
      responseBody = null;
      errorMessage = null;
    });

    try {
      final response = await apiClient.getCurrentUser();

      if (!mounted) return;

      setState(() {
        statusCode = response.statusCode;
        responseBody = ApiClient.formatResponseBody(response.body);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authenticated = statusCode == 200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dexter Platform - Backend Test'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 56,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Firebase Authentication',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'No email available',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Spring Boot API Authentication',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (loading)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Authenticating with backend...'),
                    ],
                  ),
                if (!loading && statusCode != null) ...[
                  Text(
                    'HTTP Status: $statusCode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: authenticated ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authenticated
                        ? 'Backend authentication successful.'
                        : 'Backend returned an error.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Backend response:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(responseBody ?? ''),
                  ),
                ],
                if (errorMessage != null) ...[
                  const Text(
                    'Connection error',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(errorMessage!),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: loading ? null : testBackendAuthentication,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Test backend authentication again'),
                ),
                if (authenticated) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const DexterHome()),
                      );
                    },
                    child: const Text('Continue to dashboard'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
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

      if (refreshedUser?.emailVerified == true) {
        setState(() => message = 'Email verified successfully.');
      } else {
        setState(() => message = 'Your email is not verified yet.');
      }
    } catch (_) {
      setState(() => message = 'Could not check verification status.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resendEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        setState(() => message = 'Verification email sent. Check your inbox.');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(
          () => message = e.message ?? 'Could not send verification email.',
        );
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
                  onPressed: resendEmail,
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
