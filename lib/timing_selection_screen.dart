import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'db_helper.dart';
import 'qr_check_in_page.dart';
import 'loading_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimingSelectionScreen extends StatefulWidget {
  final int franchiseId;
  const TimingSelectionScreen({required this.franchiseId, super.key});

  @override
  _TimingSelectionScreenState createState() => _TimingSelectionScreenState();
}

class _TimingSelectionScreenState extends State<TimingSelectionScreen> {
  List<Map<String, dynamic>> sessions = [];
  final DBHelper dbHelper = DBHelper.instance;
  String loadingMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Offline mode
      setState(() {
        loadingMessage = 'Loading Sessions';
      });
      sessions = await dbHelper.getFranchiseSessions(widget.franchiseId);
    } else {
      // Online mode
      await _fetchAndStoreSessions();
      sessions = await dbHelper.getFranchiseSessions(widget.franchiseId);
    }
    setState(() {});
  }

  Future<void> _fetchAndStoreSessions() async {
    setState(() {
      loadingMessage = 'Loading Sessions';
    });
    final response = await http.get(Uri.parse('https://api.web.ableaura.com/academy/franchise/sessions/all'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data') && responseData['data'] is List) {
        final List<dynamic> franchiseSessions = responseData['data'];
        for (var session in franchiseSessions) {
          final franchise = session['franchise'];

          await dbHelper.insertFranchise({
            'id': franchise['id'],
            'franchise_name': franchise['franchise_name'],
            'location_id': franchise['location_id'],
            'franchise_owner_id': franchise['franchise_owner_id'],
            'created_at': franchise['created_at'],
            'updated_at': franchise['updated_at'],
          });

          await dbHelper.insertFranchiseSession({
            'id': session['id'],
            'franchise_id': session['franchise_id'],
            'session_name': session['name'],
            'start_time': session['start_time'],
            'end_time': session['end_time'],
            'created_at': session['created_at'],
            'updated_at': session['updated_at'],
          });
        }
      }
    }
  }

  void _selectSession(int sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedSessionId', sessionId);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QRCheckInPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Session'),
      ),
      body: sessions.isEmpty
          ? LoadingWidget(message: loadingMessage)
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  title: Text(session['session_name']),
                  subtitle: Text('Start: ${session['start_time']} - End: ${session['end_time']}'),
                  onTap: () {
                    _selectSession(session['id']);
                  },
                );
              },
            ),
    );
  }
}
