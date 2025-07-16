import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LandlordVerifyEmailScreen extends StatefulWidget {
  const LandlordVerifyEmailScreen({super.key});

  @override
  State<LandlordVerifyEmailScreen> createState() =>
      _LandlordVerifyEmailScreenState();
}

class _LandlordVerifyEmailScreenState extends State<LandlordVerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 10));
      if (mounted) {
        setState(() => canResendEmail = true);
      }
    } catch (e) {
      debugPrint('Error sending email verification: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send verification email.')),
      );
    }
  }

  Future<void> checkEmailVerified() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        timer?.cancel();
        if (!mounted) return;
        setState(() => isEmailVerified = true);
        Navigator.of(context)
            .pushReplacementNamed('/home'); // or your desired page
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Verify Email')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: isEmailVerified
                ? const Text(
                    'Email successfully verified!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'A verification email has been sent to your email address. Please verify your email to continue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.email),
                        label: const Text('Resend Email'),
                        onPressed:
                            canResendEmail ? sendVerificationEmail : null,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => FirebaseAuth.instance.signOut(),
                      )
                    ],
                  ),
          ),
        ),
      );
}
