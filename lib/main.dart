import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase config
import 'firebase_options.dart';

// Core screens
import 'intro_screen.dart';
import 'loading_screen.dart';
import 'landlord_signup_screen.dart';
import 'landlord_login_screen.dart';
import 'landlord_verify_email_screen.dart';
import 'landlord_dashboard_screen.dart';
import 'landlord_forgot_password_screen.dart';
import 'landlord_settings_screen.dart';
import 'landlord_profile_screen.dart';
import 'change_password_screen.dart';

// Dashboard inner screens (Placeholder implementations for now)
import 'wallet_screen.dart';
import 'my_apartment_screen.dart';
import 'pending_transactions_screen.dart';
import 'transaction_screen.dart';
import 'contact_screen.dart';
import 'notification_screen.dart';
import 'add_apartment_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AccommediaryApp());
}

class AccommediaryApp extends StatelessWidget {
  const AccommediaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accommediary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/intro',
      routes: {
        '/intro': (_) => const IntroScreen(),
        '/loading': (_) => const LoadingScreen(),
        '/main': (_) => const MainPage(),
        '/landlord_signup': (_) => const LandlordSignupScreen(),
        '/landlord_login': (_) => const LandlordLoginScreen(),
        '/landlord_verify_email': (_) => const LandlordVerifyEmailScreen(),
        '/landlord_dashboard': (_) => const LandlordDashboardScreen(),
        '/landlord_forgot_password': (_) =>
            const LandlordForgotPasswordScreen(),
        '/landlord_settings': (_) => const LandlordSettingsScreen(),
        '/profile': (_) => const LandlordProfileScreen(),
        '/change_password': (_) => const ChangePasswordScreen(),

        // 🟩 Dashboard inner links
        '/wallet': (_) => const WalletScreen(),
        '/my_apartment': (_) => const MyApartmentScreen(),
        '/pending_transactions': (_) => const PendingTransactionsScreen(),
        '/transaction': (_) => const TransactionScreen(),
        '/contact': (_) => const ContactScreen(),
        '/notification': (_) => const NotificationScreen(),
        '/add_apartment': (_) => const AddApartmentScreen(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(context, '/intro');
                      }
                    },
                  ),
                ),
                const Spacer(flex: 2),
                Image.asset(
                  'assets/images/acc_logo.png',
                  height: 80,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Where Tenants meet\nthe landlord directly',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'No intermediary involved',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                  ),
                ),
                const Spacer(flex: 3),
                _ActionButton(
                  label: 'Get Accommodation',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tenant flow coming soon'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _ActionButton(
                  label: 'Post Accommodation',
                  onTap: () {
                    Navigator.pushNamed(context, '/landlord_login');
                  },
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2ECC71),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          shadowColor: Colors.green.withValues(alpha: 0.45),
        ),
        child: Text(label),
      ),
    );
  }
}
