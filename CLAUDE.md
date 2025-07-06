# Polyglot Puzzle - AI Development Guidelines

## Project Overview
Polyglot Puzzle is a Block Blast-style mobile puzzle game that teaches languages through gameplay. Players match falling blocks containing words/phrases while learning vocabulary through spaced repetition algorithms.

## Technical Stack
- **Framework**: Flutter (Dart 3.0+)
- **State Management**: Riverpod 2.0+ (Provider pattern)
- **Backend**: Supabase (PostgreSQL + Real-time subscriptions)
- **APIs**: Google Gemini API (language processing)
- **Monetization**: Google AdMob + IAP (in_app_purchase)
- **Analytics**: Firebase Analytics + Firebase Crashlytics
- **TTS**: Google Cloud Text-to-Speech + flutter_tts
- **Storage**: SharedPreferences + Hive (offline data)
- **Networking**: Dio + Retrofit (API calls)

## Core Architecture Patterns
1. **Clean Architecture**: Presentation → Domain → Data layers
2. **Repository Pattern**: Abstract data sources with caching
3. **BLoC Pattern**: Business logic separation (bloc/cubit)
4. **Dependency Injection**: Using get_it + injectable packages
5. **MVVM Pattern**: ViewModels with Riverpod StateNotifiers

## Game-Specific Conventions
- Grid coordinates: (0,0) top-left, (7,7) bottom-right
- Piece rotation: Clockwise, 90-degree increments
- Word difficulty: Zipf scale 0-8 (8 = easiest)
- Animation duration: 300ms standard, 150ms fast mode
- Color scheme: Material Design 3 with custom game palette
- Responsive design: Support for tablets and foldable devices

## Cursor IDE Optimizations
- **Extensions**: Flutter, Dart, Bloc, GitLens
- **Snippets**: Custom Flutter widgets and Riverpod providers
- **Debugging**: Flutter Inspector + Dart DevTools integration
- **Hot Reload**: Optimized for rapid development cycles
- **Code Analysis**: Strict lint rules with custom analysis_options.yaml

## AI Assistant Instructions
When generating code for this project:

### Flutter Best Practices
1. **Null Safety**: Always use null-safety and proper error handling
2. **Widget Composition**: Prefer composition over inheritance
3. **State Management**: Use Riverpod for global state, setState for local state
4. **Performance**: Implement `const` constructors and avoid rebuilds
5. **Responsive Design**: Use MediaQuery and LayoutBuilder appropriately

### Code Quality Standards
```dart
// Good: Semantic naming
bool get isLineComplete => _checkLineCompletion();

// Bad: Unclear naming
bool checkLine() => _check();
```

### Testing Strategy
1. **Unit Tests**: 80%+ coverage for business logic
2. **Widget Tests**: Critical UI components
3. **Integration Tests**: Complete user flows
4. **Golden Tests**: UI consistency across devices

### Performance Optimization
- Target 60fps on mid-range devices (2GB RAM+)
- Implement lazy loading for large lists
- Use `RepaintBoundary` for complex animations
- Optimize image loading with cached_network_image

## Key Components Reference

### Core Game Logic
- `GameGrid`: 8x8 game board management with state persistence
- `TetrominoGenerator`: Piece creation with word assignment
- `SpacedRepetitionEngine`: SM2 algorithm implementation
- `LanguageAPI`: Gemini API wrapper with caching and retry logic
- `ProgressTracker`: User learning analytics with local storage

### UI Components
- `GameScreen`: Main game interface with gesture handling
- `LanguageSelector`: Multi-language support with flag icons
- `ProgressDialog`: Learning statistics with charts
- `SettingsScreen`: Game preferences and accessibility options

### Services & Repositories
- `GameRepository`: Game state persistence and cloud sync
- `UserRepository`: Profile management and progress tracking
- `LanguageRepository`: Vocabulary and translation management
- `AnalyticsService`: Event tracking and user behavior analysis

## Performance Constraints
- **Target devices**: 2GB+ RAM Android/iOS (API 21+, iOS 11+)
- **Max memory usage**: 150MB peak, 80MB average
- **Battery optimization**: Pause animations when inactive
- **Network**: Offline-first with background sync every 5 minutes
- **Storage**: Max 50MB local cache, auto-cleanup after 30 days

## Development Guidelines

### Code Organization
```
lib/
├── core/               # Shared utilities and constants
├── data/              # Data sources and repositories
├── domain/            # Business logic and entities
├── presentation/      # UI layers and state management
├── shared/            # Shared widgets and components
└── main.dart          # Application entry point
```

### Git Workflow
- **Feature branches**: `feature/game-grid-optimization`
- **Commit convention**: `feat: implement word matching algorithm`
- **PR template**: Include screenshots and performance metrics
- **CI/CD**: Automated testing and deployment to staging

### Error Handling
```dart
// Always handle errors gracefully
try {
  final result = await gameRepository.saveProgress();
  return result.fold(
    (failure) => Left(GameFailure(failure.message)),
    (success) => Right(success),
  );
} catch (e) {
  return Left(GameFailure('Unexpected error: $e'));
}
```

## Security & Privacy
- **Data encryption**: Local storage with secure_storage
- **API keys**: Environment variables, never commit secrets
- **User privacy**: GDPR compliance, minimal data collection
- **Network security**: Certificate pinning for API calls

## Monitoring & Analytics
- **Crash reporting**: Firebase Crashlytics with custom logs
- **Performance monitoring**: Firebase Performance
- **User engagement**: Custom events for learning milestones
- **A/B testing**: Firebase Remote Config for feature flags

## Localization
- **Supported languages**: EN, TR, ES, FR, DE, IT, PT, RU
- **String resources**: ARB files with context annotations
- **Cultural adaptation**: Date/number formats, RTL support
- **Dynamic content**: Server-side translations for game content

## Deployment Strategy
- **Development**: Local testing with hot reload
- **Staging**: TestFlight/Play Console Internal Testing
- **Production**: Gradual rollout with feature flags
- **Monitoring**: Real-time crash and performance tracking

---

*Last Updated: $(date)*
*Framework: Flutter 3.16+*
*Minimum SDK: Android 21, iOS 11* 