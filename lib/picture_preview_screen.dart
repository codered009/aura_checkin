import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'update_profile_pic_screen.dart';

class PicturePreviewScreen extends StatelessWidget {
  final XFile pictureFile;

  PicturePreviewScreen({required this.pictureFile});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    void _searchStudent() async {
      String studentId = 'AAA#' + _controller.text;
      final response = await http.post(
        Uri.parse('https://api.web.ableaura.com/academy/student/checkstudent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'student_id': studentId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final studentData = responseData['data'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateProfilePicScreen(
              studentId: studentData['student_id'],
              studentName: studentData['student_name'],
              profilePicture: studentData['profile_picture'],
              pictureFile: pictureFile,
            ),
          ),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Student not found'),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Picture Preview')),
      body: Stack(
        children: [
          Center(
            child: Image.file(File(pictureFile.path), fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Student ID',
                      prefixText: 'AAA#',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8),
                  IconButton(
                    icon: Icon(Icons.search, size: 30, color: Colors.blue),
                    onPressed: _searchStudent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
