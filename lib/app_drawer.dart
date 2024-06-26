import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'franchise_selection_screen.dart';
import 'student_selfies_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Coach Attendance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
              );
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Franchise Actions', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Center Attendance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FranchiseSelectionScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Student Selfies'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  StudentSelfiesScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
