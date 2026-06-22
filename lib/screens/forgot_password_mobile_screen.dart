import 'package:flutter/material.dart';
import 'mobile_otp_screen.dart';

class ForgotPasswordMobileScreen extends StatelessWidget {
  const ForgotPasswordMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFEAF1FB),
              child: Icon(
                Icons.phone_android,
                color: const Color(0xFF4A7FD4),
                size: 40,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Reset via Mobile",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your registered mobile number",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Mobile Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MobileOtpScreen(),
                    ),
                  );
                },
                child: const Text("Send OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
