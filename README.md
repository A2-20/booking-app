<p align="center">
  <a href="#">
    <img src="assets/images/app_logo-removebg.png" width="180" alt="Booking App Logo">
  </a>
</p>

<h1 align="center">📱 Travel & Hotel Booking - Flutter Mobile Client App</h1>

<p align="center">
  <b>A cross-platform Flutter application for browsing hotels, booking flights, selecting travel packages, managing user profiles, and processing secure payments. Integrates seamlessly with the Laravel Admin Dashboard & RESTful API Engine.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/State_Management-Provider-02569B?style=for-the-badge" alt="Provider" />
  <img src="https://img.shields.io/badge/Design-Material_3-blue?style=for-the-badge" alt="Material 3" />
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-2C8EBB?style=for-the-badge&logo=apple&logoColor=white" alt="Android | iOS" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License MIT" />
</p>

<p align="center">
  <br />
  <img src="assets/images/showcase.gif" alt="Booking App Showcase" width="40%" />
</p>

---

## 📌 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Tech Stack & Packages](#-tech-stack--packages)
- [Project Structure](#-project-structure)
- [Installation & Setup](#-installation--setup)
- [API Connection Config](#-api-connection-config)
- [Stripe Integration](#-stripe-integration)
- [License](#-license)

---

## 🌟 Overview

This is the mobile client companion application for the [Travel & Hotel Booking - Admin Dashboard & RESTful API Engine](https://github.com/A2-20/booking-dashboard). 

Built with **Flutter** and **Dart**, this app provides a highly polished, interactive user interface designed for travelers. It communicates with the Laravel backend via a secure RESTful API authenticated with **Laravel Sanctum**. Users can effortlessly browse hotel rooms, view flight schedules, discover bundled packages, handle reservations, and make real-time secure payments using **Stripe**.

---

## 🚀 Key Features

### 🏨 1. Hotels & Rooms Booking
- **Smart Browsing:** Explore hotel options with advanced search and filters.
- **Detailed Pages:** View star ratings, dynamic interactive image galleries, location links, and specific room details.
- **Room Selection:** Browse room options by capacity, pricing, and bed types before checkout.
- **Favorite System:** Add hotels to your wishlist for quick future bookings.

### ✈️ 2. Flight Tickets & Packages
- **Flight Search:** View available flights sorted by price, schedule, airline, and airports.
- **Curated Packages:** Purchase promotional travel packages combining matching flights and hotel room reservations.

### 💳 3. Secure Checkout & Payments
- **Stripe SDK integration:** Native card input and secure validation using the Stripe Payment Intents API.
- **Reservation History:** Review booking status (Active, Confirmed, Cancelled) and access invoice summaries.

### 🌐 4. Native Bilingual Support (Arabic & English)
- **Fluid Layout Switcher:** Instant theme-aware language toggle supporting **RTL (Arabic)** and **LTR (English)** layouts.
- **Cairo & Inter Typography:** Custom-tailored typography styles optimized for Arabic readability.

### 🎨 5. Premium UI & Smooth UX
- **Page Transitions:** Sleek Scale, Slide, and Fade animations.
- **Staggered Lists:** Delayed entry effects for lists to create a smooth loading sensation.
- **Shimmer Effects:** Modern shimmer placeholders for images and texts during API loading states.
- **Offline Cache:** Network images cached locally for faster load times and offline fallback.

---

## 🛠️ Tech Stack & Packages

- **Client Framework:** [Flutter 3.x](https://flutter.dev) (Dart 3.x)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **API Network Client:** [Dio](https://pub.dev/packages/dio) (HTTP client with request interceptors)
- **Local Storage:** [Shared Preferences](https://pub.dev/packages/shared_preferences) (Token caching, session storage)
- **Payments:** [Flutter Stripe SDK](https://pub.dev/packages/flutter_stripe)
- **Interface & Animation:**
  - [Google Fonts](https://pub.dev/packages/google_fonts) (Cairo & Inter)
  - [Lottie](https://pub.dev/packages/lottie) (Vector animations)
  - [Shimmer](https://pub.dev/packages/shimmer) (Loading skeletons)
  - [Flutter Svg](https://pub.dev/packages/flutter_svg) (Scalable Vector Graphics)
  - [Cached Network Image](https://pub.dev/packages/cached_network_image) (Optimized image loading)
  - [Smooth Page Indicator](https://pub.dev/packages/smooth_page_indicator) (Intro & gallery swiping)

---

## 📂 Project Structure

```bytes
lib/
├── config/
│   └── app_config.dart            # API baseUrl, Stripe keys, and default locales
├── core/
│   └── utils/
│       ├── animations.dart        # Helper functions for fade/slide/scale transitions
│       └── page_transitions.dart  # Custom page transition builders
├── localization/
│   ├── app_localizations.dart     # Translation engine and delegate setup
│   ├── ar.dart                    # Arabic translations
│   └── en.dart                    # English translations
├── models/                        # Serializable JSON models (Hotel, Flight, Room, Booking, User...)
├── services/
│   ├── api_service.dart           # Custom Dio HTTP client with interceptors for token auth
│   ├── auth_service.dart          # Login, registration, and user management APIs
│   ├── booking_service.dart       # Core booking & history APIs
│   ├── favorites_service.dart     # Toggle favorite status APIs
│   ├── flight_service.dart        # Flight schedule retrieval APIs
│   ├── hotel_service.dart         # Hotel metadata retrieval APIs
│   ├── package_service.dart       # Promotional bundle packages APIs
│   ├── payment_service.dart       # Payment intent confirmation APIs
│   ├── room_service.dart          # Hotel room details APIs
│   ├── stripe_service.dart        # Native payment sheet initialization APIs
│   └── support_service.dart       # Ticket submitting and feedback APIs
├── state/                         # Provider state management controllers
│   ├── booking_state.dart
│   ├── favorites_state.dart
│   ├── locale_state.dart
│   ├── search_state.dart
│   └── user_state.dart
├── storage/
│   └── local_storage_manager.dart # Shared preferences storage helper
├── theme/
│   └── app_theme.dart             # Material 3 colors, Cairo & Inter text styles
└── ui/
    ├── screens/                   # Page screens (Splash, Home, Auth, Details...)
    ├── components/                # Modular view sub-elements
    └── widgets/                   # Custom reusable UI widgets (cards, buttons...)
```

---

## ⚡ Installation & Setup

Follow these steps to run the application locally on your emulator or physical device:

### 1️⃣ Prerequisites
- **Flutter SDK:** `>=3.10.7`
- **Dart SDK:** `>=3.0.0`
- **Android Studio** (for Android Emulator) or **Xcode** (for iOS Simulator)
- A running instance of the [Laravel Booking Backend](https://github.com/A2-20/booking-dashboard)

### 2️⃣ Clone & Install Dependencies
```bash
# Navigate to the project directory
cd booking_app

# Fetch dependencies
flutter pub get
```

### 3️⃣ Setup Environment Config
Configure your computer's local IP and Stripe public key in `lib/config/app_config.dart`:
```dart
class AppConfig {
  // IP address of the system running the Laravel backend
  static const String apiBaseIp = '127.0.0.1'; // Change to local IP if testing on physical device
  static const String apiPort = '8000';
  
  // Stripe Publishable Key from Stripe Developer Console
  static const String stripePublishableKey = 'pk_test_...';
}
```

### 4️⃣ Generate Data Serializers
If you modify any data models, regenerate the JSON serialization files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5️⃣ Run the App
Ensure your target device is connected or emulator is active, then launch:
```bash
flutter run
```

---

## 🔒 Stripe Integration

The app uses the **Flutter Stripe SDK** (`flutter_stripe`) to securely tokenise customer cards.
1. The app requests a `Payment Intent` client secret from the backend API.
2. The Stripe SDK securely confirms the payment directly with Stripe servers.
3. Upon success, the app updates the backend database status to `Confirmed`.

*Note: For testing, use the mock cards provided by Stripe (e.g., `4242 4242 4242 4242`).*

---

## 📄 License

This project is licensed under the **[MIT License](LICENSE)**.

<p align="center">
  Crafted with ❤️ for cross-platform excellence.
</p>