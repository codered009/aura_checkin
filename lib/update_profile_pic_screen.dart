import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';

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

  void _updateProfilePic(BuildContext context) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.web.ableaura.com/academy/student/selfie'),
    );
    request.fields['student_id'] = studentId;
    request.files.add(await http.MultipartFile.fromPath('selfie', pictureFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile picture updated successfully'),
      ));
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update profile picture'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Profile Picture')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Student ID: $studentId',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Student Name: $studentName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profilePicture),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _updateProfilePic(context),
              child: Text('Update Profile Pic'),
            ),
          ],
        ),
      ),
    );
  }
}
