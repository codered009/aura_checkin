import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'picture_preview_screen.dart';

class StudentSelfieScreen extends StatefulWidget {
  final CameraDescription camera;

  const StudentSelfieScreen({super.key, required this.camera});

  @override
  _StudentSelfieScreenState createState() => _StudentSelfieScreenState();
}

class _StudentSelfieScreenState extends State<StudentSelfieScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PicturePreviewScreen(pictureFile: image),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Selfie')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(
                    child: ClipOval(
                      child: AspectRatio(
                        aspectRatio: 1 / _controller.value.aspectRatio,
                        child: CameraPreview(_controller),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Picture'),
            ),
          ),
        ],
      ),
    );
  }
}
