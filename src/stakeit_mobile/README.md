# StakeIt Mobile

Application mobile Flutter pour StakeIt - Pariez sur vous-même et atteignez vos objectifs !

## 🎯 Vue d'ensemble

StakeIt est une application de motivation où les utilisateurs misent de l'argent réel sur leurs objectifs personnels. Complétez vos défis pour récupérer votre mise et gagner des récompenses, ou perdez votre argent en cas d'échec.

## ✨ Fonctionnalités Implémentées

### 🔐 Authentification ✅
- Inscription avec email/mot de passe
- Connexion sécurisée avec JWT
- Stockage sécurisé des tokens (FlutterSecureStorage)
- Auto-login avec refresh token
- Écrans: Splash, Login, Register

### 🎯 Stakes (Paris personnels) ✅
- **Création complète** avec :
  - 9 catégories (Fitness, Éducation, Productivité, Finance, etc.)
  - Montant personnalisable (5-500€)
  - Date et heure limite configurables
  - 3 modes de preuve (GPS, Photo, Manuel)
  - 2 modes d'échec (Perdre tout, Proportionnel)
  - Nombre de preuves requises
- **Soumission de preuves** :
  - Preuve GPS avec validation de localisation
  - Preuve photo avec compression automatique
  - Validation manuelle
- **Écran de détail** avec :
  - Badge de statut coloré
  - Barre de progression animée
  - Compte à rebours du temps restant
  - Historique des preuves
  - Annulation du stake
- **Liste filtrée** par statut (Actif/Complété/Échoué)

### 👥 Challenges (Défis multijoueurs) ✅
- **Création de challenges** :
  - 3 types : Premier à compléter, Score le plus élevé, En équipe
  - Nombre de participants configurable
  - Droit d'entrée en euros
  - Dates de début et fin personnalisables
  - Mode public/privé
  - Option spectateurs
- **Gestion des challenges** :
  - Rejoindre/Quitter un challenge
  - Voir challenges publics disponibles
  - Voir mes challenges en cours
- **Écran de détail** avec 3 tabs :
  - **Détails** : Info, participants, statut, dates
  - **Classement** : Leaderboard en temps réel avec médailles or/argent/bronze
  - **Chat** : Messagerie instantanée entre participants
- **Real-time** avec SignalR :
  - Messages instantanés
  - Mises à jour du classement live
  - Notifications de preuves soumises

### 👤 Profil Utilisateur ✅
- **Header animé** avec dégradé et avatar
- **Système de progression** :
  - Niveau et XP avec barre de progression
  - XP gagnés via stakes et challenges
  - Calcul automatique du niveau suivant
- **Statistiques complètes** :
  - Total de stakes (total, actifs, complétés, échoués)
  - Total de challenges (total, actifs, gagnés)
  - Série actuelle et record
  - Taux de succès en %
  - Profit net calculé
- **Système de badges** :
  - Affichage horizontal des badges gagnés
  - Modal "Voir tout" avec grille complète
  - Badges gagnés vs verrouillés
  - Icônes différenciées
  - Récompenses en XP affichées
- **Pull-to-refresh** pour actualiser

### 💰 Portefeuille ✅
- **Carte de solde** avec dégradé :
  - Solde disponible (gros chiffre)
  - Solde en attente
  - Gains totaux lifetime
  - Dépenses totales lifetime
- **Gestion des cartes bancaires** :
  - Ajouter une carte (setup intent Stripe)
  - Supprimer des cartes
  - Définir carte par défaut
  - Affichage sécurisé (•••• 4242)
  - Date d'expiration avec validation
  - Badge "Par défaut" coloré
- **Retrait de fonds** :
  - Dialog avec validation
  - Montant minimum 10€
  - Vérification du solde
  - Confirmation visuelle
- **Historique des transactions** :
  - Modal scrollable
  - Type (Crédit/Débit) avec couleurs
  - Statut avec badges colorés
  - Montant avec signe +/-
  - Date et heure formatées

### 🔔 Notifications ✅
- **Firebase Cloud Messaging** complet :
  - Initialisation automatique
  - Demande de permissions iOS/Android
  - Récupération FCM token
  - Envoi token au backend
- **Notifications locales** :
  - 3 canaux Android (General, Stakes, Challenges)
  - Support iOS avec DarwinNotifications
  - Sons et badges configurables
- **Gestion des états** :
  - Foreground : affichage notification locale
  - Background : handler dédié
  - Terminated : initialMessage
  - Tap notification : navigation automatique
- **Topics** :
  - Souscription/désinscription
  - Topic "general" par défaut
- **Types de notifications** :
  - Rappels de stakes
  - Stakes complétés/échoués
  - Invitations challenges
  - Messages de chat
  - Paiements reçus/échoués

### 📍 Services Implémentés

#### LocationService ✅
- Demande et vérification des permissions
- Localisation GPS haute précision
- Validation de geofence (rayon en mètres)
- Calcul de distance Haversine
- Timeout de 10 secondes
- Ouverture paramètres Location/App
- Gestion des exceptions

#### ImageService ✅
- Capture photo depuis caméra
- Sélection depuis galerie
- Sélection multiple (max 5 images)
- Compression automatique JPEG 85%
- Redimensionnement (max 1920x1080)
- Conversion base64 pour API
- Sauvegarde dans répertoire temporaire
- Suppression fichiers temporaires
- Gestion mémoire optimisée

#### SignalRService ✅
- Connexion WebSocket automatique
- Auto-reconnexion en cas de perte
- Gestion des événements :
  - Messages reçus
  - Preuves soumises
  - Classement mis à jour
- Streams pour updates temps réel
- Join/Leave challenge rooms
- Send message via SignalR

#### NotificationService ✅ (voir section Notifications)

## 🏗️ Architecture

### Structure du projet
```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart          # Configuration (API, Stripe, constantes)
│   ├── router/
│   │   └── app_router.dart          # Navigation GoRouter
│   └── theme/
│       └── app_theme.dart           # Thème Material 3
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/              # UserModel
│   │   │   ├── providers/           # AuthProvider
│   │   │   └── repositories/        # AuthRepository
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       └── splash_screen.dart
│   ├── challenges/
│   │   ├── data/
│   │   │   ├── providers/           # ChallengesProvider
│   │   │   └── repositories/        # ChallengeRepository
│   │   └── presentation/
│   │       ├── challenge_detail_screen.dart  # 3 tabs + SignalR
│   │       └── create_challenge_screen.dart
│   ├── home/
│   │   ├── presentation/
│   │   │   └── home_screen.dart     # Bottom navigation
│   │   └── widgets/
│   │       ├── stakes_tab.dart      # Liste stakes
│   │       ├── challenges_tab.dart  # Liste challenges
│   │       └── profile_tab.dart     # Profil + stats
│   ├── payment/
│   │   ├── data/
│   │   │   ├── providers/           # PaymentProvider
│   │   │   └── repositories/        # PaymentRepository
│   │   └── presentation/
│   │       └── wallet_screen.dart
│   ├── profile/
│   │   └── data/
│   │       ├── providers/           # StatsProvider
│   │       └── repositories/        # StatsRepository
│   └── stakes/
│       ├── data/
│       │   ├── providers/           # StakesProvider
│       │   └── repositories/        # StakeRepository
│       └── presentation/
│           ├── create_stake_screen.dart
│           └── stake_detail_screen.dart
└── shared/
    ├── models/
    │   ├── badge_model.dart         # Badges + Stats
    │   ├── challenge_model.dart     # Challenge + Participant + Message
    │   └── stake_model.dart         # Stake + Proof + Request
    └── services/
        ├── api_client.dart          # Dio HTTP client
        ├── image_service.dart       # Photos + compression
        ├── location_service.dart    # GPS + geofence
        ├── notification_service.dart # FCM + local
        ├── signalr_service.dart     # WebSocket temps réel
        └── storage_service.dart     # Secure + SharedPreferences
```

### Patterns utilisés
- **Clean Architecture** : Séparation presentation/data/domain
- **Repository Pattern** : Abstraction de l'accès aux données
- **State Management** : Riverpod avec StateNotifier
- **Code Generation** : Freezed pour immutabilité
- **Dependency Injection** : Providers Riverpod
- **Family Providers** : Pour paramètres dynamiques

### State Management Flow
```
UI Widget
    ↓ ref.watch(provider)
StateNotifier/FutureProvider
    ↓ notifier.method()
Repository
    ↓ dio.post/get()
API Backend
    ↓ Response
Repository
    ↓ Model.fromJson()
StateNotifier
    ↓ state = newState
UI Widget (rebuild)
```

## 🔧 Technologies

### Core
- **Flutter** 3.x
- **Dart** 3.x
- **Riverpod** 2.5.1 - State management avec StateNotifier
- **GoRouter** 14.3.0 - Navigation déclarative
- **Freezed** 2.4.4 - Code generation pour immutabilité

### Backend Integration
- **Dio** 5.7.0 - HTTP client avec interceptors
- **SignalR NetCore** 1.3.7 - WebSocket temps réel

### Payment & Finance
- **Flutter Stripe** 11.2.0 - Paiements sécurisés Stripe SDK

### Location & Media
- **Geolocator** 13.0.1 - GPS avec permissions
- **Image Picker** 1.1.2 - Caméra et galerie
- **Image** 4.2.0 - Compression et resize
- **Path Provider** - Répertoires temporaires

### Notifications
- **Firebase Core** - Firebase SDK
- **Firebase Messaging** - Push notifications FCM
- **Flutter Local Notifications** - Notifications locales

### Storage
- **Flutter Secure Storage** - Tokens JWT sécurisés
- **Shared Preferences** - Données utilisateur

## 🚀 Installation & Configuration

### Prérequis
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode
- Compte Firebase configuré
- Compte Stripe avec clés API

### Installation

1. **Installer les dépendances**
```bash
cd src/stakeit_mobile
flutter pub get
```

2. **Générer le code Freezed**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. **Configuration Firebase**
- Créer projet Firebase
- Télécharger `google-services.json` (Android) → `android/app/`
- Télécharger `GoogleService-Info.plist` (iOS) → `ios/Runner/`
- Activer Firebase Cloud Messaging dans console Firebase

4. **Configuration Stripe**

Éditer `lib/core/config/app_config.dart` :
```dart
static const String stripePublishableKey = 'pk_test_VOTRE_CLE';
```

5. **Configuration API Backend**
```dart
static const String baseUrl = 'https://votre-api.com';
```

### Lancer l'application

```bash
# Développement
flutter run

# Release Android
flutter build apk --release
flutter build appbundle --release

# Release iOS (macOS uniquement)
flutter build ios --release
```

## 🔑 Configuration Requise

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous avons besoin de votre localisation pour valider vos preuves GPS</string>
<key>NSCameraUsageDescription</key>
<string>Nous avons besoin de l'accès à la caméra pour les preuves photo</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Nous avons besoin de l'accès à vos photos</string>
```

## 📱 Écrans Principaux

### Navigation (Bottom Navigation Bar)
1. **Stakes** 🏆 - Mes paris personnels
2. **Challenges** 👥 - Défis multijoueurs
3. **Profil** 👤 - Stats, badges, paramètres

### Flux Stakes
```
StakesTab → CreateStakeScreen → StakeDetailScreen
              ↓                        ↓
         StakeCreated            Submit Proof (GPS/Photo)
```

### Flux Challenges
```
ChallengesTab → CreateChallengeScreen → ChallengeDetailScreen
(Public/Mes)         ↓                    (3 tabs: Details/Leaderboard/Chat)
                 Join Challenge               ↓
                                    Real-time via SignalR
```

### Flux Profil
```
ProfileTab → WalletScreen → Transactions History
               ↓
           Payment Methods (Add/Remove/Default)
               ↓
           Payout Request
```

## 🎨 Design System

### Couleurs
- **Primary** : `#6C5CE7` (Violet) - Boutons principaux, accents
- **Secondary** : `#00B894` (Vert) - Succès, profits
- **Error** : `#D63031` (Rouge) - Erreurs, échecs
- **Warning** : `#FDCB6E` (Jaune) - Alertes
- **Text** : `#2D3436` (Gris foncé)

### Composants UI
- **Cards** : Élévation 2-4, border radius 12px
- **Buttons** : Material 3 (Filled, Outlined, Text)
- **TextFields** : Outlined avec labels
- **Snackbars** : Feedbacks utilisateur
- **Dialogs** : Confirmations avec actions
- **BottomSheets** : Listes et détails
- **Gradients** : Headers profil, wallet, challenges

### Icônes par catégorie
- **Fitness** : fitness_center (Rouge)
- **Éducation** : school (Bleu)
- **Productivité** : work (Violet)
- **Finance** : account_balance (Vert)
- **Développement personnel** : self_improvement (Orange)
- **Famille** : family_restroom (Rose)
- **Créativité** : palette (Violet foncé)
- **Maison** : home (Marron)
- **Digital Detox** : phone_disabled (Sarcelle)

## 📊 Modèles de Données (Freezed)

### Authentification
- `UserModel` : id, email, firstName, lastName, isPremium, currentStreak

### Stakes
- `StakeModel` : id, title, category, amount, status, progress, dates
- `StakeProofModel` : id, type, location, imageUrl, timestamp
- `CreateStakeRequest` : title, category, amount, endDate, requiredCount, proofMode
- `SubmitProofRequest` : type, latitude, longitude, imageBase64

### Challenges
- `ChallengeModel` : id, title, type, status, participants, prizePool, dates
- `ChallengeParticipantModel` : userId, userName, rank, currentCount
- `ChallengeMessageModel` : senderId, senderName, message, sentAt
- `CreateChallengeRequest` : title, category, type, entryFee, maxParticipants

### Profil & Stats
- `BadgeModel` : id, name, description, iconUrl, xpReward, earnedAt
- `UserStatsModel` : stakes, challenges, streaks, earnings, spending

### Paiement
- `PaymentMethodModel` : id, type, last4, brand, expiry, isDefault
- `WalletModel` : availableBalance, pendingBalance, lifetimeEarnings/Spent
- `TransactionModel` : type, amount, status, description, createdAt

### Enums
- `StakeStatus` : Active, Completed, Failed, Cancelled
- `StakeCategory` : 9 catégories (Fitness, Education, etc.)
- `ProofMode` : GPS, Photo, Manual
- `FailureMode` : LoseAll, Proportional
- `ChallengeStatus` : Open, Active, Completed, Cancelled
- `ChallengeType` : FirstToComplete, HighestScore, TeamBased

## 🔐 Sécurité

### Authentification
- JWT tokens stockés en FlutterSecureStorage
- Refresh token automatique
- Interceptor Dio pour injection auto du token
- Déconnexion sur 401 Unauthorized

### Communications
- HTTPS uniquement
- Validation des certificats SSL
- Timeouts configurés (30s)

### Données sensibles
- Pas de stockage de mots de passe
- Tokens JWT expirables
- Stripe SDK pour paiements (PCI compliant)
- Validation côté client + serveur

### Permissions
- Demandées au moment du besoin
- Explications claires (descriptions iOS)
- Fallback si refusées
- Ouverture Settings si nécessaire

## 🧪 Tests

### Tests unitaires
```bash
flutter test
```

### Tests d'intégration
```bash
flutter test integration_test
```

### Coverage
```bash
flutter test --coverage
lcov --list coverage/lcov.info
```

## 🚀 Déploiement

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release

# Signer avec keystore
keytool -genkey -v -keystore stakeit-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias stakeit
```

### iOS
```bash
# Archive
flutter build ios --release

# Ouvrir Xcode pour upload
open ios/Runner.xcworkspace
```

## 📈 Statistiques du Projet

### Code
- **Lignes de code** : ~15,000+
- **Fichiers Dart** : 50+
- **Modèles Freezed** : 15+
- **Providers** : 20+
- **Écrans** : 12+
- **Services** : 6+

### Fonctionnalités
- ✅ Authentification JWT
- ✅ CRUD Stakes complet
- ✅ CRUD Challenges complet
- ✅ Real-time chat SignalR
- ✅ GPS validation
- ✅ Photo compression
- ✅ Stripe payments
- ✅ Wallet management
- ✅ Push notifications
- ✅ Badges & gamification
- ✅ Statistics tracking

## 🗺️ Roadmap Futur

### Court terme
- [ ] Tests unitaires complets (80% coverage)
- [ ] Tests d'intégration E2E
- [ ] Mode sombre
- [ ] Animations avancées (Hero, Fade, Slide)

### Moyen terme
- [ ] Internationalisation (FR, EN, ES)
- [ ] Mode hors-ligne avec synchronisation
- [ ] Graphiques statistiques (charts)
- [ ] Filtres et recherche avancée
- [ ] Partage sur réseaux sociaux

### Long terme
- [ ] Widget home screen
- [ ] Apple Watch / Wear OS
- [ ] Intégrations tierces (Strava, Apple Health)
- [ ] Leagues & Ladders
- [ ] Team battles
- [ ] Mode spectateur avec livestream

## 🤝 Contribution

Ce projet démontre une architecture Flutter moderne et complète avec :
- ✨ Clean Architecture
- 🎯 Riverpod State Management
- 🔄 Real-time SignalR
- 💳 Stripe Payments
- 📱 Push Notifications
- 📍 Location Services
- 📸 Media Handling
- 🎨 Material 3 Design

## 📝 Notes Techniques

### Gestion des états
- `StateNotifier` pour états mutables complexes
- `FutureProvider` pour chargements asynchrones
- `StreamProvider` pour données temps réel SignalR
- `Family` providers pour paramètres dynamiques

### Performance
- Image compression automatique (max 1MB)
- Lazy loading des listes
- Caching avec Riverpod
- Debouncing des recherches

### Erreurs
- Try-catch systématiques
- Messages d'erreur traduits
- Snackbars pour feedbacks
- Retry sur erreurs réseau

## 📄 License

Propriétaire - StakeIt © 2025

## 👨‍💻 Développement

Développé avec ❤️ par Claude AI pour le projet StakeIt

---

**Version** : 1.0.0  
**Dernière mise à jour** : Novembre 2025  
**Flutter Version** : 3.x  
**Dart Version** : 3.x
