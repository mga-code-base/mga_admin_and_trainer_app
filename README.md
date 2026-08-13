# 👨‍✈️ MGA Admin & Trainer App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com/)
[![Architecture](https://img.shields.io/badge/Architecture-Layered%20Clean-blue)](https://flutter.dev)
[![Security](https://img.shields.io/badge/Security-Encrypted%20Keystore-red)](https://pub.dev/packages/flutter_secure_storage)

A Flutter/Android front end for gym administrators and trainers — branch setup, staff and member approval workflows, equipment tracking, grievance resolution, and trainer-side progress tracking, backed by a REST API.

## Features

- **Role-based flows** for Primary Admin, Admin, and Trainer accounts
- Admin signup wizard: account details → branch setup → initial equipment catalog, in one guided flow
- Approve/deactivate flows for pending admins, trainers, and members
- Branch equipment management (add, edit, working-condition status)
- Grievance intake and resolution tracking
- Trainer-side member progress views
- Push-style in-app notifications with unread badge
- Session auto-expiry (15-minute token TTL) with proactive logout — a stale session gets the user back to the login screen even mid-use, not just on the next failed API call

## Tech Stack

- Flutter (Android)
- `http` for networking
- `flutter_secure_storage` for the auth token
- `image_picker` for equipment/profile media where applicable

## Project Structure

lib/
├── core/
│   ├── config/
│   ├── network/
│   └── utils/
├── models/
├── services/
├── screens/
│   ├── auth/
│   ├── admin/
│   ├── trainer/
│   └── common/
├── widgets/
└── main.dart

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- An Android device or emulator

### Install & Run
flutter pub get
flutter run

### Configuration
The backend base URL lives in `lib/core/config/app_constants.dart`. Point it at your own API instance before running against real data.

## Testing

flutter test

Coverage is intentionally scoped rather than exhaustive: unit tests for `Validators` and every typed model, the `ApiClient` network layer, and the token-TTL logic in `AuthCacheService`. Widget tests cover screens with real conditional logic worth pinning down, not every screen mechanically.

## Architecture Notes

Originally a flat, single-file dump; restructured into the layered shape above with a deliberate goal: every `ApiService` method used to repeat its own `Uri.parse` + header boilerplate, and raw `Map<String, dynamic>` data was read inconsistently across screens. Splitting `ApiClient` (transport) from `ApiService` (domain logic) and introducing typed models eliminated a handful of latent duplication bugs rather than just moving code around.

```
