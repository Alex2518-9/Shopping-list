# Shopping List

## Firestore data model

The app stores grocery items in the `shopping-list` collection. Each item is a
document with an automatically generated document ID and these fields:

| Field | Firestore type | Example |
| --- | --- | --- |
| `name` | string | `"Milk"` |
| `quantity` | integer | `2` |
| `category` | string | `"Dairy"` |

The document ID is the item's `id` in the app model; it is not duplicated in the
document fields. `GroceryItem.toFirestore` and `GroceryItem.fromFirestore`
define and validate this shape.

## Firebase setup

1. Register each target platform with the Firebase project that owns the
   Firestore database.
2. Run `flutterfire configure` from the project root and select that Firebase
   project and each platform you build. This installs the native Firebase
   configuration the app needs to initialize its default Firebase app. No
   Firebase platform configuration was present in this checkout when checked.
3. Create the `shopping-list` collection (it is also created automatically by
   the first successful add) and set Firestore security rules appropriate for
   your app's authentication and access model.
4. Fully stop and restart the app after configuring Firebase. Hot reload does
   not rerun Firebase initialization.

The app uses the `cloud_firestore` SDK through
[`FirestoreGroceryRepository`](./lib/data/grocery_repository.dart). Do not
enable public read/write rules for production. If Firebase initialization
fails, the app logs the underlying error in debug builds and displays a generic
startup error with a retry action instead of exposing Firebase details.
