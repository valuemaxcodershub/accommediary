import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'constants.dart';

class AddApartmentScreen extends StatefulWidget {
  const AddApartmentScreen({super.key});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _streetController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();

  String? _selectedState;
  String? _apartmentType;
  String? _apartmentSize;
  List<File> _selectedImages = [];

  @override
  void dispose() {
    _cityController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> _uploadApartment() async {
    final uri = Uri.parse(
        'https://api.accommediary.com.ng/api/landlord/profile'); // Your API endpoint

    var request = http.MultipartRequest('POST', uri)
      ..fields['state'] = _selectedState ?? ''
      ..fields['city'] = _cityController.text
      ..fields['area'] = _areaController.text
      ..fields['street'] = _streetController.text
      ..fields['type'] = _apartmentType ?? ''
      ..fields['size'] = _apartmentSize ?? ''
      ..fields['price'] = _priceController.text
      ..fields['description'] = _descriptionController.text
      ..fields['video_url'] = _videoUrlController.text;

    // Attach images
    for (var img in _selectedImages) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images', // Adjust field name as needed by your backend
          img.path,
          filename: path.basename(img.path),
        ),
      );
    }

    // If you need to send an auth token, add it here:
    // request.headers['Authorization'] = 'Bearer <your_token>';

    final response = await request.send();

    if (!mounted) return; // <-- Add this line

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apartment uploaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${response.statusCode}')),
      );
    }
  }

  String get _fullAddress {
    return [
      _streetController.text,
      _areaController.text,
      _cityController.text,
      _selectedState ?? ''
    ].where((e) => e.isNotEmpty).join(', ');
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.green[700]) : null,
      hintText: label,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {TextInputType keyboardType = TextInputType.text,
      int maxLines = 1,
      IconData? icon}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(hintText, icon: icon),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Add Apartment'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Address Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedState,
                          decoration: _inputDecoration('Select State',
                              icon: Icons.location_city),
                          items: nigeriaStates
                              .map((state) => DropdownMenuItem(
                                    value: state,
                                    child: Text(state),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedState = value),
                          validator: (value) =>
                              value == null ? 'Please select a state' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(_cityController, 'City',
                            icon: Icons.location_on),
                        const SizedBox(height: 12),
                        _buildTextField(_areaController, 'Area',
                            icon: Icons.map),
                        const SizedBox(height: 12),
                        _buildTextField(_streetController, 'Street Name',
                            icon: Icons.streetview),
                        const SizedBox(height: 12),
                        Container(
                          height: 120,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map_outlined,
                                  color: Colors.green, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                _fullAddress.isEmpty
                                    ? 'Map Placeholder'
                                    : _fullAddress,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Apartment Details Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _apartmentType,
                          decoration: _inputDecoration('Apartment Type',
                              icon: Icons.home_work),
                          items: apartmentTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _apartmentType = value),
                          validator: (value) =>
                              value == null ? 'Please select a type' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _apartmentSize,
                          decoration: _inputDecoration('Apartment Size',
                              icon: Icons.king_bed),
                          items: apartmentSizes
                              .map((size) => DropdownMenuItem(
                                    value: size,
                                    child: Text(size),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _apartmentSize = value),
                          validator: (value) =>
                              value == null ? 'Please select a size' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(_priceController, 'Price (₦)',
                            keyboardType: TextInputType.number,
                            icon: Icons.attach_money),
                        const SizedBox(height: 12),
                        _buildTextField(_descriptionController, 'Description',
                            maxLines: 3, icon: Icons.description),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Images Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upload Images',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Select Images'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _selectedImages.isEmpty
                            ? Text('No images selected',
                                style: TextStyle(color: Colors.grey[600]))
                            : SizedBox(
                                height: 90,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: _selectedImages
                                      .map((file) => Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(file,
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.cover),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Video Section (Just show the URL)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          _videoUrlController,
                          'YouTube Video URL',
                          icon: Icons.video_library,
                        ),
                        const SizedBox(height: 8),
                        if (_videoUrlController.text.isNotEmpty)
                          Text(
                            'Video URL: ${_videoUrlController.text}',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _uploadApartment();
                      }
                    },
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text(
                      'Upload Apartment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
