import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'tenant_dashboard_browse_accommodation.dart';

// Dashboard Screen
class TenantDashboardScreen extends StatelessWidget {
  const TenantDashboardScreen({super.key});

  final double walletBalance = 125000.00;

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/tenant_login');
  }

  void _showProfileMenu(BuildContext context, Offset offset) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(offset.dx, offset.dy, 40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: const [
              Icon(Icons.person, color: Colors.green),
              SizedBox(width: 8),
              Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'change_password',
          child: Row(
            children: const [
              Icon(Icons.lock, color: Colors.orange),
              SizedBox(width: 8),
              Text('Change Password'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Log Out'),
            ],
          ),
        ),
      ],
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).then((value) {
      if (!context.mounted) return;
      if (value == 'profile') {
        Navigator.pushNamed(context, '/profile');
      } else if (value == 'change_password') {
        Navigator.pushNamed(context, '/change_password');
      } else if (value == 'logout') {
        _logout(context);
      }
    });
  }

  // Use the same getCartItems() logic as your cart screen
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getStringList('cart') ?? [];
    return cart
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName =
        (user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!
            : 'Tenant';
    final brandGreen = Colors.green[400]!;

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: brandGreen,
        title: const Text(
          'Tenant Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notification');
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTapDown: (details) =>
                  _showProfileMenu(context, details.globalPosition),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: brandGreen, size: 18),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Hero(
              tag: 'tenant_drawer_header',
              child: DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [brandGreen, brandGreen.withAlpha(180)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 32, color: brandGreen),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome, $userName',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.home,
              text: 'Browse Accommodation',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardAccommodationListing(),
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.pending_actions,
              text: 'Pending Booking',
              onTap: () =>
                  Navigator.pushNamed(context, '/tenant_cart_accommodation'),
            ),
            _DrawerItem(
              icon: Icons.account_balance_wallet,
              text: 'Wallet',
              onTap: () => Navigator.pushNamed(context, '/wallet'),
            ),
            _DrawerItem(
              icon: Icons.receipt_long,
              text: 'Transaction',
              onTap: () => Navigator.pushNamed(context, '/transaction'),
            ),
            _DrawerItem(
              icon: Icons.person,
              text: 'Profile',
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            _DrawerItem(
              icon: Icons.notifications,
              text: 'Notification',
              onTap: () => Navigator.pushNamed(context, '/notification'),
            ),
            _DrawerItem(
              icon: Icons.contact_mail,
              text: 'Contact Us',
              onTap: () => Navigator.pushNamed(context, '/contact_us'),
            ),
            _DrawerItem(
              icon: Icons.logout,
              text: 'Log Out',
              onTap: () => _logout(context),
              color: Colors.red[700],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getCartItems(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            final isWide = MediaQuery.of(context).size.width > 600;
            return Column(
              children: [
                // Pending Booking Card (animated) - only show if cart is not empty
                if (items.isNotEmpty)
                  AnimatedDashboardCard(
                    icon: Icons.pending_actions,
                    title: 'Pending Booking',
                    subtitle: items.last['title'] ?? '',
                    gradient: LinearGradient(
                      colors: [Colors.orange[700]!, Colors.orange[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.pushNamed(
                        context, '/tenant_cart_accommodation'),
                    titleFontSize: 13,
                    subtitleFontSize: 11,
                    verticalPadding: 10,
                    width: double.infinity,
                    height: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items.last['details'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (items.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '+${items.length - 1} more pending',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),
                // Browse Accommodation Card (animated)
                AnimatedDashboardCard(
                  icon: Icons.home,
                  title: 'Browse Accommodation',
                  subtitle: 'Find your next home',
                  gradient: LinearGradient(
                    colors: [Colors.green[700]!, Colors.green[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const DashboardAccommodationListing(),
                    ),
                  ),
                  titleFontSize: 13,
                  subtitleFontSize: 11,
                  verticalPadding: 10,
                  width: double.infinity,
                  height: isWide ? 110 : null,
                ),
                const SizedBox(height: 18),
                WalletDashboardCard(balance: walletBalance),
                const SizedBox(height: 18),
                AnimatedDashboardCard(
                  icon: Icons.receipt_long,
                  title: 'View Transaction',
                  subtitle: 'See your transaction history',
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Navigator.pushNamed(context, '/transaction'),
                  titleFontSize: 13,
                  subtitleFontSize: 11,
                  verticalPadding: 10,
                  width: double.infinity,
                  height: isWide ? 110 : null,
                ),
                const SizedBox(height: 18),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Drawer item widget
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.text,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.green[700]),
      title: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

// Animated dashboard card widget
class AnimatedDashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final double? verticalPadding;
  final Widget? child;
  final double? width;
  final double? height;

  const AnimatedDashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.titleFontSize,
    this.subtitleFontSize,
    this.verticalPadding,
    this.child,
    this.width,
    this.height,
  });

  @override
  State<AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
}

class _AnimatedDashboardCardState extends State<AnimatedDashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final double cardHeight = 110;
    final double iconSize = 32;
    final double arrowSize = 16;
    final double titleFont = 13;
    final double subtitleFont = 11;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height ?? cardHeight,
            padding: EdgeInsets.symmetric(
              vertical: widget.verticalPadding ?? 10,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // center icon vertically
              children: [
                Icon(widget.icon, color: Colors.white, size: iconSize),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.titleFontSize ?? titleFont,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: widget.subtitleFontSize ?? subtitleFont,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.child != null) ...[
                        const SizedBox(height: 4),
                        widget.child!,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios,
                    color: Colors.white54, size: arrowSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Wallet card with animation
class WalletDashboardCard extends StatefulWidget {
  final double balance;
  const WalletDashboardCard({super.key, required this.balance});

  @override
  State<WalletDashboardCard> createState() => _WalletDashboardCardState();
}

class _WalletDashboardCardState extends State<WalletDashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleReveal() {
    setState(() {
      _isRevealed = !_isRevealed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 110;
    final double buttonHeight = 28;
    final double buttonFont = 11;
    final double balanceFont = 16;
    final double labelFont = 13;
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: cardHeight,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[700]!, Colors.teal[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: labelFont,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _isRevealed
                                ? '₦${widget.balance.toStringAsFixed(2)}'
                                : '₦••••••',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: balanceFont,
                              letterSpacing: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isRevealed
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                            size: 18,
                          ),
                          onPressed: _toggleReveal,
                          tooltip: _isRevealed ? 'Conceal' : 'Reveal',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/withdraw');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: Size(0, buttonHeight),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: TextStyle(
                                  fontSize: buttonFont,
                                  fontWeight: FontWeight.bold),
                              elevation: 0,
                            ),
                            child: const Text('Withdraw'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/wallet');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.teal[700],
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: Size(0, buttonHeight),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: TextStyle(
                                  fontSize: buttonFont,
                                  fontWeight: FontWeight.bold),
                              elevation: 0,
                            ),
                            child: const Text('Add Money'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
