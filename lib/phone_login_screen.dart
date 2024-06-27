import 'package:flutter/material.dart';
import 'otp_verify_screen.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PhoneLoginScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const PhoneLoginScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isSendingOtp = false;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text;

    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    try {
      var countryCode = 91;
      final response = await http.post(
        Uri.parse('https://api.web.ableaura.com/academy/coach/sendotp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile_no': phone,'country_code' : countryCode}),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerifyScreen(phone: phone, cameras: widget.cameras),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSendingOtp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login with Phone'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Enter your phone number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSendingOtp ? null : _sendOtp,
                child: _isSendingOtp
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
