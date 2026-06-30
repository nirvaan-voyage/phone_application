/// All user-facing strings in one place.
/// Keeps the UI files free of hardcoded copy and makes future
/// localisation straightforward.
abstract final class AppStrings {
  // ── Auth / Login screen ──────────────────────────────────────────────────
  static const String createAccount = 'Welcome to Nirvaan';
  static const String emailHint =
      'Sign in or create an account to start exploring';
  static const String continueBtn = 'Continue';
  static const String googleBtn = 'Continue with Google';
  static const String appleBtn = 'Continue with Apple';

  // ── Travel details screen ────────────────────────────────────────────────
  static const String labelName = 'YOUR NAME *';
  static const String labelAge = 'AGE *';
  static const String stepIndicator = 'STEP 1 OF 2';
  static const String whereHeaded = "Tell us about your trip";
  static const String dateHint = 'DD / MM / YYYY';
}
