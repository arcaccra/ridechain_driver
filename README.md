# RideChain Driver

A Flutter mobile app (iOS & Android) that enables drivers to participate in a blockchain-powered ride-sharing platform. Drivers can register their vehicles, create and manage rides, track live trip progress on a map, check in passengers via QR code, and earn Cardano (ADA) cryptocurrency payments.

**Backend API:** `https://app.arcaccra.com/`  
**Blockchain:** Cardano (ADA / Lovelace)  
**Firebase Project:** `ridechain-c7650`

---

## Quick Start

### Requirements

- Flutter SDK 3.8.1+
- Dart 3.x
- Android SDK 21+ / iOS 13+
- Firebase project connected (see `firebase_options.dart`)
- Google Maps API key

### Setup

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

Add a `.env` file at the project root:
```
GOOGLE_API_KEY=your_google_maps_key
PROJECT_ID=ridechain-c7650
PATH_TO_SECRET=secrets/ridechain-key.json
```

---

## Documentation

For full documentation covering all screens, user flows, features, data models, API endpoints, theme system, and architecture see:

**[APP_DOCUMENTATION.md](./APP_DOCUMENTATION.md)**

---

## Tech Stack Summary

| Category | Technology |
|----------|-----------|
| Framework | Flutter (Dart) |
| State | Provider (ChangeNotifier) |
| Navigation | GetX |
| DI | GetIt |
| HTTP | Dio |
| Realtime | Firebase Firestore |
| Auth | Firebase Auth (Phone OTP) |
| Push | Firebase Cloud Messaging |
| Maps | Google Maps Flutter |
| Location | Geolocator |
| Storage | SharedPreferences |
| QR | mobile_scanner |
