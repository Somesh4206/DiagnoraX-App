# DiagnoraX AI — Flutter Mobile App

> Next-Generation Intelligent Diagnosis — converted from React/TypeScript web app to Flutter/Dart mobile app.

## Theme
- **Background**: `#050505` (near black)
- **Accent**: `#00FFAA` (neon green) with glow effects
- **Glass cards**, neon borders, severity colour coding — exact match to the web version

---

## Project Structure

```
lib/
├── main.dart                          # Entry point
├── theme.dart                         # Neon dark theme + helpers
├── services/
│   └── gemini_service.dart            # Gemini API calls + all data models
├── widgets/
│   └── common_widgets.dart            # GlassCard, NeonButton, SeverityBadge, etc.
└── screens/
    ├── splash_screen.dart             # Animated splash
    ├── login_screen.dart              # Google Sign-In
    ├── home_screen.dart               # Bottom navigation shell (6 tabs)
    ├── dashboard_screen.dart          # Stats, quick actions, health insights
    ├── symptom_checker_screen.dart    # AI chat symptom analysis
    ├── body_analyzer_screen.dart      # BMI + body composition
    ├── reminders_screen.dart          # Medicine reminders (add/toggle/delete)
    ├── profile_screen.dart            # User profile editor
    ├── all_features_screen.dart       # "More" tab grid
    ├── prescription_scanner_screen.dart  # Camera/gallery + AI extraction
    ├── report_analyzer_screen.dart    # Lab report analysis + risk score
    ├── drug_interaction_screen.dart   # Drug safety checker
    └── doctor_recommendations_screen.dart # Find doctors by specialty
```

---

## Quick Setup

### 1. Prerequisites
- Flutter SDK ≥ 3.0.0 ([install](https://docs.flutter.dev/get-started/install))
- Dart ≥ 3.0.0
- Android Studio or VS Code with Flutter extension
- A physical device or emulator (Android API 21+ / iOS 12+)

### 2. Install dependencies
```bash
cd diagnorax_flutter
flutter pub get
```

### 3. Set your Gemini API Key
Open `lib/services/gemini_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY';
```
with your key from [Google AI Studio](https://aistudio.google.com/app/apikey).

### 4. Firebase Setup (for auth + Firestore)
1. Go to [Firebase Console](https://console.firebase.google.com/) → Create project
2. Add Android app with package `com.diagnorax.ai`
3. Download `google-services.json` → place in `android/app/`
4. Add iOS app → download `GoogleService-Info.plist` → place in `ios/Runner/`
5. In `lib/main.dart`, uncomment:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```
6. Run `flutterfire configure` to generate `firebase_options.dart`

### 5. Run the app
```bash
flutter run
```

---

## Features

| Feature | Screen | Status |
|---------|--------|--------|
| Splash + Login | splash_screen / login_screen | ✅ |
| Dashboard | dashboard_screen | ✅ |
| Symptom Checker (AI chat) | symptom_checker_screen | ✅ |
| Body Composition Analysis | body_analyzer_screen | ✅ |
| Medicine Reminders | reminders_screen | ✅ |
| Prescription Scanner | prescription_scanner_screen | ✅ |
| Report Analyzer | report_analyzer_screen | ✅ |
| Drug Interaction Checker | drug_interaction_screen | ✅ |
| Doctor Recommendations | doctor_recommendations_screen | ✅ |
| User Profile | profile_screen | ✅ |

---

## Permissions Required

### Android
- `INTERNET` — API calls
- `CAMERA` — Prescription / report scanning
- `READ_EXTERNAL_STORAGE` / `READ_MEDIA_IMAGES` — Gallery access
- `POST_NOTIFICATIONS` — Medicine reminders
- `SCHEDULE_EXACT_ALARM` — Precise reminder timing

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>DiagnoraX needs camera access to scan prescriptions and lab reports.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>DiagnoraX needs gallery access to upload medical documents.</string>
```

---

## Architecture Notes

- **State management**: `setState` (simple, no external state library needed for this scale)
- **API layer**: `lib/services/gemini_service.dart` — all Gemini calls centralised
- **Theme**: `lib/theme.dart` — single source of truth for all colours
- **Widgets**: `lib/widgets/common_widgets.dart` — reusable neon UI components

---

## Disclaimer

DiagnoraX AI is for informational purposes only. It is **not** a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider.
