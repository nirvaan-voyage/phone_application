import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/services/location_api_service.dart';
import '../providers/travel_form_provider.dart';
import '../widgets/multi_select_chips.dart';
import '../widgets/primary_button.dart';
import '../widgets/searchable_dropdown.dart';

class TravelDetailsScreen extends ConsumerStatefulWidget {
  const TravelDetailsScreen({super.key});

  @override
  ConsumerState<TravelDetailsScreen> createState() =>
      _TravelDetailsScreenState();
}

class _TravelDetailsScreenState extends ConsumerState<TravelDetailsScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  List<LocationState> _states = [];
  List<String> _cities = [];
  bool _statesLoading = true;
  bool _citiesLoading = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    try {
      final states = await LocationApiService.fetchIndianStates();
      if (!mounted) return;

      setState(() {
        _states = states;
        _statesLoading = false;
        _locationError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _statesLoading = false;
        _locationError = 'Could not load states. Check your internet.';
      });
    }
  }

  Future<void> _loadCities(String stateCode) async {
    setState(() {
      _cities = [];
      _citiesLoading = true;
      _locationError = null;
    });

    try {
      final cities = await LocationApiService.fetchCitiesForState(stateCode);
      if (!mounted) return;

      setState(() {
        _cities = cities;
        _citiesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _citiesLoading = false;
        _locationError = 'Could not load cities. Try another state.';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _pickCheckIn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: _datepickerTheme,
    );

    if (picked != null) {
      ref.read(travelFormProvider.notifier).setCheckIn(picked);
    }
  }

  Future<void> _pickCheckOut() async {
    final form = ref.read(travelFormProvider);
    final firstDate = form.checkIn != null
        ? form.checkIn!.add(const Duration(days: 1))
        : DateTime.now().add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: _datepickerTheme,
    );

    if (picked != null) {
      ref.read(travelFormProvider.notifier).setCheckOut(picked);
    }
  }

  Widget Function(BuildContext, Widget?) get _datepickerTheme {
    return (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();

    final isValid = ref
        .read(travelFormProvider.notifier)
        .validate(_nameController.text, _ageController.text);

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Journey planned!',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(travelFormProvider);
    final notifier = ref.read(travelFormProvider.notifier);
    final stateNames = _states.map((state) => state.name).toList();
    final stateOptions = ['Surprise Me', ...stateNames];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _HeaderBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _ValidatedInputField(
                          label: AppStrings.labelName,
                          hint: 'John Doe',
                          controller: _nameController,
                          errorText: form.nameError,
                          onChanged: (_) {
                            if (form.nameError != null) {
                              notifier.validate(
                                _nameController.text,
                                _ageController.text,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _ValidatedInputField(
                          label: AppStrings.labelAge,
                          hint: '25',
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          errorText: form.ageError,
                          onChanged: (_) {
                            if (form.ageError != null) {
                              notifier.validate(
                                _nameController.text,
                                _ageController.text,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SearchableDropdown(
                    label: 'SELECT STATE *',
                    hint:
                        _statesLoading ? 'Loading states...' : 'Choose a state...',
                    items: stateOptions,
                    selectedValue:
                        form.surpriseState ? 'Surprise Me' : form.selectedState,
                    enabled: !_statesLoading,
                    errorText: form.stateError,
                    onSelected: (value) {
                      if (value == 'Surprise Me') {
                        if (!form.surpriseState) {
                          notifier.toggleSurpriseState();
                        }

                        setState(() {
                          _cities = [];
                          _citiesLoading = false;
                          _locationError = null;
                        });
                        return;
                      }

                      final selectedState = _states.firstWhere(
                        (state) => state.name == value,
                      );

                      notifier.selectState(selectedState.name);
                      _loadCities(selectedState.iso2);
                    },
                  ),
                  if (_locationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _locationError!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  MultiSelectChips(
                    label: 'SELECT CITIES (OPTIONAL)',
                    items: _cities,
                    selectedItems: form.selectedCities,
                    surpriseSelected: form.surpriseMe,
                    enabled: form.selectedState != null &&
                        !form.surpriseState &&
                        !_citiesLoading,
                    onToggle: (city) => notifier.toggleCity(city),
                    onToggleSurprise: () => notifier.toggleSurpriseMe(),
                  ),
                  if (_citiesLoading) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Loading cities...',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _CounterRow(
                    label: 'Adults',
                    subtitle: 'Age 13+',
                    count: form.adults,
                    onIncrement: notifier.incrementAdults,
                    onDecrement: notifier.decrementAdults,
                  ),
                  const SizedBox(height: 12),
                  _CounterRow(
                    label: 'Kids',
                    subtitle: 'Age 2-12',
                    count: form.kids,
                    onIncrement: notifier.incrementKids,
                    onDecrement: notifier.decrementKids,
                  ),
                  const SizedBox(height: 20),
                  _DatePickerField(
                    label: 'CHECK-IN *',
                    value: _formatDate(form.checkIn),
                    onTap: _pickCheckIn,
                    errorText: form.checkIn == null &&
                            form.dateError != null &&
                            form.dateError!.contains('Check-in')
                        ? form.dateError
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _DatePickerField(
                    label: 'CHECK-OUT *',
                    value: _formatDate(form.checkOut),
                    onTap: _pickCheckOut,
                    errorText: form.dateError != null &&
                            !form.dateError!.contains('Check-in')
                        ? form.dateError
                        : null,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _BottomBar(
            onBack: () => Navigator.pop(context),
            onContinue: _onContinue,
          ),
        ],
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppStrings.stepIndicator,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white60,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.5,
                        minHeight: 4,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Plan your ',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'Journey',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.whereHeaded,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValidatedInputField extends StatelessWidget {
  const _ValidatedInputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
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
            filled: true,
            fillColor: AppColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
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
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null ? Colors.red : AppColors.border,
                width: errorText != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? AppStrings.dateHint : value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: value.isEmpty
                          ? AppColors.hint
                          : AppColors.textDark,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primary.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.subtitle,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String label;
  final String subtitle;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _CountBtn(
                icon: Icons.remove,
                onTap: count > (label == 'Adults' ? 1 : 0)
                    ? onDecrement
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$count',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              _CountBtn(
                icon: Icons.add,
                onTap: onIncrement,
                filled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountBtn extends StatelessWidget {
  const _CountBtn({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: filled
              ? (enabled ? AppColors.primary : AppColors.border)
              : Colors.transparent,
          border: filled
              ? null
              : Border.all(
                  color: enabled ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled
              ? AppColors.white
              : (enabled ? AppColors.primary : AppColors.hint),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.onBack,
    required this.onContinue,
  });

  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: 'Back',
              onPressed: onBack,
              isOutlined: true,
              foregroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              label: 'Continue',
              onPressed: onContinue,
            ),
          ),
        ],
      ),
    );
  }
}
