import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'qr_check_in_page.dart';
import 'franchise_selection_screen.dart';

class InitialSelectionScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const InitialSelectionScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aura Check-In'),
      ),
      drawer: AppDrawer(cameras: cameras),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FranchiseSelectionScreen()),
                );
              },
              child: const Text('Franchise Selection'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRCheckInPage(cameras: cameras)),
                );
              },
              child: const Text('QR Check-In'),
            ),
          ],
        ),
      ),
    );
  }
}
