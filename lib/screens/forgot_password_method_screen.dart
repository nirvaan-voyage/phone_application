// ──────────────────────────────────────────────────────────────────────────
// NOTE FOR TANYA / MERGE:
// These forgot-password screens are Meghna's UI work. They are intentionally
// UI-only for now — backend OTP/reset endpoints will be wired by Vaanya.
// Do NOT delete these files. They are reachable from auth_bottom_sheet.dart.
// ──────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'forgot_password_email_screen.dart';
import 'forgot_password_mobile_screen.dart';

class ForgotPasswordMethodScreen extends StatelessWidget {
  const ForgotPasswordMethodScreen({super.key});

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
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FB),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Color(0xFF4A7FD4),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Reset your password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'How would you like to receive your reset code?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _methodCard(
              icon: Icons.email_outlined,
              title: 'Email address',
              subtitle: 'Code sent to your email',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ForgotPasswordEmailScreen()),
              ),
            ),
            const SizedBox(height: 15),
            const Text('OR'),
            const SizedBox(height: 15),
            _methodCard(
              icon: Icons.phone_android,
              title: 'Mobile number',
              subtitle: 'OTP sent via SMS',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ForgotPasswordMobileScreen()),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4A7FD4)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
