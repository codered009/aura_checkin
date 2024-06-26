import 'package:flutter/material.dart';
import 'franchise_selection_screen.dart';
import 'sign_in_screen.dart';  // Import SignInScreen

class InitialSelectionScreen extends StatelessWidget {
  const InitialSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FranchiseSelectionScreen()),
                );
              },
              child: const Text('Center Attendance'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),  // Navigate to SignInScreen
                );
              },
              child: const Text('Coach Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
