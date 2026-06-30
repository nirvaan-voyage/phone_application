import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── State ──────────────────────────────────────────────────────────────────
class TravelFormState {
  const TravelFormState({
    this.selectedState,
    this.selectedCities = const [],
    this.surpriseState = false,
    this.surpriseMe = false,
    this.adults = 1,
    this.kids = 0,
    this.checkIn,
    this.checkOut,
    this.nameError,
    this.ageError,
    this.stateError,
    this.dateError,
  });

  final String? selectedState;
  final List<String> selectedCities;
  final bool surpriseState;
  final bool surpriseMe;
  final int adults;
  final int kids;
  final DateTime? checkIn;
  final DateTime? checkOut;

  // Validation errors
  final String? nameError;
  final String? ageError;
  final String? stateError;
  final String? dateError;

  TravelFormState copyWith({
    String? selectedState,
    List<String>? selectedCities,
    bool? surpriseState,
    bool? surpriseMe,
    int? adults,
    int? kids,
    DateTime? checkIn,
    DateTime? checkOut,
    String? nameError,
    String? ageError,
    String? stateError,
    String? dateError,
    bool clearState = false,
    bool clearCheckIn = false,
    bool clearCheckOut = false,
    bool clearNameError = false,
    bool clearAgeError = false,
    bool clearStateError = false,
    bool clearDateError = false,
  }) {
    return TravelFormState(
      selectedState: clearState ? null : (selectedState ?? this.selectedState),
      selectedCities: selectedCities ?? this.selectedCities,
      surpriseState: surpriseState ?? this.surpriseState,
      surpriseMe: surpriseMe ?? this.surpriseMe,
      adults: adults ?? this.adults,
      kids: kids ?? this.kids,
      checkIn: clearCheckIn ? null : (checkIn ?? this.checkIn),
      checkOut: clearCheckOut ? null : (checkOut ?? this.checkOut),
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      ageError: clearAgeError ? null : (ageError ?? this.ageError),
      stateError: clearStateError ? null : (stateError ?? this.stateError),
      dateError: clearDateError ? null : (dateError ?? this.dateError),
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────
class TravelFormNotifier extends Notifier<TravelFormState> {
  @override
  TravelFormState build() => const TravelFormState();

  void selectState(String stateName) {
    state = state.copyWith(
      selectedState: stateName,
      selectedCities: [],
      surpriseState: false,
      surpriseMe: false,
      clearStateError: true,
    );
  }

  void toggleSurpriseState() {
    state = state.copyWith(
      surpriseState: !state.surpriseState,
      clearState: true,
      selectedCities: [],
      surpriseMe: false,
      clearStateError: true,
    );
  }

  void toggleCity(String city) {
    final cities = List<String>.from(state.selectedCities);
    if (cities.contains(city)) {
      cities.remove(city);
    } else {
      cities.add(city);
    }
    state = state.copyWith(selectedCities: cities, surpriseMe: false);
  }

  void toggleSurpriseMe() {
    state = state.copyWith(
      surpriseMe: !state.surpriseMe,
      selectedCities: [],
    );
  }

  void incrementAdults() =>
      state = state.copyWith(adults: state.adults + 1);

  void decrementAdults() {
    if (state.adults > 1) {
      state = state.copyWith(adults: state.adults - 1);
    }
  }

  void incrementKids() => state = state.copyWith(kids: state.kids + 1);

  void decrementKids() {
    if (state.kids > 0) {
      state = state.copyWith(kids: state.kids - 1);
    }
  }

  void setCheckIn(DateTime date) {
    state = state.copyWith(
      checkIn: date,
      clearDateError: true,
      // Clear checkout if it's now before the new check-in
      clearCheckOut: state.checkOut != null &&
          !state.checkOut!.isAfter(date.add(const Duration(days: 1))),
    );
  }

  void setCheckOut(DateTime date) {
    state = state.copyWith(checkOut: date, clearDateError: true);
  }

  /// Validates the form. Returns true if valid, false otherwise.
  /// Controller text values are passed in because they live in the widget.
  bool validate(String name, String age) {
    String? nameError;
    String? ageError;
    String? stateError;
    String? dateError;

    if (name.trim().isEmpty) {
      nameError = 'Please enter your name';
    }

    final parsedAge = int.tryParse(age.trim());
    if (age.trim().isEmpty) {
      ageError = 'Please enter your age';
    } else if (parsedAge == null || parsedAge < 1 || parsedAge > 120) {
      ageError = 'Enter a valid age';
    }

    if (!state.surpriseState && state.selectedState == null) {
      stateError = 'Please select a state or choose Surprise Me';
    }

    if (state.checkIn == null) {
      dateError = 'Check-in date is required';
    } else if (state.checkOut == null) {
      dateError = 'Check-out date is required';
    } else if (!state.checkOut!.isAfter(state.checkIn!)) {
      dateError = 'Check-out must be after check-in';
    }

    state = state.copyWith(
      nameError: nameError,
      ageError: ageError,
      stateError: stateError,
      dateError: dateError,
      clearNameError: nameError == null,
      clearAgeError: ageError == null,
      clearStateError: stateError == null,
      clearDateError: dateError == null,
    );

    return nameError == null &&
        ageError == null &&
        stateError == null &&
        dateError == null;
  }

  void reset() => state = const TravelFormState();
}

// ── Provider ───────────────────────────────────────────────────────────────
final travelFormProvider =
    NotifierProvider<TravelFormNotifier, TravelFormState>(
  TravelFormNotifier.new,
);
