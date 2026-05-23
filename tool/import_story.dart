// Upserts one story from JSON into Supabase `stories`.
//
// Validation: story_lines_urdu.length == idioms.length + 1
// Idiom refs: exact `urdu_phrase` strings (same as phrase seed JSON).
//
// Env: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY in repo `.env`
//
// Usage:
//   dart run tool/import_story.dart stories/ghussay_kay_muhawray.json
//   dart run tool/import_story.dart --dry-run stories/*.json
//   dart run tool/import_story.dart stories/

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const List<String> _allowedIcons = <String>[
  'fire',
  'flower',
  'masks',
  'book',
  'star',
  'heart',
  'lightning',
  'moon',
  'sun',
  'handshake',
  'question',
];

Future<void> main(List<String> args) async {
  bool dryRun = false;
  final List<String> paths = <String>[];
  for (final String a in args) {
    if (a == '--dry-run') {
      dryRun = true;
    } else {
      paths.add(a);
    }
  }

  if (paths.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/import_story.dart [--dry-run] <story.json> [more.json ...]',
    );
    stderr.writeln('       dart run tool/import_story.dart [--dry-run] stories/');
    exitCode = 64;
    return;
  }

  final Directory repoRoot = _findRepoRoot();
  final Map<String, String> env =
      _loadEnv(File('${repoRoot.path}${Platform.pathSeparator}.env'));

  final String? urlRaw = env['SUPABASE_URL']?.trim();
  final String? key = env['SUPABASE_SERVICE_ROLE_KEY']?.trim();
  if (urlRaw == null || urlRaw.isEmpty) {
    stderr.writeln('Missing SUPABASE_URL in .env');
    exitCode = 1;
    return;
  }
  if (key == null || key.isEmpty) {
    stderr.writeln('Missing SUPABASE_SERVICE_ROLE_KEY in .env');
    exitCode = 1;
    return;
  }

  final String baseUrl =
      urlRaw.endsWith('/') ? urlRaw.substring(0, urlRaw.length - 1) : urlRaw;

  final List<File> files = await _collectJsonFiles(repoRoot, paths);
  if (files.isEmpty) {
    stderr.writeln('No JSON files found.');
    exitCode = 2;
    return;
  }

  if (dryRun) {
    stdout.writeln('DRY RUN — no writes\n');
  }

  int ok = 0;
  for (final File file in files) {
    try {
      stdout.writeln('--- ${file.path}');
      await _importStoryFile(
        file: file,
        baseUrl: baseUrl,
        apiKey: key,
        dryRun: dryRun,
      );
      ok++;
    } catch (e, st) {
      stderr.writeln('FAILED ${file.path}: $e');
      stderr.writeln('$st');
    }
  }

  stdout.writeln('\nImported $ok / ${files.length} stories.');
  if (ok < files.length) {
    exitCode = 1;
  }
}

Future<List<File>> _collectJsonFiles(
  Directory repoRoot,
  List<String> paths,
) async {
  final List<File> out = <File>[];
  for (final String raw in paths) {
    final File direct = File(raw);
    final File fromRepo = File(
      '${repoRoot.path}${Platform.pathSeparator}$raw',
    );
    final File f =
        direct.existsSync()
            ? direct.absolute
            : (fromRepo.existsSync() ? fromRepo.absolute : direct.absolute);

    if (f.existsSync() && f.path.endsWith('.json')) {
      out.add(f);
      continue;
    }

    final Directory dir =
        Directory(raw).existsSync()
            ? Directory(raw).absolute
            : Directory('${repoRoot.path}${Platform.pathSeparator}$raw');
    if (dir.existsSync()) {
      final List<FileSystemEntity> kids =
          dir
              .listSync()
              .where(
                (FileSystemEntity e) =>
                    e is File && e.path.toLowerCase().endsWith('.json'),
              )
              .toList()
            ..sort(
              (FileSystemEntity a, FileSystemEntity b) =>
                  a.path.compareTo(b.path),
            );
      out.addAll(kids.cast<File>());
    }
  }
  return out;
}

Future<void> _importStoryFile({
  required File file,
  required String baseUrl,
  required String apiKey,
  required bool dryRun,
}) async {
  final dynamic root = jsonDecode(file.readAsStringSync(encoding: utf8));
  if (root is! Map<String, dynamic>) {
    throw ArgumentError('Root must be a JSON object');
  }

  final String slug = _needString(root, 'slug');
  final String titleUrdu = _needString(root, 'title_urdu');
  final String icon = _needString(root, 'icon').toLowerCase();
  final int displayOrder = (root['display_order'] as num?)?.toInt() ?? 0;
  final bool isActive = root['is_active'] as bool? ?? true;
  final String? titleEn = _optionalString(root, 'title_en');

  if (!_allowedIcons.contains(icon)) {
    throw ArgumentError(
      'Invalid icon "$icon". Allowed: ${_allowedIcons.join(', ')}',
    );
  }

  final List<dynamic> idiomRaw = root['idioms'] as List<dynamic>? ?? <dynamic>[];
  if (idiomRaw.isEmpty) {
    throw ArgumentError('idioms must be a non-empty array');
  }
  final List<String> idioms =
      idiomRaw.map((dynamic e) => e.toString().trim()).toList();

  final List<dynamic> linesRaw =
      root['story_lines_urdu'] as List<dynamic>? ?? <dynamic>[];
  final List<String> lines =
      linesRaw.map((dynamic e) => e.toString().trim()).toList();

  final int expectedLines = idioms.length + 1;
  if (lines.length != expectedLines) {
    throw ArgumentError(
      'story_lines_urdu must have $expectedLines lines (idioms.length + 1), got ${lines.length}',
    );
  }
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].isEmpty) {
      throw ArgumentError('story_lines_urdu[$i] is empty');
    }
  }

  final List<String> phraseIds = <String>[];
  for (final String urdu in idioms) {
    final String? id = await _resolvePhraseId(
      baseUrl: baseUrl,
      apiKey: apiKey,
      urduPhrase: urdu,
    );
    if (id == null) {
      throw StateError('No active phrase for urdu_phrase: $urdu');
    }
    phraseIds.add(id);
  }

  final String legacyConnector =
      lines.length > 1 ? lines[1] : lines.first;

  final Map<String, dynamic> row = <String, dynamic>{
    'slug': slug,
    'title_urdu': titleUrdu,
    'title_en': titleEn,
    'icon_key': icon,
    'display_order': displayOrder,
    'is_active': isActive,
    'phrase_ids': phraseIds,
    'story_lines_urdu': lines,
    'connector_text': legacyConnector,
  };

  stdout.writeln('  slug: $slug');
  stdout.writeln('  idioms: ${idioms.length} → ${phraseIds.join(', ')}');
  stdout.writeln('  lines: ${lines.length}');
  stdout.writeln('  icon: $icon  order: $displayOrder');

  if (dryRun) {
    stdout.writeln('  (dry run OK)\n');
    return;
  }

  final http.Client cli = http.Client();
  try {
    final http.Response res = await cli.post(
      Uri.parse('$baseUrl/rest/v1/stories?on_conflict=slug'),
      headers: <String, String>{
        ..._hdrJson(apiKey),
        'Prefer': 'resolution=merge-duplicates,return=representation',
      },
      body: jsonEncode(row),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('UPSERT stories (${res.statusCode}): ${res.body}');
    }
    stdout.writeln('  upserted OK\n');
  } finally {
    cli.close();
  }
}

Future<String?> _resolvePhraseId({
  required String baseUrl,
  required String apiKey,
  required String urduPhrase,
}) async {
  final Uri uri = Uri.parse('$baseUrl/rest/v1/phrases').replace(
    queryParameters: <String, String>{
      'select': 'id',
      'urdu_phrase': 'eq.$urduPhrase',
      'is_active': 'eq.true',
      'limit': '1',
    },
  );

  final http.Client cli = http.Client();
  try {
    final http.Response res = await cli.get(uri, headers: _hdrAuth(apiKey));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('SELECT phrases (${res.statusCode}): ${res.body}');
    }
    final List<dynamic> rows = jsonDecode(res.body) as List<dynamic>;
    if (rows.isEmpty) return null;
    final Map<String, dynamic> row = Map<String, dynamic>.from(
      rows.first as Map,
    );
    return row['id'] as String?;
  } finally {
    cli.close();
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

String _needString(Map<String, dynamic> m, String k) {
  final Object? v = m[k];
  if (v == null || v.toString().trim().isEmpty) {
    throw ArgumentError('Missing "$k"');
  }
  return v.toString().trim();
}

String? _optionalString(Map<String, dynamic> m, String k) {
  final Object? v = m[k];
  if (v == null) return null;
  final String t = v.toString().trim();
  return t.isEmpty ? null : t;
}

Directory _findRepoRoot() {
  Directory d = Directory.current;
  while (true) {
    if (File('${d.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
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
