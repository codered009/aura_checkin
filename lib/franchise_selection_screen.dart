import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'timing_selection_screen.dart';

class FranchiseSelectionScreen extends StatefulWidget {
  const FranchiseSelectionScreen({super.key});

  @override
  _FranchiseSelectionScreenState createState() => _FranchiseSelectionScreenState();
}

class _FranchiseSelectionScreenState extends State<FranchiseSelectionScreen> {
  List<Map<String, dynamic>> franchises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFranchises();
  }

  Future<void> fetchFranchises() async {
    try {
      final response = await http.get(Uri.parse('https://api.web.ableaura.com/academy/franchises/list'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          franchises = List<Map<String, dynamic>>.from(responseData['data']);
          isLoading = false;
        });
      } else {
        // Handle error
        showErrorDialog('Failed to load franchises. Please try again.');
      }
    } catch (e) {
      // Handle error
      showErrorDialog('An error occurred. Please check your internet connection and try again.');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Franchise'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: franchises.length,
              itemBuilder: (context, index) {
                final franchise = franchises[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    title: Text(
                      franchise['franchise_name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      franchise['center']['name'],
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    trailing: const Icon(Icons.arrow_forward, color: Colors.blueAccent),
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('selectedFranchiseId', franchise['id']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TimingSelectionScreen(franchiseId: franchise['id'])),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
