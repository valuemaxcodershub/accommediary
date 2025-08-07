import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadService {
  final picker = ImagePicker();

  Future<void> uploadProfile({
    required String fullName,
    required String nin,
    required String address,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    if (idToken == null) {
      developer.log("User not authenticated", name: 'UploadService');
      return;
    }

    final profileImage = await picker.pickImage(source: ImageSource.gallery);
    final idCard = await picker.pickImage(source: ImageSource.gallery);

    if (profileImage == null || idCard == null) {
      developer.log("Image(s) not selected.", name: 'UploadService');
      return;
    }

    final uri = Uri.parse('https://api.accommediary.com.ng/upload-profile');

    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $idToken'
      ..fields['fullName'] = fullName
      ..fields['nin'] = nin
      ..fields['address'] = address
      ..files.add(
          await http.MultipartFile.fromPath('profileImage', profileImage.path))
      ..files.add(await http.MultipartFile.fromPath('idCard', idCard.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      developer.log("✅ Upload successful", name: 'UploadService');
    } else {
      developer.log("❌ Upload failed. Status: ${response.statusCode}",
          name: 'UploadService');
    }
  }
}
