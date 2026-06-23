import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'new_password_screen.dart';

class EmailOtpScreen extends StatefulWidget {
  const EmailOtpScreen({super.key});

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final _otpController = TextEditingController();
  String? _otpError;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    final otp = _otpController.text.trim();
    setState(() {
      if (otp.isEmpty) {
        _otpError = 'Enter the 4-digit OTP';
      } else if (otp.length != 4) {
        _otpError = 'OTP must be 4 digits';
      } else {
        _otpError = null;
      }
    });

    if (_otpError != null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NewPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFEAF1FB),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF4A7FD4),
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the 4-digit OTP sent to your email.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _otpController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _verify(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  hintText: '4-digit OTP',
                  errorText: _otpError,
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
                  onPressed: _verify,
                  child: const Text('Verify Code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
