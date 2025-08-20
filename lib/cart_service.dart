class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);

  void addItem(Map<String, dynamic> item) {
    _cartItems.insert(0, item); // latest first
  }

  void clear() => _cartItems.clear();
}
