// loading_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dotCtrls;
  late final List<Animation<double>> _dotScales;

  @override
  void initState() {
    super.initState();

    // Create four controllers, each with a 600 ms period
    _dotCtrls = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _dotScales = _dotCtrls
        .map((controller) => CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            ).drive(Tween(begin: 0.5, end: 1.0)))
        .toList();

    // Staggered start so the dots pulse sequentially
    for (int i = 0; i < _dotCtrls.length; i++) {
      Future.delayed(Duration(milliseconds: i * 120), () {
        _dotCtrls[i].repeat(reverse: true);
      });
    }

    // After ~3 s switch to the main route
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _dotCtrls) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9E9DF), Color(0xFFEAE4F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated dots row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final bool isBlue = index.isEven;
                return AnimatedBuilder(
                  animation: _dotScales[index],
                  builder: (_, child) => Transform.scale(
                    scale: _dotScales[index].value,
                    child: child,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isBlue
                          ? const Color(0xFF001B7A) // navy
                          : const Color(0xFF2ECC71), // green
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            Text(
              'Loading  Please wait...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
