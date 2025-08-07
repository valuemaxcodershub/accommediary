import 'package:flutter/material.dart';

class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({super.key});

  @override
  State<LandlordDashboardScreen> createState() =>
      _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen>
    with SingleTickerProviderStateMixin {
  final double _walletBalance = 150000.0;
  final int _pendingTransactions = 3;
  final int _transactionCount = 27;
  final String _landlordFirstName = 'Tunji';

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _safeNavigateTo(String route) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    Navigator.pushNamed(context, route);
  }

  Future<void> _safeLogout() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/landlord_login');
  }

  void _handlePopup(String value) {
    switch (value) {
      case 'profile':
        _safeNavigateTo('/profile');
        break;
      case 'change_password':
        _safeNavigateTo('/change_password');
        break;
      case 'logout':
        _safeLogout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _animatedCard(
              title: 'Wallet Balance',
              value: '₦${_walletBalance.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet,
              color: Colors.green.shade50,
              iconColor: Colors.green.shade700,
              delay: 0,
            ),
            _animatedCard(
              title: 'Pending Transactions',
              value: '₦${(_pendingTransactions * 5000).toStringAsFixed(2)}',
              icon: Icons.pending_actions,
              color: Colors.orange.shade50,
              iconColor: Colors.orange.shade700,
              delay: 200,
            ),
            _animatedCard(
              title: 'My Apartment',
              value: 'View',
              icon: Icons.home,
              color: Colors.teal.shade50,
              iconColor: Colors.teal.shade700,
              delay: 400,
              onTap: () {
                Navigator.pushNamed(context, '/my_apartment');
              },
            ),
            _animatedCard(
              title: 'Transactions',
              value: '$_transactionCount',
              icon: Icons.compare_arrows,
              color: Colors.blue.shade50,
              iconColor: Colors.blue.shade700,
              delay: 600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required int delay,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _controller, curve: Interval(delay / 1000, 1)),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.green[700],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[800]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, color: Colors.green[800]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome, $_landlordFirstName',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            _drawerItem(Icons.wallet, 'Wallet', '/wallet'),
            _drawerItem(
                Icons.home_work_outlined, 'My Apartment', '/my_apartment'),
            _drawerItem(Icons.pending_actions, 'Pending Transactions',
                '/pending_transactions'),
            _drawerItem(Icons.compare_arrows, 'Transaction', '/transaction'),
            _drawerItem(Icons.contact_support, 'Contact', '/contact'),
            _drawerItem(
                Icons.notifications_active, 'Notification', '/notification'),
            _drawerItem(Icons.settings, 'Profile', '/profile'),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: _safeLogout,
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => _safeNavigateTo(route),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.green[800],
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.person, color: Colors.white),
          onSelected: _handlePopup,
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'profile', child: Text('My Profile')),
            PopupMenuItem(
                value: 'change_password', child: Text('Change Password')),
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
        ),
      ],
    );
  }
}
