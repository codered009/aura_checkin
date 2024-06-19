import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'qr_check_in_page.dart';

class TimingSelectionScreen extends StatefulWidget {
  final int franchiseId;

  const TimingSelectionScreen({super.key, required this.franchiseId});

  @override
  _TimingSelectionScreenState createState() => _TimingSelectionScreenState();
}

class _TimingSelectionScreenState extends State<TimingSelectionScreen> {
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.web.ableaura.com/academy/franchise/sessions/list'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'franchise_id': widget.franchiseId}),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          sessions = List<Map<String, dynamic>>.from(responseData['data']);
          isLoading = false;
        });
      } else {
        // Handle error
        showErrorDialog('Failed to load sessions. Please try again.');
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
        title: const Text('Select Timing'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    title: Text(
                      session['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    trailing: const Icon(Icons.arrow_forward, color: Colors.blueAccent),
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('selectedSessionId', session['id']);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const QRCheckInPage()),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
