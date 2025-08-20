import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'tenant_paynow.dart';
import 'tenant_dashboard_browse_accommodation.dart';

class TenantCartAccommodationScreen extends StatefulWidget {
  const TenantCartAccommodationScreen({super.key});

  @override
  State<TenantCartAccommodationScreen> createState() =>
      _TenantCartAccommodationScreenState();
}

class _TenantCartAccommodationScreenState
    extends State<TenantCartAccommodationScreen> {
  late Future<List<Map<String, dynamic>>> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = getCartItems();
  }

  Future<void> _refreshCart() async {
    setState(() {
      _cartFuture = getCartItems();
    });
  }

  Future<void> _deleteCartItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getStringList('cart') ?? [];
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      await prefs.setStringList('cart', cart);
      _refreshCart();
    }
  }

  void _viewDetail(BuildContext context, Map<String, dynamic> booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartAccommodationDetailsPage(apartment: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brandGreen = Colors.green[400]!;
    final accentColor = Colors.orange[600]!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: brandGreen,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/tenant_dashboard');
          },
        ),
        title: const Text(
          "Pending Bookings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _refreshCart,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cartItems = snapshot.data ?? [];
          if (cartItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "You have no pending accommodation booked,\nclick below to get a choice accommodation.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DashboardAccommodationListing(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text("Browse Accommodation"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final booking = cartItems[index];
              final images = booking['images'] as List<dynamic>? ?? [];
              final imageUrl = images.isNotEmpty ? images[0] : null;
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(18)),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 120,
                                width: 120,
                                color: Colors.grey[300],
                              ),
                            )
                          : Container(
                              height: 120,
                              width: 120,
                              color: Colors.grey[200],
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['title'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: brandGreen,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              booking['price'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: accentColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              booking['details'] ?? '',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _viewDetail(context, booking),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('View Detail'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _deleteCartItem(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Fetch cart items from SharedPreferences
Future<List<Map<String, dynamic>>> getCartItems() async {
  final prefs = await SharedPreferences.getInstance();
  final cart = prefs.getStringList('cart') ?? [];
  return cart.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
}

// Accommodation Details Page for Cart with "Pay Now" button and carousel
class CartAccommodationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> apartment;
  const CartAccommodationDetailsPage({super.key, required this.apartment});

  @override
  State<CartAccommodationDetailsPage> createState() =>
      _CartAccommodationDetailsPageState();
}

class _CartAccommodationDetailsPageState
    extends State<CartAccommodationDetailsPage> {
  int currentImage = 0;
  late PageController pageController;
  Timer? carouselTimer;
  bool isPaused = false;

  // Video player controller
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentImage);
    _startAutoPlay();

    // Initialize video player
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    )..initialize().then((_) {
        setState(() {
          _videoInitialized = true;
        });
      });
  }

  void _startAutoPlay() {
    carouselTimer?.cancel();
    carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (isPaused) return;
      final images = widget.apartment['images'] as List<dynamic>? ?? [];
      if (images.isEmpty) return;
      int nextPage = currentImage + 1;
      if (nextPage >= images.length) nextPage = 0;
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _pauseAutoPlay() {
    setState(() {
      isPaused = true;
    });
  }

  void _resumeAutoPlay() {
    setState(() {
      isPaused = false;
    });
  }

  @override
  void dispose() {
    carouselTimer?.cancel();
    pageController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.apartment['images'] as List<dynamic>? ?? [];
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        elevation: 2,
        title: Text(
          widget.apartment['title'] ?? 'Details',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: MouseRegion(
                onEnter: (_) => _pauseAutoPlay(),
                onExit: (_) => _resumeAutoPlay(),
                child: GestureDetector(
                  onTapDown: (_) => _pauseAutoPlay(),
                  onTapUp: (_) => _resumeAutoPlay(),
                  onTapCancel: () => _resumeAutoPlay(),
                  child: Stack(
                    children: [
                      PageView.builder(
                        itemCount: images.length,
                        controller: pageController,
                        onPageChanged: (i) {
                          setState(() => currentImage = i);
                        },
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(22)),
                            child: Image.network(
                              images[index],
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: double.infinity,
                                height: 220,
                                color: Colors.grey[300],
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: currentImage == index ? 16 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: currentImage == index
                                    ? Colors.green[700]
                                    : Colors.grey[400],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Accommodation type: ${widget.apartment['title'] ?? ''}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Price: ${widget.apartment['price'] ?? ''}",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Details: ${widget.apartment['details'] ?? ''}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Description: ${widget.apartment['description'] ?? "No additional description available."}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  // Google Map Section REMOVED
                  // const Text(
                  //   "Location",
                  //   style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 8),
                  // Container(
                  //   height: 180,
                  //   width: double.infinity,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(14),
                  //     border: Border.all(color: Colors.green, width: 1),
                  //   ),
                  //   child: ClipRRect(
                  //     borderRadius: BorderRadius.circular(14),
                  //     child: widget.apartment['mapUrl'] != null
                  //         ? Image.network(
                  //             widget.apartment['mapUrl'],
                  //             fit: BoxFit.cover,
                  //             width: double.infinity,
                  //             height: 180,
                  //           )
                  //         : Image.network(
                  //             // fallback to Lagos if no mapUrl
                  //             'https://maps.googleapis.com/maps/api/staticmap?center=Lagos,Nigeria&zoom=13&size=600x300&maptype=roadmap&key=YOUR_GOOGLE_MAPS_API_KEY',
                  //             fit: BoxFit.cover,
                  //             width: double.infinity,
                  //             height: 180,
                  //           ),
                  //   ),
                  // ),
                  // const SizedBox(height: 24),
                  // Video Section
                  const Text(
                    "Insect through the video",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      if (_videoInitialized) {
                        await showDialog(
                            context: context,
                            builder: (context) => Dialog(
                                  insetPadding: const EdgeInsets.all(16),
                                  child: AspectRatio(
                                    aspectRatio:
                                        _videoController.value.aspectRatio,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        VideoPlayer(_videoController),
                                        if (!_videoController.value.isPlaying)
                                          IconButton(
                                            icon: const Icon(
                                                Icons.play_circle_fill,
                                                size: 64,
                                                color: Colors.white),
                                            onPressed: () {
                                              _videoController.play();
                                              setState(() {});
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ));

                        _videoController.pause();
                        setState(() {});
                      }
                    },
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.black12,
                      ),
                      child: _videoInitialized
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: AspectRatio(
                                    aspectRatio:
                                        _videoController.value.aspectRatio,
                                    child: VideoPlayer(_videoController),
                                  ),
                                ),
                                if (!_videoController.value.isPlaying)
                                  const Icon(Icons.play_circle_fill,
                                      color: Colors.white, size: 64),
                              ],
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final tenantEmail =
                            prefs.getString('tenantEmail') ?? '';

                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TenantPayNowPage(
                              property: widget.apartment,
                              tenantEmail: tenantEmail,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text("Pay Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
