import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/services/google_auth_service.dart';
import '../providers/auth_provider.dart';
import '../screens/forgot_password_method_screen.dart';
import '../screens/travel_details_screen.dart';
import '../widgets/nirvaan_logo.dart';

/// Shows the auth bottom sheet.
/// Returns true if the user successfully authenticated, false/null otherwise.
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
  // ── Controllers ──────────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late _AuthMode _mode;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _rememberMe = true;

  // ── Field-level errors ────────────────────────────────────────────────────
  String? _nameError;
  String? _usernameError;
  String? _ageError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isCreateAccount => _mode == _AuthMode.createAccount;

  void _switchToCreateAccount() => setState(() {
        _mode = _AuthMode.createAccount;
        _clearErrors();
      });

  void _switchToSignIn() => setState(() {
        _mode = _AuthMode.signIn;
        _clearErrors();
      });

  void _clearErrors() {
    _nameError = null;
    _usernameError = null;
    _ageError = null;
    _emailError = null;
    _phoneError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    _serverError = null;
  }

  // ── Client-side validation ─────────────────────────────────────────────
  bool _validateFields() {
    bool valid = true;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _emailError = 'Please enter your email';
      valid = false;
    } else if (!email.contains('@') || !email.contains('.')) {
      _emailError = 'Please enter a valid email';
      valid = false;
    } else {
      _emailError = null;
    }

    final password = _passwordController.text;
    if (password.isEmpty) {
      _passwordError = 'Please enter your password';
      valid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      valid = false;
    } else {
      _passwordError = null;
    }

    if (_isCreateAccount) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _nameError = 'Please enter your name';
        valid = false;
      } else {
        _nameError = null;
      }

      final username = _usernameController.text.trim();
      if (username.isEmpty) {
        _usernameError = 'Please choose a username';
        valid = false;
      } else if (username.length < 3) {
        _usernameError = 'Username must be at least 3 characters';
        valid = false;
      } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
        _usernameError = 'Only letters, numbers, and underscores';
        valid = false;
      } else {
        _usernameError = null;
      }

      final ageText = _ageController.text.trim();
      if (ageText.isEmpty) {
        _ageError = 'Please enter your age';
        valid = false;
      } else {
        final age = int.tryParse(ageText);
        if (age == null || age < 13 || age > 120) {
          _ageError = 'Please enter a valid age (13+)';
          valid = false;
        } else {
          _ageError = null;
        }
      }

      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        _phoneError = 'Please enter your phone number';
        valid = false;
      } else if (phone.length < 10) {
        _phoneError = 'Enter a valid 10-digit number';
        valid = false;
      } else {
        _phoneError = null;
      }

      final confirmPassword = _confirmPasswordController.text;
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
        valid = false;
      } else if (confirmPassword != password) {
        _confirmPasswordError = 'Passwords do not match';
        valid = false;
      } else {
        _confirmPasswordError = null;
      }
    }

    return valid;
  }

  // ── Submit ─────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _clearErrors());

    if (!_validateFields()) {
      setState(() {}); // trigger rebuild to show field errors
      return;
    }

    final notifier = ref.read(authProvider.notifier);
    String? error;

    if (_isCreateAccount) {
      error = await notifier.register(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        password: _passwordController.text,
      );
    } else {
      error = await notifier.login(
        // Sign-in accepts email OR username — send whatever they typed
        emailOrUsername: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );
    }

    if (!mounted) return;

    if (error != null) {
      setState(() => _serverError = error);
    } else {
      Navigator.of(context).pop(true);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.92;

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
                // Drag handle
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

                // ── Server error banner ──────────────────────────────────
                if (_serverError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: Colors.red.shade400, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _serverError!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.red.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Registration-only fields ─────────────────────────────
                if (_isCreateAccount) ...[
                  _SheetField(
                    controller: _nameController,
                    hint: 'Full name',
                    errorText: _nameError,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  _SheetField(
                    controller: _usernameController,
                    hint: 'Username (e.g. travel_meghna)',
                    errorText: _usernameError,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9_]')),
                      LengthLimitingTextInputFormatter(30),
                    ],
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

                // ── Email / Username field ────────────────────────────────
                _SheetField(
                  controller: _emailController,
                  hint: _isCreateAccount
                      ? 'Email address'
                      : 'Email or username',
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),

                // ── Phone (registration only) ─────────────────────────────
                if (_isCreateAccount) ...[
                  const SizedBox(height: 12),
                  _SheetField(
                    controller: _phoneController,
                    hint: 'Phone number (10 digits)',
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

                // ── Password ──────────────────────────────────────────────
                _SheetField(
                  controller: _passwordController,
                  hint: 'Password',
                  errorText: _passwordError,
                  obscure: !_passwordVisible,
                  textInputAction: _isCreateAccount
                      ? TextInputAction.next
                      : TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isCreateAccount) _submit();
                  },
                  onChanged: (_) => setState(() => _passwordError = null),
                  suffix: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                      color: AppColors.hint,
                    ),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),

                // ── Confirm password (registration only) ──────────────────
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
                      onPressed: () => setState(() =>
                          _confirmPasswordVisible = !_confirmPasswordVisible),
                    ),
                  ),
                ],

                // ── Remember Me (sign-in only) ────────────────────────────
                if (!_isCreateAccount) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (v) =>
                                setState(() => _rememberMe = v ?? true),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _rememberMe = !_rememberMe),
                            child: Text(
                              'Remember me',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ForgotPasswordMethodScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 22),

                // ── Submit button ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isCreateAccount ? 'Create Account' : 'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Google Sign-In button ─────────────────────────────────
                _SocialButton(
                  label: AppStrings.googleBtn,
                  icon: Text(
                    'G',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4285F4),
                    ),
                  ),
                  onTap: () async {
                    try {
                      final user = await GoogleAuthService.signInWithGoogle();

                      if (user != null && mounted) {
                        // Update auth state with Google user info
                        final firebaseUser = user.user;
                        if (firebaseUser != null) {
                          final notifier = ref.read(authProvider.notifier);
                          await notifier.persistAndApplySession(
                            token: await firebaseUser.getIdToken() ?? '',
                            email: firebaseUser.email ?? '',
                            name: firebaseUser.displayName,
                            username: firebaseUser.email?.split('@').first,
                            phone: firebaseUser.phoneNumber,
                          );
                        }
                        Navigator.of(context).pop(true);
                      }
                    } catch (e) {
                      if (mounted) {
                        String errorMsg = 'Google Sign-In failed';
                        if (e.toString().contains('network')) {
                          errorMsg = 'Network error. Please check your internet connection.';
                        } else if (e.toString().contains('Firebase')) {
                          errorMsg = 'Firebase authentication failed. Check Firebase Console configuration.';
                        } else if (e.toString().contains('account')) {
                          errorMsg = 'No Google account found on device.';
                        }
                        setState(() => _serverError = '$errorMsg\n\nCheck debug console for details.');
                      }
                    }
                  },
                ),

                const SizedBox(height: 16),

                // ── Switch mode link ──────────────────────────────────────
                if (!_isCreateAccount)
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 13,
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
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _switchToSignIn,
                    child: Text(
                      'Already have an account? Sign in',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Social sign-in button ───────────────────────────────────────────────────
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}

// ── Reusable sheet text field ──────────────────────────────────────────────
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
