import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class StartSessionScreen extends StatefulWidget {
  final int sessionId; // Define sessionId parameter
  final String sessionDate; // Define sessionDate parameter
  final String sessionTime; // Define sessionTime parameter

  StartSessionScreen({
    required this.sessionId,
    required this.sessionDate,
    required this.sessionTime,
  });

  @override
  _StartSessionScreenState createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Location fetching logic here using Geolocator package
  }

  Future<void> _startSession() async {
    if (_currentPosition == null) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    final response = await http.post(
      Uri.parse('https://dev.web.api.ableaura.com/academy/coaches/session/start'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'session_id': widget.sessionId, // Access sessionId from widget
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful session start
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session started successfully')),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start session')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Session'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _startSession,
          child: Text('Start Session'),
        ),
      ),
    );
  }
}
