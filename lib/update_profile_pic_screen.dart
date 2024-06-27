import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class UpdateProfilePicScreen extends StatelessWidget {
  final String studentId;
  final String studentName;
  final String profilePicture;
  final XFile pictureFile;

  UpdateProfilePicScreen({
    required this.studentId,
    required this.studentName,
    required this.profilePicture,
    required this.pictureFile,
  });

  Future<void> _uploadImage() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.web.ableaura.com/academy/student/selfie'),
      );
      request.fields['student_id'] = studentId;
      request.files.add(await http.MultipartFile.fromPath('selfie', pictureFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var jsonResponse = json.decode(responseData.body);
        if (jsonResponse['success']) {
          print('Image uploaded successfully');
          // Handle successful upload
        } else {
          print('Failed to upload image');
          // Handle failed upload
        }
      } else {
        print('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Profile Picture')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(profilePicture),
              radius: 50,
            ),
            SizedBox(height: 16),
            Text(
              studentName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Image.file(File(pictureFile.path)),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _uploadImage,
              icon: Icon(Icons.upload_file),
              label: Text('Update Profile Pic'),
            ),
          ],
        ),
      ),
    );
  }
}
