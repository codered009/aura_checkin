import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'franchise_selection_screen.dart';
import 'timing_selection_screen.dart';
import 'package:geolocator/geolocator.dart';

class QRCheckInPage extends StatefulWidget {
  const QRCheckInPage({super.key});

  @override
  _QRCheckInPageState createState() => _QRCheckInPageState();
}

class _QRCheckInPageState extends State<QRCheckInPage> {
  final GlobalKey _qrKey = GlobalKey();
  QRViewController? _qrViewController;
  String apiResponse = '';
  bool isProcessing = false;
  String? scannedCode;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? selectedFranchiseId;
  int? selectedSessionId;

  @override
  void initState() {
    super.initState();
    _loadSelectedValues();
  }

  Future<void> _loadSelectedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFranchiseId = prefs.getInt('selectedFranchiseId');
      selectedSessionId = prefs.getInt('selectedSessionId');
    });
  }

  @override
  void dispose() {
    _qrViewController?.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Check-In'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 8.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.all(16.0),
              child: QRView(
                key: _qrKey,
                onQRViewCreated: _onQRViewCreated,
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
                  Text(
                    apiResponse,
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isProcessing) const SizedBox(height: 20.0),
                  if (isProcessing) const CircularProgressIndicator(),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing && scanData.code != scannedCode) {
        setState(() {
          scannedCode = scanData.code;
          _handleQRCode(scanData.code!);
        });
      }
    });
  }

  Future<void> _handleQRCode(String code) async {
    setState(() {
      apiResponse = 'Processing...';
      isProcessing = true;
    });

    try {
      Position position = await _determinePosition();
      final response = await http.post(
        Uri.parse('https://api.web.ableaura.com/academy/students/checkin/entry'),  // Replace with your actual endpoint
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
        });
        // Check if is_payment_pending is true
        if (responseData['data'] != null && responseData['data']['is_payment_pending'] == true) {
          _playNotificationSound();
        }
      } else {
        setState(() {
          apiResponse = 'Failed to check-in. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        apiResponse = 'Error: $e';
      });
    } finally {
      setState(() {
        isProcessing = false;
      });
      // Resume the QR scanner and stop the notification sound after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        _qrViewController?.resumeCamera();
        _audioPlayer.stop();
        setState(() {
          apiResponse = '';
          scannedCode = null;
        });
      });
    }
  }

  void _playNotificationSound() async {
    await _audioPlayer.play(AssetSource('loud_alarm.mp3'));
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
}
