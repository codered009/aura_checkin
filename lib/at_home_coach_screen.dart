import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'start_session_screen.dart';

class AtHomeCoachScreen extends StatefulWidget {
  final String authToken;

  AtHomeCoachScreen({required this.authToken});

  @override
  _AtHomeCoachScreenState createState() => _AtHomeCoachScreenState();
}

class _AtHomeCoachScreenState extends State<AtHomeCoachScreen> {
  bool _isLoading = true;
  List<dynamic> _sessions = [];

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    final url = Uri.parse('https://dev.web.api.ableaura.com/academy/coach/sessions/today');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _sessions = data['data'];
            _isLoading = false;
          });
        } else {
          _showErrorSnackBar('Failed to load sessions.');
        }
      } else {
        _showErrorSnackBar('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
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
        title: Text('Today\'s Sessions'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(child: Text('No sessions for today.'))
              : ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    final customer = session['customer'];
                    return ListTile(
                      title: Text('${customer['first_name']} (${customer['phone']})'),
                      subtitle: Text('${session['date']} ${session['from_time']} - ${session['to_time']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StartSessionScreen(
                              sessionId: session['id'].toString(), // Ensure session ID is a string
                              authToken: widget.authToken,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
