// Upload all images from ./newphotos/ to Supabase Storage bucket `phrase-images`.
//
// Object key: `{original_basename_without_ext}_photo.png`
// Example: `mycat.jpg` → `mycat_photo.png`
//
// After each OK upload prints the PUBLIC URL — paste that into phrase JSON field `image_url`
// (`https://YOUR_PROJECT.supabase.co/storage/v1/object/public/phrase-images/STEM_photo.png`).
// Bucket must allow public reads for URLs to load in-app without signing.
//
// Setup: add to `.env` at repo root:
//   SUPABASE_URL=https://YOUR_PROJECT.supabase.co
//   SUPABASE_SERVICE_ROLE_KEY=your_service_role_secret
//
// (Service role avoids storage RLS issues for uploads. Keep this key secret.)
//
// Usage (from repo root):
//   dart run tool/upload_phrase_photos.dart

import 'dart:io';

import 'package:http/http.dart' as http;

const String _bucket = 'phrase-images';
const String _localFolder = 'newphotos';

String _publicImageUrl({required String baseUrl, required String objectPath}) {
  final String pathEnc = Uri.encodeComponent(objectPath);
  return '${baseUrl.replaceAll(RegExp(r'/$'), '')}/storage/v1/object/public/'
      '$_bucket/$pathEnc';
}

final Set<String> _imageSuffixes = <String>{
  '.png',
  '.jpg',
  '.jpeg',
  '.webp',
  '.gif',
};

Future<void> main() async {
  final Directory repoRoot = _findRepoRoot();
  Directory.current = repoRoot.path;

  final Map<String, String> env = _loadEnv(File('${repoRoot.path}${Platform.pathSeparator}.env'));

  final String? urlRaw = env['SUPABASE_URL']?.trim();
  final String? key = env['SUPABASE_SERVICE_ROLE_KEY']?.trim() ?? env['SUPABASE_ANON_KEY']?.trim();

  if (urlRaw == null || urlRaw.isEmpty) {
    stderr.writeln('Missing SUPABASE_URL in .env');
    exitCode = 1;
    return;
  }
  if (key == null || key.isEmpty) {
    stderr.writeln(
      'Missing SUPABASE_SERVICE_ROLE_KEY (recommended) or SUPABASE_ANON_KEY in .env',
    );
    exitCode = 1;
    return;
  }

  if (env['SUPABASE_SERVICE_ROLE_KEY'] == null || env['SUPABASE_SERVICE_ROLE_KEY']!.trim().isEmpty) {
    stderr.writeln(
      'Warning: using anon key — upload may fail if storage policies block it.',
    );
    stderr.writeln('Add SUPABASE_SERVICE_ROLE_KEY for reliable uploads.\n');
  }

  final String baseUrl = urlRaw.endsWith('/') ? urlRaw.substring(0, urlRaw.length - 1) : urlRaw;

  final Directory dir = Directory('${repoRoot.path}${Platform.pathSeparator}$_localFolder');
  if (!dir.existsSync()) {
    stderr.writeln('Create folder $_localFolder/ and add images.');
    exitCode = 1;
    return;
  }

  final List<File> files =
      dir
          .listSync(followLinks: false)
          .whereType<File>()
          .where((File f) {
            final String lower = f.path.toLowerCase();
            for (final String ext in _imageSuffixes) {
              if (lower.endsWith(ext)) return true;
            }
            return false;
          })
          .toList();

  files.sort((File a, File b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    stderr.writeln('No image files found in $_localFolder/');
    exitCode = 1;
    return;
  }

  int ok = 0;
  final List<String> successObjectPaths = <String>[];
  for (final File file in files) {
    final String name = _basename(file.path);
    final String stem = _stem(name);
    final String objectPath = '${stem}_photo.png';
    final String contentType = _contentTypeFor(file.path);

    final List<int> bytes = await file.readAsBytes();

    final Uri uri = Uri.parse(
      '$baseUrl/storage/v1/object/$_bucket/${Uri.encodeComponent(objectPath)}',
    );

    stdout.writeln('Upload: $name → $_bucket/$objectPath ($contentType)');

    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $key',
        'apikey': key,
        HttpHeaders.contentTypeHeader: contentType,
        'x-upsert': 'true',
      },
      body: bytes,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ok++;
      successObjectPaths.add(objectPath);
      stdout.writeln('  OK (${response.statusCode})');
      stdout.writeln(
        '  public URL: ${_publicImageUrl(baseUrl: baseUrl, objectPath: objectPath)}',
      );
    } else {
      stderr.writeln('  FAILED (${response.statusCode}): ${response.body}');
    }
  }

  stdout.writeln('');
  stdout.writeln('Done: $ok/${files.length} uploaded.');
  if (successObjectPaths.isNotEmpty) {
    stdout.writeln('');
    stdout.writeln('Public URLs summary (paste into phrase JSON image_url):');
    for (final String objectPath in successObjectPaths) {
      stdout.writeln(
        _publicImageUrl(baseUrl: baseUrl, objectPath: objectPath),
      );
    }
  }
  if (ok < files.length) {
    exitCode = 1;
  }
}

String _basename(String filepath) {
  final String normalized = filepath.replaceAll(r'\', '/');
  final int i = normalized.lastIndexOf('/');
  return i < 0 ? normalized : normalized.substring(i + 1);
}

String _stem(String basename) {
  final int dot = basename.lastIndexOf('.');
  if (dot <= 0) return basename;
  return basename.substring(0, dot);
}

String _contentTypeFor(String filepath) {
  final String lower = filepath.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'application/octet-stream';
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
  final List<String> lines = envFile.readAsLinesSync();
  for (final String line in lines) {
    final String t = line.trim();
    if (t.isEmpty || t.startsWith('#')) continue;
    final int eq = t.indexOf('=');
    if (eq <= 0) continue;
    final String key = t.substring(0, eq).trim();
    String value = t.substring(eq + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1);
    }
    map[key] = value;
  }
  return map;
}
