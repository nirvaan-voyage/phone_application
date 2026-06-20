import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
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
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late _AuthMode _mode;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String? _nameError;
  String? _ageError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isCreateAccount => _mode == _AuthMode.createAccount;

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
    _emailError = null;
    _phoneError = null;
    _passwordError = null;
    _confirmPasswordError = null;
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  List<String> _missingPasswordRequirements(String password) {
    final missing = <String>[];
    if (password.length < 6) {
      missing.add('At least 6 characters');
    }
    return missing;
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    setState(() {
      _clearErrors();

      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _emailError = 'Please enter your email';
      } else if (!email.contains('@') || !email.contains('.')) {
        _emailError = 'Please enter a valid email';
      }

      final password = _passwordController.text;
      if (password.isEmpty) {
        _passwordError = 'Please enter your password';
      } else if (_isCreateAccount && !_isValidPassword(password)) {
        _passwordError = 'Password must be at least 6 characters';
      } else if (!_isCreateAccount && password.length < 6) {
        _passwordError = 'Minimum 6 characters';
      }

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

        if (phone.isEmpty) {
          _phoneError = 'Please enter your phone number';
        } else if (phone.length < 10) {
          _phoneError = 'Enter a valid phone number';
        }

        if (confirmPassword.isEmpty) {
          _confirmPasswordError = 'Please confirm your password';
        } else if (confirmPassword != password) {
          _confirmPasswordError = 'Passwords do not match';
        }
      }
    });

    final hasErrors = [
      _nameError,
      _ageError,
      _emailError,
      _phoneError,
      _passwordError,
      _confirmPasswordError,
    ].any((error) => error != null);

    if (hasErrors) return;

    ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          name: _isCreateAccount ? _nameController.text.trim() : null,
          age: _isCreateAccount ? int.tryParse(_ageController.text.trim()) : null,
          phone: _isCreateAccount ? _phoneController.text.trim() : null,
        );

    Navigator.of(context).pop(true);
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
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
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
                const SizedBox(height: 20),
                const NirvaanLogo(size: 72, showTagline: false),
                const SizedBox(height: 14),
                Text(
                  _isCreateAccount ? 'Create account' : 'Sign in to continue',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isCreateAccount
                      ? 'Set up your Nirvaan profile'
                      : 'Access all features of Nirvaan',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 22),
                if (_isCreateAccount) ...[
                  _SheetField(
                    controller: _nameController,
                    hint: 'Name',
                    errorText: _nameError,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
                ],
                _SheetField(
                  controller: _emailController,
                  hint: 'Email',
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                if (_isCreateAccount) ...[
                  const SizedBox(height: 12),
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
                const SizedBox(height: 12),
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
                      setState(() {
                        _passwordError = null;
                      });
                    }
                  },
                  suffix: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                      color: AppColors.hint,
                    ),
                    onPressed: () => setState(
                      () => _passwordVisible = !_passwordVisible,
                    ),
                  ),
                ),
                if (_isCreateAccount) ...[
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: missingPasswordRequirements
                          .map(
                            (requirement) => Text(
                              requirement,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.red,
                                height: 1.35,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isCreateAccount ? 'Continue' : 'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!_isCreateAccount) ...[
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 14),
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
          vertical: 13,
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
