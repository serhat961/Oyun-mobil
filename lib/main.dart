import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polyglot_puzzle/core/themes/app_theme.dart';
import 'package:polyglot_puzzle/features/game/presentation/pages/game_page.dart';
import 'package:polyglot_puzzle/features/language_learning/domain/entities/vocabulary_word.dart';
import 'package:polyglot_puzzle/features/game/presentation/widgets/player_profile_widget.dart';
import 'package:polyglot_puzzle/features/settings/presentation/pages/settings_page.dart';
import 'package:polyglot_puzzle/features/tutorial/presentation/pages/tutorial_page.dart';
import 'package:polyglot_puzzle/features/achievements/presentation/pages/achievements_page.dart';
import 'package:polyglot_puzzle/core/services/audio_service.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize audio service
  await AudioService().initialize();
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const PolyglotPuzzleApp());
}

class PolyglotPuzzleApp extends StatelessWidget {
  const PolyglotPuzzleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyglot Puzzle',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial();
  }

  Future<void> _checkAndShowTutorial() async {
    final shouldShow = await TutorialPage.shouldShowTutorial();
    if (shouldShow && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TutorialPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate sample vocabulary words for demo
    final sampleWords = _generateSampleWords();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title
                Text(
                  'POLYGLOT',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 48,
                        letterSpacing: 2,
                      ),
                ),
                Text(
                  'PUZZLE',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.accentCyan,
                        letterSpacing: 4,
                      ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Learn Languages While Playing',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                
                const SizedBox(height: 80),
                
                // Play button
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePage(
                            vocabularyWords: sampleWords,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'PLAY',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Secondary buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSecondaryButton(
                      context,
                      icon: Icons.person,
                      label: 'Profile',
                      onPressed: () {
                        _showPlayerProfile(context);
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildSecondaryButton(
                      context,
                      icon: Icons.emoji_events,
                      label: 'Achievements',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AchievementsPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildSecondaryButton(
                      context,
                      icon: Icons.settings,
                      label: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Premium button
                TextButton.icon(
                  onPressed: () {
                    // Show premium features
                  },
                  icon: const Icon(
                    Icons.star,
                    color: AppTheme.warningOrange,
                  ),
                  label: Text(
                    'Go Premium',
                    style: TextStyle(
                      color: AppTheme.warningOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            color: AppTheme.accentCyan,
            iconSize: 28,
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showPlayerProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: const PlayerProfileWidget(),
      ),
    );
  }

  List<VocabularyWord> _generateSampleWords() {
    const uuid = Uuid();
    
    return [
      VocabularyWord.newWord(
        id: uuid.v4(),
        word: 'bonjour',
        translation: 'hello',
        language: 'fr',
        targetLanguage: 'en',
        pronunciation: 'bon-ZHOOR',
        example: 'Bonjour, comment allez-vous?',
        exampleTranslation: 'Hello, how are you?',
        difficulty: 1,
        tags: ['greetings', 'basic'],
      ),
      VocabularyWord.newWord(
        id: uuid.v4(),
        word: 'merci',
        translation: 'thank you',
        language: 'fr',
        targetLanguage: 'en',
        pronunciation: 'mer-SEE',
        example: 'Merci beaucoup!',
        exampleTranslation: 'Thank you very much!',
        difficulty: 1,
        tags: ['polite', 'basic'],
      ),
      VocabularyWord.newWord(
        id: uuid.v4(),
        word: 'eau',
        translation: 'water',
        language: 'fr',
        targetLanguage: 'en',
        pronunciation: 'oh',
        example: "Je voudrais de l'eau, s'il vous plaît.",
        exampleTranslation: 'I would like some water, please.',
        difficulty: 1,
        tags: ['food', 'basic'],
      ),
      VocabularyWord.newWord(
        id: uuid.v4(),
        word: 'livre',
        translation: 'book',
        language: 'fr',
        targetLanguage: 'en',
        pronunciation: 'LEE-vruh',
        example: "J'aime lire des livres.",
        exampleTranslation: 'I like to read books.',
        difficulty: 2,
        tags: ['education', 'objects'],
      ),
      VocabularyWord.newWord(
        id: uuid.v4(),
        word: 'ordinateur',
        translation: 'computer',
        language: 'fr',
        targetLanguage: 'en',
        pronunciation: 'or-dee-na-TEUR',
        example: "Je travaille sur mon ordinateur.",
        exampleTranslation: 'I work on my computer.',
        difficulty: 2,
        tags: ['technology', 'objects'],
      ),
    ];
  }
}