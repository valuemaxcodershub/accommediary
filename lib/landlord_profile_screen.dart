import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LandlordProfileScreen extends StatefulWidget {
  const LandlordProfileScreen({super.key});

  @override
  State<LandlordProfileScreen> createState() => _LandlordProfileScreenState();
}

class _LandlordProfileScreenState extends State<LandlordProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _profileImage;
  XFile? _idCardImage;
  Uint8List? _profilePreview;
  Uint8List? _idCardPreview;

  final TextEditingController _ninController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source, bool isProfileImage) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (isProfileImage) {
          _profileImage = pickedFile;
          _profilePreview = bytes;
        } else {
          _idCardImage = pickedFile;
          _idCardPreview = bytes;
        }
      });
    }
  }

  Future<void> _uploadProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profileImage == null || _idCardImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both images')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) throw Exception("Authentication token missing.");

      final uri =
          Uri.parse("https://api.accommediary.com.ng/api/landlord/profile");
      final request = http.MultipartRequest("POST", uri);

      request.headers['Authorization'] = 'Bearer $idToken';
      request.fields['nin'] = _ninController.text;
      request.fields['address'] = _addressController.text;

      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        _profileImage!.path,
        contentType: MediaType('image', _profileImage!.path.split('.').last),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'idCard',
        _idCardImage!.path,
        contentType: MediaType('image', _idCardImage!.path.split('.').last),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _imagePreview(Uint8List? bytes, String label) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green),
            image: bytes != null
                ? DecorationImage(
                    image: MemoryImage(bytes),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: bytes == null
              ? const Icon(Icons.person, size: 60, color: Colors.green)
              : null,
        ),
        TextButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery, label == 'Profile'),
          icon: Icon(label == 'Profile' ? Icons.camera_alt : Icons.file_copy),
          label: Text("Upload $label"),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _imagePreview(_profilePreview, 'Profile'),
                  _imagePreview(_idCardPreview, 'ID Card'),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ninController,
                decoration: const InputDecoration(
                  labelText: "NIN",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter your NIN' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your address' : null,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.upload),
                        label: const Text("Submit Profile"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _uploadProfile,
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
