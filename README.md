# Elder Ring Application

Elder Ring is a Flutter application designed to assist in elder care. It provides features like medication reminders, location sharing, group chat, emergency medication list, and video call with care provider.

## Features

- **Medication Reminders**: Sends reminders for medication times. If a medication is missed, a notification is sent to the care provider.
- **Location Sharing**: Allows elders to share their location with their care providers.
- **Group Chat**: Enables chat between elders for better communication and social interaction.
- **Emergency Medication**: Provides a predefined list of medication for emergency cases.
- **Call with Care Provider**: Facilitates video call and screen sharing with the care provider for better assistance.

## Technologies Used

- Flutter
- Firebase Cloud Messaging (FCM)
- Google Maps API
- Jitsi Meet

## Getting Started

To get a local copy up and running, follow these steps:

1. Clone the repository.
2. Install the Flutter SDK and Dart plugin.
3. Run `flutter pub get` to install the necessary packages.
4. Replace the text "your_key_here" in the following files with your own keys:
   - `google-services.json`
   - `AndroidManifest.xml`
   - `main.dart`
   - `global_notifications.dart`
   - `elderring-9e5f6-57ca287c64f3.json`
5. Run `flutter run` to start the application.

## Note

The app is still in the development phase, so not all features work as expected. Any feedback is welcome and appreciated.
