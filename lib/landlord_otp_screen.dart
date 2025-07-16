import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LandlordOtpScreen extends StatefulWidget {
  final String email;
  final String userId;
  const LandlordOtpScreen({
    super.key,
    required this.email,
    required this.userId,
  });

  @override
  State<LandlordOtpScreen> createState() => _LandlordOtpScreenState();
}

class _LandlordOtpScreenState extends State<LandlordOtpScreen> {
  String _code = '';
  bool _busy = false;

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _verify() async {
    if (_code.length != 6) {
      _msg('Enter all 6 digits');
      return;
    }
    setState(() => _busy = true);

    // ── fetch OTP from Firestore
    final snap = await FirebaseFirestore.instance
        .collection('otps')
        .doc(widget.userId)
        .get();

    if (!mounted) return;
    setState(() => _busy = false);

    if (!snap.exists) {
      _msg('Code expired – request new one.');
      return;
    }

    final data = snap.data()!;
    final int stored = data['code'];
    final expires = (data['expires'] as Timestamp).toDate();

    if (DateTime.now().isAfter(expires)) {
      _msg('Code has expired');
      return;
    }

    if (stored.toString() != _code) {
      _msg('Incorrect code');
      return;
    }

    // ── mark landlord verified
    await FirebaseFirestore.instance
        .collection('landlords')
        .doc(widget.userId)
        .update({'verified': true});

    if (!mounted) return;
    _msg('Verified! 🎉');
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  Future<void> _resend() async {
    if (!mounted) return;
    _msg('For demo, re‑signup to get a new code');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            _page(),
            if (_busy)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      );

  Widget _page() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9E9DF), Color(0xFFEAE4F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text('Request For OTP',
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Enter the 6‑digit code sent to\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // Pin‑code input
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    inactiveColor: Colors.green,
                    activeColor: Colors.green,
                    selectedColor: Colors.green,
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onChanged: (v) => _code = v,
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _resend,
                    child: Text('Resend Code',
                        style: GoogleFonts.poppins(
                          decoration: TextDecoration.underline,
                          color: Colors.green[700],
                        )),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001B7A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Verify'),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      );
}
