import 'vocab_word.dart';

class SM2Scheduler {
  /// Update [word] scheduling based on [quality] (0-5).
  /// Returns updated word.
  static VocabWord review(VocabWord word, int quality) {
    var easiness = word.easiness;
    var repetitions = word.repetitions;
    var interval = word.interval;

    if (quality < 3) {
      repetitions = 0;
      interval = 1;
    } else {
      final double q = quality.toDouble();
      easiness = easiness + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (easiness < 1.3) easiness = 1.3;
      repetitions += 1;
      if (repetitions == 1) {
        interval = 1;
      } else if (repetitions == 2) {
        interval = 6;
      } else {
        interval = (interval * easiness).round();
      }
    }

    final nextDue = DateTime.now().add(Duration(days: interval));

    return word.copyWith(
      easiness: easiness,
      repetitions: repetitions,
      interval: interval,
      nextDue: nextDue,
    );
  }
}