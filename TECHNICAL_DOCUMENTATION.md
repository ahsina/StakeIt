# StakeIt - Technical Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Setup & Installation](#setup--installation)
5. [Backend API](#backend-api)
6. [Mobile App](#mobile-app)
7. [Database Schema](#database-schema)
8. [Deployment](#deployment)

## Project Overview

StakeIt is a motivation application where users bet real money on personal goals and compete with others in challenges. The platform takes a 10% commission on failed stakes/challenges.

### Key Features

#### Solo Mode (Stakes)
- Create personal challenges with financial stakes (€5 - €500)
- Choose proof mode: GPS, Photo, or Manual
- Set daily/weekly goals with automatic tracking
- Geofence validation for location-based goals
- Automatic settlement after deadline
- Gamification: XP, levels, streaks, badges

#### Challenge Mode (Multiplayer)
- Create or join public/private challenges
- Three challenge types:
  - First to Complete: Winner is first to reach target
  - Highest Score: Winner has highest count
  - Team Based: Collaborative challenges
- Real-time chat and leaderboard via SignalR
- Entry fees pooled into prize pot (90% after platform fee)
- Automatic prize distribution to winners

#### Monetization
- 10% platform commission on all failures
- Stripe integration for payments
- Pre-authorization pattern: Hold funds, capture on failure, release on success

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter Mobile App                      │
│  ┌──────────┐  ┌───────────┐  ┌──────────┐  ┌───────────┐ │
│  │  Splash  │  │   Auth    │  │   Home   │  │  Stakes   │ │
│  │  Screen  │  │  Screens  │  │Dashboard │  │  Screens  │ │
│  └──────────┘  └───────────┘  └──────────┘  └───────────┘ │
│  ┌───────────┐  ┌──────────┐  ┌──────────┐                │
│  │Challenges │  │  Profile │  │  Common  │                │
│  │  Screens  │  │  Screens │  │ Widgets  │                │
│  └───────────┘  └──────────┘  └──────────┘                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │        Riverpod State Management + GoRouter         │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  API Client (Dio) + Storage + Location + Stripe    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼ HTTPS REST + WebSocket (SignalR)
┌─────────────────────────────────────────────────────────────┐
│                    .NET 8 Web API                            │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────┐    │
│  │ Auth         │  │ Stakes        │  │ Challenges   │    │
│  │ Controller   │  │ Controller    │  │ Controller   │    │
│  └──────────────┘  └───────────────┘  └──────────────┘    │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────┐    │
│  │ Geofences    │  │ SignalR Hub   │  │ Background   │    │
│  │ Controller   │  │ (WebSocket)   │  │ Services     │    │
│  └──────────────┘  └───────────────┘  └──────────────┘    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │    Business Services (Auth, Stakes, Challenges,     │   │
│  │    Payment, Geofence, Settlement)                   │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Entity Framework Core + Repositories        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              PostgreSQL / SQL Server Database                │
│  15 Tables: Users, Stakes, Challenges, Transactions, etc.   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    External Services                         │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────┐    │
│  │ Stripe       │  │ Azure Blob    │  │ Azure        │    │
│  │ Payments     │  │ Storage       │  │ Notification │    │
│  └──────────────┘  └───────────────┘  └──────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack

### Backend (.NET 8 API)
- **Framework**: ASP.NET Core 8.0
- **ORM**: Entity Framework Core 8.0
- **Database**: PostgreSQL (primary) / SQL Server (alternative)
- **Authentication**: JWT Bearer tokens with PBKDF2 password hashing
- **Real-time**: SignalR for WebSocket connections
- **Payments**: Stripe.net SDK
- **Validation**: FluentValidation
- **Mapping**: AutoMapper
- **Logging**: Serilog

### Mobile App (Flutter)
- **Framework**: Flutter 3.10+
- **Language**: Dart
- **State Management**: Riverpod 2.5
- **Routing**: GoRouter 14.3
- **HTTP Client**: Dio 5.7
- **Data Models**: Freezed + json_serializable
- **Local Storage**:
  - flutter_secure_storage (tokens)
  - shared_preferences (user data)
- **Location**: Geolocator 13.0 + google_maps_flutter
- **Payments**: flutter_stripe 11.2
- **Real-time**: signalr_netcore 1.3
- **Images**: image_picker + cached_network_image

## Setup & Installation

### Prerequisites

- .NET 8 SDK
- Flutter 3.10 or higher
- PostgreSQL 14+ or SQL Server 2019+
- Stripe account (for testing)
- Git

### Backend Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd StakeIt
```

2. **Configure Database Connection**

Edit `src/StakeIt.API/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=stakeit;Username=postgres;Password=yourpassword"
  }
}
```

3. **Configure Stripe Keys**

Add your Stripe test keys to `appsettings.json`:

```json
{
  "Stripe": {
    "SecretKey": "sk_test_...",
    "PublishableKey": "pk_test_..."
  }
}
```

4. **Create Database & Run Migrations**

```bash
cd src/StakeIt.API
dotnet ef migrations add InitialCreate --project ../StakeIt.Infrastructure
dotnet ef database update
```

Note: The application automatically runs migrations and seeds data on startup.

5. **Run the API**

```bash
cd src/StakeIt.API
dotnet run
```

The API will be available at:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger: `https://localhost:5001/swagger`

### Mobile App Setup

1. **Navigate to Flutter project**

```bash
cd src/stakeit_mobile
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure API endpoint**

Edit `lib/core/config/app_config.dart`:

```dart
static const String baseUrl = 'http://localhost:5000'; // or your API URL
```

For Android emulator, use `http://10.0.2.2:5000` instead of `localhost`.

4. **Run code generation**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. **Run the app**

```bash
flutter run
```

Or use your IDE's run configuration.

## Backend API

### API Endpoints

#### Authentication (`/api/auth`)
- `POST /register` - Register new user
- `POST /login` - Login user
- `GET /me` - Get current user info
- `GET /test` - Test authentication

#### Stakes (`/api/stakes`)
- `GET /` - Get my stakes
- `GET /{id}` - Get stake by ID
- `POST /` - Create stake
- `POST /{id}/cancel` - Cancel stake
- `POST /{id}/proofs` - Submit proof
- `GET /{id}/proofs` - Get stake proofs
- `POST /{id}/settle` - Settle stake

#### Challenges (`/api/challenges`)
- `GET /` - Get public challenges
- `GET /my` - Get my challenges
- `GET /{id}` - Get challenge by ID
- `POST /` - Create challenge
- `POST /{id}/join` - Join challenge
- `POST /{id}/leave` - Leave challenge
- `POST /{id}/cancel` - Cancel challenge
- `POST /{id}/proofs` - Submit proof
- `GET /{id}/proofs` - Get challenge proofs
- `GET /{id}/leaderboard` - Get leaderboard
- `POST /{id}/messages` - Send message
- `GET /{id}/messages` - Get messages
- `POST /{id}/settle` - Settle challenge

#### Geofences (`/api/geofences`)
- `GET /` - Get public geofences
- `GET /{id}` - Get geofence by ID
- `GET /nearby` - Find nearby geofences
- `POST /{id}/check` - Check if within geofence

#### SignalR Hub (`/hubs/challenge`)
- `JoinChallenge(int challengeId)` - Join challenge room
- `LeaveChallenge(int challengeId)` - Leave challenge room
- `SendMessage(int challengeId, string message)` - Send chat message
- Events: `NewMessage`, `ProofSubmitted`, `LeaderboardUpdated`, `ParticipantJoined`, `ParticipantLeft`, `ChallengeStatusChanged`

### Authentication

All protected endpoints require JWT Bearer token:

```
Authorization: Bearer <token>
```

Token is obtained from `/api/auth/login` or `/api/auth/register`.

### Request/Response Examples

**Register User**
```bash
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123",
  "firstName": "John",
  "lastName": "Doe",
  "dateOfBirth": "1990-01-01T00:00:00Z"
}
```

**Create Stake**
```bash
POST /api/stakes
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Aller à la salle 3 fois cette semaine",
  "category": "Fitness",
  "amountEUR": 20.00,
  "endDate": "2025-11-23T23:59:59Z",
  "requiredCount": 3,
  "proofMode": "GPS",
  "geofenceId": 1,
  "failureMode": "AllOrNothing"
}
```

## Mobile App

### Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart          # App-wide configuration
│   ├── router/
│   │   └── app_router.dart          # GoRouter configuration
│   └── theme/
│       └── app_theme.dart           # Material 3 theme
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── providers/           # Riverpod providers
│   │   │   └── repositories/        # API repositories
│   │   └── presentation/            # UI screens
│   ├── home/
│   │   ├── presentation/
│   │   └── widgets/                 # Tab widgets
│   ├── stakes/
│   ├── challenges/
│   ├── profile/
│   └── splash/
├── shared/
│   ├── models/                      # Data models
│   ├── services/                    # Shared services
│   └── widgets/                     # Reusable widgets
├── app.dart                         # Root app widget
└── main.dart                        # Entry point
```

### State Management with Riverpod

```dart
// Provider definition
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Usage in widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    // ...
  }
}
```

### Navigation with GoRouter

```dart
// Navigate to route
context.go(AppRoutes.home);

// Navigate with parameters
context.go('/stakes/123');

// Pop navigation
context.pop();
```

## Database Schema

### Core Tables

**Users**
- id, email, password_hash, first_name, last_name
- is_premium, total_xp, current_level, current_streak
- avatar_url, date_of_birth, created_at, updated_at

**Stakes**
- id, user_id, title, description, category
- amount_eur, status, required_count, current_count
- proof_mode, failure_mode, geofence_id
- start_date, end_date, completed_at, settled_at

**Challenges**
- id, creator_id, title, description, category
- challenge_type, status, max_participants
- entry_fee_eur, target_count, proof_mode, geofence_id
- start_date, end_date, is_public, allow_spectators

**ChallengeParticipants**
- id, challenge_id, user_id
- current_count, rank, completed_at, joined_at

**StakeProofs / ChallengeProofs**
- id, stake_id/challenge_id, participant_id
- latitude, longitude, photo_url, notes
- validation_status, rejection_reason
- submitted_at, validated_at

**Transactions**
- id, user_id, stake_id, challenge_id
- amount_eur, type, status, description
- stripe_payment_intent_id, created_at

**Badges**
- id, name, description, icon_url, category
- xp_reward, criteria

**Geofences**
- id, name, latitude, longitude, radius_meters
- category, city, is_public

### Relationships

- User → Stakes (1:N)
- User → ChallengeParticipants (1:N)
- User → Transactions (1:N)
- Challenge → ChallengeParticipants (1:N)
- Challenge → ChallengeProofs (1:N)
- Stake → StakeProofs (1:N)
- Geofence → Stakes (1:N)
- Geofence → Challenges (1:N)

## Deployment

### Backend Deployment (Azure)

1. **Create Azure Resources**
   - App Service (Linux, .NET 8)
   - Azure Database for PostgreSQL
   - Azure Blob Storage (for photos)
   - Azure Notification Hubs (for push notifications)

2. **Configure Connection Strings**
   - Add production connection string to App Service configuration
   - Add Stripe production keys
   - Configure CORS for mobile app domain

3. **Deploy API**
```bash
cd src/StakeIt.API
dotnet publish -c Release -o ./publish
# Deploy ./publish to Azure App Service
```

4. **Setup CI/CD**
   - GitHub Actions or Azure DevOps
   - Automatic deployment on push to main branch

### Mobile App Deployment

#### iOS (App Store)
1. Configure signing in Xcode
2. Update bundle ID and version
3. Build release: `flutter build ios --release`
4. Archive and submit via Xcode

#### Android (Google Play)
1. Generate signing key
2. Configure `android/key.properties`
3. Build release: `flutter build appbundle --release`
4. Upload to Google Play Console

### Environment Variables

**Backend (appsettings.Production.json)**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "<azure-postgres-connection-string>"
  },
  "Jwt": {
    "Secret": "<production-jwt-secret>",
    "ExpiryMinutes": 60
  },
  "Stripe": {
    "SecretKey": "<stripe-live-secret>",
    "PublishableKey": "<stripe-live-publishable>"
  },
  "Azure": {
    "BlobStorage": "<connection-string>",
    "NotificationHub": "<connection-string>"
  }
}
```

**Mobile App**
- Update `app_config.dart` with production API URL
- Use environment-specific config files
- Store sensitive keys in platform-specific secure storage

## Testing

### Backend Tests
```bash
cd src/StakeIt.Tests
dotnet test
```

### Mobile Tests
```bash
cd src/stakeit_mobile
flutter test
```

### Integration Tests
```bash
# Run API
cd src/StakeIt.API
dotnet run

# Run integration tests
cd ../StakeIt.IntegrationTests
dotnet test
```

## Security Considerations

1. **Password Security**: PBKDF2 with 100,000 iterations and SHA256
2. **Token Expiry**: JWT tokens expire after 60 minutes
3. **HTTPS Only**: All production traffic must use HTTPS
4. **Input Validation**: FluentValidation on all inputs
5. **SQL Injection**: Entity Framework parameterized queries
6. **CORS**: Restrict to known origins in production
7. **Rate Limiting**: Implement rate limiting middleware
8. **PCI Compliance**: Stripe handles all payment data

## Performance Optimization

1. **Database Indexing**: Indexes on frequently queried fields
2. **Caching**: Redis for frequently accessed data
3. **CDN**: Azure CDN for static assets
4. **Image Optimization**: Compress photos before upload
5. **Lazy Loading**: Paginated API responses
6. **SignalR Scaling**: Azure SignalR Service for multiple instances

## Monitoring & Logging

1. **Application Insights**: Real-time monitoring
2. **Structured Logging**: Serilog with JSON formatting
3. **Error Tracking**: Sentry or Application Insights
4. **Performance Monitoring**: APM tools
5. **Database Monitoring**: Azure Monitor for PostgreSQL

## Support & Maintenance

- **API Documentation**: Swagger UI at `/swagger`
- **Version**: 1.0.0
- **License**: Proprietary
- **Contact**: support@stakeit.app

---

**Last Updated**: November 16, 2025
