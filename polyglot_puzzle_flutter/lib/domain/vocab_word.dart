class VocabWord {
  final int? id;
  final String term;
  final String translation;
  double easiness;
  int repetitions;
  int interval; // in days
  DateTime nextDue;
  int exposureCount;
  int successCount;

  VocabWord({
    this.id,
    required this.term,
    required this.translation,
    this.easiness = 2.5,
    this.repetitions = 0,
    this.interval = 0,
    DateTime? nextDue,
    this.exposureCount = 0,
    this.successCount = 0,
  }) : nextDue = nextDue ?? DateTime.now();

  factory VocabWord.fromMap(Map<String, dynamic> map) => VocabWord(
        id: map['id'] as int?,
        term: map['term'] as String,
        translation: map['translation'] as String,
        easiness: map['easiness'] as double,
        repetitions: map['repetitions'] as int,
        interval: map['interval'] as int,
        nextDue: DateTime.fromMillisecondsSinceEpoch(map['next_due'] as int),
        exposureCount: map['exposure_count'] as int,
        successCount: map['success_count'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'term': term,
        'translation': translation,
        'easiness': easiness,
        'repetitions': repetitions,
        'interval': interval,
        'next_due': nextDue.millisecondsSinceEpoch,
        'exposure_count': exposureCount,
        'success_count': successCount,
      };

  VocabWord copyWith({
    int? id,
    double? easiness,
    int? repetitions,
    int? interval,
    DateTime? nextDue,
    int? exposureCount,
    int? successCount,
  }) {
    return VocabWord(
      id: id ?? this.id,
      term: term,
      translation: translation,
      easiness: easiness ?? this.easiness,
      repetitions: repetitions ?? this.repetitions,
      interval: interval ?? this.interval,
      nextDue: nextDue ?? this.nextDue,
      exposureCount: exposureCount ?? this.exposureCount,
      successCount: successCount ?? this.successCount,
    );
  }
}