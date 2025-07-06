import 'package:equatable/equatable.dart';

class VocabularyWord extends Equatable {
  final String id;
  final String word;
  final String translation;
  final String language;
  final String targetLanguage;
  final String? pronunciation;
  final String? example;
  final String? exampleTranslation;
  final int difficulty;
  final List<String> tags;
  final String? imageUrl;
  final String? audioUrl;
  
  // Spaced Repetition fields
  final int repetitions;
  final double easeFactor;
  final int interval;
  final DateTime? nextReviewDate;
  final DateTime lastSeenDate;
  final int correctCount;
  final int incorrectCount;
  final double successRate;

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.translation,
    required this.language,
    required this.targetLanguage,
    this.pronunciation,
    this.example,
    this.exampleTranslation,
    this.difficulty = 1,
    this.tags = const [],
    this.imageUrl,
    this.audioUrl,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.nextReviewDate,
    required this.lastSeenDate,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.successRate = 0.0,
  });

  factory VocabularyWord.newWord({
    required String id,
    required String word,
    required String translation,
    required String language,
    required String targetLanguage,
    String? pronunciation,
    String? example,
    String? exampleTranslation,
    int difficulty = 1,
    List<String> tags = const [],
    String? imageUrl,
    String? audioUrl,
  }) {
    return VocabularyWord(
      id: id,
      word: word,
      translation: translation,
      language: language,
      targetLanguage: targetLanguage,
      pronunciation: pronunciation,
      example: example,
      exampleTranslation: exampleTranslation,
      difficulty: difficulty,
      tags: tags,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      lastSeenDate: DateTime.now(),
      nextReviewDate: DateTime.now(),
    );
  }

  // SM2 Algorithm implementation
  VocabularyWord updateWithResponse(int quality) {
    // quality: 0-5 (0 = complete failure, 5 = perfect response)
    
    int newRepetitions = repetitions;
    double newEaseFactor = easeFactor;
    int newInterval = interval;
    
    if (quality >= 3) {
      // Correct response
      if (repetitions == 0) {
        newInterval = 1;
      } else if (repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (interval * newEaseFactor).round();
      }
      newRepetitions++;
      
      // Update ease factor
      newEaseFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (newEaseFactor < 1.3) newEaseFactor = 1.3;
    } else {
      // Incorrect response
      newRepetitions = 0;
      newInterval = 1;
    }
    
    final newCorrectCount = quality >= 3 ? correctCount + 1 : correctCount;
    final newIncorrectCount = quality < 3 ? incorrectCount + 1 : incorrectCount;
    final totalAttempts = newCorrectCount + newIncorrectCount;
    final newSuccessRate = totalAttempts > 0 ? newCorrectCount / totalAttempts : 0.0;
    
    return copyWith(
      repetitions: newRepetitions,
      easeFactor: newEaseFactor,
      interval: newInterval,
      nextReviewDate: DateTime.now().add(Duration(days: newInterval)),
      lastSeenDate: DateTime.now(),
      correctCount: newCorrectCount,
      incorrectCount: newIncorrectCount,
      successRate: newSuccessRate,
    );
  }

  bool get isDueForReview {
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }

  int get masteryLevel {
    if (successRate >= 0.9 && correctCount >= 5) return 5;
    if (successRate >= 0.8 && correctCount >= 4) return 4;
    if (successRate >= 0.7 && correctCount >= 3) return 3;
    if (successRate >= 0.5 && correctCount >= 2) return 2;
    if (correctCount >= 1) return 1;
    return 0;
  }

  VocabularyWord copyWith({
    String? id,
    String? word,
    String? translation,
    String? language,
    String? targetLanguage,
    String? pronunciation,
    String? example,
    String? exampleTranslation,
    int? difficulty,
    List<String>? tags,
    String? imageUrl,
    String? audioUrl,
    int? repetitions,
    double? easeFactor,
    int? interval,
    DateTime? nextReviewDate,
    DateTime? lastSeenDate,
    int? correctCount,
    int? incorrectCount,
    double? successRate,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      language: language ?? this.language,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      pronunciation: pronunciation ?? this.pronunciation,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastSeenDate: lastSeenDate ?? this.lastSeenDate,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      successRate: successRate ?? this.successRate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        word,
        translation,
        language,
        targetLanguage,
        pronunciation,
        example,
        exampleTranslation,
        difficulty,
        tags,
        imageUrl,
        audioUrl,
        repetitions,
        easeFactor,
        interval,
        nextReviewDate,
        lastSeenDate,
        correctCount,
        incorrectCount,
        successRate,
      ];
}