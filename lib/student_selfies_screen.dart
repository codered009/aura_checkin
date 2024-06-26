import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'picture_preview_screen.dart';

class StudentSelfiesScreen extends StatefulWidget {
  @override
  _StudentSelfiesScreenState createState() => _StudentSelfiesScreenState();
}

class _StudentSelfiesScreenState extends State<StudentSelfiesScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  XFile? pictureFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras!.first, ResolutionPreset.high);
    await _cameraController!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController!.value.isInitialized) {
      pictureFile = await _cameraController!.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PicturePreviewScreen(pictureFile: pictureFile!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('Student Profile Pic')),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            bottom: 50,
            left: MediaQuery.of(context).size.width * 0.25,
            child: ElevatedButton(
              onPressed: _takePicture,
              child: Text('Take Picture'),
            ),
          ),
        ],
      ),
    );
  }
}
