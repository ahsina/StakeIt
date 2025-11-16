# Build Instructions for StakeIt Mobile

## Code Generation Required

Before building the app, you need to run code generation for Freezed models and JSON serialization.

### Run Code Generation

```bash
cd /home/user/StakeIt/src/stakeit_mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate the following files:
- `lib/shared/models/notification_model.freezed.dart`
- `lib/shared/models/notification_model.g.dart`
- `lib/shared/models/stats_model.freezed.dart`
- `lib/shared/models/stats_model.g.dart`

### Watch Mode (Optional)

For development, you can run code generation in watch mode:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

This will automatically regenerate files when you modify models.

### Build the App

After code generation:

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Debug Mode:**
```bash
flutter run
```

## Dependencies

All dependencies are already configured in `pubspec.yaml`:
- freezed: ^2.5.7
- freezed_annotation: ^2.4.4
- build_runner: ^2.4.13
- json_serializable: ^6.8.0

## Troubleshooting

If you encounter build errors:

1. Clean the build:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Delete generated files and regenerate:
   ```bash
   find . -name "*.freezed.dart" -delete
   find . -name "*.g.dart" -delete
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Check Flutter version:
   ```bash
   flutter --version
   # Ensure SDK: ^3.10.0 or higher
   ```

## Firebase Setup

Don't forget to add your Firebase configuration files:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Stripe Setup

Add your Stripe publishable key in the app configuration.

## Environment Variables

Create a `.env` file (if using flutter_dotenv) or configure in `lib/core/config/app_config.dart`:
- API Base URL
- Stripe Publishable Key
- Other environment-specific configurations
