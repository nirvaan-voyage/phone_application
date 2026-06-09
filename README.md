# Nirvaan – Smart Travel Platform UI 🌊✈️

> **Go.Fast. Stay.Zen.**  
> A clean, premium Flutter UI prototype for a smart travel app.

---

## 📱 Screens

| # | Screen | Description |
|---|--------|-------------|
| 1 | Splash Screen | Fade-in logo animation → auto-navigates to Home |
| 2 | Home Screen | Full-screen hero image, gradient overlay, CTA button |
| 3 | Login Screen | Email sign-up + Google / Apple social login |
| 4 | Travel Details | Multi-field journey planner with counters & date pickers |

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK **≥ 3.3.0** ([install guide](https://docs.flutter.dev/get-started/install))
- Dart SDK **≥ 3.3.0**
- Android Studio or Xcode (for emulator/simulator)

### Steps

```bash
# 1. Clone / unzip the project
cd nirvaan

# 2. Install dependencies
flutter pub get

# 3. Create the assets folder (placeholder)
mkdir -p assets/images
# Optionally add your own travel_bg.jpg there and update pubspec.yaml

# 4. Run on a device or emulator
flutter run

# 5. (Optional) Run with a specific device
flutter devices          # list connected devices
flutter run -d <device>
```

---

## 🗂️ Project Structure

```
nirvaan/
├── lib/
│   ├── main.dart                         # App entry point (Riverpod + Theme)
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart           # All color tokens
│   │   │   └── app_strings.dart          # All UI text / copy
│   │   └── theme/
│   │       └── app_theme.dart            # Material 3 ThemeData
│   │
│   ├── screens/
│   │   ├── splash_screen.dart            # Logo + fade-in animation
│   │   ├── home_screen.dart              # Hero + CTA
│   │   ├── login_screen.dart             # Email / social login
│   │   └── travel_details_screen.dart    # Journey planner form
│   │
│   └── widgets/
│       ├── nirvaan_logo.dart             # Pure-Flutter logo widget
│       ├── primary_button.dart           # Reusable filled / outlined button
│       ├── input_field.dart              # Labeled text field
│       └── counter_widget.dart           # +/- counter row
│
├── assets/
│   └── images/                           # Drop your images here
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 🎨 Customisation Guide

### Change the theme colour
Open `lib/core/constants/app_colors.dart` and update:
```dart
static const Color primary = Color(0xFF3D6B9E);   // ← change this
```

### Replace the home background
1. Add your image to `assets/images/travel_bg.jpg`  
2. In `home_screen.dart`, replace `Image.network(...)` with:
   ```dart
   Image.asset('assets/images/travel_bg.jpg', fit: BoxFit.cover)
   ```

### Replace the logo mark
In `lib/widgets/nirvaan_logo.dart`, swap `CustomPaint` for:
```dart
Image.asset('assets/images/logo.png', width: size, height: size)
```

### Add navigation
Each screen uses `Navigator.push(...)`. Swap for **GoRouter** or **AutoRoute**
when you're ready to add deeper navigation or deep links.

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management scaffolding |
| `google_fonts` | Poppins typeface |
| `cupertino_icons` | iOS-style icon set |

---

## ⚠️ Notes

- This is a **UI prototype only** – no backend, no API calls.
- The home screen uses an Unsplash image via network; replace with a local asset for production.
- State (counters, form fields) lives in local `StatefulWidget` state. Lift to Riverpod providers when you add business logic.

---

## 📄 Licence

MIT – free to use and modify.
