class StoryModel {
  const StoryModel({
    required this.id,
    required this.titleUrdu,
    required this.phraseIds,
    required this.displayOrder,
    this.slug,
    this.titleEn,
    this.iconKey = 'book',
    this.storyLinesUrdu = const <String>[],
    this.connectorText,
    this.isActive = true,
  });

  final String id;
  final String titleUrdu;
  final List<String> phraseIds;
  final int displayOrder;
  final String? slug;
  final String? titleEn;
  final String iconKey;

  /// Narration lines: length must be [phraseIds.length + 1] when fully configured.
  /// [0] intro before first card; [1..N-1] between cards; [N] closing before summary.
  final List<String> storyLinesUrdu;

  /// Legacy single connector; ignored when [storyLinesUrdu] is non-empty.
  final String? connectorText;
  final bool isActive;

  bool get hasStoryLines => storyLinesUrdu.isNotEmpty;

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: _readString(json['id']),
      titleUrdu: _readString(json['title_urdu']),
      phraseIds: _readStringList(json['phrase_ids']),
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      slug: _optionalString(json['slug']),
      titleEn: _optionalString(json['title_en']),
      iconKey: _readString(
        json['icon_key'] ?? json['icon'],
        fallback: 'book',
      ),
      storyLinesUrdu: _readStringList(json['story_lines_urdu']),
      connectorText: _optionalString(json['connector_text']),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title_urdu': titleUrdu,
      'phrase_ids': phraseIds,
      'display_order': displayOrder,
      'slug': slug,
      'title_en': titleEn,
      'icon_key': iconKey,
      'story_lines_urdu': storyLinesUrdu,
      'connector_text': connectorText,
      'is_active': isActive,
    };
  }

  static String _readString(Object? raw, {String fallback = ''}) {
    if (raw == null) return fallback;
    final String value = raw.toString().trim();
    return value.isEmpty ? fallback : value;
  }

  static String? _optionalString(Object? raw) {
    if (raw == null) return null;
    final String value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static List<String> _readStringList(Object? raw) {
    if (raw is! List<dynamic>) return const <String>[];
    return raw
        .where((dynamic e) => e != null)
        .map((dynamic e) => e.toString().trim())
        .where((String s) => s.isNotEmpty)
        .toList();
  }
}
