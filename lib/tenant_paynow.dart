import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import the global navigatorKey
import 'package:accommediary/main.dart' show navigatorKey;

// Only imported on web, ignored on mobile/desktop
// ignore: uri_does_not_exist
import 'paynow_web_helper_stub.dart'
    if (dart.library.html) 'paynow_web_helper.dart';

class TenantPayNowPage extends StatefulWidget {
  final Map<String, dynamic> property;
  final String tenantEmail;

  const TenantPayNowPage({
    super.key,
    required this.property,
    required this.tenantEmail,
  });

  @override
  State<TenantPayNowPage> createState() => _TenantPayNowPageState();
}

class _TenantPayNowPageState extends State<TenantPayNowPage> {
  late int propertyAmount;
  late String propertyTitle;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final priceString = widget.property['price'] as String? ?? '₦0';
    propertyAmount =
        int.tryParse(priceString.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    propertyTitle = widget.property['title'] ?? '';

    if (kIsWeb) {
      setupPaystackWebListener(navigatorKey, _removePaidItemFromCart);
    }
  }

  Future<void> _removePaidItemFromCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getStringList('cart') ?? [];
    final propertyTitle = widget.property['title'];
    cart.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['title'] == propertyTitle;
    });
    await prefs.setStringList('cart', cart);
  }

  void _handlePaymentResult(dynamic result) async {
    if (!mounted) return;
    if (result == true) {
      await _removePaidItemFromCart();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/tenant_receipt');
    }
  }

  Future<void> _startPaystackPayment() async {
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('https://api.accommediary.com.ng/api/paystack/initialize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.tenantEmail,
          'amount': propertyAmount * 100, // Paystack expects kobo
        }),
      );
      setState(() => _loading = false);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authUrl = data['authorization_url'];
        if (kIsWeb) {
          await launchUrl(Uri.parse(authUrl), webOnlyWindowName: '_blank');
        } else {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaystackWebViewPage(url: authUrl),
            ),
          );
          _handlePaymentResult(result);
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize payment')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pay for $propertyTitle",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFBFB), Color(0xFFE2D1C3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Amount to Pay: ₦$propertyAmount",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.credit_card, color: Colors.white),
                label: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Pay with Card",
                        style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: _loading ? null : _startPaystackPayment,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                "We’ve got you covered",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaystackWebViewPage extends StatefulWidget {
  final String url;

  const PaystackWebViewPage({
    super.key,
    required this.url,
  });

  @override
  State<PaystackWebViewPage> createState() => _PaystackWebViewPageState();
}

class _PaystackWebViewPageState extends State<PaystackWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(
                'https://api.accommediary.com.ng/paystack-success')) {
              Navigator.of(context, rootNavigator: true).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay with Paystack')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
