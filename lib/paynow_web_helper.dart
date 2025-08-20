import 'dart:html' as html;
import 'package:flutter/widgets.dart';

/// Listens for Paystack payment success messages on web,
/// removes the paid item from the cart, and navigates to the receipt page.
void setupPaystackWebListener(
  GlobalKey<NavigatorState> navigatorKey,
  Future<void> Function() removeCartItem,
) {
  // Prevent multiple listeners if called more than once
  html.window.onMessage
      .where((event) => event.data == 'paystack-success')
      .listen((event) async {
    await removeCartItem();
    navigatorKey.currentState?.pushReplacementNamed('/tenant_receipt');
  });
}
