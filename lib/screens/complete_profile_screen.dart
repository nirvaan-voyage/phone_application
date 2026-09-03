import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/primary_button.dart';
import 'main_app_screen.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();

  String? _usernameError;
  String? _phoneError;
  String? _ageError;
  String? _serverError;
  String? _profilePhotoPath;
  String _initialUsername = '';
  String _initialPhone = '';
  String _initialAge = '';
  String? _initialProfilePhotoPath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    _usernameController.text = auth.username ?? '';
    _phoneController.text = auth.phone ?? '';
    _ageController.text = auth.age?.toString() ?? '';
    _profilePhotoPath = auth.profilePhotoPath;
    _initialUsername = _usernameController.text;
    _initialPhone = _phoneController.text;
    _initialAge = _ageController.text;
    _initialProfilePhotoPath = _profilePhotoPath;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null || !mounted) return;

      final savedPath = await _saveProfilePhoto(File(image.path));
      if (!mounted) return;

      setState(() {
        _profilePhotoPath = savedPath;
        _serverError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _serverError = 'Could not open photos. Please check app permissions.';
      });
    }
  }

  Future<String> _saveProfilePhoto(File pickedFile) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final photosDirectory = Directory('${appDirectory.path}/profile_photos');
    if (!await photosDirectory.exists()) {
      await photosDirectory.create(recursive: true);
    }

    final extension = pickedFile.path.split('.').last.toLowerCase();
    final safeExtension = extension.length <= 5 ? extension : 'jpg';
    final fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
    final savedFile =
        await pickedFile.copy('${photosDirectory.path}/$fileName');
    return savedFile.path;
  }

  bool _hasUnsavedChanges() {
    return _usernameController.text.trim() != _initialUsername.trim() ||
        _phoneController.text.trim() != _initialPhone.trim() ||
        _ageController.text.trim() != _initialAge.trim() ||
        (_profilePhotoPath ?? '') != (_initialProfilePhotoPath ?? '');
  }

  Future<bool> _confirmExitWithUnsavedChanges() async {
    if (!_hasUnsavedChanges()) return true;

    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save profile changes?'),
        content: const Text(
            'You changed your profile. Do you want to save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (action == 'save') {
      await _onContinue(popAfterSave: false);
      return mounted && _serverError == null;
    }
    return action == 'discard';
  }

  bool _validateFields() {
    bool valid = true;

    // Username validation
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

    // Phone validation
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

    // Age validation
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

    return valid;
  }

  Future<void> _onContinue({bool popAfterSave = true}) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _usernameError = null;
      _phoneError = null;
      _ageError = null;
      _serverError = null;
    });

    if (!_validateFields()) {
      setState(() {});
      return;
    }

    final notifier = ref.read(authProvider.notifier);
    final error = await notifier.completeProfile(
      username: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      profilePhotoPath: _profilePhotoPath,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _serverError = error);
    } else {
      _initialUsername = _usernameController.text.trim();
      _initialPhone = _phoneController.text.trim();
      _initialAge = _ageController.text.trim();
      _initialProfilePhotoPath = _profilePhotoPath;
      if (!popAfterSave) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainAppScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final photoPath = _profilePhotoPath?.trim() ?? '';
    final hasLocalPhoto = photoPath.isNotEmpty && File(photoPath).existsSync();

    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canLeave = await _confirmExitWithUnsavedChanges();
        if (canLeave && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 18),

                // Header
                Text(
                  'Complete Your Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Just a few more details to get started',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                Column(
                  children: [
                    GestureDetector(
                      onTap: _pickProfilePhoto,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.inputFill,
                        backgroundImage:
                            hasLocalPhoto ? FileImage(File(photoPath)) : null,
                        child: !hasLocalPhoto
                            ? const Icon(
                                Icons.add_a_photo_rounded,
                                color: AppColors.primary,
                                size: 30,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickProfilePhoto,
                      icon: const Icon(Icons.photo_library_rounded, size: 18),
                      label: Text(
                        hasLocalPhoto
                            ? 'Change profile photo'
                            : 'Add profile photo',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Server error banner
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

                // Pre-filled info (read-only)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.name ?? 'User',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.userEmail ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.verified_rounded,
                          color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Username field
                TextField(
                  controller: _usernameController,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Choose a username',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.hint,
                    ),
                    errorText: _usernameError,
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(Icons.alternate_email_rounded,
                        color: AppColors.hint, size: 20),
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
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Phone field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Phone number (10 digits)',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.hint,
                    ),
                    errorText: _phoneError,
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(Icons.phone_rounded,
                        color: AppColors.hint, size: 20),
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
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Age field
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your age',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.hint,
                    ),
                    errorText: _ageError,
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(Icons.cake_rounded,
                        color: AppColors.hint, size: 20),
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
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Continue button
                PrimaryButton(
                  label: 'Continue',
                  onPressed: _onContinue,
                  backgroundColor: AppColors.textDark,
                  height: 48,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
