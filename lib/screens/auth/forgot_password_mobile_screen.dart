import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mobile_otp_screen.dart';

class ForgotPasswordMobileScreen extends StatefulWidget {
  const ForgotPasswordMobileScreen({super.key});

  @override
  State<ForgotPasswordMobileScreen> createState() =>
      _ForgotPasswordMobileScreenState();
}

class _ForgotPasswordMobileScreenState
    extends State<ForgotPasswordMobileScreen> {
  final _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    setState(() {
      if (phone.isEmpty) {
        _phoneError = 'Enter your mobile number';
      } else if (phone.length != 10) {
        _phoneError = 'Phone number must be 10 digits';
      } else {
        _phoneError = null;
      }
    });

    if (_phoneError != null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MobileOtpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            24,
            10,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFEAF1FB),
                child: Icon(
                  Icons.phone_android,
                  color: Color(0xFF4A7FD4),
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Reset via Mobile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your registered mobile number.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _sendOtp(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText: 'Mobile Number',
                  errorText: _phoneError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _sendOtp,
                  child: const Text('Send OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
