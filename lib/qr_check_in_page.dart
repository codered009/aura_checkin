import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'franchise_selection_screen.dart';
import 'timing_selection_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'app_drawer.dart';
import 'sync_service.dart';
import 'db_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRCheckInPage extends StatefulWidget {
  const QRCheckInPage({super.key});

  @override
  _QRCheckInPageState createState() => _QRCheckInPageState();
}

class _QRCheckInPageState extends State<QRCheckInPage> {
  String apiResponse = '';
  bool isProcessing = false;
  String? scannedCode;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? selectedFranchiseId;
  int? selectedSessionId;
  Map<String, dynamic>? studentInfo;
  final SyncService syncService = SyncService();
  final DBHelper dbHelper = DBHelper.instance;
  final http.Client httpClient = http.Client(); // Reuse the same HTTP client instance

  @override
  void initState() {
    super.initState();
    _loadSelectedValues();
    syncService.synchronizeData(); // Synchronize data on start
  }

  Future<void> _loadSelectedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFranchiseId = prefs.getInt('selectedFranchiseId');
      selectedSessionId = prefs.getInt('selectedSessionId');
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _handleQRCode(String code) async {
    setState(() {
      apiResponse = 'Processing...';
      isProcessing = true;
    });

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        // Offline mode
        var students = await dbHelper.getStudents();
        var student = students.firstWhere(
          (student) => student['unique_id'] == code,
          orElse: () => <String, dynamic>{}, // Return an empty map if not found
        );
        if (student.isNotEmpty) {
          Position position = await _determinePosition();
          var now = DateTime.now();
          await dbHelper.insertStudentCheckIn({
            'student_id': student['id'],
            'lat': position.latitude,
            'lng': position.longitude,
            'date': now.toIso8601String(),
            'is_checked_in': 1,
            'check_in_time': now.toIso8601String(),
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });
          setState(() {
            studentInfo = student;
            apiResponse = 'Checked in locally';
          });
          _playSuccessNotificationSound();
        } else {
          setState(() {
            apiResponse = 'Student not found in local database';
          });
        }
      } else {
        // Online mode
        Position position = await _determinePosition();
        final response = await httpClient.post(
          Uri.parse('https://api.web.ableaura.com/academy/students/checkin/entry'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'franchise_id': selectedFranchiseId,
            'session_id': selectedSessionId,
            'qr_code': code,
            'latitude': position.latitude,
            'longitude': position.longitude,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            apiResponse = responseData['message'];
            studentInfo = responseData['data'];
          });
          if (responseData['data'] != null && responseData['data']['is_payment_pending'] == true) {
            _playNotificationSound();
          } else if (responseData['data'] != null && responseData['data']['is_checked_in'] == true) {
            _playExistsNotificationSound();
          } else {
            _playSuccessNotificationSound();
          }
        } else {
          setState(() {
            apiResponse = 'Failed to check-in. Please try again.';
          });
        }
      }
    } catch (e) {
      setState(() {
        apiResponse = 'Error: $e';
      });
    } finally {
      setState(() {
        isProcessing = false;
      });
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          apiResponse = '';
          scannedCode = null;
          studentInfo = null;
        });
      });
    }
  }

  void _playNotificationSound() async {
    await _audioPlayer.play(AssetSource('loud_alarm.mp3'));
  }

  void _playSuccessNotificationSound() async {
    await _audioPlayer.play(AssetSource('success.mp3'));
  }

  void _playExistsNotificationSound() async {
    await _audioPlayer.play(AssetSource('exists.mp3'));
  }

  void _changeFranchise(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FranchiseSelectionScreen()),
    );
  }

  void _changeSession(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TimingSelectionScreen(franchiseId: selectedFranchiseId!)),
    );
  }

  void _showManualEntryDialog() {
    TextEditingController _manualEntryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter QR Code Manually'),
          content: Row(
            children: [
              Text(
                'AAA#',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: TextField(
                  controller: _manualEntryController,
                  maxLength: 5, // Enforce the 5 digit limit
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Enter QR Code',
                    counterText: '', // Remove the counter text
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleQRCode('AAA#' + _manualEntryController.text);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Check-In'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: AppDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 8.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.all(16.0),
                  child: MobileScanner(
                    onDetect: (barcode) {
                      if (!isProcessing && barcode.barcodes.isNotEmpty) {
                        final String code = barcode.barcodes.first.rawValue ?? '';
                        setState(() {
                          scannedCode = code;
                          _handleQRCode(code);
                        });
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isProcessing) const CircularProgressIndicator(),
                      if (!isProcessing && apiResponse.isNotEmpty)
                        Text(
                          apiResponse,
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _changeFranchise(context),
                            child: const Text('Change Franchise'),
                          ),
                                                   const SizedBox(width: 20.0),
                          ElevatedButton(
                            onPressed: () => _changeSession(context),
                            child: const Text('Change Session'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: _showManualEntryDialog,
                        child: const Text('Enter QR Code Manually'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (studentInfo != null)
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: CachedNetworkImageProvider(studentInfo!['profile_picture']),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'ID: ${studentInfo!['student_id']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Name: ${studentInfo!['student_name']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (studentInfo!['is_payment_pending'] == true)
                        Text(
                          'Payment Pending',
                          style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      if (studentInfo!['is_checked_in'] == true)
                        Text(
                          'Already Checked In',
                          style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
