# Polyglot Puzzle 🧩🌍

A revolutionary mobile game that combines the addictive gameplay of Block Blast with language learning through spaced repetition. Built with Flutter for cross-platform performance.

![Flutter](https://img.shields.io/badge/Flutter-3.32.5-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey.svg)

## 🎮 Game Overview / Oyun Özeti

Polyglot Puzzle transforms language learning into an engaging puzzle experience. Players arrange tetromino-style pieces on an 8x8 grid while learning vocabulary through contextual exposure and spaced repetition algorithms.

Polyglot Puzzle, dil öğrenmeyi eğlenceli bir bulmaca deneyimine dönüştürür. Oyuncular 8x8 ızgarada tetromino tarzı parçaları yerleştirirken, bağlamsal maruz kalma ve aralıklı tekrar algoritmaları aracılığıyla kelime öğrenirler.

### Key Features / Temel Özellikler

- **Block Blast Mechanics**: Classic tetromino puzzle gameplay with line clearing
- **Language Learning Integration**: Words assigned to pieces with translations
- **Spaced Repetition (SM2)**: Scientifically proven learning algorithm
- **60fps Performance**: Optimized for smooth gameplay
- **Hybrid Monetization**: Ads + IAP + Subscriptions
- **Offline Support**: Learn without internet connection
- **Progress Sync**: Cloud synchronization with Supabase
- **AI-Powered**: Gemini AI integration for dynamic vocabulary generation
- **Multi-Language**: Turkish ↔ English support with more languages coming

## 🏗️ Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── errors/             # Error handling
│   ├── themes/             # App theming
│   ├── usecases/           # Base use cases
│   ├── utils/              # Utilities
│   └── widgets/            # Shared widgets
│
├── features/               # Feature modules
│   ├── game/              # Game mechanics
│   │   ├── domain/        # Business logic
│   │   ├── data/          # Data layer
│   │   └── presentation/  # UI layer
│   │
│   ├── language_learning/ # Learning system
│   ├── monetization/      # Revenue features
│   └── settings/          # User preferences
│
└── injection/             # Dependency injection
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: ^3.32.5
- Dart SDK: ^3.6.0
- Android Studio / Xcode
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/polyglot_puzzle.git
   cd polyglot_puzzle
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase** (for analytics and crashlytics)
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

4. **Configure Supabase** (for cloud sync)
   - Create a project at [supabase.com](https://supabase.com)
   - Add your credentials to `.env` file:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

5. **Configure AdMob**
   - Add your AdMob app IDs to:
     - `android/app/src/main/AndroidManifest.xml`
     - `ios/Runner/Info.plist`

6. **Run the app**
   ```bash
   flutter run
   ```

## � Supported Languages

### Currently Available
- 🇹🇷 **Turkish (Türkçe)** ↔ 🇬🇧 **English (İngilizce)**

### Coming Soon
- 🇩🇪 German (Almanca)
- 🇫🇷 French (Fransızca)  
- 🇪🇸 Spanish (İspanyolca)
- 🇮🇹 Italian (İtalyanca)
- 🇯🇵 Japanese (Japonca)
- 🇰🇷 Korean (Korece)

### Gemini AI Integration

The game uses Google's Gemini AI to:
- Generate vocabulary lists based on topics and difficulty
- Provide accurate translations with pronunciation guides
- Create contextual example sentences
- Adapt to learner's progress

**Setup Gemini API:**
```bash
# Add to your .env file
GEMINI_API_KEY=your_gemini_api_key_here
```

## �🎯 Core Features Implementation

### Game Mechanics

The game implements all classic Block Blast features:

- **8x8 Grid System**: Optimized grid rendering with gesture detection
- **7 Piece Types**: I, O, T, S, Z, J, L shapes with rotation
- **Line Clearing**: Horizontal and vertical line detection
- **Cascade Effects**: Chain reactions for combo scoring
- **Smooth Animations**: 60fps performance with Flutter Animate

### Language Learning System

Sophisticated learning integration:

- **SM2 Algorithm**: Spaced repetition for optimal retention
- **Word Selection**:
  - 70% review words (based on intervals)
  - 20% new words (frequency-based)
  - 10% challenge words (above level)
- **Progress Tracking**: Success rates and mastery levels
- **Contextual Learning**: Words shown during gameplay

### Monetization

Comprehensive revenue system:

- **Banner Ads**: Non-intrusive placement in menus
- **Interstitial Ads**: Between levels (5-minute cooldown)
- **Rewarded Videos**: For hints and continues
- **In-App Purchases**:
  - Remove Ads: $4.99
  - Premium Languages: $9.99
  - Hint Bundle (10): $1.99
  - Monthly Subscription: $7.99

## 🛠️ Technical Implementation

### State Management

Using **flutter_bloc** for predictable state management:

```dart
// Game events flow
StartGame → PieceDragStarted → PieceDragUpdated → PieceDragEnded → PiecePlaced
```

### Performance Optimization

- **Widget pooling** for pieces
- **Efficient redraw strategies**
- **Memory-conscious data structures**
- **Lazy loading** for vocabulary

### Database Schema

**Local (SQLite)**:
```sql
-- Vocabulary words with learning data
CREATE TABLE vocabulary_words (
  id TEXT PRIMARY KEY,
  word TEXT NOT NULL,
  translation TEXT NOT NULL,
  language TEXT NOT NULL,
  repetitions INTEGER DEFAULT 0,
  ease_factor REAL DEFAULT 2.5,
  next_review_date INTEGER
);
```

**Remote (Supabase)**:
- User profiles
- Learning progress
- Leaderboards
- Purchase history

## 📱 Supported Platforms

- **iOS**: 12.0+
- **Android**: API 21+ (5.0 Lollipop)
- **Performance Target**: 60fps on Snapdragon 665+

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Specific test types:
```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

## 📊 Analytics & Monitoring

- **Firebase Analytics**: User behavior tracking
- **Firebase Crashlytics**: Crash reporting
- **Firebase Performance**: Performance monitoring
- **Custom Events**:
  - Game started/completed
  - Word learned/reviewed
  - Purchase completed
  - Level progression

## 🔧 Configuration

### Environment Variables

Create `.env` file in project root:
```env
# Supabase
SUPABASE_URL=your_url
SUPABASE_ANON_KEY=your_key

# Gemini API (for translations)
GEMINI_API_KEY=your_api_key

# AdMob
ADMOB_APP_ID_ANDROID=ca-app-pub-xxx
ADMOB_APP_ID_IOS=ca-app-pub-xxx
```

### Build Configuration

**Release builds**:
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ipa --release
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` before committing
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Block Blast for gameplay inspiration
- SM2 algorithm by Piotr Wozniak
- All contributors and testers

## 📞 Support

- **Email**: support@polyglotpuzzle.com
- **Discord**: [Join our community](https://discord.gg/polyglotpuzzle)
- **Issues**: [GitHub Issues](https://github.com/yourusername/polyglot_puzzle/issues)

---

Built with ❤️ by the Polyglot Puzzle Team