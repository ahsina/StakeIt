# StakeIt - Motivation App with Real Money Stakes

## 🎯 Concept

StakeIt est une application mobile qui utilise l'argent réel comme levier de motivation. Les utilisateurs misent de l'argent sur leurs objectifs personnels. S'ils échouent, ils perdent leur mise. S'ils réussissent, ils récupèrent leur argent (et peuvent même gagner plus en mode challenge).

### Principe Psychologique
- **Loss Aversion** : La peur de perdre est 2-3x plus motivante que l'envie de gagner
- **Skin in the Game** : Argent réel = Engagement réel
- **Commitment Device** : Se piéger volontairement pour vaincre la procrastination

## 🏗️ Architecture

### Stack Technique

**Mobile App:**
- Framework: Flutter (Dart)
- Platforms: iOS + Android + Web PWA
- Key Packages:
  - `geolocator` - GPS tracking
  - `camera` - Photo proofs
  - `flutter_local_notifications` - Push notifications
  - `stripe_flutter` - Payments
  - `http` / `dio` - API calls

**Backend API:**
- Framework: .NET 8 Web API (ASP.NET Core)
- Architecture: Clean Architecture / Domain-Driven Design
- Database: PostgreSQL / Azure SQL
- ORM: Entity Framework Core
- Real-time: SignalR (challenges live)
- Auth: JWT + ASP.NET Core Identity
- Payments: Stripe SDK

**Infrastructure:**
- Hosting: Azure App Service (API)
- Functions: Azure Functions (cron jobs for settlements)
- Storage: Azure Blob Storage (photos, avatars)
- Notifications: Azure Notification Hubs
- CI/CD: GitHub Actions

### Project Structure

```
StakeIt/
├── src/
│   ├── StakeIt.API/              # Web API (controllers, middleware)
│   ├── StakeIt.Core/             # Domain models, interfaces
│   ├── StakeIt.Infrastructure/   # EF Core, external services
│   └── StakeIt.Mobile/           # Flutter app
├── tests/
│   ├── StakeIt.API.Tests/
│   ├── StakeIt.Core.Tests/
│   └── StakeIt.Mobile.Tests/
└── docs/
    ├── api-spec.md
    ├── database-schema.md
    └── user-flows.md
```

## 🎮 Features

### Mode Solo - Self Challenge

**User Journey:**
1. Create a stake (objective + amount + duration)
2. Choose proof method (GPS, Photo, Manual, App Integration)
3. Choose failure destination (Charity, Friend, Winner Pool)
4. Track progress automatically
5. At deadline: Settlement (success = refund, failure = charge)

**Categories:**
- 💪 Fitness & Health (gym, running, sleep, diet)
- 🎓 Learning & Education (languages, courses, reading)
- 💼 Productivity & Work (coding, tasks, focus time)
- 💰 Finance & Savings (budgeting, no impulse buying)
- 🧘 Personal Development (meditation, journaling)
- 👨‍👩‍👧‍👦 Family & Relationships (quality time, communication)
- 🎨 Creativity & Hobbies (art, music, DIY)
- 🏠 Home & Lifestyle (cleaning, cooking, sustainability)
- 💻 Digital Detox (limit social media, screen time)

### Mode Challenge - Compete Against Others

**Types:**

1. **Duel 1v1** (Race Mode)
   - Two people, same objective
   - Highest score wins
   - Winner takes pot (minus commission)

2. **Duel Asymmetric** (Bet Mode)
   - Person A bets Person B will fail
   - If B succeeds, B wins A's money
   - Different odds possible

3. **Team Battle**
   - 2 teams (2-10 people each)
   - Cumulative score
   - Winning team shares the pot

4. **Ladder/League**
   - Open competition
   - Weekly/monthly rankings
   - Top X share prize pool

**Social Features:**
- Live leaderboards
- Trash talk chat
- Spectator mode (friends can watch & bet)
- Rematch system
- Rivalries tracking

### Gamification

**XP & Levels:**
- Earn XP for completing stakes and winning challenges
- Levels: Beginner → Committed → Achiever → Champion → Legend
- Perks per level (reduced commission, access to premium features)

**Badges:**
- Achievement badges (milestones)
- Streak badges (consecutive wins)
- Challenge badges (duels won, team victories)
- Financial badges (money saved, profit made)
- Social badges (friends invited, trash talker)

**Leaderboards:**
- Global (all-time)
- Monthly
- Local (by city)
- Category-specific
- Friends-only

## 💰 Monetization

### Revenue Streams

1. **Commission on Failures** (10%)
   - Primary revenue
   - Transparent: clearly shown when creating stake
   - Example: User stakes 50€ → Fails → 45€ to destination, 5€ to platform

2. **Premium Subscription** (€6.99/month or €59.99/year)
   - Zero commission on failures
   - Unlimited stakes/challenges
   - Advanced analytics
   - Custom geofences
   - Private leagues
   - No ads
   - Priority support

3. **Challenge Commission** (10-15%)
   - On multi-player pots
   - Duels: 10%
   - Team battles: 10%
   - Leagues: 15%

4. **Spectator Bets** (20% commission) - Optional
   - Mini-bets on challenge outcomes
   - Requires gambling license in some jurisdictions

5. **B2B Partnerships**
   - Corporate wellness programs
   - Gym partnerships
   - Health insurance integrations
   - Brand sponsorships

### Revenue Projections

**Conservative Scenario:**
- 1,000 active users
- 50% create 1 stake/week = 500 stakes
- 40% failure rate = 200 failures
- Average stake: €20
- Commission: €2 per failure

**Monthly Revenue:** €1,600

**At Scale:**
- 10,000 users → €16,000/month
- 50,000 users → €80,000/month

## 🔒 Security & Compliance

### Anti-Fraud Mechanisms

**GPS Spoofing Detection:**
- Velocity checks (impossible travel speed)
- Accuracy validation
- Mock location detection (Android)
- Timezone consistency
- Historical pattern analysis

**Photo Manipulation Detection:**
- EXIF metadata validation
- Timestamp verification
- Source verification (camera vs gallery)
- Edit detection
- AI/Computer Vision validation (Premium)

**Collusion Detection:**
- Repetition patterns
- Shared IP/device detection
- Timing analysis

### Legal Compliance

**Luxembourg/EU Requirements:**
- GDPR compliant (data privacy, right to erasure)
- KYC for transactions > €1,000/month
- AML monitoring
- Not classified as gambling (commitment device)
- PSP license OR use Stripe Connect

**Policies:**
- Clear Terms of Service
- Transparent commission disclosure
- Refund policy (2-hour cancellation window)
- Dispute resolution process
- Fair play rules with consequences

## 🚀 Development Roadmap

### Phase 1: MVP (Months 1-3)
- ✅ Project structure
- ✅ Backend API with core models
- [ ] Authentication (email + Google)
- [ ] Solo stakes (GPS proof)
- [ ] Stripe integration (pre-auth + capture)
- [ ] Basic Flutter UI (create stake, dashboard)
- [ ] Automatic settlement cron job
- [ ] Push notifications

### Phase 2: Social Features (Month 4)
- [ ] Duel challenges 1v1
- [ ] Trash talk chat
- [ ] Friend system
- [ ] Leaderboards
- [ ] Badges & achievements

### Phase 3: Advanced (Month 5-6)
- [ ] Team battles
- [ ] Leagues/Ladders
- [ ] App integrations (Strava, Apple Health, etc.)
- [ ] AI photo validation
- [ ] Advanced analytics
- [ ] Spectator mode

### Phase 4: Scale (Month 7+)
- [ ] Premium features
- [ ] B2B corporate wellness
- [ ] International expansion
- [ ] Web PWA version
- [ ] Marketing & growth campaigns

## 📊 Success Metrics

**User Acquisition:**
- DAU/MAU (target: >30%)
- Sign-up conversion rate (target: 40%+)
- Cost Per Acquisition (target: <€15)

**Engagement:**
- Stakes created per user/month (target: 3+)
- Stake completion rate (target: 65%+)
- Challenge participation rate (target: 40%)
- Daily return rate (target: 50%+)

**Monetization:**
- MRR (Monthly Recurring Revenue)
- ARPU (Average Revenue Per User) (target: €8/month)
- Premium conversion rate (target: 12%+)
- LTV (Lifetime Value) (target: €120)

**Retention:**
- D1 retention (target: 60%+)
- D7 retention (target: 40%+)
- D30 retention (target: 25%+)
- Churn rate (target: <5%/month)

**Quality:**
- NPS (Net Promoter Score) (target: 50+)
- App Store rating (target: 4.5★+)
- Fraud rate (target: <1%)

## 🛠️ Local Development

### Prerequisites
- .NET 8 SDK
- Flutter SDK (stable channel)
- PostgreSQL / SQL Server
- Stripe account (test mode)
- Azure account (for local testing with emulators)

### Setup

**Backend:**
```bash
cd src/StakeIt.API
dotnet restore
dotnet ef database update
dotnet run
```

**Mobile:**
```bash
cd src/StakeIt.Mobile
flutter pub get
flutter run
```

### Environment Variables

Create `.env` files:

**Backend (.env):**
```
DATABASE_CONNECTION_STRING=Server=localhost;Database=stakeit;...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
JWT_SECRET=your-secret-key
AZURE_STORAGE_CONNECTION_STRING=...
```

**Mobile (.env):**
```
API_BASE_URL=https://localhost:7001/api
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

## 📄 License

Proprietary - All rights reserved

## 👥 Team

- **Wassim** - Full Stack Developer (.NET + Flutter)

## 📞 Contact

For questions or feedback: [your-email@example.com]

---

**Built with ❤️ to help people achieve their goals**
