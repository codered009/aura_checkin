import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';
import 'at_home_coach_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;
  final List<CameraDescription> cameras;

  OtpVerifyScreen({required this.phone, required this.cameras});

  @override
  _OtpVerifyScreenState createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;

  Future<void> _verifyOtp() async {
    final otp = _otpController.text;

    if (otp.isEmpty || otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 4-digit OTP')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.web.ableaura.com/academy/coach/verifyotp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile_no': widget.phone, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          String authToken = data['data']['access_token'];

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AtHomeCoachScreen(
                authToken: authToken,
                cameras: widget.cameras,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP verification failed. Please try again.')),
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
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Enter the OTP sent to ${widget.phone}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                child: _isVerifying
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
