# Shopping List

A simple grocery-list app built with Flutter and Firebase Cloud Firestore. Add
items with a quantity and category, view the list across app sessions, and
swipe an item away to delete it.

## Features

- Create grocery items with a name, positive quantity, and category.
- Store and load items from Cloud Firestore.
- Delete items with a swipe gesture.
- Show retry and error feedback when a Firestore request fails.
- Validate item names and quantities before saving.

## Built with

- [Flutter](https://flutter.dev/) and Dart
- [Firebase Core](https://firebase.google.com/docs/flutter/setup)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)

## Requirements

- Flutter SDK with Dart `^3.9.0` (see [`pubspec.yaml`](pubspec.yaml)).
- A Firebase project with Cloud Firestore enabled.
- A configured Firebase app for each platform you want to run.

## Getting started

1. Clone this repository and change into the project directory:

   ```sh
   git clone https://github.com/Alex2518-9/Shopping-list.git
   cd Shopping-list
   ```

2. Install Flutter dependencies:

   ```sh
   flutter pub get
   ```

3. Configure Firebase for your project:

   ```sh
   flutterfire configure
   ```

   Select your Firebase project and the platforms you intend to use. This
   generates `lib/firebase_options.dart` and the platform-specific Firebase
   configuration files. If you use a different Firebase project, make sure
   those generated files correspond to it.

4. In the Firebase console, create or select a Cloud Firestore database and
   configure its security rules for your deployment. The app currently has no
   sign-in flow, so do not use open, public read/write rules in production.

5. Run the app on a configured device, emulator, or supported desktop target:

   ```sh
   flutter run
   ```

Firebase configuration is required before launching because the app initializes
Firebase at startup. Firebase is supported by the configured Android, iOS,
macOS, web, and Windows targets; Linux is not configured in
[`firebase_options.dart`](lib/firebase_options.dart).

## Firestore data model

The app stores items in the `shopping-list` collection. Firestore assigns each
document an ID, which the app uses as the item's ID. The document contains:

| Field | Type | Example |
| --- | --- | --- |
| `name` | string | `"Milk"` |
| `quantity` | integer | `2` |
| `category` | string | `"Dairy"` |

The serialization and validation logic lives in
[`GroceryItem`](lib/models/grocery_item.dart), and Firestore access is handled
by [`FirestoreGroceryRepository`](lib/data/grocery_repository.dart).

## Development

Run the tests and static analysis with:

```sh
flutter test
flutter analyze
```

The tests cover Firestore item serialization and repository operations, as well
as grocery-list loading and adding items.
