import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LandlordVerifyEmailScreen extends StatefulWidget {
  const LandlordVerifyEmailScreen({super.key});

  @override
  State<LandlordVerifyEmailScreen> createState() =>
      _LandlordVerifyEmailScreenState();
}

class _LandlordVerifyEmailScreenState extends State<LandlordVerifyEmailScreen> {
  bool _isVerifying = false;
  String _statusMessage =
      'A verification link has been sent to your email. Please check your inbox and click the link to verify.';

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
  }

  Future<void> _sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _isVerifying = true);

    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/landlord_dashboard');
      } else {
        if (!mounted) return;
        setState(() {
          _isVerifying = false;
          _statusMessage =
              "Email not yet verified. Please check your inbox or spam.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _statusMessage = "An error occurred: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verify Your Email"),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            _isVerifying
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _checkVerificationStatus,
                    icon: const Icon(Icons.check_circle),
                    label: const Text("I have verified"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
