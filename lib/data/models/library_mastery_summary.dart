/// Aggregated mastery stats for home strip and library header.
class LibraryMasterySummary {
  const LibraryMasterySummary({
    required this.totalPhrases,
    required this.masteredCount,
    required this.learningCount,
    required this.unseenCount,
  });

  final int totalPhrases;
  final int masteredCount;
  final int learningCount;
  final int unseenCount;

  double get masteredFraction =>
      totalPhrases == 0 ? 0 : masteredCount / totalPhrases;
}
