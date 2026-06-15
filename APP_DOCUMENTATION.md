# RideChain Driver — Complete App Documentation

---

## Table of Contents

1. [App Overview](#1-app-overview)
2. [Tech Stack](#2-tech-stack)
3. [Project Structure](#3-project-structure)
4. [Design System & Themes](#4-design-system--themes)
5. [User App Flow](#5-user-app-flow)
6. [Screen Reference](#6-screen-reference)
7. [Ride Lifecycle (State Machine)](#7-ride-lifecycle-state-machine)
8. [Features & Processes](#8-features--processes)
9. [Data Models](#9-data-models)
10. [API Reference](#10-api-reference)
11. [Firebase Integration](#11-firebase-integration)
12. [State Management](#12-state-management)
13. [Services & Dependency Injection](#13-services--dependency-injection)
14. [Local Storage](#14-local-storage)
15. [Notifications](#15-notifications)
16. [Location & Maps](#16-location--maps)
17. [Supported Platforms](#17-supported-platforms)

---

## 1. App Overview

**App Name:** RideChain Driver  
**Version:** 1.0.1+3  
**Platform:** Flutter (iOS & Android)  
**Backend API:** `https://app.arcaccra.com/`  
**Firebase Project:** `ridechain-c7650`  
**Blockchain:** Cardano (ADA / Lovelace)

RideChain Driver is a blockchain-powered ride-sharing platform for drivers. It enables drivers to register their vehicles, create and manage rides, track live trip progress on a map, check in passengers via QR code scanning, and earn Cardano (ADA) cryptocurrency payments — all with a streamlined mobile experience.

### Core Value Propositions

- **For Drivers:** Earn ADA cryptocurrency for each completed ride without needing a centralised payment intermediary.
- **For Trust:** Multi-step KYC document verification (ID, license, vehicle docs) builds passenger confidence.
- **For Transparency:** Blockchain-backed payments are traceable and immutable.
- **For Real-Time:** Live GPS tracking, Firebase-powered push notifications, and Firestore-driven trip state keep everyone in sync.

---

## 2. Tech Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| Framework | Flutter (Dart 3.8.1+) | Cross-platform mobile UI |
| State Management | Provider (ChangeNotifier) | Reactive app state |
| Navigation | GetX | Declarative routing & navigation |
| Dependency Injection | GetIt (Service Locator) | Singleton service registry |
| HTTP Client | Dio | REST API calls, cookie handling, interceptors |
| Realtime Database | Firebase Firestore | Live trip state, passenger requests, payments |
| Authentication | Firebase Auth | Phone-based OTP verification |
| Push Notifications | Firebase Cloud Messaging (FCM) | Trip alerts, status updates, payment notices |
| Maps | Google Maps Flutter | Interactive route and location display |
| Location | Geolocator | Real-time GPS, distance calculations |
| Local Storage | SharedPreferences | Token, user, and session caching |
| QR Scanning | mobile_scanner | Passenger boarding verification |
| Image Handling | image (dart) | JPEG compression before upload |
| File Picker | file_picker | Document selection from device storage |
| Responsive UI | flutter_screenutil | Base design 393×852 px, .h/.w scaling |
| Animations | flutter_animate | Screen transitions, widget animations |

---

## 3. Project Structure

```
lib/
├── main.dart                    # Entry point; Firebase init, FCM setup
├── firebase_options.dart        # Auto-generated Firebase config
├── app/
│   ├── app.dart                 # Root MaterialApp (GetX + MultiProvider)
│   ├── app_config.dart          # Flavor config (prod/dev base URLs)
│   └── theme.dart               # Design system: colors, text styles, spacing
├── core/
│   ├── cache_helper.dart        # SharedPreferences read/write wrapper
│   ├── providers.dart           # MultiProvider registration list
│   ├── utility.dart             # Misc helper functions
│   └── core_constants/
│       ├── colors.dart          # Full color palette (AppColors)
│       ├── label.dart           # All UI string constants
│       └── media.dart           # Asset path references
├── data/
│   ├── locator.dart             # GetIt service registrations
│   ├── models/                  # All data models (serializable)
│   │   ├── user_model.dart      # UserModel, AuthModel
│   │   ├── driver_model.dart    # DriverModel
│   │   ├── ride_model.dart      # RideModel, Driver, Passenger, DropOff
│   │   ├── booked_model.dart    # BookedRideModel
│   │   ├── location_model.dart  # LocationModel
│   │   ├── wallet.dart          # Wallet, Balance
│   │   └── api_response.dart    # ApiResponse wrapper
│   └── constants/
│       └── api_constants.dart   # All API endpoint strings
├── services/                    # External integrations and business logic
│   ├── http_service.dart        # Dio HTTP client (auth headers, CSRF)
│   ├── login_service.dart       # Auth & user API calls
│   ├── rides_service.dart       # Ride CRUD API + vehicle helpers
│   ├── location_service.dart    # GPS streaming, permissions, proximity
│   ├── fcm_service.dart         # Firebase Auth + FCM token management
│   ├── trip_firebase_service.dart # Firestore trip read/write operations
│   ├── dialog_service.dart      # Snackbars, alert dialogs, modals
│   ├── connectivity_service.dart # Network status monitoring
│   ├── image_service.dart       # Camera capture, file pick, JPEG compress
│   └── nav_service.dart         # Programmatic navigation routes
├── providers/                   # App-wide state (ChangeNotifier)
│   ├── auth_provider.dart       # AuthVm — user/auth/document state
│   ├── rides_provider.dart      # RideProvider — ride state machine
│   └── base_provider.dart       # BaseProvider — shared busy/error state
└── ui/
    ├── screens/
    │   ├── splash/              # SplashScreen (auto-login check)
    │   ├── onboarding/          # OnboardingScreen (3 benefit slides)
    │   ├── auth/                # Login, Register, OTP, Password, Docs
    │   ├── home/                # HomePage (map + active trip dashboard)
    │   ├── create_ride/         # CreateRidePage (ride listing form)
    │   ├── scan/                # ScanScreen (QR passenger check-in)
    │   ├── trip_history/        # TripHistoryPage (past rides)
    │   ├── profile/             # ProfileScreen (driver info & wallet)
    │   └── navigation/          # AppNavigationScreen (bottom nav hub)
    └── shared_widgets/          # Reusable components across screens
```

---

## 4. Design System & Themes

### 4.1 Color Palette (`lib/core/core_constants/colors.dart`)

#### Primary Colors
| Name | Hex | Usage |
|------|-----|-------|
| `primaryColor` | `#101010` | Primary dark background, main text, buttons |
| `white` | `#FFFFFF` | Cards, text on dark, backgrounds |
| `backgroundColor` | `#F8F8FF` | App scaffold background (light lavender-white) |

#### Brand Accent Colors
| Name | Hex | Usage |
|------|-----|-------|
| `purple` | `#5500BF` | Primary brand accent, CTAs, active indicators |
| `orange` | `#FBBC05` | Warnings, highlights, star ratings |
| `green` | `#00C950` | Success states, active trip, completed status |
| `darkGreen` | `#016630` | Confirmed/verified status text |
| `yellow` | `#FFF000` | Attention states |

#### Purple Shades (Brand Secondary)
| Name | Hex | Usage |
|------|-----|-------|
| `lightPurple` | `#F4EFF9` | Selected state backgrounds, chips |
| `lightPurpleD9` | `#D9C1FF` | Light accent fills |
| `lightPurpleEF` | `#EFDEFF` | Card borders, subtle highlights |
| `lightPurpleFF` | `#DAC2FF` | Hover/pressed states |

#### Neutral Grays
| Name | Hex | Usage |
|------|-----|-------|
| `grey` | `#6D7280` | Body text, secondary labels |
| `greyAd` | `#ADADAD` | Disabled states, placeholder text |
| `greyC2` | `#C2C2C2` | Dividers, inactive icons |
| `greyEd` | `#EDEDED` | Background fills, list separators |
| `borderColor` | `#ECECEC` | Card/input borders |
| `textFieldBorderColor` | `#E0E0E0` | Form field outlines |
| `textFieldHintColor` | `#828282` | Hint/placeholder text in inputs |

#### UI-Specific Colors
| Name | Hex | Usage |
|------|-----|-------|
| `fill` | `#1E1E1E` | Dark card fills |
| `cancelButtonColor` | `#E8EAE9` | Cancel/secondary button background |
| `googleColour` | `#EEEEEE` | Google sign-in button background |

### 4.2 Typography

#### Custom Font Families (`assets/fonts/`)
| Font | Weights Available | Primary Usage |
|------|------------------|---------------|
| **BeauSans** | 400, 500, 700, 800 | Headlines, brand text, titles |
| **Outfit** | 400, 600, 700 | Body text, labels, buttons |
| **Inter** | 300, 400, 500 | Data display, secondary body |
| **Zain** | Regular | Decorative/accent text |

#### Text Style Helpers (`lib/app/theme.dart`)
```dart
// Google Fonts utility functions:
outfit({double? size, FontWeight? weight, Color? color})  // → Outfit TextStyle
sora({double? size, FontWeight? weight, Color? color})    // → Sora TextStyle
inter({double? size, FontWeight? weight, Color? color})   // → Inter TextStyle

// Pre-built named styles:
appOutFitSmall      // Outfit, small size
appBeauSansLarge    // BeauSans, large, bold
appBeauSansMedium   // BeauSans, medium weight
appInterSmallGrey   // Inter, small, grey color
```

### 4.3 Spacing System
| Name | Value | Usage |
|------|-------|-------|
| Small | `EdgeInsets.symmetric(8, 8)` | Tight padding (chips, tags) |
| Medium | `EdgeInsets.symmetric(12, 12)` | Form elements, list items |
| Large | `EdgeInsets.symmetric(16, 16)` | Section padding, cards |

### 4.4 Shape & Border Radii
| Component | Radius | Notes |
|-----------|--------|-------|
| Cards | `20.52` | Standard cards |
| Cards with shadow | `21.24` | Elevated cards |
| Buttons | `33.5` | Pill-shaped CTAs |
| Inputs | `8.0` | Form fields, outlined inputs |

### 4.5 Shadows
**Standard card shadow:**
- Offset: `(0, 3.27)`
- Blur radius: `31.6`
- Spread: `0`
- Color: `primaryColor` at 11% opacity

### 4.6 Responsive Scaling
All layout dimensions use `flutter_screenutil` extensions:
- Base design canvas: `393 × 852 px`
- `.h` → height scaled to device
- `.w` → width scaled to device
- `.sh` → percentage of screen height
- `.sw` → percentage of screen width
- `minTextAdapt: true` → text scales to smaller of width/height

### 4.7 Theme Configuration
**MaterialApp theme** (`lib/app/theme.dart`):
- `useMaterial3: true`
- `primaryColor` → `AppColors.white`
- `secondaryColor` → `AppColors.primaryColor`
- Custom `AppBarTheme` (transparent, no elevation)

---

## 5. User App Flow

### 5.1 First Launch (New User)

```
App Launch
    │
    ▼
SplashScreen (logo animation, 2s)
    │
    ├─ is_first_timer = true?
    │       │
    │       ▼
    │   OnboardingScreen (3 swipeable benefit slides)
    │       │
    │       ▼
    │   LoginScreen (toggled to Register mode)
    │       │
    │       ▼
    │   RegisterScreen
    │   ┌─────────────────────────────────────────┐
    │   │ Enter: Full Name, Email, Phone, Country │
    │   └─────────────────────────────────────────┘
    │       │
    │       ▼
    │   OTPScreen
    │   ┌────────────────────────────────┐
    │   │ Firebase SMS OTP sent to phone │
    │   │ Enter 6-digit code             │
    │   └────────────────────────────────┘
    │       │
    │       ▼
    │   ImageCaptureScreen
    │   ┌───────────────────────────────────────┐
    │   │ Capture/upload profile photo          │
    │   └───────────────────────────────────────┘
    │       │
    │       ▼
    │   DocumentUpload (multi-step wizard)
    │   ┌───────────────────────────────────────────────┐
    │   │ Step 1: National ID / Passport (front + back) │
    │   │ Step 2: Driver's License image                │
    │   │ Step 3: Vehicle Registration Certificate      │
    │   │ Step 4: Insurance Certificate                 │
    │   │ Step 5: Vehicle photo + plate/color/type      │
    │   │ Step 6: Blockchain wallet address entry       │
    │   └───────────────────────────────────────────────┘
    │       │
    │       ▼
    │   PasswordScreen
    │   ┌──────────────────────────┐
    │   │ Create account password  │
    │   └──────────────────────────┘
    │       │
    │       ▼
    │   AppNavigationScreen (Main App)
    │
    └─ is_first_timer = false?
            │
            ▼ (see Returning User flow below)
```

### 5.2 Returning User (Already Registered)

```
App Launch
    │
    ▼
SplashScreen
    │
    ├─ Cached auth token found?
    │       │
    │       YES → Load user data from cache
    │               │
    │               ▼
    │           AppNavigationScreen (Home tab)
    │
    └─ No token / expired
            │
            ▼
        LoginScreen
        ┌──────────────────────────────────────┐
        │ Enter: Phone number + Password       │
        └──────────────────────────────────────┘
            │
            ▼
        OTPScreen (phone re-verification if needed)
            │
            ▼
        AppNavigationScreen (Home tab)
```

### 5.3 Creating a Ride

```
Home Screen (idle state)
    │
    ▼
Tap "Let's Ride" / Create Ride button
    │
    ▼
[Check] Driver has complete documentation?
    │
    ├─ NO → Show "Complete your profile" banner
    │         → Navigate to DocumentUpload
    │
    └─ YES
        │
        ▼
    CreateRidePage
    ┌────────────────────────────────────────────────────────┐
    │ 1. Select Pickup Location (from predefined list)       │
    │ 2. Select Dropoff/Destination Location                 │
    │ 3. Set Departure Date & Time (up to 90 days ahead)    │
    │ 4. Set Number of Available Seats (1–8)                 │
    │ 5. Set Price Per Seat (ADA)                            │
    └────────────────────────────────────────────────────────┘
        │
        ▼
    Validate form → POST to rides API
        │
        ▼
    Ride created → Navigate back to Home Screen
    (new ride now visible in available rides list)
```

### 5.4 Accepting and Completing a Trip

```
Home Screen (tripsAvailable state)
    │
    ▼
Ride markers visible on Google Map
Bottom card shows available rides list
    │
    ▼
Driver selects a ride
    │
    ▼
ConfirmAndStartRide modal
┌────────────────────────────────────┐
│ Ride details: pickup, dropoff,     │
│ passenger count, price per seat    │
│ [Confirm & Start]                  │
└────────────────────────────────────┘
    │
    ▼
Ride status → "ENROUTE_PICKUP"
Firestore trip document created
FCM notification sent to all passengers
    │
    ▼
Home screen → driverEnRouteToPickUp state
Map shows pickup marker
Bottom card shows "En Route to Pickup"
GPS location streams continuously
    │
    ▼
[GPS] Driver within proximity of pickup location
    │
    ▼
Home screen → driverAtPickupLocation state
Bottom card: "You have arrived at pickup"
Shows passenger list with QR check-in prompt
    │
    ▼
ScanScreen (QR code reader)
    │
    ▼
Scan passenger QR code → Verify booking UUID
Passenger marked as boarded
    │
    ▼
All passengers boarded → Start Trip
Ride status → "IN_PROGRESS" (Firestore: "started")
FCM notification to all passengers: trip started
    │
    ▼
Home screen → tripStarted state
Bottom card: active trip display with destination info
    │
    ▼
Driver reaches destination
Tap "End Trip"
    │
    ▼
Ride status → "COMPLETED" (Firestore: "completed")
completePayment() called → ADA payment triggered
FCM payment notifications to driver + passengers
    │
    ▼
Home screen → tripEnded state → resets to idle
Trip logged in TripHistory
```

### 5.5 Viewing Trip History

```
Bottom Navigation → History tab
    │
    ▼
TripHistoryPage loads past trips
    │
    ├─ No trips → Empty state illustration + message
    │
    └─ Trips found → Scrollable list
        Each item shows:
        ─ Pickup → Dropoff route
        ─ Date and time
        ─ Number of passengers
        ─ Fare earned
        ─ Status badge (Completed / Cancelled)
```

### 5.6 Profile & Wallet Management

```
Bottom Navigation → Profile tab
    │
    ▼
ProfileScreen
┌──────────────────────────────────────────────────────────┐
│ Avatar • Driver name • Verification status               │
├──────────────────────────────────────────────────────────┤
│ Quick action cards:                                      │
│  [Wallet]      → WalletInfo screen (ADA balance, addr)   │
│  [Hours Online]→ Time tracked as active driver           │
│  [Vehicle Info]→ Registered vehicle details              │
│  [Support]     → Help/contact options                    │
├──────────────────────────────────────────────────────────┤
│ [Logout] → Clear cache, disconnect FCM, → LoginScreen    │
└──────────────────────────────────────────────────────────┘
```

**WalletInfo screen:**
```
WalletInfo
┌───────────────────────────────────────┐
│ Wallet Address (Cardano)              │
│ ADA Balance (in ADA and Lovelace)     │
│ [Copy Address] [Update Address]       │
│ Transaction history (if available)   │
└───────────────────────────────────────┘
```

---

## 6. Screen Reference

### Authentication Screens

| Screen | File | Description |
|--------|------|-------------|
| `SplashScreen` | `ui/screens/splash/splash_screen.dart` | Animated logo with gradient. Reads cached token → routes to home or onboarding. |
| `OnboardingScreen` | `ui/screens/onboarding/onboarding_screen.dart` | 3-page carousel showcasing ride-sharing benefits. Shown only on first launch. |
| `LoginScreen` | `ui/screens/auth/login_screen.dart` | Phone number + password entry. Toggle to register mode. Integrates Firebase Auth. |
| `RegisterScreen` | `ui/screens/auth/register_screen.dart` | Full name, email, phone, country fields. Saves progress to cache between steps. |
| `OTPScreen` | `ui/screens/auth/otp_screen.dart` | 6-digit SMS OTP input. Auto-resend after timeout. Firebase phone verification. |
| `PasswordScreen` | `ui/screens/auth/password_screen.dart` | Password creation during registration. |
| `ImageCaptureScreen` | `ui/screens/auth/image_capture_screen.dart` | Camera/gallery profile photo capture. Compresses to JPEG before upload. |
| `DocumentUpload` | `ui/screens/auth/document_upload.dart` | Master wizard screen (608 lines) orchestrating all document upload steps. |
| `IDCardDocuments` | `ui/screens/auth/id_card_documents.dart` | ID front/back image capture. Supports: National ID, Passport, Driver Licence, Voter ID. |
| `VehicleRegistrationDocuments` | `ui/screens/auth/vehicle_registration_documents.dart` | Vehicle image, plate number, color, type. Certificate upload. |
| `WalletInfo` | `ui/screens/auth/wallet_info.dart` | Enter/view Cardano wallet address. Displays ADA balance and Lovelace equivalent. |

### Main App Screens

| Screen | File | Description |
|--------|------|-------------|
| `AppNavigationScreen` | `ui/screens/navigation/app_navigation_screen.dart` | Bottom nav hub (4 tabs). Initialises location services and permission caching on first load. |
| `HomePage` | `ui/screens/home/home_screen.dart` | Core driver interface. Google Maps + dynamic bottom card that adapts to `RideState`. Shows driver info, ride markers, and all trip action controls. |
| `CreateRidePage` | `ui/screens/create_ride/` | Form: pickup, dropoff, departure time, seats, price. Validates all fields before API submission. |
| `ScanScreen` | `ui/screens/scan/scan_screen.dart` | Mobile QR scanner using `mobile_scanner`. Reads passenger `qrcodeUuid` to verify boarding. |
| `TripHistoryPage` | `ui/screens/trip_history/trip_history.dart` | Paginated list of completed/cancelled rides. Empty-state illustration when no history. |
| `ProfileScreen` | `ui/screens/profile/profile_screen.dart` | Driver profile, vehicle details, wallet balance, quick-action cards, logout. |

### Home Screen — Dynamic Bottom Card States

The Home screen's bottom card changes entirely based on `RideState`:

| State | Bottom Card Content | Primary Action |
|-------|--------------------|-|
| `idle` | "Let's Ride" call-to-action | → Open CreateRidePage |
| `searchingRides` | Loading indicator | — |
| `tripsAvailable` | Scrollable list of available rides with details | Select a ride |
| `driverEnRouteToPickUp` | "En route to pickup" + ETA | View map |
| `driverAtPickupLocation` | "You have arrived" + passenger list | → Open ScanScreen |
| `tripStarted` | Active trip info + destination | — |
| `tripEnded` | Trip summary + earnings | End trip / return to idle |

---

## 7. Ride Lifecycle (State Machine)

The `RideState` enum in `lib/providers/rides_provider.dart` drives all trip UI and logic:

```
idle
  │  Driver taps "Create/Find Ride"
  ▼
searchingRides
  │  API returns ride list
  ▼
tripsAvailable
  │  Driver selects and confirms a ride
  ▼
driverEnRouteToPickUp
  │  GPS proximity callback fires
  ▼
driverAtPickupLocation
  │  Driver taps "Start Trip" (after QR scan)
  ▼
tripStarted
  │  Driver taps "End Trip" at destination
  ▼
tripEnded
  │  Payment processed, state reset
  ▼
idle  (cycle repeats)
```

**State transition triggers:**

| From | To | Trigger |
|------|----|---------|
| `idle` | `searchingRides` | Driver requests ride list |
| `searchingRides` | `tripsAvailable` | API responds with rides |
| `tripsAvailable` | `driverEnRouteToPickUp` | Driver confirms ride; API PATCH → `ENROUTE_PICKUP` |
| `driverEnRouteToPickUp` | `driverAtPickupLocation` | GPS distance to pickup < threshold |
| `driverAtPickupLocation` | `tripStarted` | Driver starts trip; Firestore → `started` |
| `tripStarted` | `tripEnded` | Driver ends trip; Firestore → `completed` |
| `tripEnded` | `idle` | UI reset after payment confirmed |

---

## 8. Features & Processes

### 8.1 Driver Registration & KYC

**Purpose:** Verify driver identity and vehicle legitimacy before allowing ride creation.

**Document Types Collected:**

| Document | Fields | Format |
|----------|--------|--------|
| National ID | Front image, Back image, ID type, ID number | JPEG image |
| Driver's License | License image | JPEG image |
| Vehicle Registration | Registration certificate | JPEG image |
| Insurance Certificate | Certificate image | JPEG image |
| Vehicle Profile | Vehicle photo, plate number, color, type | JPEG + text |
| Profile Photo | Avatar image | JPEG image |
| Wallet | Cardano wallet address string | Text |

**Upload Process:**
1. Image captured via camera (`ImageService.captureImage()`) or file picker (`ImageService.pickFile()`)
2. Decoded to bytes → re-encoded as JPEG with compression
3. Wrapped in `dio.MultipartFile`
4. Sent via `LoginService.uploadDriverDocs(FormData)` → POST `/apis/accounts/drivers/`
5. On update: `LoginService.updateDriverDocs(FormData, driverId)` → PUT `/apis/accounts/drivers/{id}/`

**Validation Gate:**
`AuthVm.checkIfDriverHasCompleteDocumentation()` verifies all 9 fields are non-null before allowing ride creation. Incomplete drivers see a persistent banner on the Home screen.

---

### 8.2 Ride Creation

**Purpose:** Let a verified driver publish a new ride listing for passengers to book.

**Form Fields:**
- Pickup location (dropdown from backend location list)
- Dropoff/destination location (same list)
- Departure date and time (DateTimePicker, max 90 days ahead)
- Available seats (integer, 1–8)
- Price per seat (ADA, decimal number)

**Process:**
1. Locations loaded from cache (`CacheHelper`) or fetched via `LoginService.loadAllLocations()`
2. Form validated (all fields required)
3. `RideProvider.createRide(data)` → `RidesService.createRide(FormData)` → POST `/apis/rides_apis/`
4. On success, navigate back to Home and refresh rides list

---

### 8.3 Browsing & Selecting Rides

**Purpose:** Show available rides to the driver for acceptance.

**Process:**
1. `RideProvider.fetchRides()` → `RidesService.fetchRides()` → GET `/apis/rides_apis/`
2. Response parsed into `List<RideModel>`
3. Rides rendered as interactive markers on Google Map (using `RideModel.latLng` getter)
4. Bottom card lists rides with: route, passengers, price, departure time
5. Driver taps a ride → ride detail loaded → modal shown

---

### 8.4 QR Code Passenger Verification

**Purpose:** Confirm that passengers boarding the vehicle have valid bookings.

**Process:**
1. Driver arrives at pickup → `driverAtPickupLocation` state
2. Driver opens ScanScreen (via tab or prompt)
3. `mobile_scanner` camera stream reads passenger QR code
4. Decoded value matched against `BookedRideModel.qrcodeUuid`
5. Matching UUID → passenger confirmed as boarded
6. All passengers confirmed → "Start Trip" button becomes active

---

### 8.5 Live Trip Tracking

**Purpose:** Monitor driver GPS position and update all stakeholders in real-time.

**Process:**
1. `LocationService` opens a continuous GPS stream (`Geolocator.getPositionStream()`) with high-accuracy settings
2. Each new position broadcast to all listeners via `StreamController`
3. `Geolocator.distanceBetween()` calculates distance to pickup/dropoff
4. When distance < threshold (configurable), `approachingPickup` callback fires
5. Driver position can be uploaded to Firestore for passenger tracking (if implemented)

**Time Estimation:**
- Assumes walking speed of 5 m/s for pickup distance ETA
- Distance in metres ÷ 5 = estimated seconds to arrival

---

### 8.6 Payment Processing

**Purpose:** Trigger ADA payment from passenger wallet to driver wallet on trip completion.

**Process:**
1. Driver taps "End Trip"
2. `TripFirebaseService.updateTripStatus(tripId, "completed")` called
3. `TripFirebaseService.completePayment(tripId, ...)` called
4. Backend (ARC Accra) processes the Cardano blockchain transaction
5. FCM notification sent to driver with: amount, paymentId, tripId, `isDriver: true`
6. FCM notification sent to each passenger with: amount, tripId, `isDriver: false`
7. Wallet balance updated after blockchain confirmation

---

### 8.7 Push Notifications

**Purpose:** Keep drivers and passengers informed of trip status changes in real-time.

**Handled Events:**

| Event | Recipient | Notification Channel |
|-------|-----------|---------------------|
| New passenger booking | Driver | Trip Requests |
| Driver en route | Passenger | Trip Updates |
| Driver approaching pickup | Passenger | Trip Updates |
| Driver at pickup | Passenger | Trip Updates |
| Trip started | Passenger | Trip Updates |
| Trip completed | Both | Payments |
| Payment received | Driver | Payments |

---

### 8.8 Wallet Management

**Purpose:** Let drivers view their ADA balance and manage their Cardano wallet address.

**Process:**
1. Driver enters wallet address during registration (WalletInfo screen)
2. Address stored: `LoginService.updateWalletAddress(data)` → POST `/apis/accounts/wallets/`
3. Wallet details fetched: `LoginService.getWalletAddress()` → GET `/apis/accounts/wallets/`
4. Balance displayed in both ADA (decimal) and Lovelace (integer)
5. Driver can update wallet address at any time from Profile screen

---

### 8.9 Offline & Connectivity Handling

**Purpose:** Gracefully handle network interruptions.

**Process:**
1. `ConnectivityService` monitors network state via `connectivity_plus`
2. Before any API call, connectivity is checked
3. If offline: friendly error shown via `DialogService.showSnackBar()`
4. Cached data (user profile, locations) used when available
5. Automatic retry not implemented — driver must manually retry

---

## 9. Data Models

### UserModel (`lib/data/models/user_model.dart`)
```dart
UserModel {
  String id
  String? avatar          // Profile image URL
  String fullName
  String email
  String phoneNumber
  String? walletAddress   // Cardano address
  String country
  List<double> currentLocation  // [latitude, longitude]
  bool isDriver
  DriverModel? driver     // Nested driver profile
}
```

### DriverModel (`lib/data/models/driver_model.dart`)
```dart
DriverModel {
  String id
  String? vehicleImage
  String vehicleType      // Sedan, SUV, Truck, Van, Minivan, Saloon, Other
  String vehicleColor
  String vehiclePlateNumber
  String? licenceImage
  String idType           // national_id, passport, drivers_license, voter_id
  String? idNumber
  String? idFrontImage
  String? idBackImage
  String? insuranceCert
  String status           // pending, approved, rejected
  DateTime dateCreated
  DateTime dateUpdated
}
```

### RideModel (`lib/data/models/ride_model.dart`)
```dart
RideModel {
  String uuid
  Driver driver           // Nested driver + user info
  List<Passenger> passengers
  DropOff pickUp          // { id, name, latitude, longitude }
  DropOff dropOff
  DateTime departureTime
  DateTime? arrivalTime
  int seatsAvailable
  double pricePerSeat
  String status           // AVAILABLE, ENROUTE_PICKUP, IN_PROGRESS, COMPLETED, CANCELLED
  DateTime createdAt
  DateTime updatedAt
  // Helper:
  LatLng get latLng       // pickUp coordinates as Google Maps LatLng
}
```

### BookedRideModel (`lib/data/models/booked_model.dart`)
```dart
BookedRideModel {
  String id
  Passenger passenger
  RideModel ride
  String rideId           // UUID of the ride
  String qrcodeUuid       // Unique identifier encoded in QR code
  String qrCode           // Base64 QR image data
  DateTime dateBooked
  DateTime createdAt
  DateTime updatedAt
}
```

### LocationModel (`lib/data/models/location_model.dart`)
```dart
LocationModel {
  String id
  String name
  double latitude
  double longitude
}
```

### Wallet (`lib/data/models/wallet.dart`)
```dart
Wallet {
  String id
  UserModel user
  String address          // Cardano wallet address
  Balance balance
  DateTime createdAt
  DateTime updatedAt
}

Balance {
  int lovelace            // 1 ADA = 1,000,000 Lovelace
  double ada
}
```

### ApiResponse (`lib/data/models/api_response.dart`)
```dart
ApiResponse {
  int code                // HTTP status code
  String message
  String status           // "success" or "error"
  dynamic body            // Parsed response data
  List<dynamic>? errors
}
```

---

## 10. API Reference

**Base URL:** `https://app.arcaccra.com/`  
**Auth Header:** `Authorization: Token {token}`  
**Content-Type:** `application/json` or `multipart/form-data` (for file uploads)

### Authentication Endpoints

| Method | Path | Body | Description |
|--------|------|------|-------------|
| POST | `/apis/accounts/login/` | `{phone, password}` | Driver login. Returns `AuthModel` with token. |
| POST | `/apis/accounts/register/` | `{fullName, email, phone, country}` | Create driver account. |
| POST | `/apis/accounts/logout/` | — | Invalidate server session. |

### User & Driver Endpoints

| Method | Path | Body | Description |
|--------|------|------|-------------|
| GET | `/apis/accounts/users/{id}/` | — | Fetch driver profile by ID. |
| POST | `/apis/accounts/drivers/` | FormData (images + text) | Submit driver documents (first time). |
| PUT | `/apis/accounts/drivers/{id}/` | FormData (images + text) | Update driver documents. |
| GET | `/apis/accounts/drivers/` | — | List all drivers. |

### Wallet Endpoints

| Method | Path | Body | Description |
|--------|------|------|-------------|
| GET | `/apis/accounts/wallets/` | — | Fetch current driver's wallet and balance. |
| POST | `/apis/accounts/wallets/` | `{address}` | Set or update Cardano wallet address. |
| GET | `/apis/accounts/wallets/{id}/` | — | Fetch wallet by ID. |

### Ride Endpoints

| Method | Path | Body | Description |
|--------|------|------|-------------|
| GET | `/apis/rides_apis/` | — | List all available rides for driver. |
| POST | `/apis/rides_apis/` | FormData | Create a new ride listing. |
| GET | `/apis/rides_apis/{uuid}/` | — | Fetch details of a specific ride. |
| PUT | `/apis/rides_apis/{uuid}/` | `{status}` | Update ride status (e.g., ENROUTE_PICKUP, COMPLETED). |

### Location Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/apis/rides_apis/locations/` | Fetch all available pickup/dropoff locations. |

---

## 11. Firebase Integration

### Firebase Auth

Used for phone number verification via SMS OTP:
- `verifyPhoneNumber()` with auto-retrieval timeout
- Callbacks: `codeSent`, `codeAutoRetrievalTimeout`, `verificationCompleted`, `verificationFailed`
- On success: `PhoneAuthProvider.credential` → `signInWithCredential()`

### Firestore Collections

| Collection | Document ID | Key Fields | Purpose |
|-----------|-------------|------------|---------|
| `users` | `{userId}` | `fcmToken`, `userId` | FCM token storage per user |
| `trips` | `{tripId}` | `status`, `driverId`, `passengers`, `pickUp`, `dropOff` | Live trip documents |
| `trips/{tripId}/requests` | `{requestId}` | `passengerId`, `status`, `timestamp` | Passenger booking requests for a trip |

### Firestore Trip Document Schema

```
trips/{tripId}:
  status: string          // "created" | "approaching_pickup" | "arrived_pickup" 
                          //   | "started" | "completed" | "cancelled"
  driverId: string
  driverName: string
  pickUp: { name, latitude, longitude }
  dropOff: { name, latitude, longitude }
  passengers: [ { id, name, fcmToken } ]
  payment: { amount, paymentId, status }
  createdAt: Timestamp
  updatedAt: Timestamp
```

### Firebase Cloud Messaging (FCM)

**Token Lifecycle:**
1. Token generated on login via `FcmService.getToken()`
2. Saved to Firestore `users/{userId}.fcmToken`
3. Token refresh handled via `onTokenRefresh` listener
4. Token removed from Firestore on logout

**Message Handling:**
- **Foreground:** `FirebaseMessaging.onMessage` → show local notification via `flutter_local_notifications`
- **Background:** `FirebaseMessaging.onBackgroundMessage` → registered top-level handler
- **Terminated state:** FCM launches app and routes to relevant screen via `getInitialMessage()`

---

## 12. State Management

### Provider Architecture

Two main providers registered in `lib/core/providers.dart`:

```
MultiProvider
├── ChangeNotifierProvider<AuthVm>
└── ChangeNotifierProvider<RideProvider>
```

### AuthVm (`lib/providers/auth_provider.dart`)

Manages all authentication and user-related state:

| State Field | Type | Description |
|-------------|------|-------------|
| `currentUser` | `UserModel?` | Logged-in driver's profile |
| `authToken` | `String?` | Bearer token for API requests |
| `wallet` | `Wallet?` | Blockchain wallet data |
| `locations` | `List<LocationModel>` | Available pickup/dropoff locations |
| `driverDocs` | `Map<String, dynamic>` | Document capture progress map |
| `isLoading` | `bool` | API call in progress |

**Key Methods:**
- `login(phone, password)` — REST API login + cache token
- `register(data)` — Create account
- `verifyOTP(smsCode)` — Firebase OTP verification
- `uploadDriverDocs(data)` — Submit KYC documents
- `updateDriverDocs(data, id)` — Update existing docs
- `checkIfDriverHasCompleteDocumentation()` — Validates all 9 doc fields
- `logout()` — Clear cache, disconnect FCM, navigate to login

### RideProvider (`lib/providers/rides_provider.dart`)

Manages all ride lifecycle state:

| State Field | Type | Description |
|-------------|------|-------------|
| `rideState` | `RideState` | Current trip phase (idle → completed) |
| `availableRides` | `List<RideModel>` | Fetched rides from API |
| `selectedRide` | `RideModel?` | Currently active/selected ride |
| `isLoading` | `bool` | API call in progress |

**Key Methods:**
- `fetchRides()` — Load available rides from API
- `createRide(data)` — Post new ride listing
- `fetchRideDetails(uuid)` — Load single ride
- `updateRideStatus(uuid, status)` — Patch ride status
- `setRideState(RideState)` — Transition the state machine

### BaseProvider (`lib/providers/base_provider.dart`)

Shared superclass for both providers:
- `setBusy(bool)` / `setDone()` / `setError(msg)` — UI state management
- Service accessors: `dialogService`, `loginService`, `ridesService`, etc.
- `updateUi()` — Calls `notifyListeners()` safely

---

## 13. Services & Dependency Injection

All services registered as lazy singletons in `lib/data/locator.dart` via GetIt.

### Service Registry

| Service | Class | Responsibility |
|---------|-------|----------------|
| `DialogService` | `dialog_service.dart` | Show snackbars, alert dialogs, bottom sheets |
| `NavService` | `nav_service.dart` | Programmatic navigation without BuildContext |
| `LoginService` | `login_service.dart` | Auth and user/driver REST API calls |
| `RidesService` | `rides_service.dart` | Ride CRUD API calls + vehicle type helpers |
| `LocationService` | `location_service.dart` | GPS stream, permissions, proximity detection |
| `FcmService` | `fcm_service.dart` | Firebase Auth + FCM token lifecycle |
| `TripFirebaseService` | `trip_firebase_service.dart` | Firestore trip documents and payment flow |
| `ConnectivityService` | `connectivity_service.dart` | Network availability monitoring |
| `ImageService` | `image_service.dart` | Camera, file picker, JPEG compression |

### NavService Routes (`lib/services/nav_service.dart`)

All navigation is performed via `NavService` methods so screens don't need `BuildContext` for routing:
- `toHome()` → AppNavigationScreen
- `toLogin()` → LoginScreen
- `toOtp(phone)` → OTPScreen
- `toRegister()` → RegisterScreen
- `toDocumentUpload()` → DocumentUpload
- `toCreateRide()` → CreateRidePage
- `toWalletInfo()` → WalletInfo
- `pop()` → Go back

### RidesService Helpers

```dart
// Vehicle type enum:
vehicleTypes → ['Sedan', 'SUV', 'Truck', 'Van', 'Minivan', 'Saloon', 'Other']

// Car color options:
carColors → ['Black', 'White', 'Silver', 'Red', 'Blue', 'Green', 'Yellow', 'Orange', 'Brown']

// ID type mapping:
idTypes → ['National ID', 'Passport', 'Driver License', 'Voter ID']

// Color to MaterialColor map:
getCarMaterialColor(colorName) → MaterialColor
```

---

## 14. Local Storage

All persistence handled by `CacheHelper` (`lib/core/cache_helper.dart`), a typed SharedPreferences wrapper.

| Cache Key | Type | Content |
|-----------|------|---------|
| `auth-key` | JSON | Full `AuthModel` (token + user) |
| `user-key` | JSON | `UserModel` profile |
| `wallet-key` | String | Raw Cardano wallet address |
| `wallet-info-key` | JSON | Full `Wallet` object with balance |
| `locations-key` | JSON | `List<LocationModel>` for ride form |
| `register-process-key` | JSON | Registration progress tracking |
| `first-timer-key` | Bool | Whether onboarding has been shown |

---

## 15. Notifications

### Notification Channels (Android)

| Channel ID | Name | Importance | LED Color | Vibration |
|-----------|------|-----------|-----------|-----------|
| `trip_requests` | Trip Requests | HIGH | Orange `#FF9800` | Yes |
| `trip_updates` | Trip Updates | HIGH | Green `#4CAF50` | Yes |
| `payment` | Payments | MAX | Blue `#2196F3` | Yes |

### Notification Payload Structure

**Trip Request (to driver):**
```json
{
  "type": "trip_request",
  "action": "view_request",
  "tripId": "uuid",
  "userId": "passengerId",
  "destination": "Location Name"
}
```

**Trip Status Update (to passenger):**
```json
{
  "type": "trip_update",
  "status": "arrived_pickup | started | completed",
  "tripId": "uuid",
  "driverName": "John Doe"
}
```

**Payment Notification:**
```json
{
  "type": "payment",
  "amount": "15.5",
  "paymentId": "pay_uuid",
  "tripId": "uuid",
  "isDriver": true
}
```

---

## 16. Location & Maps

### GPS Configuration
```dart
LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 10,   // Emit update every 10 metres moved
)
```

### Proximity Detection
- `Geolocator.distanceBetween(lat1, lng1, lat2, lng2)` returns metres
- Threshold for "at pickup": configurable (default ~50–100 m)
- Triggers `approachingPickup()` callback → state transitions to `driverAtPickupLocation`

### Google Maps Integration
- Map type: normal
- Driver location shown as custom marker
- Ride pickup/dropoff shown as distinct markers
- Tapping a marker highlights the associated ride in the bottom card
- "Get Directions" button launches native maps app for turn-by-turn navigation

### Location Permissions
1. `LocationService.checkPermission()` called at app start
2. Permission status cached to avoid repeated system dialogs
3. If denied: dialog offered to open app settings
4. If permanently denied: informational message shown

---

## 17. Supported Platforms

| Platform | Status |
|----------|--------|
| Android | Supported |
| iOS | Supported |
| Web | Not configured |
| Desktop | Not configured |

### Environment Configuration

**`.env` file (not committed):**
```
GOOGLE_API_KEY=<Google Maps API key>
PROJECT_ID=ridechain-c7650
PATH_TO_SECRET=secrets/ridechain-key.json
```

**Firebase config:** Auto-generated `firebase_options.dart` (via FlutterFire CLI)

**App config flavors:** `AppConfig` in `lib/app/app_config.dart`
- `prod`: Base URL `https://app.arcaccra.com/`
- `dev`: Base URL (configurable for local backend)

---

*Last updated: May 2026*
