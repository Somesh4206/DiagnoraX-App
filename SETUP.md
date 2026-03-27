# DiagnoraX AI - Setup Guide

## Prerequisites
- Flutter SDK (3.0.0 or higher)
- Firebase account
- Google Gemini API key (free)

## Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Gemini API Key

The app requires a Gemini API key for AI features (symptom analysis, prescription scanning, etc.)

**Get your FREE API key:**
1. Visit: https://aistudio.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated key

**Add to .env file:**
```
GEMINI_API_KEY=your_actual_api_key_here
```

### 3. Configure Firebase

1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password and Google Sign-In)
3. Enable Cloud Firestore
4. Download configuration files:
   - For Android: `google-services.json` → `android/app/`
   - For iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - For Web: Add Firebase config to `web/index.html`

5. Uncomment Firebase initialization in `lib/main.dart`:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform
);
```

### 4. Run the App

```bash
# Web
flutter run -d chrome

# Android
flutter run

# iOS (macOS only)
flutter run

# Windows
flutter run -d windows
```

## Features

### AI-Powered Features (Requires Gemini API Key)
- ✅ Symptom Checker - AI diagnosis predictions
- ✅ Prescription Scanner - Extract medicines from images
- ✅ Report Analyzer - Lab report insights
- ✅ Drug Interaction Checker - Safety analysis
- ✅ Body Composition Analyzer - BMI, fat %, muscle mass
- ✅ Doctor Recommendations - Find specialists

### User Management (Requires Firebase)
- ✅ Email/Password Registration & Login
- ✅ Google Sign-In
- ✅ Profile Management (Name, Age, Email, Contact, Medical History)
- ✅ User data stored in Firestore

### Other Features
- ✅ Medication Reminders
- ✅ Health Dashboard
- ✅ Dark neon-themed UI

## Troubleshooting

### "API key not valid" Error
- Make sure you've added your Gemini API key to the `.env` file
- Restart the app after adding the key
- Verify the key is correct (no extra spaces)

### Firebase Errors
- Ensure Firebase is properly initialized in `main.dart`
- Check that you've added the configuration files
- Enable Email/Password and Google Sign-In in Firebase Console

### Build Errors
- Run `flutter clean` then `flutter pub get`
- Make sure Flutter SDK is up to date: `flutter upgrade`

## Support

For issues or questions, please check the Firebase and Flutter documentation:
- Firebase: https://firebase.google.com/docs
- Flutter: https://docs.flutter.dev
- Gemini API: https://ai.google.dev/docs

---

**DISCLAIMER:** DiagnoraX AI is for informational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment.
