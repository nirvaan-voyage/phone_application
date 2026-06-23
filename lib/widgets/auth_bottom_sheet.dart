import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../screens/forgot_password_method_screen.dart';
import '../widgets/nirvaan_logo.dart';

Future<bool> showAuthSheet(
  BuildContext context, {
  bool startInCreateAccount = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AuthSheet(
      initialMode:
          startInCreateAccount ? _AuthMode.createAccount : _AuthMode.signIn,
    ),
  );
  return result == true;
}

enum _AuthMode { signIn, createAccount }

class _AuthSheet extends ConsumerStatefulWidget {
  const _AuthSheet({required this.initialMode});

  final _AuthMode initialMode;

  @override
  ConsumerState<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends ConsumerState<_AuthSheet> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _loginController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  late _AuthMode _mode;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _rememberMe = true;

  String? _nameError;
  String? _ageError;
  String? _loginError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _loginController.addListener(_refreshForLoginType);
  }

  @override
  void dispose() {
    _loginController.removeListener(_refreshForLoginType);
    _nameController.dispose();
    _ageController.dispose();
    _loginController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool get _isCreateAccount => _mode == _AuthMode.createAccount;

  bool get _isPhoneLogin {
    if (_isCreateAccount) return false;
    final value = _loginController.text.trim();
    return RegExp(r'^\d+$').hasMatch(value);
  }

  void _refreshForLoginType() {
    if (!_isCreateAccount) {
      setState(() {
        _loginError = null;
        _otpError = null;
        _passwordError = null;
      });
    }
  }

  void _switchToCreateAccount() {
    setState(() {
      _mode = _AuthMode.createAccount;
      _clearErrors();
    });
  }

  void _switchToSignIn() {
    setState(() {
      _mode = _AuthMode.signIn;
      _clearErrors();
    });
  }

  void _clearErrors() {
    _nameError = null;
    _ageError = null;
    _loginError = null;
    _phoneError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    _otpError = null;
  }

  bool _isValidPassword(String password) => password.length >= 6;

  List<String> _missingPasswordRequirements(String password) {
    if (password.isEmpty || password.length >= 6) return const [];
    return const ['At least 6 characters'];
  }

  bool _isValidEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _clearErrors();

      final loginId = _loginController.text.trim();
      final password = _passwordController.text;

      if (_isCreateAccount) {
        final name = _nameController.text.trim();
        final ageText = _ageController.text.trim();
        final phone = _phoneController.text.trim();
        final confirmPassword = _confirmPasswordController.text;

        if (name.isEmpty) {
          _nameError = 'Please enter your name';
        }

        if (ageText.isEmpty) {
          _ageError = 'Please enter your age';
        } else if (int.tryParse(ageText) == null) {
          _ageError = 'Please enter a valid age';
        }

        if (loginId.isEmpty) {
          _loginError = 'Please enter your email';
        } else if (!_isValidEmail(loginId)) {
          _loginError = 'Please enter a valid email';
        }

        if (phone.isEmpty) {
          _phoneError = 'Please enter your phone number';
        } else if (phone.length != 10) {
          _phoneError = 'Phone number must be 10 digits';
        }

        if (password.isEmpty) {
          _passwordError = 'Please enter your password';
        } else if (!_isValidPassword(password)) {
          _passwordError = 'Password must be at least 6 characters';
        }

        if (confirmPassword.isEmpty) {
          _confirmPasswordError = 'Please confirm your password';
        } else if (confirmPassword != password) {
          _confirmPasswordError = 'Passwords do not match';
        }
      } else {
        if (loginId.isEmpty) {
          _loginError = 'Enter email, username, or phone';
        } else if (_isPhoneLogin && loginId.length != 10) {
          _loginError = 'Phone number must be 10 digits';
        }

        if (_isPhoneLogin) {
          final otp = _otpController.text.trim();
          if (otp.isEmpty) {
            _otpError = 'Enter the 4-digit OTP';
          } else if (otp.length != 4) {
            _otpError = 'OTP must be 4 digits';
          }
        } else if (password.isEmpty) {
          _passwordError = 'Please enter your password';
        } else if (password.length < 6) {
          _passwordError = 'Minimum 6 characters';
        }
      }
    });

    final hasErrors = [
      _nameError,
      _ageError,
      _loginError,
      _phoneError,
      _passwordError,
      _confirmPasswordError,
      _otpError,
    ].any((error) => error != null);

    if (hasErrors) return;

    await ref.read(authProvider.notifier).login(
          _loginController.text.trim(),
          name: _isCreateAccount ? _nameController.text.trim() : null,
          age: _isCreateAccount ? int.tryParse(_ageController.text.trim()) : null,
          phone: _isCreateAccount
              ? _phoneController.text.trim()
              : (_isPhoneLogin ? _loginController.text.trim() : null),
          rememberMe: _rememberMe,
        );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _socialLogin(String provider) async {
    await ref.read(authProvider.notifier).socialLogin(
          provider,
          rememberMe: _rememberMe,
        );
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _openForgotPassword() {
    final navigator = Navigator.of(context);
    navigator.pop(false);
    Future.microtask(() {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => const ForgotPasswordMethodScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.88;
    final missingPasswordRequirements =
        _missingPasswordRequirements(_passwordController.text);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                const NirvaanLogo(size: 62, showTagline: false),
                const SizedBox(height: 10),
                Text(
                  _isCreateAccount ? 'Create account' : 'Sign in',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isCreateAccount
                      ? 'Set up your Nirvaan profile'
                      : 'Use email, username, or phone',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 18),
                if (_isCreateAccount) ...[
                  _SheetField(
                    controller: _nameController,
                    hint: 'Name',
                    errorText: _nameError,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  _SheetField(
                    controller: _ageController,
                    hint: 'Age',
                    errorText: _ageError,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                _SheetField(
                  controller: _loginController,
                  hint: _isCreateAccount ? 'Email' : 'Email, username, or phone',
                  errorText: _loginError,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                if (_isCreateAccount) ...[
                  const SizedBox(height: 10),
                  _SheetField(
                    controller: _phoneController,
                    hint: 'Phone number',
                    errorText: _phoneError,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                if (_isPhoneLogin)
                  _SheetField(
                    controller: _otpController,
                    hint: '4-digit OTP',
                    errorText: _otpError,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onSubmitted: (_) => _submit(),
                  )
                else
                  _SheetField(
                    controller: _passwordController,
                    hint: 'Password',
                    errorText: _passwordError,
                    obscure: !_passwordVisible,
                    textInputAction:
                        _isCreateAccount ? TextInputAction.next : TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isCreateAccount) _submit();
                    },
                    onChanged: (_) {
                      if (_isCreateAccount) {
                        setState(() => _passwordError = null);
                      }
                    },
                    suffix: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: AppColors.hint,
                      ),
                      onPressed: () => setState(
                        () => _passwordVisible = !_passwordVisible,
                      ),
                    ),
                  ),
                if (_isCreateAccount) ...[
                  const SizedBox(height: 10),
                  _SheetField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm password',
                    errorText: _confirmPasswordError,
                    obscure: !_confirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    suffix: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 18,
                        color: AppColors.hint,
                      ),
                      onPressed: () => setState(
                        () => _confirmPasswordVisible = !_confirmPasswordVisible,
                      ),
                    ),
                  ),
                ],
                if (_isCreateAccount &&
                    _passwordController.text.isNotEmpty &&
                    missingPasswordRequirements.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      missingPasswordRequirements.first,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.red,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                    ),
                    Text(
                      'Remember me',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    if (!_isCreateAccount)
                      TextButton(
                        onPressed: _openForgotPassword,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isCreateAccount
                          ? 'Continue'
                          : (_isPhoneLogin ? 'Verify OTP' : 'Sign In'),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!_isCreateAccount) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Google',
                          icon: Text(
                            'G',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4285F4),
                            ),
                          ),
                          onTap: () => _socialLogin('Google'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SocialButton(
                          label: 'Apple',
                          icon: const Icon(Icons.apple, size: 20),
                          onTap: () => _socialLogin('Apple'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: _switchToCreateAccount,
                            child: Text(
                              'Create account',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _switchToSignIn,
                    child: Text(
                      'Already have an account? Sign in',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.hint,
    this.errorText,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.textInputAction,
    this.inputFormatters,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.hint,
        ),
        errorText: errorText,
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
