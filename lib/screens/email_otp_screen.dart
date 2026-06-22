import 'package:flutter/material.dart';
import 'new_password_screen.dart';

class EmailOtpScreen extends StatelessWidget {
  const EmailOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFEAF1FB),
              child: Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF4A7FD4),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Check Your Email",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter the 6-digit OTP sent to your email",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 45,
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewPasswordScreen(),
                    ),
                  );
                },
                child: const Text("Verify Code"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
