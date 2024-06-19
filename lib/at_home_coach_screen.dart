import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'start_session_screen.dart';

class AtHomeCoachScreen extends StatefulWidget {
  final List sessions;

  const AtHomeCoachScreen({required this.sessions});

  @override
  _AtHomeCoachScreenState createState() => _AtHomeCoachScreenState();
}

class _AtHomeCoachScreenState extends State<AtHomeCoachScreen> {
  List sessions = [];

  @override
  void initState() {
    super.initState();
    sessions = widget.sessions;
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final url = 'https://dev.web.api.ableaura.com/api/coach/sessions/today';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            sessions = data['data'];
          });
        } else {
          print('API Error: ${data['message']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('At Home Coach Screen'),
      ),
      body: sessions.isEmpty ? _buildLoading() : _buildSessionsList(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSessionsList() {
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return ListTile(
          title: Text('Session ID: ${session['session_id']}'),
          subtitle: Text(
            'Date: ${session['session_date']} - Time: ${session['session_time']}',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StartSessionScreen(
                  sessionId: session['session_id'],
                  sessionDate: session['session_date'],
                  sessionTime: session['session_time'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
