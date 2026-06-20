import 'package:flutter_riverpod/flutter_riverpod.dart';

class TravelFormState {
  const TravelFormState({
    this.selectedState,
    this.selectedCities = const [],
    this.surpriseMe = false,
    this.adults = 2,
    this.kids = 0,
    this.checkIn,
    this.checkOut,
    this.nameError,
    this.ageError,
    this.stateError,
    this.dateError,
    this.surpriseState = false,
  });

  final String? selectedState;
  final bool surpriseState;
  final List<String> selectedCities;
  final bool surpriseMe;
  final int adults;
  final int kids;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? nameError;
  final String? ageError;
  final String? stateError;
  final String? dateError;

  TravelFormState copyWith({
    String? selectedState,
    bool? surpriseState,
    List<String>? selectedCities,
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
    bool clearCities = false,
    bool clearCheckIn = false,
    bool clearCheckOut = false,
    bool clearNameError = false,
    bool clearAgeError = false,
    bool clearStateError = false,
    bool clearDateError = false,
  }) {
    return TravelFormState(
      selectedState:
          clearState ? null : selectedState ?? this.selectedState,
      selectedCities:
          clearCities ? [] : selectedCities ?? this.selectedCities,
      surpriseMe: surpriseMe ?? this.surpriseMe,
      surpriseState: surpriseState ?? this.surpriseState,
      adults: adults ?? this.adults,
      kids: kids ?? this.kids,
      checkIn: clearCheckIn ? null : checkIn ?? this.checkIn,
      checkOut: clearCheckOut ? null : checkOut ?? this.checkOut,
      nameError: clearNameError ? null : nameError ?? this.nameError,
      ageError: clearAgeError ? null : ageError ?? this.ageError,
      stateError:
          clearStateError ? null : stateError ?? this.stateError,
      dateError: clearDateError ? null : dateError ?? this.dateError,
    );
  }
}

class TravelFormNotifier extends StateNotifier<TravelFormState> {
  TravelFormNotifier() : super(const TravelFormState());

  void selectState(String? stateName) {
    state = state.copyWith(
      selectedState: stateName,
      surpriseState: false,
      clearCities: true,
      surpriseMe: false,
      clearStateError: true,
    );
  }

  void toggleSurpriseState() {
    state = state.copyWith(
      selectedState: null,
      surpriseState: !state.surpriseState,
      clearCities: true,
      surpriseMe: false,
      clearStateError: true,
    );
  }

  void toggleCity(String city) {
    final current = List<String>.from(state.selectedCities);
    if (current.contains(city)) {
      current.remove(city);
    } else {
      current.add(city);
    }
    state = state.copyWith(selectedCities: current, surpriseMe: false);
  }

  void toggleSurpriseMe() {
    state = state.copyWith(
      surpriseMe: !state.surpriseMe,
      clearCities: true,
    );
  }

  void incrementAdults() =>
      state = state.copyWith(adults: state.adults + 1);

  void decrementAdults() {
    if (state.adults > 1) {
      state = state.copyWith(adults: state.adults - 1);
    }
  }

  void incrementKids() =>
      state = state.copyWith(kids: state.kids + 1);

  void decrementKids() {
    if (state.kids > 0) {
      state = state.copyWith(kids: state.kids - 1);
    }
  }

  void setCheckIn(DateTime date) {
    state = state.copyWith(
      checkIn: date,
      clearCheckOut: true,
      clearDateError: true,
    );
  }

  void setCheckOut(DateTime date) {
    if (state.checkIn != null && !date.isAfter(state.checkIn!)) {
      state = state.copyWith(
          dateError: 'Check-out must be after check-in');
    } else {
      state = state.copyWith(checkOut: date, clearDateError: true);
    }
  }

  bool validate(String name, String age) {
    String? nameErr =
        name.trim().isEmpty ? 'Name is required' : null;
    String? ageErr =
        age.trim().isEmpty ? 'Age is required' : null;
    String? stateErr = state.selectedState == null && !state.surpriseState
      ? 'Please select a state or choose Surprise Me'
      : null;
    String? dateErr;
    if (state.checkIn == null) {
      dateErr = 'Check-in date is required';
    } else if (state.checkOut == null) {
      dateErr = 'Check-out date is required';
    } else if (!state.checkOut!.isAfter(state.checkIn!)) {
      dateErr = 'Check-out must be after check-in';
    }

    state = state.copyWith(
      nameError: nameErr,
      ageError: ageErr,
      stateError: stateErr,
      dateError: dateErr,
    );

    return nameErr == null &&
        ageErr == null &&
        stateErr == null &&
        dateErr == null;
  }
}

final travelFormProvider =
    StateNotifierProvider<TravelFormNotifier, TravelFormState>(
  (ref) => TravelFormNotifier(),

  
);

