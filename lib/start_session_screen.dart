import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class StartSessionScreen extends StatefulWidget {
  final String sessionId;
  final String authToken;

  StartSessionScreen({required this.sessionId, required this.authToken});

  @override
  _StartSessionScreenState createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  bool _isStarting = false;
  bool _isCompleting = false;
  bool _sessionStarted = false;
  bool _sessionCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkSessionStatus();
  }

  Future<void> _checkSessionStatus() async {
    try {
      final url = Uri.parse('https://dev.web.api.ableaura.com/academy/coach/session/status');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
        body: jsonEncode({'session_id': widget.sessionId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['session_state'] == 'session_started') {
          setState(() {
            _sessionStarted = true;
          });
        } else if (data['session_state'] == 'session_completed') {
          setState(() {
            _sessionCompleted = true;
          });
        }
      } else {
        _showErrorSnackBar('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _getCurrentLocationAndStartSession() async {
    setState(() {
      _isStarting = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final url = Uri.parse('https://dev.web.api.ableaura.com/academy/coaches/session/start');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
        body: jsonEncode({
          'session_id': widget.sessionId,
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _sessionStarted = true;
          });
        } else {
          _showErrorSnackBar('Failed to start session.');
        }
      } else {
        _showErrorSnackBar('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isStarting = false;
      });
    }
  }

  Future<void> _getCurrentLocationAndCompleteSession() async {
    setState(() {
      _isCompleting = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final url = Uri.parse('https://dev.web.api.ableaura.com/academy/coaches/session/complete');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
        body: jsonEncode({
          'session_id': widget.sessionId,
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _sessionCompleted = true;
          });
        } else {
          _showErrorSnackBar('Failed to complete session.');
        }
      } else {
        _showErrorSnackBar('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isCompleting = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Session'),
      ),
      body: Center(
        child: _sessionCompleted
            ? Text('Session Completed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_sessionStarted)
                    ElevatedButton(
                      onPressed: _isStarting ? null : _getCurrentLocationAndStartSession,
                      child: _isStarting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Start Session'),
                    ),
                  if (_sessionStarted && !_sessionCompleted)
                    ElevatedButton(
                      onPressed: _isCompleting ? null : _getCurrentLocationAndCompleteSession,
                      child: _isCompleting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Complete Session'),
                    ),
                ],
              ),
      ),
    );
  }
}
