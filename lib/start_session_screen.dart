import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class StartSessionScreen extends StatefulWidget {
  final String sessionId;  // sessionId as String
  final String authToken;

  StartSessionScreen({required this.sessionId, required this.authToken});

  @override
  _StartSessionScreenState createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  bool _isLoading = false;

  Future<void> _startSession() async {
    setState(() {
      _isLoading = true;
    });

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final url = Uri.parse('https://dev.web.api.ableaura.com/academy/coaches/session/start');
    final body = jsonEncode({
      'session_id': widget.sessionId,
      'latitude': position.latitude.toString(),  // Ensure latitude is a string
      'longitude': position.longitude.toString(), // Ensure longitude is a string
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session started successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start session.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Session'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _startSession,
                child: Text('Start Session'),
              ),
      ),
    );
  }
}
