import '../../core/constants/mastery_constants.dart';
import '../../data/models/phrase_model.dart';

class LibraryLoadResult {
  const LibraryLoadResult({
    required this.phrases,
    required this.masteryByPhraseId,
  });

  final List<PhraseModel> phrases;
  final Map<String, int> masteryByPhraseId;

  int masteryFor(String phraseId) => masteryByPhraseId[phraseId] ?? 0;

  int get masteredCount =>
      masteryByPhraseId.values.where((int l) => MasteryConstants.isMastered(l)).length;

  /// Phrases the player has fully mastered — only these appear in the library.
  List<PhraseModel> get masteredPhrases => phrases
      .where((PhraseModel p) => MasteryConstants.isMastered(masteryFor(p.id)))
      .toList();
}
