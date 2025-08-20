import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'constants.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';

class TenantAccommodationListing extends StatefulWidget {
  const TenantAccommodationListing({super.key});

  @override
  State<TenantAccommodationListing> createState() =>
      _TenantAccommodationListingState();
}

class _TenantAccommodationListingState extends State<TenantAccommodationListing>
    with SingleTickerProviderStateMixin {
  bool showFilters = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Filter values
  String? selectedState;
  String? city;
  String? area;
  String? selectedType;
  String? selectedSize;

  final List<Map<String, dynamic>> listings = [
    {
      'title': 'Modern Apartment',
      'price': '₦120,000',
      'details': '2 beds, 2 baths, Lekki Phase 1',
      'images': [
        'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
        'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&w=400&q=80',
      ],
      'state': 'Lagos',
      'city': 'Lagos',
      'area': 'Lekki',
      'type': 'Apartment',
      'size': '2 Bedroom',
      'description': 'A beautiful modern apartment in Lekki.',
    },
    {
      'title': 'Cozy Studio',
      'price': '₦80,000',
      'details': '1 bed, 1 bath, Victoria Island',
      'images': [
        'https://images.unsplash.com/photo-1523217582562-09d0def993a6?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?auto=format&fit=crop&w=400&q=80',
      ],
      'state': 'Lagos',
      'city': 'Lagos',
      'area': 'Victoria Island',
      'type': 'Studio',
      'size': '1 Bedroom',
      'description': 'A cozy studio in the heart of Victoria Island.',
    },
    {
      'title': 'Luxury Duplex',
      'price': '₦350,000',
      'details': '4 beds, 4 baths, Ikoyi',
      'images': [
        'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&w=400&q=80',
        'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&w=400&q=80',
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      ],
      'state': 'Lagos',
      'city': 'Lagos',
      'area': 'Ikoyi',
      'type': 'Duplex',
      'size': '4 Bedroom',
      'description': 'Spacious luxury duplex with modern amenities.',
    },
    {
      'title': 'Affordable Mini Flat',
      'price': '₦60,000',
      'details': '1 bed, 1 bath, Yaba',
      'images': [
        'https://images.unsplash.com/photo-1523217582562-09d0def993a6?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
      ],
      'state': 'Lagos',
      'city': 'Lagos',
      'area': 'Yaba',
      'type': 'Mini Flat',
      'size': '1 Bedroom',
      'description': 'Affordable mini flat close to Unilag.',
    },
    {
      'title': 'Family Bungalow',
      'price': '₦200,000',
      'details': '3 beds, 2 baths, Ikeja',
      'images': [
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
      ],
      'state': 'Lagos',
      'city': 'Lagos',
      'area': 'Ikeja',
      'type': 'Bungalow',
      'size': '3 Bedroom',
      'description': 'Perfect for families, located in a serene environment.',
    },
  ];

  List<Map<String, dynamic>> get filteredListings {
    return listings.where((apt) {
      if (selectedState != null && apt['state'] != selectedState) return false;
      if (city != null && city!.isNotEmpty && apt['city'] != city) return false;
      if (area != null && area!.isNotEmpty && apt['area'] != area) return false;
      if (selectedType != null && apt['type'] != selectedType) return false;
      if (selectedSize != null && apt['size'] != selectedSize) return false;
      return true;
    }).toList();
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void toggleFilters() {
    setState(() {
      showFilters = !showFilters;
      if (showFilters) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void clearFilters() {
    setState(() {
      selectedState = null;
      city = null;
      area = null;
      selectedType = null;
      selectedSize = null;
    });
  }

  // --- ADD TO CART LOGIC ---
  Future<void> addAccommodationToCart(
      Map<String, dynamic> accommodation) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getStringList('cart') ?? [];
    // Prevent duplicate entries
    final encoded = jsonEncode(accommodation);
    if (!cart.contains(encoded)) {
      cart.add(encoded);
      await prefs.setStringList('cart', cart);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Hero(
          tag: 'app_logo',
          child: Image.asset(
            'assets/images/acc_logo.png',
            height: 36,
          ),
        ),
        actions: [
          _ProfileIconButton(),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: showFilters
                      ? FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            key: const ValueKey('filters'),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22)),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      value: selectedState,
                                      decoration: const InputDecoration(
                                        labelText: 'State',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: nigeriaStates
                                          .map((state) => DropdownMenuItem(
                                                value: state,
                                                child: Text(state),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedState = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'City',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          city = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Area',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          area = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: selectedType,
                                      decoration: const InputDecoration(
                                        labelText: 'Apartment Type',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: apartmentTypes
                                          .map((type) => DropdownMenuItem(
                                                value: type,
                                                child: Text(type),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedType = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: selectedSize,
                                      decoration: const InputDecoration(
                                        labelText: 'Apartment Size',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: apartmentSizes
                                          .map((size) => DropdownMenuItem(
                                                value: size,
                                                child: Text(size),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedSize = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: clearFilters,
                                          icon: const Icon(Icons.clear),
                                          label: const Text('Clear'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300],
                                            foregroundColor: Colors.black87,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: toggleFilters,
                                          icon: const Icon(Icons.check),
                                          label: const Text('Apply Filters'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green[700],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          key: const ValueKey('search'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: GestureDetector(
                            onTap: toggleFilters,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.search,
                                      color: Colors.grey, size: 28),
                                  SizedBox(width: 16),
                                  Text(
                                    "Filter for your preference",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
                      return Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio:
                                  constraints.maxWidth < 600 ? 1.1 : 0.75,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: filteredListings.length,
                            itemBuilder: (context, index) {
                              final apt = filteredListings[index];
                              return Card(
                                elevation: 3,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AccommodationDetailsPage(
                                          apartment: apt,
                                          addToCart: addAccommodationToCart,
                                        ),
                                      ),
                                    );
                                  },
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 120,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(18)),
                                            child: apt['images'] != null
                                                ? Image.network(
                                                    apt['images'][0],
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                apt['title'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                apt['price'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                apt['details'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AccommodationDetailsPage(
                                                          apartment: apt,
                                                          addToCart:
                                                              addAccommodationToCart,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green[700],
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                      "View Details"),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AccommodationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> apartment;
  final Future<void> Function(Map<String, dynamic>) addToCart;
  const AccommodationDetailsPage({
    super.key,
    required this.apartment,
    required this.addToCart,
  });

  @override
  State<AccommodationDetailsPage> createState() =>
      _AccommodationDetailsPageState();
}

class _AccommodationDetailsPageState extends State<AccommodationDetailsPage> {
  int _currentImage = 0;
  late PageController _pageController;
  Timer? _carouselTimer;
  bool _isPaused = false;

  late VideoPlayerController _videoController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentImage);
    _startAutoPlay();

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
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isPaused) return;
      final images = widget.apartment['images'] as List<String>? ?? [];
      if (images.isEmpty) return;
      int nextPage = _currentImage + 1;
      if (nextPage >= images.length) nextPage = 0;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _pauseAutoPlay() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeAutoPlay() {
    setState(() {
      _isPaused = false;
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.apartment['images'] as List<String>? ?? [];
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          widget.apartment['title'] ?? 'Details',
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
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
                        controller: _pageController,
                        onPageChanged: (i) {
                          setState(() => _currentImage = i);
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
                              width: _currentImage == index ? 16 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentImage == index
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
                        if (mounted) setState(() {});
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
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await widget.addToCart(widget.apartment);
                        if (!mounted) return; // <-- check right after await
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Accommodation added to cart!')),
                        );
                        Navigator.pushNamed(context, '/tenant_login');
                      },
                      icon: const Icon(Icons.event_available),
                      label: const Text("Book Accommodation Now"),
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

class _ProfileIconButton extends StatefulWidget {
  @override
  State<_ProfileIconButton> createState() => _ProfileIconButtonState();
}

class _ProfileIconButtonState extends State<_ProfileIconButton> {
  bool _hovering = false;
  bool _pressed = false;

  Color get _circleColor {
    if (_pressed) return Colors.grey[700]!;
    if (_hovering) return Colors.grey[400]!;
    return Colors.grey[300]!;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            builder: (context) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.green),
                    title: const Text('Sign In'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/tenant_login');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.green),
                    title: const Text('Sign Up'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/tenant_register');
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CircleAvatar(
            backgroundColor: _circleColor,
            radius: 16,
            child: const Icon(Icons.person, color: Colors.grey, size: 20),
          ),
        ),
      ),
    );
  }
}
