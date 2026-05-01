import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class PhraseGuessJudge {
  Future<PhraseGuessDecision> evaluateGuess({
    required String spokenText,
    required String correctPhrase,
  }) async {
    final String normalizedSpoken = _normalize(spokenText);
    final String normalizedCorrect = _normalize(correctPhrase);
    if (normalizedSpoken.isEmpty) {
      const PhraseGuessDecision decision =
          PhraseGuessDecision(isCorrect: false, source: 'local-empty');
      debugPrint('phrase-judge: ${decision.source}');
      return decision;
    }
    if (normalizedSpoken == normalizedCorrect) {
      const PhraseGuessDecision decision =
          PhraseGuessDecision(isCorrect: true, source: 'local-exact');
      debugPrint('phrase-judge: ${decision.source}');
      return decision;
    }

    final double localSimilarity = _similarity(normalizedSpoken, normalizedCorrect);
    if (localSimilarity >= 0.95) {
      final PhraseGuessDecision decision = PhraseGuessDecision(
        isCorrect: true,
        source: 'local-95',
        similarity: localSimilarity,
      );
      debugPrint('phrase-judge: ${decision.source} sim=${decision.similarity}');
      return decision;
    }

    final String? apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      final PhraseGuessDecision decision = PhraseGuessDecision(
        isCorrect: localSimilarity >= 0.88,
        source: 'local-fallback',
        similarity: localSimilarity,
      );
      debugPrint('phrase-judge: ${decision.source} sim=${decision.similarity}');
      return decision;
    }

    try {
      final http.Response response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: <String, String>{
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'model': 'gpt-4o-mini',
          'temperature': 0,
          'response_format': <String, String>{'type': 'json_object'},
          'messages': <Map<String, String>>[
            <String, String>{
              'role': 'system',
              'content':
                  'You are a strict Urdu phrase matcher. Return JSON with key "is_correct" boolean only. Mark true only when spoken text is the same phrase with tiny pronunciation/transcription noise.',
            },
            <String, String>{
              'role': 'user',
              'content':
                  'Correct phrase: "$correctPhrase"\nSpoken transcript: "$spokenText"\nThreshold: 95% similarity.',
            },
          ],
          'max_tokens': 20,
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final PhraseGuessDecision decision = PhraseGuessDecision(
          isCorrect: localSimilarity >= 0.88,
          source: 'local-after-gpt-http-${response.statusCode}',
          similarity: localSimilarity,
        );
        debugPrint('phrase-judge: ${decision.source} sim=${decision.similarity}');
        return decision;
      }
      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> choices = decoded['choices'] as List<dynamic>? ?? <dynamic>[];
      if (choices.isEmpty) {
        final PhraseGuessDecision decision = PhraseGuessDecision(
          isCorrect: localSimilarity >= 0.88,
          source: 'local-after-gpt-empty',
          similarity: localSimilarity,
        );
        debugPrint('phrase-judge: ${decision.source} sim=${decision.similarity}');
        return decision;
      }
      final String content =
          (choices.first as Map<String, dynamic>)['message']['content'] as String;
      final Map<String, dynamic> result = jsonDecode(content) as Map<String, dynamic>;
      final PhraseGuessDecision decision = PhraseGuessDecision(
        isCorrect: result['is_correct'] == true,
        source: 'gpt',
        similarity: localSimilarity,
      );
      debugPrint('phrase-judge: ${decision.source} sim=${decision.similarity}');
      return decision;
    } catch (_) {
      final PhraseGuessDecision decision = PhraseGuessDecision(
        isCorrect: localSimilarity >= 0.88,
        source: 'local-after-gpt-error',
        similarity: localSimilarity,
      );
      debugPrint('phrase-judge: ${decision.source} sim=${decision.similarity}');
      return decision;
    }
  }

  String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  double _similarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1;
    final int distance = _levenshtein(a, b);
    final int maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen == 0) return 1;
    return 1 - (distance / maxLen);
  }

  int _levenshtein(String s, String t) {
    final List<List<int>> dp = List<List<int>>.generate(
      s.length + 1,
      (_) => List<int>.filled(t.length + 1, 0),
    );
    for (int i = 0; i <= s.length; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= t.length; j++) {
      dp[0][j] = j;
    }
    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        final int cost = s[i - 1] == t[j - 1] ? 0 : 1;
        dp[i][j] = <int>[
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((int x, int y) => x < y ? x : y);
      }
    }
    return dp[s.length][t.length];
  }
}

class PhraseGuessDecision {
  const PhraseGuessDecision({
    required this.isCorrect,
    required this.source,
    this.similarity,
  });

  final bool isCorrect;
  final String source;
  final double? similarity;
}

final Provider<PhraseGuessJudge> phraseGuessJudgeProvider =
    Provider<PhraseGuessJudge>((Ref ref) => PhraseGuessJudge());
