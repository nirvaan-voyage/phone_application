import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'new_password_screen.dart';
import '../../repositories/auth_repository.dart';

class EmailOtpScreen extends StatefulWidget {
  final String email;

  const EmailOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final _otpController = TextEditingController();
  final _repository = AuthRepository();
  String? _otpError;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();

    setState(() {
      if (otp.isEmpty) {
        _otpError = 'Enter the 6-digit OTP';
      } else if (otp.length != 6) {
        _otpError = 'OTP must be 6 digits';
      } else {
        _otpError = null;
      }
    });

    if (_otpError != null) return;

    try {
      await _repository.verifyOTP(
        email: widget.email,
        purpose: "forgot_password",
        code: otp,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordScreen(
            email: widget.email,
            code: otp,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
        ),
      );
    }
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
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  hintText: '6-digit OTP',
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
