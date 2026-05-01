// Pushes phrases from JSON into Supabase: phrases, wrong_options, phrase_options
//
// Postgres enums: category ∈ {محاورہ, کہاوت}, difficulty ∈ {آسان, درمیانہ, مشکل}.
// English easy|medium|hard mapped; theme-style category strings → محاورہ unless
// db_category / phrase_type is set to کہاوت (or proverb / idiom aliases).
//
// Reveal BG = app asset only. DB reveal_image_url always ''.
//
// image_url resolution:
//   1. Non-empty `image_url` or `image` → use as-is
//   2. Else `photo_stem` | `image_stem` | `storage_stem` → PUBLIC URL from project origin +
//      `/storage/v1/object/public/<bucket>/<stem>_photo.png` (default bucket phrase-images)
//
// Env: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY. Optional PUBLIC_SUPABASE_ORIGIN (CDN),
// PHRASE_IMAGES_BUCKET=bucket-name
//
// Flags: --origin=https://PROJECT.supabase.co  --bucket=phrase-images  (override .env)
//
// Usage:
//   dart run tool/push_phrases_from_json.dart phrase_seedv1.json

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  String? cliOrigin;
  String? cliBucket;
  final List<String> rest = <String>[];
  for (final String a in args) {
    if (a.startsWith('--origin=')) {
      cliOrigin = a.substring('--origin='.length).trim();
    } else if (a.startsWith('--bucket=')) {
      cliBucket = a.substring('--bucket='.length).trim();
    } else {
      rest.add(a);
    }
  }

  if (rest.length != 1) {
    stderr.writeln(
      'Usage: dart run tool/push_phrases_from_json.dart [--origin=URL] [--bucket=name] <json_file>',
    );
    exitCode = 64;
    return;
  }

  final Directory repoRoot = _findRepoRoot();
  final Map<String, String> env =
      _loadEnv(File('${repoRoot.path}${Platform.pathSeparator}.env'));

  final String? urlRaw = env['SUPABASE_URL']?.trim();
  final String? key =
      env['SUPABASE_SERVICE_ROLE_KEY']?.trim() ??
          env['SUPABASE_ANON_KEY']?.trim();

  if (urlRaw == null || urlRaw.isEmpty) {
    stderr.writeln('Missing SUPABASE_URL in .env');
    exitCode = 1;
    return;
  }
  if (key == null || key.isEmpty) {
    stderr.writeln(
      'Missing SUPABASE_SERVICE_ROLE_KEY (recommended) or SUPABASE_ANON_KEY',
    );
    exitCode = 1;
    return;
  }

  final String baseUrl =
      urlRaw.endsWith('/') ? urlRaw.substring(0, urlRaw.length - 1) : urlRaw;

  final String? originEnv = env['PUBLIC_SUPABASE_ORIGIN']?.trim();
  final String projectOrigin = _stripTrailingSlash(
    (cliOrigin != null && cliOrigin.isNotEmpty)
        ? cliOrigin
        : ((originEnv != null && originEnv.isNotEmpty) ? originEnv : baseUrl),
  );

  final String? bucketEnv = env['PHRASE_IMAGES_BUCKET']?.trim();
  final String phraseBucket =
      (cliBucket != null && cliBucket.isNotEmpty)
          ? cliBucket
          : ((bucketEnv != null && bucketEnv.isNotEmpty) ? bucketEnv : 'phrase-images');

  if (env['SUPABASE_SERVICE_ROLE_KEY'] == null ||
      env['SUPABASE_SERVICE_ROLE_KEY']!.trim().isEmpty) {
    stderr.writeln(
      'Warning: anon key may fail under RLS. Prefer SUPABASE_SERVICE_ROLE_KEY.\n',
    );
  }

  stdout.writeln(
    'Public URLs use origin=$projectOrigin bucket=$phraseBucket',
  );

  final String jsonRel = rest[0];
  final File resolved =
      File(jsonRel).existsSync()
          ? File(jsonRel).absolute
          : File('${repoRoot.path}${Platform.pathSeparator}$jsonRel').absolute;

  if (!resolved.existsSync()) {
    stderr.writeln('File not found: $jsonRel (${resolved.path})');
    exitCode = 2;
    return;
  }

  final dynamic root =
      jsonDecode(resolved.readAsStringSync(encoding: utf8));

  late final List<dynamic> items;
  if (root is Map<String, dynamic>) {
    final dynamic p = root['phrases'];
    if (p is! List<dynamic>) {
      stderr.writeln('Expected key "phrases" with array value.');
      exitCode = 3;
      return;
    }
    items = p;
  } else if (root is List<dynamic>) {
    items = root;
  } else {
    stderr.writeln('JSON must be {"phrases":[...]} or a top-level array.');
    exitCode = 3;
    return;
  }

  int ok = 0;
  for (int i = 0; i < items.length; i++) {
    final dynamic raw = items[i];
    if (raw is! Map<String, dynamic>) {
      stderr.writeln('Skipping item $i — not object');
      continue;
    }
    try {
      stdout.writeln('--- ${_field(raw, const <String>['urdu_phrase'])}');
      await _pushOnePhrase(
        apiKey: key,
        baseUrl: baseUrl,
        projectOrigin: projectOrigin,
        phraseBucket: phraseBucket,
        phrase: raw,
      );
      ok++;
    } catch (e, st) {
      stderr.writeln('FAILED item $i: $e');
      stderr.writeln('$st');
    }
  }

  stdout.writeln('\nImported $ok / ${items.length} phrases.');
  if (ok < items.length) {
    exitCode = 1;
  }
}

Map<String, String> _hdrAuth(String key) => <String, String>{
  HttpHeaders.authorizationHeader: 'Bearer $key',
  'apikey': key,
  'Accept': 'application/json',
};

Map<String, String> _hdrJson(String key) => <String, String>{
  ..._hdrAuth(key),
  HttpHeaders.contentTypeHeader: 'application/json',
};

Map<String, String> _hdrPostReturn(String key) => <String, String>{
  ..._hdrJson(key),
  'Prefer': 'return=representation',
};

String _stripTrailingSlash(String s) =>
    s.endsWith('/') ? s.substring(0, s.length - 1) : s;

/// Public read URL (bucket must be public or URL signed elsewhere).
String _publicStorageObjectUrl({
  required String projectOrigin,
  required String bucket,
  required String objectPath,
}) {
  final String enc = Uri.encodeComponent(objectPath);
  return '$projectOrigin/storage/v1/object/public/$bucket/$enc';
}

/// DB check: phrases only allow these (see Postgres `phrases_category_check`).
const String _dbCategoryMahawarah = 'محاورہ';
const String _dbCategoryKahawat = 'کہاوت';

/// DB check: phrases_difficulty_check.
const String _dbDifficultyEasy = 'آسان';
const String _dbDifficultyMedium = 'درمیانہ';
const String _dbDifficultyHard = 'مشکل';

/// Prefer `db_category` in JSON (`محاورہ` | `کہاوت`) when `category` is a free-form label.
String _normalizeCategoryForDb({
  required String rawCategory,
  required Map<String, dynamic> phrase,
}) {
  final String? override = _field(
    phrase,
    const <String>['db_category', 'phrase_type', 'type'],
  );
  final String source = override ?? rawCategory;
  final String t = source.trim();

  if (t == _dbCategoryMahawarah || t == _dbCategoryKahawat) {
    return t;
  }
  final String low = t.toLowerCase();
  if (low == 'proverb' ||
      low == 'saying' ||
      low == 'kahawat') {
    return _dbCategoryKahawat;
  }
  if (low == 'idiom') {
    return _dbCategoryMahawarah;
  }
  stderr.writeln(
    '  category "$rawCategory" → $_dbCategoryMahawarah (DB allows $_dbCategoryMahawarah | $_dbCategoryKahawat; use db_category to force)',
  );
  return _dbCategoryMahawarah;
}

String _normalizeDifficultyForDb(String raw) {
  final String t = raw.trim();
  if (t == _dbDifficultyEasy ||
      t == _dbDifficultyMedium ||
      t == _dbDifficultyHard) {
    return t;
  }
  switch (t.toLowerCase()) {
    case 'easy':
    case 'facile':
      return _dbDifficultyEasy;
    case 'medium':
    case 'intermediate':
    case 'mid':
      return _dbDifficultyMedium;
    case 'hard':
    case 'difficult':
      return _dbDifficultyHard;
    default:
      stderr.writeln(
        '  difficulty "$raw" → $_dbDifficultyMedium (allowed: $_dbDifficultyEasy|$_dbDifficultyMedium|$_dbDifficultyHard / easy|medium|hard)',
      );
      return _dbDifficultyMedium;
  }
}

String _resolvePhotoImageUrl({
  required Map<String, dynamic> phrase,
  required String projectOrigin,
  required String phraseBucket,
}) {
  final String? explicit =
      _field(phrase, const <String>['image_url', 'image']);
  if (explicit != null && explicit.isNotEmpty) {
    return explicit.trim();
  }
  final String? stem = _field(
    phrase,
    const <String>['photo_stem', 'image_stem', 'storage_stem'],
  );
  if (stem == null || stem.isEmpty) {
    return '';
  }
  final String objectPath = '${stem}_photo.png';
  return _publicStorageObjectUrl(
    projectOrigin: projectOrigin,
    bucket: phraseBucket,
    objectPath: objectPath,
  );
}

Future<void> _pushOnePhrase({
  required String apiKey,
  required String baseUrl,
  required String projectOrigin,
  required String phraseBucket,
  required Map<String, dynamic> phrase,
}) async {
  final String urdu = _needString(phrase, 'urdu_phrase');
  final String romanised = _needString(phrase, 'romanised');
  final String rawCategoryLabel = _needString(phrase, 'category');
  final String category = _normalizeCategoryForDb(
    rawCategory: rawCategoryLabel,
    phrase: phrase,
  );
  final String rawDifficulty = _needString(phrase, 'difficulty');
  final String difficulty = _normalizeDifficultyForDb(rawDifficulty);
  final String example = _needString(phrase, 'example_sentence');
  final String meaningUrdu =
      _field(phrase, const <String>['correct_meaning', 'meaning_urdu']) ?? '';
  if (meaningUrdu.isEmpty) {
    throw ArgumentError('Missing correct_meaning (or meaning_urdu).');
  }

  final String? explicitImage =
      _field(phrase, const <String>['image_url', 'image']);
  final String imageUrl = _resolvePhotoImageUrl(
    phrase: phrase,
    projectOrigin: projectOrigin,
    phraseBucket: phraseBucket,
  );
  if (imageUrl.isEmpty) {
    stderr.writeln(
      '  WARN no image: set image_url or photo_stem → public/$phraseBucket/<stem>_photo.png',
    );
  } else if ((explicitImage ?? '').trim().isEmpty) {
    stdout.writeln('  image_url (from stem): $imageUrl');
  }

  final Map<String, dynamic>? phraseOpts =
      phrase['phrase_options'] is Map
          ? Map<String, dynamic>.from(phrase['phrase_options'] as Map)
          : null;
  if (phraseOpts == null) {
    throw ArgumentError('Missing phrase_options object.');
  }
  final String correctPhrase =
      _needString(Map<String, dynamic>.from(phraseOpts), 'correct');
  final dynamic wrongDyn = phraseOpts['wrong'];
  if (wrongDyn is! List<dynamic>) {
    throw ArgumentError('phrase_options.wrong must be array.');
  }
  final List<String> phraseWrongRaw =
      wrongDyn.map((dynamic e) => e.toString().trim()).where(
        (String s) => s.isNotEmpty,
      ).toList();
  if (phraseWrongRaw.length < 3) {
    throw ArgumentError('phrase_options.wrong must have at least 3 items.');
  }
  final List<String> phraseWrong = phraseWrongRaw.take(3).toList();

  final dynamic wMean = phrase['wrong_options'];
  if (wMean is! List<dynamic>) {
    throw ArgumentError('wrong_options must be array (meaning quiz wrong).');
  }
  final List<String> meaningWrongRaw =
      wMean.map((dynamic e) => e.toString().trim()).where(
        (String s) => s.isNotEmpty,
      ).toList();
  if (meaningWrongRaw.length < 3) {
    throw ArgumentError('wrong_options must have at least 3 strings.');
  }
  final List<String> meaningWrong = meaningWrongRaw.take(3).toList();

  final http.Client cli = http.Client();
  try {
    final Uri find = Uri.parse('$baseUrl/rest/v1/phrases').replace(
      queryParameters: <String, String>{
        'select': 'id',
        'limit': '1',
        'urdu_phrase': 'eq.$urdu',
      },
    );

    final http.Response found = await cli.get(find, headers: _hdrAuth(apiKey));
    if (found.statusCode != 200) {
      throw StateError(
        'GET phrases failed (${found.statusCode}): ${found.body}',
      );
    }

    String phraseId;

    final List<dynamic>? rows = jsonDecode(found.body) as List<dynamic>?;

    if (rows != null &&
        rows.isNotEmpty &&
        rows.first is Map<String, dynamic> &&
        (rows.first as Map<String, dynamic>)['id'] is String) {
      phraseId = (rows.first as Map<String, dynamic>)['id'] as String;

      final Uri patchUri = Uri.parse('$baseUrl/rest/v1/phrases?id=eq.$phraseId');
      final String bodyPatch = jsonEncode(<String, dynamic>{
        'urdu_phrase': urdu,
        'romanised': romanised,
        'meaning_urdu': meaningUrdu,
        'example_sentence': example,
        'category': category,
        'difficulty': difficulty,
        'image_url': imageUrl,
        'reveal_image_url': '',
        'is_active': true,
      });
      final http.Response patched = await cli.patch(
        patchUri,
        headers: _hdrJson(apiKey),
        body: bodyPatch,
      );
      if (patched.statusCode < 200 || patched.statusCode >= 300) {
        throw StateError(
          'PATCH phrase failed (${patched.statusCode}): ${patched.body}',
        );
      }
    } else {
      final Uri ins = Uri.parse('$baseUrl/rest/v1/phrases');
      final Map<String, dynamic> payload = <String, dynamic>{
        'urdu_phrase': urdu,
        'romanised': romanised,
        'meaning_urdu': meaningUrdu,
        'example_sentence': example,
        'category': category,
        'difficulty': difficulty,
        'image_url': imageUrl,
        'reveal_image_url': '',
        'is_active': true,
      };
      final http.Response inserted = await cli.post(
        ins,
        headers: _hdrPostReturn(apiKey),
        body: jsonEncode(payload),
      );
      if (inserted.statusCode < 200 ||
          inserted.statusCode >= 300 ||
          inserted.body.trim().isEmpty) {
        throw StateError(
          'POST phrase failed (${inserted.statusCode}): ${inserted.body}',
        );
      }
      final dynamic dec = jsonDecode(inserted.body);
      if (dec is List<dynamic> && dec.isNotEmpty) {
        final Map<String, dynamic> firstRow =
            Map<String, dynamic>.from(dec.first as Map);
        phraseId = firstRow['id'] as String? ?? '';
      } else if (dec is Map<String, dynamic>) {
        phraseId = dec['id'] as String? ?? '';
      } else {
        throw StateError('Unexpected POST response shape: ${inserted.body}');
      }
      if (phraseId.isEmpty) {
        throw StateError('No phrase id returned from insert.');
      }
    }

    final Uri delWrong =
        Uri.parse('$baseUrl/rest/v1/wrong_options?phrase_id=eq.$phraseId');
    final Uri delPhraseOpt =
        Uri.parse('$baseUrl/rest/v1/phrase_options?phrase_id=eq.$phraseId');

    final http.Response r1 = await cli.delete(delWrong, headers: _hdrAuth(apiKey));
    if (r1.statusCode >= 400) {
      stderr.writeln('DELETE wrong_options: ${r1.statusCode} ${r1.body}');
    }

    final http.Response r2 =
        await cli.delete(delPhraseOpt, headers: _hdrAuth(apiKey));
    if (r2.statusCode >= 400) {
      stderr.writeln('DELETE phrase_options: ${r2.statusCode} ${r2.body}');
    }

    final List<Map<String, dynamic>> wrongRows =
        meaningWrong.map((String t) =>
            <String, dynamic>{'phrase_id': phraseId, 'option_text': t}).toList();

    final http.Response wi = await cli.post(
      Uri.parse('$baseUrl/rest/v1/wrong_options'),
      headers: _hdrJson(apiKey),
      body: jsonEncode(wrongRows),
    );
    if (wi.statusCode < 200 || wi.statusCode >= 300) {
      throw StateError(
        'INSERT wrong_options (${wi.statusCode}): ${wi.body}',
      );
    }

    final List<Map<String, dynamic>> optRows =
        <Map<String, dynamic>>[
              <String, dynamic>{
                'phrase_id': phraseId,
                'option_text': correctPhrase,
                'is_correct': true,
              },
            ] +
            phraseWrong
                .map(
                  (String t) =>
                      <String, dynamic>{
                        'phrase_id': phraseId,
                        'option_text': t,
                        'is_correct': false,
                      },
                )
                .toList();

    final http.Response poi = await cli.post(
      Uri.parse('$baseUrl/rest/v1/phrase_options'),
      headers: _hdrJson(apiKey),
      body: jsonEncode(optRows),
    );
    if (poi.statusCode < 200 || poi.statusCode >= 300) {
      throw StateError(
        'INSERT phrase_options (${poi.statusCode}): ${poi.body}',
      );
    }

    stdout.writeln(' OK id=$phraseId');
  } finally {
    cli.close();
  }
}

String _needString(Map<String, dynamic> m, String k) {
  final Object? v = m[k];
  if (v == null || v.toString().trim().isEmpty) {
    throw ArgumentError('Missing "$k"');
  }
  return v.toString().trim();
}

String? _field(Map<String, dynamic> phrase, List<String> keys) {
  for (final String k in keys) {
    if (phrase[k] != null && phrase[k].toString().trim().isNotEmpty) {
      return phrase[k].toString().trim();
    }
  }
  return null;
}

Directory _findRepoRoot() {
  Directory d = Directory.current;
  while (true) {
    if (File(
      '${d.path}${Platform.pathSeparator}pubspec.yaml',
    ).existsSync()) {
      return d;
    }
    final Directory parent = d.parent;
    if (parent.path == d.path) break;
    d = parent;
  }
  return Directory.current;
}

Map<String, String> _loadEnv(File envFile) {
  if (!envFile.existsSync()) {
    stderr.writeln('Missing .env (${envFile.absolute.path})');
    exit(1);
  }
  final Map<String, String> map = <String, String>{};
  for (final String line in envFile.readAsLinesSync(encoding: utf8)) {
    final String t = line.trim();
    if (t.isEmpty || t.startsWith('#')) continue;
    final int eq = t.indexOf('=');
    if (eq <= 0) continue;
    final String k = t.substring(0, eq).trim();
    String value = t.substring(eq + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1);
    }
    map[k] = value;
  }
  return map;
}
