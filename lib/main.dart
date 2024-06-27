import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'initial_selection_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  MyApp({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Check-In',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitialSelectionScreen(cameras: cameras),
    );
  }
}
