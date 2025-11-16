# StakeIt Mobile

Application mobile Flutter pour StakeIt - L'app de motivation par engagement financier.

## 🚀 Fonctionnalités Prévues

### MVP (Phase 1)
- [ ] Authentification (Email + Google Sign-In)
- [ ] Création de stakes (Mode Solo)
- [ ] Dashboard utilisateur
- [ ] Tracking GPS pour validation
- [ ] Notifications push
- [ ] Intégration Stripe pour paiements

### Phase 2 - Social
- [ ] Mode Challenge (Duels 1v1)
- [ ] Chat trash talk
- [ ] Système d'amis
- [ ] Leaderboards
- [ ] Badges & achievements

### Phase 3 - Avancé
- [ ] Team battles
- [ ] Leagues/Ladders
- [ ] Validation par photo
- [ ] Intégrations apps tierces (Strava, Apple Health)
- [ ] Mode spectateur

## 📦 Packages Utilisés

### Core
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `dio` - HTTP client pour l'API

### UI/UX
- `google_fonts` - Typographie
- `flutter_animate` - Animations
- `cached_network_image` - Images optimisées

### Fonctionnalités
- `geolocator` - GPS tracking
- `camera` - Photo proofs
- `flutter_local_notifications` - Notifications
- `firebase_messaging` - Push notifications
- `stripe_flutter` - Paiements
- `image_picker` - Sélection photos

### Stockage
- `shared_preferences` - Stockage local simple
- `flutter_secure_storage` - Stockage sécurisé (tokens)
- `hive` - Database locale

### Utilités
- `intl` - Internationalisation
- `timeago` - Affichage dates relatives
- `url_launcher` - Ouvrir URLs externes

## 🏗️ Architecture

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── routes.dart
│   ├── theme.dart
│   └── constants.dart
├── core/
│   ├── providers/
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── gps_service.dart
│   │   ├── notification_service.dart
│   │   └── payment_service.dart
│   └── models/
│       ├── user.dart
│       ├── stake.dart
│       ├── challenge.dart
│       └── ...
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── providers/
│   ├── stakes/
│   │   ├── screens/
│   │   │   ├── create_stake_screen.dart
│   │   │   ├── stake_detail_screen.dart
│   │   │   └── stakes_list_screen.dart
│   │   ├── widgets/
│   │   └── providers/
│   ├── challenges/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── providers/
│   ├── profile/
│   ├── leaderboard/
│   └── home/
└── shared/
    ├── widgets/
    └── utils/
```

## 🔧 Configuration

### Variables d'environnement

Créer `.env` à la racine :

```env
API_BASE_URL=https://api.stakeit.app
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

### Configuration Firebase

1. Ajouter `google-services.json` dans `android/app/`
2. Ajouter `GoogleService-Info.plist` dans `ios/Runner/`

## 🚦 Démarrage

### Installation

```bash
flutter pub get
```

### Lancer en développement

```bash
# Android
flutter run

# iOS (macOS uniquement)
flutter run -d ios

# Web
flutter run -d chrome
```

### Build Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (pour Play Store)
flutter build appbundle --release

# iOS (macOS uniquement)
flutter build ios --release

# Web
flutter build web --release
```

## 🧪 Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widgets/
```

## 📱 Plateformes Supportées

- ✅ Android (API 21+)
- ✅ iOS (13.0+)
- ✅ Web (PWA)

## 🎨 Design System

### Couleurs Principales
- Primary: `#6C5CE7` (Violet)
- Secondary: `#00B894` (Vert)
- Error: `#D63031` (Rouge)
- Success: `#00B894` (Vert)
- Warning: `#FDCB6E` (Jaune)

### Typography
- Font Family: Inter (Google Fonts)
- Heading: 24-32px, Bold
- Body: 14-16px, Regular
- Caption: 12px, Regular

## 📄 License

Proprietary - All rights reserved
