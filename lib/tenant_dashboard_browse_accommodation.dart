import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'tenant_paynow.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

final List<Map<String, dynamic>> listings = [
  {
    'title': 'Deluxe Room',
    'price': '₦30,000',
    'details': 'Spacious room with ensuite bathroom',
    'description': 'A beautiful deluxe room with all amenities.',
    'images': [
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&w=400&q=80',
    ],
    'state': 'Lagos',
    'city': 'Ikeja',
    'area': 'GRA',
    'type': 'Room',
    'size': 'Medium',
  },
  {
    'title': 'Studio Apartment',
    'price': '₦45,000',
    'details': 'Modern studio apartment in city center',
    'description': 'Perfect for singles or couples.',
    'images': [
      'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
      'https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg?auto=compress&w=400&q=80',
    ],
    'state': 'Lagos',
    'city': 'Lekki',
    'area': 'Phase 1',
    'type': 'Apartment',
    'size': 'Small',
  },
];

class DashboardAccommodationListing extends StatefulWidget {
  const DashboardAccommodationListing({super.key});

  @override
  State<DashboardAccommodationListing> createState() =>
      _DashboardAccommodationListingState();
}

class _DashboardAccommodationListingState
    extends State<DashboardAccommodationListing> {
  bool showFilters = false;
  String? selectedState;
  String? selectedType;
  String? selectedSize;
  String? city;
  String? area;

  List<Map<String, dynamic>> filteredResults = listings;

  List<Map<String, dynamic>> get filteredListings => filteredResults;

  void clearFilters() {
    setState(() {
      selectedState = null;
      city = null;
      area = null;
      selectedType = null;
      selectedSize = null;
      filteredResults = listings;
    });
  }

  void applyFilters() {
    setState(() {
      filteredResults = listings.where((apt) {
        if (selectedState != null &&
            selectedState!.isNotEmpty &&
            apt['state'] != selectedState) {
          return false;
        }
        if (city != null && city!.isNotEmpty && apt['city'] != city) {
          return false;
        }
        if (area != null && area!.isNotEmpty && apt['area'] != area) {
          return false;
        }
        if (selectedType != null &&
            selectedType!.isNotEmpty &&
            apt['type'] != selectedType) {
          return false;
        }
        if (selectedSize != null &&
            selectedSize!.isNotEmpty &&
            apt['size'] != selectedSize) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/tenant_dashboard',
            (route) => false,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Browse Accommodation",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showFilters
                  ? Stack(
                      children: [
                        // This GestureDetector covers the whole area and closes the filter when tapped outside the card
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              setState(() {
                                showFilters = false;
                              });
                            },
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap:
                                () {}, // Prevent tap propagation to outer GestureDetector
                            child: Card(
                              key: const ValueKey('filters'),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // State
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
                                    // Type
                                    DropdownButtonFormField<String>(
                                      value: selectedType,
                                      decoration: const InputDecoration(
                                        labelText: 'Type',
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
                                    // City
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
                                    // Area
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
                                    // Size
                                    DropdownButtonFormField<String>(
                                      value: selectedSize,
                                      decoration: const InputDecoration(
                                        labelText: 'Size',
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
                                    const SizedBox(height: 12),
                                    // Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: applyFilters,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green[700],
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text('Apply Filter'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: clearFilters,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[300],
                                              foregroundColor: Colors.black87,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text('Clear'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return InkWell(
                          key: const ValueKey('search'),
                          onTap: () {
                            setState(() {
                              showFilters = true;
                            });
                          },
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight: 56,
                              maxWidth: constraints.maxWidth,
                            ),
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
                              children: [
                                const Icon(Icons.search,
                                    color: Colors.grey, size: 28),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: Text(
                                    "Search or filter for your preference",
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Expanded(
            child: filteredListings.isEmpty
                ? const Center(child: Text("No accommodations found."))
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filteredListings.length,
                    itemBuilder: (context, index) {
                      final apt = filteredListings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  apt['images'][0],
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      apt['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      apt['price'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      apt['details'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DashboardAccommodationDetailsPage(
                                                      apartment: apt),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text("View Detail"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DashboardAccommodationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> apartment;
  const DashboardAccommodationDetailsPage({super.key, required this.apartment});

  @override
  State<DashboardAccommodationDetailsPage> createState() =>
      _DashboardAccommodationDetailsPageState();
}

class _DashboardAccommodationDetailsPageState
    extends State<DashboardAccommodationDetailsPage> {
  int _currentImage = 0;
  late PageController _pageController;
  bool _videoInitialized = false;
  late VideoPlayerController _videoController;
  Timer? _carouselTimer;
  final bool _isPaused = false;

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
        backgroundColor: Colors.green[700],
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
            if (images.isNotEmpty)
              SizedBox(
                height: 240,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
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
                            height: 240,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 14,
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
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Accommodation type: ${widget.apartment['title'] ?? ''}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Price: ${widget.apartment['price'] ?? ''}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Details: ${widget.apartment['details'] ?? ''}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Description: ${widget.apartment['description'] ?? "No additional description available."}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Inspect through the video",
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
                        if (mounted) {
                          setState(() {});
                        }
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
